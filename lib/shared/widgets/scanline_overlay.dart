import 'package:flutter/material.dart';

/// Renders a CRT-style horizontal scanline texture.
///
/// Usage inside a [Stack]:
///   Positioned.fill(child: ScanlineOverlay(opacity: 0.03))
///
/// Pointer events pass through. [RepaintBoundary] isolates repaints from
/// the rest of the widget tree.
class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key, this.opacity = 0.04});
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScanlinePainter(opacity: opacity),
      ),
    ),
  );
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    double y = 0;
    while (y < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), paint);
      y += 3.5;
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.opacity != opacity;
}
