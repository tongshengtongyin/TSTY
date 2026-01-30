import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_header_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_recent_list_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_scene_grid_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_section_header_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_teacher_intro_sliver.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<AiChatSceneItem> _scenes = const [
    AiChatSceneItem(
      id: 'greeting',
      name: '日常问候',
      desc: '打招呼、问好',
      icon: Icons.sentiment_satisfied_alt,
      iconColor: Color(0xFF1565C0),
      iconBg: Color(0xFFE3F2FD),
      difficulty: '⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'toys',
      name: '玩具分享',
      desc: '聊聊喜欢的玩具',
      icon: Icons.extension,
      iconColor: Color(0xFF2E7D32),
      iconBg: Color(0xFFE8F5E9),
      difficulty: '⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'food',
      name: '食物认知',
      desc: '说说爱吃的食物',
      icon: Icons.restaurant,
      iconColor: Color(0xFFE65100),
      iconBg: Color(0xFFFFF3E0),
      difficulty: '⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'weather',
      name: '天气交流',
      desc: '聊聊今天的天气',
      icon: Icons.wb_sunny,
      iconColor: Color(0xFFF9A825),
      iconBg: Color(0xFFFFFDE7),
      difficulty: '⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'family',
      name: '家庭成员',
      desc: '介绍家人',
      icon: Icons.favorite,
      iconColor: Color(0xFFC2185B),
      iconBg: Color(0xFFFCE4EC),
      difficulty: '⭐⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'kindergarten',
      name: '幼儿园生活',
      desc: '说说在幼儿园的事',
      icon: Icons.home,
      iconColor: Color(0xFF7B1FA2),
      iconBg: Color(0xFFF3E5F5),
      difficulty: '⭐⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'festival',
      name: '节日庆祝',
      desc: '聊聊过节的事',
      icon: Icons.card_giftcard,
      iconColor: Color(0xFFC62828),
      iconBg: Color(0xFFFFEBEE),
      difficulty: '⭐⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'yi-culture',
      name: '彝族文化',
      desc: '说说彝族的故事',
      icon: Icons.local_fire_department,
      iconColor: Color(0xFFC00003),
      iconBg: Color(0xFFF0C000),
      difficulty: '⭐⭐⭐',
      locked: false,
    ),
  ];

  final List<AiChatRecentChat> _recentChats = const [
    AiChatRecentChat(
      id: '1',
      title: '玩具分享',
      meta: '2分钟前 · 聊了5句',
      icon: Icons.extension,
      iconColor: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
    AiChatRecentChat(
      id: '2',
      title: '日常问候',
      meta: '昨天 10:30 · 聊了8句',
      icon: Icons.sentiment_satisfied_alt,
      iconColor: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
    ),
  ];

  void _onSceneTap(AiChatSceneItem scene) {
    if (scene.locked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先完成更多关卡解锁此场景')));
      return;
    }

    Navigator.of(context).pushNamed(
      '/ai-chat/detail',
      arguments: {'sceneId': scene.id, 'sceneName': scene.name},
    );
  }

  void _onRecentTap(AiChatRecentChat item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('查看${item.title}历史记录')));
  }

  @override
  Widget build(BuildContext context) {
    final deepRed = const Color(0xFF8B0002);
    final warmRed = const Color(0xFFC00003);
    final warmYellow = const Color(0xFFFFD666);

    return CustomScrollView(
      slivers: [
        const AiChatHeaderSliver(),
        const AiChatTeacherIntroSliver(
          avatarAsset: 'lib/assets/ayimo.webp',
          name: '阿依莫老师',
          desc: '温柔耐心，陪你练习普通话',
        ),
        AiChatSectionHeaderSliver(
          icon: Icons.apps,
          iconColor: warmRed,
          title: '选择对话场景',
        ),
        AiChatSceneGridSliver(scenes: _scenes, onSceneTap: _onSceneTap),
        AiChatSectionHeaderSliver(
          icon: Icons.history,
          iconColor: warmRed,
          title: '最近聊天',
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        AiChatRecentListSliver(chats: _recentChats, onTap: _onRecentTap),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}
