import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 彝族风格基础渐变背景（含45°/-45°条纹）
class YiBaseBackground extends StatelessWidget {
  /// 子组件（可选，用于直接包裹内容）
  final Widget? child;

  /// 浅黄起始色（默认彝族浅黄）
  final Color lightColor;

  /// 浅黄结束色（默认#fff8ed）
  final Color lightEndColor;

  /// 条纹透明黄色（默认0.05透明度彝族黄）
  final Color stripeColor;

  /// 条纹尺寸
  final double stripeSize;

  final List<double> stripeAngles;

  const YiBaseBackground({
    super.key,
    this.child,
    this.lightColor = const Color(0xFFfff5e6),
    this.lightEndColor = const Color(0xFFfff8ed),
    this.stripeColor = const Color(0x0Cf0c000),
    this.stripeSize = 30,
    this.stripeAngles = const [45, -45],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _YiBaseBackgroundPainter(
              lightColor: lightColor,
              lightEndColor: lightEndColor,
              stripeColor: stripeColor,
              stripeSize: stripeSize,
              stripeAngles: stripeAngles,
            ),
          ),
        ),

        // 子组件（若有）
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _YiBaseBackgroundPainter extends CustomPainter {
  final Color lightColor;
  final Color lightEndColor;
  final Color stripeColor;
  final double stripeSize;
  final List<double> stripeAngles;

  const _YiBaseBackgroundPainter({
    required this.lightColor,
    required this.lightEndColor,
    required this.stripeColor,
    required this.stripeSize,
    required this.stripeAngles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [lightColor, lightEndColor],
        const [0.0, 1.0],
      );
    canvas.drawRect(rect, basePaint);

    final tile = stripeSize <= 0 ? 1.0 : stripeSize;

    final stripeStops = const [0.0, 0.65, 0.65, 0.70, 0.70, 1.0];
    final stripeColors = [
      Colors.transparent,
      Colors.transparent,
      stripeColor,
      stripeColor,
      Colors.transparent,
      Colors.transparent,
    ];

    final center = Offset(tile / 2, tile / 2);

    for (final angle in stripeAngles) {
      final rad = angle * 3.14159265358979323846 / 180.0;
      // Match CSS linear-gradient angle convention:
      // 0deg points to top, 90deg points to right.
      // Flutter canvas y-axis is downwards, so dy is negated.
      final rotatedDir = Offset(math.sin(rad), -math.cos(rad));

      final start = center - rotatedDir * (tile / 2);
      final end = center + rotatedDir * (tile / 2);

      final stripePaint = Paint()
        ..shader = ui.Gradient.linear(
          start,
          end,
          stripeColors,
          stripeStops,
          TileMode.repeated,
        );
      canvas.drawRect(rect, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _YiBaseBackgroundPainter oldDelegate) {
    return lightColor != oldDelegate.lightColor ||
        lightEndColor != oldDelegate.lightEndColor ||
        stripeColor != oldDelegate.stripeColor ||
        stripeSize != oldDelegate.stripeSize ||
        !_anglesEqual(stripeAngles, oldDelegate.stripeAngles);
  }

  bool _anglesEqual(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
