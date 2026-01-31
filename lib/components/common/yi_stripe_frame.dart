import 'package:flutter/material.dart';

class YiStripeFrame extends StatelessWidget {
  final EdgeInsets inset;
  final double thickness;
  final double blockExtent;
  final double radius;
  final double opacity;

  const YiStripeFrame({
    super.key,
    this.inset = EdgeInsets.zero,
    this.thickness = 14,
    this.blockExtent = 16,
    this.radius = 18,
    this.opacity = 0.78,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: inset,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CustomPaint(
            painter: _YiStripeFramePainter(
              thickness: thickness,
              blockExtent: blockExtent,
              opacity: opacity,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _YiStripeFramePainter extends CustomPainter {
  final double thickness;
  final double blockExtent;
  final double opacity;

  const _YiStripeFramePainter({
    required this.thickness,
    required this.blockExtent,
    required this.opacity,
  });

  static const _colors = [
    Color(0xFFc00000),
    Color(0xFFf0c000),
    Color(0xFF3d2800),
    Color(0xFFf0c000),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = thickness.clamp(1.0, double.infinity);
    final e = blockExtent.clamp(4.0, double.infinity);

    final paint = Paint()..style = PaintingStyle.fill;

    // Top
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final w = (x + e) > size.width ? (size.width - x) : e;
      paint.color = _colors[i % _colors.length].withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(x, 0, w, t), paint);
      x += e;
      i++;
    }

    // Bottom
    x = 0.0;
    i = 0;
    while (x < size.width) {
      final w = (x + e) > size.width ? (size.width - x) : e;
      paint.color = _colors[(_colors.length - 1 - (i % _colors.length))]
          .withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(x, size.height - t, w, t), paint);
      x += e;
      i++;
    }

    // Left
    var y = 0.0;
    i = 0;
    while (y < size.height) {
      final h = (y + e) > size.height ? (size.height - y) : e;
      paint.color = _colors[i % _colors.length].withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(0, y, t, h), paint);
      y += e;
      i++;
    }

    // Right
    y = 0.0;
    i = 0;
    while (y < size.height) {
      final h = (y + e) > size.height ? (size.height - y) : e;
      paint.color = _colors[(_colors.length - 1 - (i % _colors.length))]
          .withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(size.width - t, y, t, h), paint);
      y += e;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant _YiStripeFramePainter oldDelegate) {
    return thickness != oldDelegate.thickness ||
        blockExtent != oldDelegate.blockExtent ||
        opacity != oldDelegate.opacity;
  }
}
