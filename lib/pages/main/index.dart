import 'package:flutter/material.dart';
import 'package:tsty_app/components/main/bottomNavigationBarCustom.dart';
import 'package:tsty_app/constants/tabList.dart';
import 'package:tsty_app/style/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppTheme appTheme = AppTheme();
  int _currentIndex = 0;

  List<Widget> get pages => TabListConstant.tabList.map((tabItem) {
    return tabItem["page"] as Widget;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSTY App',
      theme: appTheme.light(),
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: IndexedStack(index: _currentIndex, children: pages),
            ),
            bottomNavigationBar: BottomNavigationBarCustom(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() {
                _currentIndex = index;
              }),
            ),
          );
        },
      ),
    );
  }
}
