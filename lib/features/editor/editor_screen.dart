import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  late final AnimationController _panelController;
  late final Animation<double> _panelAnim;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _panelAnim = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  Future<void> _applyFilter() async {
    if (_state == _ProcessState.processing) return;
    setState(() {
      _state = _ProcessState.processing;
      _filteredBytes = null;
      _errorMessage = null;
    });
    try {
      final sourceBytes = await widget.imageFile.readAsBytes();
      final payload = FilterPayload(
        sourceBytes: sourceBytes,
        options: _options,
      );
      final result = await compute(applyFilter, payload);
      if (mounted) {
        setState(() {
          _filteredBytes = result;
          _state = _ProcessState.done;
        });
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

  Future<void> _saveImage() async {
    final bytes = _filteredBytes;
    if (bytes == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/milk_filter_$ts.png');
      await file.writeAsBytes(bytes);
      if (mounted) {
        _showSnack('Saved to documents ·  milk_filter_$ts.png', success: true);
      }
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
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'image/png'),
      ], text: 'Filtered with A Milk Filter — Outside the Bag');
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
              size: 14,
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
        backgroundColor: AppColors.crypt,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: const EdgeInsets.all(16),
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
        children: [
          const ScanlineOverlay(opacity: 0.025),
          Column(
            children: [
              // ── Image viewport (flex to fill remaining space) ──────────
              Expanded(
                child: BeforeAfterView(
                  originalFile: widget.imageFile,
                  filteredBytes: _filteredBytes,
                  isProcessing: _state == _ProcessState.processing,
                ),
              ),

              // ── Control Panel ─────────────────────────────────────────
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(_panelAnim),
                child: FadeTransition(
                  opacity: _panelAnim,
                  child: _ControlPanel(
                    options: _options,
                    state: _state,
                    errorMessage: _errorMessage,
                    onOptionsChanged: (o) => setState(() => _options = o),
                    onApply: _applyFilter,
                    onSave: _saveImage,
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

// ── Control Panel ─────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.abyss,
      border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
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

        // ── Action row ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Row(
            children: [
              // Primary apply button
              Expanded(child: _ApplyButton(state: state, onPressed: onApply)),

              // Save / Share — only after filter is applied
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child:
                    state == _ProcessState.done
                        ? Row(
                          children: [
                            const SizedBox(width: 10),
                            _ActionIconButton(
                              icon: Icons.save_alt_rounded,
                              label: 'SAVE',
                              onTap: onSave,
                            ),
                            const SizedBox(width: 8),
                            _ActionIconButton(
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
        ),
      ],
    ),
  );
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.blood.withOpacity(0.10),
      border: Border(
        bottom: BorderSide(color: AppColors.blood.withOpacity(0.3)),
      ),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, size: 12, color: AppColors.blood),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.blood,
              letterSpacing: 0.3,
              fontSize: 9,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Apply Button ──────────────────────────────────────────────────────────────

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

    return GestureDetector(
      onTap: processing ? null : widget.onPressed,
      onTapDown: processing ? null : (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color:
              _pressed
                  ? AppColors.maroon
                  : processing
                  ? AppColors.maroon
                  : AppColors.crimson,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              processing || _pressed
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
        ),
        child: Center(
          child:
              processing
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
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    done ? 'REAPPLY' : 'APPLY FILTER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.chalk,
                      letterSpacing: 1.4,
                      fontSize: 12,
                    ),
                  ),
        ),
      ),
    );
  }
}

// ── Action Icon Button ────────────────────────────────────────────────────────

class _ActionIconButton extends StatefulWidget {
  const _ActionIconButton({
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
  State<_ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<_ActionIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 58,
        height: 52,
        decoration: BoxDecoration(
          color:
              _pressed
                  ? AppColors.vessel
                  : widget.accent
                  ? AppColors.haze
                  : AppColors.crypt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                widget.accent
                    ? AppColors.mauve.withOpacity(0.4)
                    : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: widget.accent ? AppColors.mauve : AppColors.chalk,
            ),
            const SizedBox(height: 3),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: widget.accent ? AppColors.mauve : AppColors.dust,
                fontSize: 8,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
