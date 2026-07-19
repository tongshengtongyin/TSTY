import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/main/bottomNavigationBarCustom.dart';
import 'package:tsty_app/constants/tabList.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _guardLogin();
  }

  Future<void> _guardLogin() async {
    final loggedIn = await UserPrefs.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }

  List<Widget> get pages => TabListConstant.tabList.map((tabItem) {
    return tabItem["page"] as Widget;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFC00003),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFC00003),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFfff5e6),
            body: Column(
              children: [
                Container(
                  height: statusBarHeight,
                  color: const Color(0xFFC00003),
                ),
                Expanded(
                  child: YiBaseBackground(
                    child: IndexedStack(index: _currentIndex, children: pages),
                  ),
                ),
              ],
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
