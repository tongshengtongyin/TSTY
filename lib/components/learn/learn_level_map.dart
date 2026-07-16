import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum LearnLevelStatus { locked, unlocked, completed, perfect }

class LearnLevelData {
  final int id;
  final String? levelId;
  final LearnLevelStatus status;
  final int flowers;

  const LearnLevelData({
    required this.id,
    this.levelId,
    required this.status,
    this.flowers = 0,
  });
}

class LearnLevelMap extends StatelessWidget {
  final List<LearnLevelData> levels;
  final double spacingY;
  final double topPadding;
  final double bottomPaddingBase;
  final double nodeSize;
  final double strokeWidth;
  final Color? strokeColor;
  final bool blocked;
  final ValueChanged<LearnLevelData>? onLevelTap;

  const LearnLevelMap({
    super.key,
    required this.levels,
    this.spacingY = 150.0,
    this.topPadding = 24.0,
    this.bottomPaddingBase = 80.0,
    this.nodeSize = 72.0,
    this.strokeWidth = 8.0,
    this.strokeColor,
    this.blocked = false,
    this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomPadding =
            bottomPaddingBase + MediaQuery.of(context).padding.bottom;

        final contentHeight =
            topPadding +
            bottomPadding +
            (levels.length - 1) * spacingY +
            nodeSize;
        final canvasHeight = math.max(constraints.maxHeight, contentHeight);

        final width = constraints.maxWidth;
        final leftX = width * 0.18;
        final rightX = width * 0.62;

        final points = <Offset>[];
        for (var i = 0; i < levels.length; i++) {
          final x = (i % 2 == 0) ? leftX : rightX;
          final y = canvasHeight - bottomPadding - nodeSize - (i * spacingY);
          points.add(Offset(x + nodeSize / 2, y + nodeSize / 2));
        }

        final finalStrokeColor =
            strokeColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.9);

        return SingleChildScrollView(
          reverse: true,
          child: SizedBox(
            height: canvasHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LearnLevelPathPainter(
                      points: points,
                      strokeColor: finalStrokeColor,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                ),
                for (var i = 0; i < levels.length; i++)
                  _LearnLevelNodePositioned(
                    level: levels[i],
                    top:
                        canvasHeight -
                        bottomPadding -
                        nodeSize -
                        (i * spacingY),
                    left: (i % 2 == 0) ? leftX : rightX,
                    size: nodeSize,
                    blocked: blocked,
                    onTap: onLevelTap,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LearnLevelNodePositioned extends StatelessWidget {
  final LearnLevelData level;
  final double top;
  final double left;
  final double size;
  final bool blocked;
  final ValueChanged<LearnLevelData>? onTap;

  const _LearnLevelNodePositioned({
    required this.level,
    required this.top,
    required this.left,
    required this.size,
    required this.blocked,
    required this.onTap,
  });

  String get _assetPath {
    switch (level.status) {
      case LearnLevelStatus.locked:
        return 'lib/assets/level-locked.png';
      case LearnLevelStatus.unlocked:
        return 'lib/assets/level-unlocked.png';
      case LearnLevelStatus.completed:
        return 'lib/assets/level-passed.png';
      case LearnLevelStatus.perfect:
        return 'lib/assets/level-passed.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTap =
        level.status == LearnLevelStatus.unlocked ||
        level.status == LearnLevelStatus.completed ||
        level.status == LearnLevelStatus.perfect;

    final shouldGrey = blocked && canTap;

    return Positioned(
      left: left,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: canTap ? () => onTap?.call(level) : null,
            borderRadius: BorderRadius.circular(18),
            child: Opacity(
              opacity: shouldGrey ? 0.55 : 1,
              child: ColorFiltered(
                colorFilter: shouldGrey
                    ? const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Image.asset(_assetPath, fit: BoxFit.contain),
                      ),
                      if (level.status == LearnLevelStatus.perfect)
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Color(0xFFF0C000),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -2,
                        child: Center(
                          child: Text(
                            '${level.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if ((level.status == LearnLevelStatus.completed ||
                  level.status == LearnLevelStatus.perfect) &&
              level.flowers > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  level.flowers.clamp(0, 3),
                  (i) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: _FlowerBadge(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowerBadge extends StatelessWidget {
  const _FlowerBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Image.asset(
          'lib/assets/flower.png',
          width: 25,
          height: 25,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _LearnLevelPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color strokeColor;
  final double strokeWidth;

  const _LearnLevelPathPainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, mid.dy, mid.dx, mid.dy);
      path.quadraticBezierTo(curr.dx, mid.dy, curr.dx, curr.dy);
    }

    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);

    final basePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final darkTwistPaint = Paint()
      ..color = _lerpColor(strokeColor, const Color(0xFF000000), 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highlightPaint = Paint()
      ..color = _lerpColor(
        strokeColor,
        const Color(0xFFFFFFFF),
        0.35,
      ).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.42
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.55);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, basePaint);

    canvas.save();
    canvas.translate(-1.2, 1.0);
    canvas.drawPath(path, darkTwistPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(1.0, -1.2);
    canvas.drawPath(path, highlightPaint);
    canvas.restore();

    _paintSpiralTwist(canvas, path);

    _paintFibers(canvas, path);
  }

  void _paintSpiralTwist(Canvas canvas, Path path) {
    final metrics = path.computeMetrics(forceClosed: false).toList();
    if (metrics.isEmpty) return;

    final spiralPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(1.2, strokeWidth * 0.18)
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(0.6, strokeWidth * 0.10),
      );

    final amplitude = strokeWidth * 0.32;
    final wavelength = math.max(10.0, strokeWidth * 1.4);
    final step = math.max(1.6, strokeWidth * 0.22);

    for (final metric in metrics) {
      final spiral = Path();
      var started = false;

      for (double d = 0; d <= metric.length; d += step) {
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;

        final v = t.vector;
        final vLen = math.sqrt(v.dx * v.dx + v.dy * v.dy);
        if (vLen <= 0.0001) continue;

        final nx = -v.dy / vLen;
        final ny = v.dx / vLen;
        final phase = (d / wavelength) * math.pi * 2;
        final offset = math.sin(phase) * amplitude;
        final p = Offset(
          t.position.dx + nx * offset,
          t.position.dy + ny * offset,
        );

        if (!started) {
          spiral.moveTo(p.dx, p.dy);
          started = true;
        } else {
          spiral.lineTo(p.dx, p.dy);
        }
      }

      if (started) {
        canvas.drawPath(spiral, spiralPaint);
      }
    }
  }

  void _paintFibers(Canvas canvas, Path path) {
    final metrics = path.computeMetrics(forceClosed: false).toList();
    if (metrics.isEmpty) return;

    final seed = points.isEmpty
        ? 1
        : points.fold<int>(
            0,
            (acc, p) => acc ^ (p.dx.round() * 31) ^ (p.dy.round() * 17),
          );
    final rnd = math.Random(seed);

    final fiberPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (final metric in metrics) {
      final step = math.max(10.0, strokeWidth * 1.6);
      for (double d = 0; d < metric.length; d += step) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;

        final p = tangent.position;
        final dir = tangent.vector;
        final len = 2.5 + rnd.nextDouble() * 4.0;
        final sign = rnd.nextBool() ? 1.0 : -1.0;
        final nx = -dir.dy;
        final ny = dir.dx;
        final jitter = (rnd.nextDouble() - 0.5) * 1.2;

        final start = Offset(p.dx + nx * jitter, p.dy + ny * jitter);
        final end = Offset(
          start.dx + nx * len * sign,
          start.dy + ny * len * sign,
        );

        final c = rnd.nextDouble() < 0.6
            ? _lerpColor(strokeColor, const Color(0xFFFFFFFF), 0.4)
            : _lerpColor(strokeColor, const Color(0xFF000000), 0.15);
        fiberPaint.color = c.withValues(alpha: 0.18 + rnd.nextDouble() * 0.20);

        canvas.drawLine(start, end, fiberPaint);
      }
    }
  }

  Color _lerpColor(Color a, Color b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return Color.lerp(a, b, clamped) ?? a;
  }

  @override
  bool shouldRepaint(covariant _LearnLevelPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
