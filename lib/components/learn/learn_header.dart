import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class LearnUnitProgress {
  final int completed;
  final int total;

  const LearnUnitProgress({required this.completed, required this.total});
}

const List<LearnUnitProgress> _defaultUnitProgress = <LearnUnitProgress>[
  LearnUnitProgress(completed: 0, total: 0),
  LearnUnitProgress(completed: 0, total: 0),
  LearnUnitProgress(completed: 0, total: 0),
  LearnUnitProgress(completed: 0, total: 0),
];

const List<IconData> _unitIcons = <IconData>[
  Icons.record_voice_over,
  Icons.music_note,
  Icons.translate,
  Icons.subject,
];

class LearnHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onUnitTap;
  final List<LearnUnitProgress> unitProgress;

  const LearnHeader({
    super.key,
    this.selectedIndex = 0,
    this.onUnitTap,
    this.unitProgress = _defaultUnitProgress,
  });

  static const List<String> _units = ['声母', '韵母', '汉字', '词语'];

  String _progressText(int index) {
    final p = index < unitProgress.length
        ? unitProgress[index]
        : const LearnUnitProgress(completed: 0, total: 0);
    return '${p.completed}/${p.total}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth < 360;
        final useScroll = maxWidth < 330;

        final cardHeight = isCompact ? 68.0 : 80.0;
        final iconSize = isCompact ? 30.0 : 36.0;
        final titleSize = isCompact ? 14.0 : 16.0;
        final subSize = isCompact ? 12.0 : 14.0;
        final itemMargin = isCompact ? 4.0 : 8.0;
        final itemPaddingH = isCompact ? 5.0 : 10.0;
        final iconGap = isCompact ? 8.0 : 10.0;

        final row = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: useScroll
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: List.generate(_units.length, (index) {
            final isSelected = index == selectedIndex;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onUnitTap?.call(index),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: cardHeight,
                  margin: EdgeInsets.symmetric(horizontal: itemMargin),
                  padding: EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: itemPaddingH,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.yiYellow.value.withValues(
                      alpha: isSelected ? 1.0 : 0.88,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _unitIcons[index],
                        color: Theme.of(context).colorScheme.onSurface,
                        size: iconSize,
                      ),
                      SizedBox(width: iconGap),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _units[index],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _progressText(index),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: subSize,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );

        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          //margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: useScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: row,
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: row,
                ),
        );
      },
    );
  }
}

class LearnContentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> units = ['声母', '韵母', '汉字', '词语'];
  final List<LearnUnitProgress> unitProgress;

  LearnContentHeaderDelegate({this.unitProgress = _defaultUnitProgress});

  String _progressText(int index) {
    final p = index < unitProgress.length
        ? unitProgress[index]
        : const LearnUnitProgress(completed: 0, total: 0);
    return '${p.completed}/${p.total}';
  }

  List<Widget> _getHeaderContent(BuildContext context) {
    return List.generate(units.length, (index) {
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
              _unitIcons[index],
              color: Theme.of(context).colorScheme.onSurface,
              size: 36,
            ),
            const SizedBox(width: 10),
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
                const SizedBox(height: 4),
                Text(
                  _progressText(index),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final useScroll = constraints.maxWidth < 330;
        final row = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: useScroll
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: _getHeaderContent(context),
        );

        return Container(
          width: double.infinity,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: useScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: row,
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: row,
                ),
        );
      },
    );
  }

  @override
  double get maxExtent => 104;

  @override
  double get minExtent => 92;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
