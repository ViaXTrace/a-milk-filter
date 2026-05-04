import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Full-screen before/after image comparison with a draggable divider.
/// Left = filtered result, right = original.
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

class _BeforeAfterViewState extends State<BeforeAfterView>
    with SingleTickerProviderStateMixin {
  double _split = 0.5;
  bool _isDragging = false;

  late final AnimationController _hintController;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(BeforeAfterView old) {
    super.didUpdateWidget(old);
    // When filtered result arrives, briefly animate the handle to hint
    if (old.filteredBytes == null && widget.filteredBytes != null) {
      _hintController.forward(from: 0);
      _split = 0.5;
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.filteredBytes;
    final hasFiltered = filtered != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart:
              hasFiltered ? (_) => setState(() => _isDragging = true) : null,
          onHorizontalDragUpdate:
              hasFiltered
                  ? (d) => setState(() {
                    _split = (_split + d.delta.dx / width).clamp(0.04, 0.96);
                  })
                  : null,
          onHorizontalDragEnd:
              hasFiltered ? (_) => setState(() => _isDragging = false) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Original (full, behind) ──────────────────────────────
              _ImagePane(
                child: Image.file(widget.originalFile, fit: BoxFit.contain),
              ),

              // ── Filtered (clipped left) ──────────────────────────────
              if (hasFiltered)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _split,
                    child: _ImagePane(
                      child: Image.memory(
                        filtered,
                        fit: BoxFit.contain,
                        width: width,
                      ),
                    ),
                  ),
                ),

              // ── Divider + Handle ─────────────────────────────────────
              if (hasFiltered)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: width * _split - 20,
                  width: 40,
                  child: _DividerHandle(isDragging: _isDragging),
                ),

              // ── Processing overlay ────────────────────────────────────
              if (widget.isProcessing) const _ProcessingOverlay(),

              // ── Corner labels ─────────────────────────────────────────
              if (hasFiltered)
                Positioned(
                  top: 14,
                  left: 14,
                  child: _PaneLabel(text: 'AFTER', accent: true),
                ),
              Positioned(
                top: 14,
                right: 14,
                child: _PaneLabel(text: 'BEFORE', accent: false),
              ),

              // ── Drag hint (before filter is applied) ──────────────────
              if (!hasFiltered && !widget.isProcessing)
                const Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: _EmptyHint(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ImagePane extends StatelessWidget {
  const _ImagePane({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: AppColors.abyss, child: child);
}

class _DividerHandle extends StatelessWidget {
  const _DividerHandle({required this.isDragging});
  final bool isDragging;

  @override
  Widget build(BuildContext context) => Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Vertical rule
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isDragging ? 2 : 1.5,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.crimson.withValues(alpha: isDragging ? 0.9 : 0.6),
                AppColors.crimson.withValues(alpha: isDragging ? 0.9 : 0.6),
                Colors.transparent,
              ],
              stops: const [0.0, 0.15, 0.85, 1.0],
            ),
          ),
        ),

        // Handle pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isDragging ? 36 : 32,
          height: isDragging ? 36 : 32,
          decoration: BoxDecoration(
            color: isDragging ? AppColors.crimson : AppColors.maroon,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isDragging
                      ? AppColors.chalk.withValues(alpha: 0.3)
                      : AppColors.crimson,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.crimson.withValues(
                  alpha: isDragging ? 0.5 : 0.3,
                ),
                blurRadius: isDragging ? 18 : 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                size: 12,
                color: isDragging ? AppColors.chalk : AppColors.dust,
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 12,
                color: isDragging ? AppColors.chalk : AppColors.dust,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProcessingOverlay extends StatefulWidget {
  const _ProcessingOverlay();

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.void_.withValues(alpha: 0.78),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder:
                (_, __) => SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: AppColors.crimson.withValues(
                      alpha: 0.6 + _anim.value * 0.4,
                    ),
                    strokeWidth: 1.5,
                  ),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'PROCESSING',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.dust,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'mapping palette · pixel by pixel',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ash,
              letterSpacing: 0.4,
              fontSize: 9,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaneLabel extends StatelessWidget {
  const _PaneLabel({required this.text, required this.accent});
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color:
          accent
              ? AppColors.crimson.withValues(alpha: 0.85)
              : AppColors.abyss.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: accent ? AppColors.crimson : AppColors.border,
        width: accent ? 0 : 1,
      ),
      boxShadow:
          accent
              ? [
                BoxShadow(
                  color: AppColors.crimson.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
              : null,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: accent ? AppColors.chalk : AppColors.dust,
        letterSpacing: 0.8,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.abyss.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Apply filter to compare',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.ash,
          letterSpacing: 0.4,
          fontSize: 10,
        ),
      ),
    ),
  );
}
