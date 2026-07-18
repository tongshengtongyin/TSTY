// 路由管理
import 'package:flutter/material.dart';
import 'package:tsty_app/pages/ai_chat/detail.dart';
import 'package:tsty_app/pages/ai_chat/video_test.dart';
import 'package:tsty_app/pages/learn/level_detail.dart';
import 'package:tsty_app/pages/login/index.dart';
import 'package:tsty_app/pages/main/index.dart';
import 'package:tsty_app/pages/mine/edit_profile.dart';
import 'package:tsty_app/pages/mine/parent_center.dart';
import 'package:tsty_app/pages/mine/parent_change_password.dart';
import 'package:tsty_app/pages/mine/parent_entry.dart';
import 'package:tsty_app/pages/settings/index.dart';
import 'package:tsty_app/pages/settings/privacy_settings.dart';
import 'package:tsty_app/pages/settings/third_party_share.dart';
import 'package:tsty_app/pages/splash_video.dart';
import 'package:tsty_app/routes/app_navigator.dart';
import 'package:tsty_app/routes/route_observer.dart';
import 'package:tsty_app/style/app_theme.dart';

Widget _wrapSafeArea(Widget child) {
  return SafeArea(child: child);
}

// 返回App根组件
Widget myApp() {
  final AppTheme appTheme = AppTheme();

  return MaterialApp(
    theme: appTheme.light(),
    initialRoute: '/splash',
    routes: getRootRoutes(),
    navigatorKey: appNavigatorKey,
    navigatorObservers: [routeObserver],
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/splash": (context) => const SplashVideoPage(),
    "/": (context) => MainPage(), // 主页路由
    "/login": (context) => _wrapSafeArea(const LoginPage()),
    "/settings": (context) => _wrapSafeArea(const SettingsPage()),
    "/settings/privacy": (context) =>
        _wrapSafeArea(const PrivacySettingsPage()),
    "/settings/third-party-share": (context) =>
        _wrapSafeArea(const ThirdPartySharePage()),
    "/mine/edit-profile": (context) => _wrapSafeArea(const EditProfilePage()),
    "/mine/parent-entry": (context) => _wrapSafeArea(const ParentEntryPage()),
    "/mine/parent-center": (context) => _wrapSafeArea(const ParentCenterPage()),
    "/mine/parent-change-password": (context) =>
        _wrapSafeArea(const ParentChangePasswordPage()),
    "/learn/level-detail": (context) => _wrapSafeArea(
      LevelDetailPage.fromArgs(ModalRoute.of(context)?.settings.arguments),
    ),
    "/ai-chat/detail": (context) => _wrapSafeArea(
      AiChatDetailPage.fromArgs(ModalRoute.of(context)?.settings.arguments),
    ),
    "/video-test": (context) => _wrapSafeArea(const VideoTestPage()),
  };
}
