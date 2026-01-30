// 路由管理
import 'package:flutter/material.dart';
import 'package:tsty_app/pages/ai_chat/detail.dart';
import 'package:tsty_app/pages/learn/level_detail.dart';
import 'package:tsty_app/pages/mine/edit_profile.dart';
import 'package:tsty_app/pages/mine/parent_center.dart';
import 'package:tsty_app/pages/mine/parent_entry.dart';
import 'package:tsty_app/pages/settings/index.dart';
import 'package:tsty_app/pages/main/index.dart';
import 'package:tsty_app/style/app_theme.dart';

// 返回App根组件
Widget myApp() {
  final AppTheme appTheme = AppTheme();

  return MaterialApp(
    theme: appTheme.light(),
    initialRoute: '/',
    routes: getRootRoutes(),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => MainPage(), // 主页路由
    "/settings": (context) => const SettingsPage(),
    "/mine/edit-profile": (context) => const EditProfilePage(),
    "/mine/parent-entry": (context) => const ParentEntryPage(),
    "/mine/parent-center": (context) => const ParentCenterPage(),
    "/learn/level-detail": (context) => LevelDetailPage.fromArgs(
          ModalRoute.of(context)?.settings.arguments,
        ),
    "/ai-chat/detail": (context) => AiChatDetailPage.fromArgs(
          ModalRoute.of(context)?.settings.arguments,
        ),
    //"/login": (context) => LoginPage(), // 登录页路由
  };
}
