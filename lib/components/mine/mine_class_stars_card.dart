import 'package:flutter/material.dart';
import 'package:tsty_app/components/mine/models.dart';
import 'package:tsty_app/style/app_theme.dart';

class MineClassStarsCard extends StatelessWidget {
  final List<MineStarStudent> stars;

  const MineClassStarsCard({
    super.key,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final red = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: yellow, width: 4),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: yellow, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          '班级之星',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3D2800),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.star,
                      color: yellow.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stars.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          yellow.withValues(alpha: 0.16),
                          red.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFF1D6),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: yellow.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: red.withValues(alpha: 0.85),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '暂无班级排名',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3D2800),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '可能是未分配班级，或班级暂无数据',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3D2800)
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: yellow.withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: yellow.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '去学习',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3D2800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final list = _sortedStars();
                    final count = list.isEmpty ? 1 : list.length;
                    final slotWidth = (constraints.maxWidth / count)
                        .clamp(72.0, 160.0)
                        .toDouble();

                    double pickAvatarSize(MineStarStudent s) {
                      final base = (slotWidth - 26).clamp(52.0, 80.0);
                      if (s.rank == 1) return base;
                      if (s.rank == 2) return (base * 0.9).clamp(48.0, base);
                      return (base * 0.84).clamp(46.0, base);
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final s in list)
                          SizedBox(
                            width: slotWidth,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _StarProfile(
                                student: s,
                                avatarSize: pickAvatarSize(s),
                                slotWidth: slotWidth,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<MineStarStudent> _sortedStars() {
    final list = List<MineStarStudent>.from(stars);
    list.sort((a, b) => a.rank.compareTo(b.rank));

    MineStarStudent? first;
    MineStarStudent? second;
    MineStarStudent? third;
    for (final s in list) {
      if (s.rank == 1) first = s;
      if (s.rank == 2) second = s;
      if (s.rank == 3) third = s;
    }

    final out = <MineStarStudent>[];
    if (second != null) out.add(second);
    if (first != null) out.add(first);
    if (third != null) out.add(third);

    if (out.isNotEmpty) return out;
    return list;
  }
}

class _StarProfile extends StatelessWidget {
  final MineStarStudent student;
  final double avatarSize;
  final double slotWidth;

  const _StarProfile({
    required this.student,
    required this.avatarSize,
    required this.slotWidth,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    final isFirst = student.rank == 1;
    final size = avatarSize;
    final topOffset = isFirst ? 0.0 : (size * 0.18).clamp(10.0, 16.0);
    final medalColor = student.rank == 1
        ? const Color(0xFFFFD700)
        : student.rank == 2
            ? const Color(0xFFC0C0C0)
            : const Color(0xFFCD7F32);

    final nameFontSize = (isFirst ? size * 0.18 : size * 0.17)
        .clamp(isFirst ? 14.0 : 13.0, isFirst ? 16.0 : 14.0);
    final heartSize = (size * 0.17).clamp(12.0, 14.0);
    final medalSize = (size * 0.27).clamp(18.0, 24.0);
    final medalOffset = -(medalSize * 0.33);

    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: SizedBox(
        width: slotWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(isFirst ? 4 : 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst ? yellow : const Color(0xFFFFF5E6),
                      width: isFirst ? 4 : 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      student.avatar,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: medalOffset,
                  left: medalOffset,
                  child: Container(
                    width: medalSize,
                    height: medalSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: medalColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${student.rank}',
                      style: TextStyle(
                        fontSize: (medalSize * 0.5).clamp(10.0, 12.0),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              student.name,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3D2800),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isFirst ? 10 : 8,
                vertical: isFirst ? 4 : 2,
              ),
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: heartSize),
                  const SizedBox(width: 2),
                  Text(
                    student.badge,
                    style: TextStyle(
                      fontSize: (size * 0.13).clamp(10.0, 11.0),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
