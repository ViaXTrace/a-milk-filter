import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Draggable split-screen before/after image comparison.
/// Left side = filtered result, right side = original.
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

  late final AnimationController _hintCtrl;
  late final Animation<double> _hintAnim;

  @override
  void initState() {
    super.initState();
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hintAnim = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_hintCtrl);
  }

  @override
  void didUpdateWidget(BeforeAfterView old) {
    super.didUpdateWidget(old);
    if (old.filteredBytes == null && widget.filteredBytes != null) {
      _split = 0.5;
      _hintCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hintCtrl.dispose();
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
          onHorizontalDragStart: hasFiltered
              ? (_) => setState(() => _isDragging = true)
              : null,
          onHorizontalDragUpdate: hasFiltered
              ? (d) => setState(
                    () => _split =
                        (_split + d.delta.dx / width).clamp(0.04, 0.96),
                  )
              : null,
          onHorizontalDragEnd: hasFiltered
              ? (_) => setState(() => _isDragging = false)
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Original image (full, behind) ────────────────────────
              _ImagePane(child: Image.file(widget.originalFile, fit: BoxFit.contain)),

              // ── Filtered image (clipped to split) ────────────────────
              if (hasFiltered)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _split,
                    child: _ImagePane(
                      child: Image.memory(filtered, fit: BoxFit.contain, width: width),
                    ),
                  ),
                ),

              // ── Divider handle ────────────────────────────────────────
              if (hasFiltered)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: width * _split - 22,
                  width: 44,
                  child: _DividerHandle(
                    isDragging: _isDragging,
                    hintAnim: _hintAnim,
                  ),
                ),

              // ── Drag nudge hint (appears briefly after filter applied) ─
              if (hasFiltered)
                AnimatedBuilder(
                  animation: _hintAnim,
                  builder: (_, __) => Opacity(
                    opacity: (1 - _hintAnim.value).clamp(0.0, 1.0),
                    child: const _DragHint(),
                  ),
                ),

              // ── Processing overlay ────────────────────────────────────
              if (widget.isProcessing) const _ProcessingOverlay(),

              // ── Corner pane labels ────────────────────────────────────
              if (hasFiltered)
                const Positioned(
                  top: 12,
                  left: 12,
                  child: _PaneLabel(text: 'AFTER', accent: true),
                ),
              const Positioned(
                top: 12,
                right: 12,
                child: _PaneLabel(text: 'BEFORE', accent: false),
              ),

              // ── Empty state hint ──────────────────────────────────────
              if (!hasFiltered && !widget.isProcessing)
                const Positioned(
                  bottom: 20,
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

// ── Image pane ────────────────────────────────────────────────────────────────

class _ImagePane extends StatelessWidget {
  const _ImagePane({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: ColoredBox(color: AppColors.abyss, child: child),
  );
}

// ── Divider handle ────────────────────────────────────────────────────────────

class _DividerHandle extends StatelessWidget {
  const _DividerHandle({required this.isDragging, required this.hintAnim});
  final bool isDragging;
  final Animation<double> hintAnim;

  @override
  Widget build(BuildContext context) => Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Vertical rule
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: isDragging ? 2 : 1.5,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.crimson.withValues(alpha: isDragging ? 0.95 : 0.65),
                AppColors.crimson.withValues(alpha: isDragging ? 0.95 : 0.65),
                Colors.transparent,
              ],
              stops: const [0.0, 0.12, 0.88, 1.0],
            ),
          ),
        ),
        // Handle pill
        AnimatedBuilder(
          animation: hintAnim,
          builder: (_, child) => Transform.scale(
            scale: 1.0 + hintAnim.value * 0.18 * (1 - hintAnim.value) * 4,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: isDragging ? 40 : 34,
            height: isDragging ? 40 : 34,
            decoration: BoxDecoration(
              color: isDragging ? AppColors.crimson : AppColors.maroon,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDragging
                    ? AppColors.chalk.withValues(alpha: 0.25)
                    : AppColors.crimson,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.crimson
                      .withValues(alpha: isDragging ? 0.55 : 0.30),
                  blurRadius: isDragging ? 20 : 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  size: 13,
                  color: isDragging ? AppColors.chalk : AppColors.dust,
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 13,
                  color: isDragging ? AppColors.chalk : AppColors.dust,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Drag hint ─────────────────────────────────────────────────────────────────

class _DragHint extends StatelessWidget {
  const _DragHint();

  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: Align(
      alignment: Alignment(0, 0.78),
      child: IgnorePointer(
        child: _HintPill(text: '←  DRAG TO COMPARE  →'),
      ),
    ),
  );
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.void_.withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.dust,
        fontSize: 9,
        letterSpacing: 0.8,
      ),
    ),
  );
}

// ── Processing overlay ────────────────────────────────────────────────────────

class _ProcessingOverlay extends StatefulWidget {
  const _ProcessingOverlay();

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: ColoredBox(
      color: AppColors.void_.withValues(alpha: 0.80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  color: AppColors.crimson.withValues(alpha: 0.55 + _pulse.value * 0.45),
                  strokeWidth: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'PROCESSING',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.dust,
                letterSpacing: 2.4,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'mapping palette · pixel by pixel',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.ash,
                letterSpacing: 0.5,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Pane labels ───────────────────────────────────────────────────────────────

class _PaneLabel extends StatelessWidget {
  const _PaneLabel({required this.text, required this.accent});
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: accent
          ? AppColors.crimson.withValues(alpha: 0.88)
          : AppColors.abyss.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: accent ? AppColors.crimson : AppColors.border,
        width: accent ? 0 : 1,
      ),
      boxShadow: accent
          ? [
              BoxShadow(
                color: AppColors.crimson.withValues(alpha: 0.32),
                blurRadius: 10,
              ),
            ]
          : null,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: accent ? AppColors.chalk : AppColors.dust,
        letterSpacing: 0.9,
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ── Empty hint ────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.abyss.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Apply filter to compare',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.ash,
          letterSpacing: 0.5,
          fontSize: 9,
        ),
      ),
    ),
  );
}
