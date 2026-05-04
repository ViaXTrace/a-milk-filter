import 'package:flutter/material.dart';

/// Renders a subtle horizontal scanline pattern over its parent.
/// Pointer events pass through. Uses RepaintBoundary to isolate repaints.
class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key, this.opacity = 0.045});
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(painter: _ScanlinePainter(opacity: opacity)),
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
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), paint);
      y += 4;
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.opacity != opacity;
}
