import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Dual-pane image comparison with a draggable vertical divider.
/// The left pane shows the original; the right pane shows the filtered result.
class BeforeAfterView extends StatefulWidget {
  const BeforeAfterView({
    super.key,
    required this.originalFile,
    required this.filteredBytes,
    required this.isProcessing,
  });

  final File originalFile;
  final Uint8List? filteredBytes;
  final bool isProcessing;

  @override
  State<BeforeAfterView> createState() => _BeforeAfterViewState();
}

class _BeforeAfterViewState extends State<BeforeAfterView> {
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.filteredBytes;
    final hasFiltered = filtered != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: hasFiltered
              ? (d) => setState(() {
                  _split = (_split + d.delta.dx / width).clamp(0.0, 1.0);
                })
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Original (full width, behind)
              Image.file(widget.originalFile, fit: BoxFit.contain),

              // Filtered (clipped to left fraction)
              if (hasFiltered)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _split,
                    child: Image.memory(
                      filtered,
                      fit: BoxFit.contain,
                      width: width,
                    ),
                  ),
                ),

              // Divider + handle
              if (hasFiltered)
                Positioned(
                  top: 0, bottom: 0,
                  left: width * _split - 18,
                  width: 36,
                  child: _DividerHandle(),
                ),

              // Processing overlay
              if (widget.isProcessing) _ProcessingOverlay(),

              // Corner labels
              Positioned(
                top: 10, left: 10,
                child: _PaneLabel(text: 'BEFORE'),
              ),
              if (hasFiltered)
                Positioned(
                  top: 10, right: 10,
                  child: _PaneLabel(text: 'AFTER', highlight: true),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DividerHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 1.5, height: double.infinity, color: AppColors.crimson),
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(
              color: AppColors.crimson.withOpacity(0.5), blurRadius: 10,
            )],
          ),
          child: const Icon(Icons.unfold_more, color: AppColors.chalk, size: 13),
        ),
      ],
    ),
  );
}

class _ProcessingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.void_.withOpacity(0.72),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
              color: AppColors.crimson, strokeWidth: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PROCESSING',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.dust, letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaneLabel extends StatelessWidget {
  const _PaneLabel({required this.text, this.highlight = false});
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: highlight ? AppColors.maroon : AppColors.abyss.withOpacity(0.85),
      borderRadius: BorderRadius.circular(2),
      border: Border.all(
        color: highlight ? AppColors.crimson : AppColors.border,
      ),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: highlight ? AppColors.chalk : AppColors.dust,
        letterSpacing: 0.4,
      ),
    ),
  );
}
