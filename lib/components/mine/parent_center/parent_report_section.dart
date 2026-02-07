import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tsty_app/components/mine/parent_center/parent_center_models.dart';

class ParentReportSection extends StatelessWidget {
  final ParentChildInfo child;
  final ParentReportPeriod period;
  final ValueChanged<ParentReportPeriod> onPeriodChanged;

  final ParentReportData data;
  final bool loading;
  final void Function(int index) onBarTap;

  const ParentReportSection({
    super.key,
    required this.child,
    required this.period,
    required this.onPeriodChanged,
    required this.data,
    required this.loading,
    required this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    final trendTitle = period == ParentReportPeriod.week
        ? '本周学习时长'
        : period == ParentReportPeriod.month
            ? '本月学习时长'
            : '全部学习时长趋势';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChildHeaderCard(
                nickname: child.nickname,
                className: child.className,
                avatarAsset: child.avatarAsset,
                activeDays: data.summary.activeDays,
                lastActivityAt: data.summary.lastActivityAt,
                lastStudyDate: data.summary.lastStudyDate,
              ),
              const SizedBox(height: 14),
              _PeriodTabs(
                value: period,
                onChanged: onPeriodChanged,
              ),
              const SizedBox(height: 14),
              _StatsGrid(data: data),
              const SizedBox(height: 14),
              _ProgressCard(
                progress: data.progress,
                shengmuProgress: data.shengmuProgress,
                yunmuProgress: data.yunmuProgress,
                hanziProgress: data.hanziProgress,
                ciyuProgress: data.ciyuProgress,
              ),
              const SizedBox(height: 14),
              _TrendCard(
                title: trendTitle,
                icon: Icons.bar_chart,
                accent: red,
                minutes: data.trend.learningMinutes,
                labels: data.trend.dates,
                period: period,
                onBarTap: onBarTap,
              ),
              const SizedBox(height: 14),
              if (data.evaluation.comment.isNotEmpty)
                _EvaluationCard(data: data.evaluation),
              if (data.evaluation.comment.isNotEmpty)
                const SizedBox(height: 10),
            ],
          ),
        ),
        if (loading)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.white.withValues(alpha: 0.55),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }
}

class _AllTimeTrendCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<int> minutes;
  final List<String> labels;
  final void Function(int index) onPointTap;

  const _AllTimeTrendCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.minutes,
    required this.labels,
    required this.onPointTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMinutes = _trimTrailingZeros(minutes);
    final effectiveLabels = labels.take(effectiveMinutes.length).toList();

    String shortLabel(String raw) {
      if (raw.isEmpty) return '';
      final s = raw.split('T').first;
      final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
      if (m != null) {
        final mm = (m.group(2) ?? '').padLeft(2, '0');
        final dd = (m.group(3) ?? '').padLeft(2, '0');
        return '$mm-$dd';
      }
      final m2 = RegExp(r'^(\d{4})-(\d{1,2})').firstMatch(s);
      if (m2 != null) {
        return (m2.group(2) ?? '').padLeft(2, '0');
      }
      return raw;
    }

    final maxMinutes = effectiveMinutes.fold<int>(0, (p, e) => e > p ? e : p);
    final denom = (maxMinutes > 60 ? maxMinutes : 60).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
              const Spacer(),
              Text(
                '趋势',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: accent.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, c) {
                final count = effectiveMinutes.length;
                if (count <= 1) {
                  return const SizedBox.shrink();
                }

                const dxStep = 46.0;
                final viewportW = c.maxWidth;
                const rightGutter = 18.0;
                final labelW = (effectiveLabels.length * dxStep) + rightGutter;
                final lineW = (count * dxStep) + rightGutter;
                final contentW = math.max(viewportW, math.max(labelW, lineW));

                final interval = count <= 14
                    ? 1
                    : count <= 31
                        ? 2
                        : count <= 90
                            ? 7
                            : 30;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentW,
                    height: 220,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerUp: (e) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final local = box.globalToLocal(e.position);
                        final usable = contentW.clamp(1.0, double.infinity);
                        final idx = ((local.dx / usable) * (count - 1)).round().clamp(0, count - 1);
                        onPointTap(idx);
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            width: contentW,
                            height: 186,
                            child: CustomPaint(
                              painter: _AllTimeTrendPainter(
                                accent: accent,
                                minutes: effectiveMinutes,
                                denom: denom,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: contentW,
                            height: 34,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ...List.generate(effectiveLabels.length, (i) {
                                  final show = i == 0 || i == effectiveLabels.length - 1 || (i % interval == 0);
                                  return SizedBox(
                                    width: dxStep,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        show ? shortLabel(effectiveLabels[i]) : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: rightGutter),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllTimeTrendPainter extends CustomPainter {
  final Color accent;
  final List<int> minutes;
  final double denom;

  _AllTimeTrendPainter({
    required this.accent,
    required this.minutes,
    required this.denom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (minutes.isEmpty) return;

    final chartHeight = 170.0;
    final bottomOffset = 30.0;
    final usableHeight = chartHeight;
    final w = size.width;
    final count = minutes.length;
    if (count == 1) return;

    final dxStep = w / (count - 1);

    final points = <Offset>[];
    for (var i = 0; i < count; i++) {
      final m = minutes[i].toDouble();
      final y = (m / denom).clamp(0.0, 1.0);
      final px = dxStep * i;
      final py = (usableHeight * (1 - y)) + 10;
      points.add(Offset(px, py));
    }

    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final c1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final c2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
    }

    final areaPath = Path.from(path)
      ..lineTo(points.last.dx, usableHeight + bottomOffset)
      ..lineTo(points.first.dx, usableHeight + bottomOffset)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.22),
          accent.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, usableHeight + bottomOffset));

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = accent;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(
        p,
        8,
        Paint()..color = accent.withValues(alpha: 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AllTimeTrendPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.denom != denom ||
        oldDelegate.minutes != minutes;
  }
}

List<int> _trimTrailingZeros(List<int> input) {
  var end = input.length;
  while (end > 0 && input[end - 1] == 0) {
    end--;
  }
  if (end <= 0) return const <int>[];
  return input.take(end).toList(growable: false);
}

double _computeAvgY({
  required int avg,
  required double denom,
  required double availableHeight,
}) {
  final v = (avg / denom).clamp(0.0, 1.0);
  return (1 - v) * availableHeight;
}

class _ChildHeaderCard extends StatelessWidget {
  final String nickname;
  final String className;
  final String avatarAsset;
  final int activeDays;
  final String lastActivityAt;
  final String lastStudyDate;

  const _ChildHeaderCard({
    required this.nickname,
    required this.className,
    required this.avatarAsset,
    required this.activeDays,
    required this.lastActivityAt,
    required this.lastStudyDate,
  });

  String _formatActivityAt(String raw) {
    if (raw.isEmpty) return '';
    final s = raw.replaceFirst('T', ' ');
    if (s.length >= 16) return s.substring(0, 16);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            red,
            Color.lerp(red, Colors.black, 0.12) ?? red,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: red.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.40),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(avatarAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$className · 已学习$activeDays天',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                if (lastActivityAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '最后活动时间：${_formatActivityAt(lastActivityAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                ],
                if (lastStudyDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '最后学习日期：$lastStudyDate',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  final ParentReportPeriod value;
  final ValueChanged<ParentReportPeriod> onChanged;

  const _PeriodTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    Widget tab(String label, ParentReportPeriod v) {
      final active = v == value;
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: active ? red : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(v),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: active ? Colors.white : const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          tab('本周', ParentReportPeriod.week),
          tab('本月', ParentReportPeriod.month),
          tab('全部', ParentReportPeriod.all),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ParentReportData data;

  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final completion = (data.progress.completionRate * 100).round();
    final completionValue = data.progress.completionRate.clamp(0.0, 1.0);
    final scoreValue = (data.summary.avgScore / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RingStat(
                label: '完成率',
                value: '$completion%',
                progress: completionValue,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RingStat(
                label: '平均分',
                value: '${data.summary.avgScore}分',
                progress: scoreValue,
                color: const Color(0xFF388E3C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _IconStat(
                label: '总时长',
                value: '${data.summary.totalLearningMinutes}分钟',
                icon: Icons.schedule,
                iconBg: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF57C00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _IconStat(
                label: '学习天数',
                value: '${data.summary.activeDays}天',
                icon: Icons.local_fire_department,
                iconBg: const Color(0xFFFCE4EC),
                iconColor: const Color(0xFFC2185B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: '平均每日',
                value: '${data.summary.avgDailyMinutes}分钟',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: '学习时长',
                value: '${data.summary.totalLearningMinutes}分钟',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: '获得星星',
                value: '${data.summary.earnedStars}颗',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'AI对话时长',
                value: '${data.summary.totalAiChatMinutes}分钟',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatefulWidget {
  final ParentReportProgress progress;
  final ParentReportProgress shengmuProgress;
  final ParentReportProgress yunmuProgress;
  final ParentReportProgress hanziProgress;
  final ParentReportProgress ciyuProgress;

  const _ProgressCard({
    required this.progress,
    required this.shengmuProgress,
    required this.yunmuProgress,
    required this.hanziProgress,
    required this.ciyuProgress,
  });

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final rate = widget.progress.completionRate.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: red),
              const SizedBox(width: 10),
              const Text(
                '关卡进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? '收起' : '展开',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color.lerp(red, Colors.black, 0.25) ?? red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: red.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.progress.completedLevels}/${widget.progress.totalLevels}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 10,
              backgroundColor: red.withValues(alpha: 0.12),
              color: red,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _UnitProgressRow(
                      label: '声母',
                      color: const Color(0xFFE53935),
                      progress: widget.shengmuProgress,
                    ),
                    const SizedBox(height: 10),
                    _UnitProgressRow(
                      label: '韵母',
                      color: const Color(0xFF1E88E5),
                      progress: widget.yunmuProgress,
                    ),
                    const SizedBox(height: 10),
                    _UnitProgressRow(
                      label: '汉字',
                      color: const Color(0xFF43A047),
                      progress: widget.hanziProgress,
                    ),
                    const SizedBox(height: 10),
                    _UnitProgressRow(
                      label: '词语',
                      color: const Color(0xFF8E24AA),
                      progress: widget.ciyuProgress,
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOut,
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

class _UnitProgressRow extends StatelessWidget {
  final String label;
  final Color color;
  final ParentReportProgress progress;

  const _UnitProgressRow({
    required this.label,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final rate = progress.completionRate.clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2800),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${progress.completedLevels}/${progress.totalLevels}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

class _RingStat extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _RingStat({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOut,
                    builder: (context, v, _) {
                      return CircularProgressIndicator(
                        value: v,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.12),
                      );
                    },
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D2800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _IconStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<int> minutes;
  final List<String> labels;
  final ParentReportPeriod period;
  final void Function(int index) onBarTap;

  const _TrendCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.minutes,
    required this.labels,
    required this.period,
    required this.onBarTap,
  });

  Color _barColor(int m) {
    if (m == 0) return const Color(0xFFE0E0E0);
    if (m < 15) return const Color(0xFFF44336);
    if (m > 30) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    if (period == ParentReportPeriod.all) {
      return _AllTimeTrendCard(
        title: title,
        icon: icon,
        accent: accent,
        minutes: minutes,
        labels: labels,
        onPointTap: onBarTap,
      );
    }

    final effectiveMinutes = _trimTrailingZeros(minutes);
    final effectiveLabels = labels.take(effectiveMinutes.length).toList();

    final maxMinutes = effectiveMinutes.fold<int>(0, (p, e) => e > p ? e : p);
    final avg = effectiveMinutes.isEmpty
        ? 0
        : (effectiveMinutes.fold<int>(0, (p, e) => p + e) /
                effectiveMinutes.length)
            .round();

    final denom = (maxMinutes > 60 ? maxMinutes : 60).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '均值 $avg 分钟',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color.lerp(accent, Colors.black, 0.25) ?? accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const rightGutter = 26.0;
                final avgY = _computeAvgY(
                  avg: avg,
                  denom: denom,
                  availableHeight: 150,
                );
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 44 + avgY,
                      child: Container(
                        height: 2,
                        color: accent.withValues(alpha: 0.18),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 44 + avgY + 4,
                      child: Text(
                        '均值',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accent.withValues(alpha: 0.60),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: rightGutter),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(effectiveMinutes.length, (i) {
                          final m = effectiveMinutes[i];
                          final h = m == 0 ? 8.0 : (m / denom) * 150 + 18;
                          return Expanded(
                            child: InkWell(
                              onTap: () => onBarTap(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      m > 0 ? '$m分' : '-',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF3D2800),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                      height: h,
                                      width: 22,
                                      decoration: BoxDecoration(
                                        color: _barColor(m),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      i < effectiveLabels.length
                                          ? effectiveLabels[i]
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: Color(0xFF4CAF50), text: '适中'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFF44336), text: '不足'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFFF9800), text: '过长'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  final ParentReportEvaluation data;

  const _EvaluationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: red),
              const SizedBox(width: 10),
              const Text(
                '学习评价',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.level,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3D2800),
            ),
          ),
          if (data.suggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFF0C000).withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '建议：',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...data.suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '· $s',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
