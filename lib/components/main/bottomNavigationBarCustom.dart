import 'package:flutter/material.dart';
import 'package:tsty_app/constants/tabList.dart';
import 'package:tsty_app/style/app_theme.dart';

class BottomNavigationBarCustom extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarCustom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationBarCustom> createState() =>
      _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State<BottomNavigationBarCustom> {
  List<BottomNavigationBarItem> _buildTabItems() {
    return TabListConstant.tabList.map((tab) {
      return BottomNavigationBarItem(
        icon: tab['icon'],
        activeIcon: tab['activeIcon'],
        label: tab['label'],
      );
    }).toList();
  }

  final AppTheme appTheme = AppTheme();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        height: 110,
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: AppTheme.yiYellow.value,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            //color: Theme.of(context).colorScheme.primary,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: BottomNavigationBar(
                elevation: 0,
                selectedItemColor: Theme.of(context).colorScheme.onPrimary,
                selectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedItemColor: Theme.of(context).colorScheme.shadow,
                unselectedLabelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                selectedFontSize: 14,
                unselectedFontSize: 12,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                items: _buildTabItems(),
                currentIndex: widget.currentIndex,
                onTap: widget.onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
