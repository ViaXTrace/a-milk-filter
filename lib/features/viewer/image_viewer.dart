import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Full-screen interactive viewer for the filtered image.
/// Supports pinch-to-zoom, double-tap to reset, save, and share.
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    super.key,
    required this.filteredBytes,
    this.paletteName,
  });

  final Uint8List filteredBytes;
  final String? paletteName;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  late final AnimationController _resetCtrl;
  Animation<Matrix4>? _resetAnimation;

  bool _isSaving = false;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final current = _transformCtrl.value;
    final isZoomed = current != Matrix4.identity();

    if (isZoomed) {
      _resetAnimation = Matrix4Tween(
        begin: current,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOutCubic));

      _resetAnimation!.addListener(() {
        _transformCtrl.value = _resetAnimation!.value;
      });
      _resetCtrl.forward(from: 0);
    }
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted && mounted) {
          _showSnack('Gallery access denied.');
          return;
        }
      }
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/milk_filter_$ts.png');
      await file.writeAsBytes(widget.filteredBytes);
      await Gal.putImage(file.path, album: 'A Milk Filter');
      await file.delete();
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSnack('Saved to gallery.', success: true);
      }
    } catch (e) {
      if (mounted) _showSnack('Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareImage() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/milk_filter_share.png');
      await file.writeAsBytes(widget.filteredBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Filtered with A Milk Filter — outside the bag of milk',
      );
    } catch (e) {
      if (mounted) _showSnack('Share failed: $e');
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              size: 13,
              color: success ? AppColors.mauve : AppColors.blood,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 11,
                  color: AppColors.chalk,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Interactive viewer ──────────────────────────────────────────
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformCtrl,
              minScale: 0.5,
              maxScale: 8.0,
              panEnabled: true,
              scaleEnabled: true,
              child: SizedBox.expand(
                child: Center(
                  child: Image.memory(
                    widget.filteredBytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _controlsVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.only(
                    top: safePadding.top + 8,
                    left: 12,
                    right: 16,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.void_.withValues(alpha: 0.92),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Close button
                      _ViewerIconButton(
                        icon: Icons.close_rounded,
                        label: 'Close',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      // Title
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FULL RESOLUTION',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.chalk,
                                letterSpacing: 1.2,
                                fontSize: 10,
                              ),
                            ),
                            if (widget.paletteName != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                widget.paletteName!.toLowerCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.mauve.withValues(alpha: 0.85),
                                  letterSpacing: 0.6,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Hint
                      Text(
                        'double-tap to reset',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.ash,
                          fontSize: 8,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _controlsVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: safePadding.bottom + 20,
                    top: 20,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.void_.withValues(alpha: 0.90),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Save button
                      Expanded(
                        child: _SaveButton(
                          isSaving: _isSaving,
                          onTap: _saveToGallery,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share button
                      _ViewerIconButton(
                        icon: Icons.ios_share_rounded,
                        label: 'SHARE',
                        accentColor: AppColors.mauve,
                        onTap: _shareImage,
                        large: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────

class _ViewerIconButton extends StatefulWidget {
  const _ViewerIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool large;

  @override
  State<_ViewerIconButton> createState() => _ViewerIconButtonState();
}

class _ViewerIconButtonState extends State<_ViewerIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.chalk;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        width: widget.large ? 64 : 44,
        height: widget.large ? 52 : 44,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.vessel : AppColors.abyss.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.accentColor != null
                ? accent.withValues(alpha: 0.40)
                : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 16, color: accent),
            if (widget.large) ...[
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontSize: 7,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.isSaving, required this.onTap});
  final bool isSaving;
  final VoidCallback onTap;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSaving ? null : widget.onTap,
      onTapDown: widget.isSaving ? null : (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        height: 52,
        decoration: BoxDecoration(
          color: _pressed || widget.isSaving ? AppColors.maroon : AppColors.crimson,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _pressed || widget.isSaving
              ? null
              : [
                  BoxShadow(
                    color: AppColors.crimson.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: widget.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.chalk,
                    strokeWidth: 1.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.save_alt_rounded,
                      size: 14,
                      color: AppColors.chalk,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SAVE TO GALLERY',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.chalk,
                        letterSpacing: 1.4,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
