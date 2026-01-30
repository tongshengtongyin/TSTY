import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:tsty_app/style/app_theme.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  Widget build(BuildContext context) {
    final levels = _buildDemoLevels();
    return Column(
      children: [
        const SizedBox(height: 12),
        const SizedBox(height: 120, child: _LearnHeader()),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacingY = 150.0;
              const topPadding = 24.0;
              const bottomPadding = 24.0;
              const nodeSize = 72.0;

              final contentHeight =
                  topPadding + bottomPadding + (levels.length - 1) * spacingY + nodeSize;
              final canvasHeight = math.max(constraints.maxHeight, contentHeight);

              final width = constraints.maxWidth;
              final leftX = width * 0.18;
              final rightX = width * 0.62;

              final points = <Offset>[];
              for (var i = 0; i < levels.length; i++) {
                final x = (i % 2 == 0) ? leftX : rightX;
                final y =
                    canvasHeight - bottomPadding - nodeSize - (i * spacingY);
                points.add(Offset(x + nodeSize / 2, y + nodeSize / 2));
              }

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
                          painter: _LevelPathPainter(
                            points: points,
                            strokeColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.9),
                            strokeWidth: 8,
                          ),
                        ),
                      ),
                      for (var i = 0; i < levels.length; i++)
                        _LevelNodePositioned(
                          level: levels[i],
                          index: i,
                          top: canvasHeight - bottomPadding - nodeSize - (i * spacingY),
                          left: (i % 2 == 0) ? leftX : rightX,
                          size: nodeSize,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LearnHeader extends StatelessWidget {
  const _LearnHeader();

  static const List<String> _units = ['声母', '韵母', '汉字', '词语'];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_units.length, (index) {
          return Container(
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.yiYellow.value,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _units[index],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1/23',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

enum _LevelStatus { locked, unlocked, passed }

class _LevelData {
  final int id;
  final _LevelStatus status;
  final int flowers;

  const _LevelData({required this.id, required this.status, this.flowers = 0});
}

List<_LevelData> _buildDemoLevels() {
  return const [
    _LevelData(id: 1, status: _LevelStatus.passed, flowers: 3),
    _LevelData(id: 2, status: _LevelStatus.passed, flowers: 2),
    _LevelData(id: 3, status: _LevelStatus.passed, flowers: 1),
    _LevelData(id: 4, status: _LevelStatus.unlocked),
    _LevelData(id: 5, status: _LevelStatus.locked),
    _LevelData(id: 6, status: _LevelStatus.locked),
    _LevelData(id: 7, status: _LevelStatus.locked),
    _LevelData(id: 8, status: _LevelStatus.locked),
    _LevelData(id: 9, status: _LevelStatus.locked),
    _LevelData(id: 10, status: _LevelStatus.locked),
  ];
}

class _LevelNodePositioned extends StatelessWidget {
  final _LevelData level;
  final int index;
  final double top;
  final double left;
  final double size;

  const _LevelNodePositioned({
    required this.level,
    required this.index,
    required this.top,
    required this.left,
    required this.size,
  });

  String get _assetPath {
    switch (level.status) {
      case _LevelStatus.locked:
        return 'lib/assets/level-locked.png';
      case _LevelStatus.unlocked:
        return 'lib/assets/level-unlocked.png';
      case _LevelStatus.passed:
        return 'lib/assets/level-passed.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTap =
        level.status == _LevelStatus.unlocked || level.status == _LevelStatus.passed;

    return Positioned(
      left: left,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: canTap
                ? () {
                    Navigator.of(context).pushNamed(
                      '/learn/level-detail',
                      arguments: {
                        'levelIndex': level.id,
                        'totalLevels': 23,
                      },
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(_assetPath, fit: BoxFit.contain),
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
          if (level.status == _LevelStatus.passed && level.flowers > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  level.flowers.clamp(0, 3) as int,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.asset(
                      'lib/assets/flower.png',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color strokeColor;
  final double strokeWidth;

  const _LevelPathPainter({
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
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);

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
      ..color = _lerpColor(strokeColor, const Color(0xFFFFFFFF), 0.35)
          .withValues(alpha: 0.75)
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

    _paintFibers(canvas, path);
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
  bool shouldRepaint(covariant _LevelPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class LearnContentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> units = ['声母', '韵母', '汉字', '词语'];

  List<Widget> _getHeaderContent(BuildContext context) {
    return List.generate(units.length, (index) {
      return Container(
        height: 90,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.yiYellow.value,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              color: Theme.of(context).colorScheme.onSurface,
              size: 36,
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  units[index],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1/23',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _getHeaderContent(context),
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
