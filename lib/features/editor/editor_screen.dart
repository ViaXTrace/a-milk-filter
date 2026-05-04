import 'dart:io';
import 'dart:typed_data';
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

class _EditorScreenState extends State<EditorScreen> {
  FilterOptions _options = const FilterOptions(palette: MilkPaletteOne());
  _ProcessState _state = _ProcessState.idle;
  Uint8List? _filteredBytes;
  String? _errorMessage;

  Future<void> _applyFilter() async {
    if (_state == _ProcessState.processing) return;
    setState(() {
      _state = _ProcessState.processing;
      _filteredBytes = null;
      _errorMessage = null;
    });

    try {
      final sourceBytes = await widget.imageFile.readAsBytes();
      final payload = FilterPayload(sourceBytes: sourceBytes, options: _options);
      final result = await compute(applyFilter, payload);
      if (mounted) setState(() { _filteredBytes = result; _state = _ProcessState.done; });
    } on FilterException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _state = _ProcessState.error; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _state = _ProcessState.error; });
    }
  }

  Future<void> _saveImage() async {
    final bytes = _filteredBytes;
    if (bytes == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/milk_filter_$ts.png');
    await file.writeAsBytes(bytes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: milk_filter_$ts.png'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareImage() async {
    final bytes = _filteredBytes;
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/milk_filter_share.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: 'Filtered with A Milk Filter — Outside the Bag',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: MilkAppBar(
        title: 'EDITOR',
        subtitle: _options.palette.name,
      ),
      body: Stack(
        children: [
          const ScanlineOverlay(),
          Column(
            children: [
              Expanded(
                child: BeforeAfterView(
                  originalFile: widget.imageFile,
                  filteredBytes: _filteredBytes,
                  isProcessing: _state == _ProcessState.processing,
                ),
              ),
              _ControlPanel(
                options: _options,
                state: _state,
                errorMessage: _errorMessage,
                onOptionsChanged: (o) => setState(() => _options = o),
                onApply: _applyFilter,
                onSave: _saveImage,
                onShare: _shareImage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    decoration: BoxDecoration(
      color: AppColors.abyss,
      border: Border(top: BorderSide(color: AppColors.divider)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == _ProcessState.error && errorMessage != null)
          _ErrorBanner(message: errorMessage!),
        FilterControls(
          options: options,
          onChanged: onOptionsChanged,
          enabled: state != _ProcessState.processing,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(child: _ApplyButton(state: state, onPressed: onApply)),
              if (state == _ProcessState.done) ...[
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.save_alt_outlined,
                  label: 'SAVE',
                  onTap: onSave,
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.ios_share_outlined,
                  label: 'SHARE',
                  onTap: onShare,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: AppColors.blood.withOpacity(0.15),
    child: Text(
      'ERROR: $message',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.blood, letterSpacing: 0.3,
      ),
    ),
  );
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.state, required this.onPressed});
  final _ProcessState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final processing = state == _ProcessState.processing;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: processing ? AppColors.maroon : AppColors.crimson,
        borderRadius: BorderRadius.circular(4),
        boxShadow: processing
            ? null
            : [BoxShadow(
                color: AppColors.crimson.withOpacity(0.3),
                blurRadius: 14, offset: const Offset(0, 2),
              )],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: processing ? null : onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: processing
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.chalk, strokeWidth: 1.5,
                    ),
                  )
                : Text(
                    state == _ProcessState.done ? 'REAPPLY' : 'APPLY FILTER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.chalk, letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 54,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.crypt,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: AppColors.chalk),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(letterSpacing: 0.3)),
        ],
      ),
    ),
  );
}
