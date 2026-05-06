import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:a_milk_filter/core/filter/filter_options.dart';
import 'package:a_milk_filter/core/filter/milk_filter.dart';
import 'package:a_milk_filter/core/filter/milk_palette.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';
import 'package:a_milk_filter/features/editor/widgets/before_after_view.dart';
import 'package:a_milk_filter/features/editor/widgets/filter_controls.dart';
import 'package:a_milk_filter/shared/widgets/milk_app_bar.dart';
import 'package:a_milk_filter/shared/widgets/scanline_overlay.dart';

enum _ProcessState { idle, processing, done, error }

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.imageFile});
  final File imageFile;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  FilterOptions _options = const FilterOptions(palette: MilkPaletteOne());
  _ProcessState _state = _ProcessState.idle;
  Uint8List? _filteredBytes;
  String? _errorMessage;

  late final AnimationController _panelCtrl;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _panelFade;

  @override
  void initState() {
    super.initState();
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..forward();
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));
    _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyFilter() async {
    if (_state == _ProcessState.processing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _state = _ProcessState.processing;
      _filteredBytes = null;
      _errorMessage = null;
    });
    try {
      final sourceBytes = await widget.imageFile.readAsBytes();
      final payload = FilterPayload(sourceBytes: sourceBytes, options: _options);
      final result = await compute(applyFilter, payload);
      if (mounted) {
        setState(() {
          _filteredBytes = result;
          _state = _ProcessState.done;
        });
        HapticFeedback.mediumImpact();
      }
    } on FilterException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _state = _ProcessState.error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _state = _ProcessState.error;
        });
      }
    }
  }

  Future<void> _saveToGallery() async {
    final bytes = _filteredBytes;
    if (bytes == null) return;
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
      await file.writeAsBytes(bytes);
      await Gal.putImage(file.path, album: 'A Milk Filter');
      await file.delete();
      if (mounted) _showSnack('Saved to gallery.', success: true);
    } catch (e) {
      if (mounted) _showSnack('Save failed: $e');
    }
  }

  Future<void> _shareImage() async {
    final bytes = _filteredBytes;
    if (bytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/milk_filter_share.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Filtered with A Milk Filter — Outside the Bag',
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
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: MilkAppBar(
        title: 'EDITOR',
        subtitle: _options.palette.name.toLowerCase(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: ScanlineOverlay(opacity: 0.025)),
          Column(
            children: [
              // ── Image viewport ───────────────────────────────────────
              Expanded(
                child: BeforeAfterView(
                  originalFile: widget.imageFile,
                  filteredBytes: _filteredBytes,
                  isProcessing: _state == _ProcessState.processing,
                ),
              ),

              // ── Control panel ────────────────────────────────────────
              SlideTransition(
                position: _panelSlide,
                child: FadeTransition(
                  opacity: _panelFade,
                  child: _ControlPanel(
                    options: _options,
                    state: _state,
                    errorMessage: _errorMessage,
                    onOptionsChanged: (o) {
                      setState(() => _options = o);
                    },
                    onApply: _applyFilter,
                    onSave: _saveToGallery,
                    onShare: _shareImage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Control panel ─────────────────────────────────────────────────────────────

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.options,
    required this.state,
    required this.errorMessage,
    required this.onOptionsChanged,
    required this.onApply,
    required this.onSave,
    required this.onShare,
  });

  final FilterOptions options;
  final _ProcessState state;
  final String? errorMessage;
  final ValueChanged<FilterOptions> onOptionsChanged;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.abyss,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error banner
          if (state == _ProcessState.error && errorMessage != null)
            _ErrorBanner(message: errorMessage!),

          // Filter controls
          FilterControls(
            options: options,
            onChanged: onOptionsChanged,
            enabled: state != _ProcessState.processing,
          ),

          // Action bar
          _ActionBar(
            state: state,
            onApply: onApply,
            onSave: onSave,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.blood.withValues(alpha: 0.09),
      border: Border(
        bottom: BorderSide(color: AppColors.blood.withValues(alpha: 0.28)),
      ),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.blood),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.blood,
              letterSpacing: 0.3,
              fontSize: 9,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.state,
    required this.onApply,
    required this.onSave,
    required this.onShare,
  });

  final _ProcessState state;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final done = state == _ProcessState.done;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        children: [
          Expanded(child: _ApplyButton(state: state, onPressed: onApply)),
          // Save / Share — only visible after filter applied
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: done
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      _IconAction(
                        icon: Icons.save_alt_rounded,
                        label: 'SAVE',
                        onTap: onSave,
                      ),
                      const SizedBox(width: 8),
                      _IconAction(
                        icon: Icons.ios_share_rounded,
                        label: 'SHARE',
                        onTap: onShare,
                        accent: true,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Apply button ──────────────────────────────────────────────────────────────

class _ApplyButton extends StatefulWidget {
  const _ApplyButton({required this.state, required this.onPressed});
  final _ProcessState state;
  final VoidCallback onPressed;

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final processing = widget.state == _ProcessState.processing;
    final done = widget.state == _ProcessState.done;

    return Semantics(
      button: true,
      label: processing ? 'Processing' : done ? 'Reapply filter' : 'Apply filter',
      child: GestureDetector(
        onTap: processing ? null : widget.onPressed,
        onTapDown: processing ? null : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 52,
          decoration: BoxDecoration(
            color: _pressed || processing ? AppColors.maroon : AppColors.crimson,
            borderRadius: BorderRadius.circular(10),
            boxShadow: processing || _pressed
                ? null
                : [
                    BoxShadow(
                      color: AppColors.crimson.withValues(alpha: 0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: processing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.chalk,
                          strokeWidth: 1.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PROCESSING…',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.dust,
                          letterSpacing: 1.4,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Text(
                    done ? 'REAPPLY' : 'APPLY FILTER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.chalk,
                      letterSpacing: 1.6,
                      fontSize: 11,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Icon action button ────────────────────────────────────────────────────────

class _IconAction extends StatefulWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          width: 58,
          height: 52,
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.vessel
                : widget.accent
                    ? AppColors.haze
                    : AppColors.crypt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.accent
                  ? AppColors.mauve.withValues(alpha: 0.45)
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: widget.accent ? AppColors.mauve : AppColors.chalk,
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: widget.accent ? AppColors.mauve : AppColors.dust,
                  fontSize: 7,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
