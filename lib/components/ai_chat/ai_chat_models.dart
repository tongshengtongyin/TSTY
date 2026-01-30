import 'package:flutter/material.dart';

class AiChatSceneItem {
  final String id;
  final String name;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String difficulty;
  final bool locked;

  const AiChatSceneItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.difficulty,
    required this.locked,
  });
}

class AiChatRecentChat {
  final String id;
  final String title;
  final String meta;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const AiChatRecentChat({
    required this.id,
    required this.title,
    required this.meta,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
