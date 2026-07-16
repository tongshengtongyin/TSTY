import 'package:flutter/material.dart';

class YiRadialBubble extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final Alignment highlightAlignment;
  final double highlightAlpha;
  final double highlightStop;
  final double highlightRadius;
  final double highlightCenterBias;

  const YiRadialBubble({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.highlightAlignment = const Alignment(-0.4, -0.4),
    this.highlightAlpha = 0.90,
    this.highlightStop = 0.45,
    this.highlightRadius = 0.9,
    this.highlightCenterBias = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final base = color.withValues(alpha: (color.a * opacity).clamp(0.0, 1.0));
    final center =
        Alignment.lerp(
          highlightAlignment,
          Alignment.center,
          highlightCenterBias.clamp(0.0, 1.0),
        ) ??
        highlightAlignment;
    final stop = highlightStop.clamp(0.05, 0.95);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: center,
          radius: highlightRadius,
          colors: [
            Colors.white.withValues(alpha: highlightAlpha),
            base,
            base.withValues(alpha: 0.0),
          ],
          stops: [0.0, stop, 1.0],
        ),
      ),
    );
  }
}
