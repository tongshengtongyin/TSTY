import 'package:flutter/material.dart';
import 'package:tsty_app/pages/ai_chat/index.dart';
import 'package:tsty_app/pages/learn/index.dart';
import 'package:tsty_app/pages/mine/index.dart';

class TabListConstant {
  static final List<Map<String, dynamic>> tabList = [
    {
      'label': '学习',
      'icon': Image.asset("lib/assets/learn.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/learn_active.png",
        width: 30,
        height: 30,
      ),
      'page': LearnPage(),
    },
    {
      'label': 'AI对话',
      'icon': Image.asset("lib/assets/ai_chat.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/ai_chat_active.png",
        width: 30,
        height: 30,
      ),
      'page': AiChatPage(),
    },
    {
      'label': '我的',
      'icon': Image.asset("lib/assets/mine.png", width: 30, height: 30),
      'activeIcon': Image.asset(
        "lib/assets/mine_active.png",
        width: 30,
        height: 30,
      ),
      'page': MinePage(),
    },
  ];
}
