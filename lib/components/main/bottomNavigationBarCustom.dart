import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class BottomNavigationBarCustom extends StatefulWidget {
  const BottomNavigationBarCustom({super.key});

  @override
  State<BottomNavigationBarCustom> createState() =>
      _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State<BottomNavigationBarCustom> {
  final List<Map<String, dynamic>> _tabList = [
    {
      'label': '学习',
      'icon': Image.asset("lib/assets/learn.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/learn_active.png",
        width: 30,
        height: 30,
      ),
      'page': const Center(child: Text('学习')),
    },
    {
      'label': 'AI对话',
      'icon': Image.asset("lib/assets/ai_chat.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/ai_chat_active.png",
        width: 30,
        height: 30,
      ),
      'page': const Center(child: Text('AI对话')),
    },
    {
      'label': '我的',
      'icon': Image.asset("lib/assets/mine.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/mine_active.png",
        width: 30,
        height: 30,
      ),
      'page': const Center(child: Text('我的')),
    },
  ];

  List<BottomNavigationBarItem> _buildTabItems() {
    return _tabList.map((tab) {
      return BottomNavigationBarItem(
        icon: tab['icon'],
        activeIcon: tab['activeIcon'],
        label: tab['label'],
      );
    }).toList();
  }

  int _currentIndex = 0;
  final AppTheme appTheme = AppTheme();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        height: 100,
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
            color: Theme.of(context).colorScheme.primary,
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: BottomNavigationBar(
                elevation: 0,
                selectedItemColor: Theme.of(context).colorScheme.onPrimary,
                selectedLabelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                unselectedItemColor: Theme.of(context).colorScheme.shadow,
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                items: _buildTabItems(),
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
