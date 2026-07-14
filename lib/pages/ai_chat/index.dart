import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_header_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_recent_list_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_scene_grid_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_section_header_sliver.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_teacher_intro_sliver.dart';
import 'package:tsty_app/components/common/select_character_dialog.dart';
import 'package:tsty_app/services/parental_control.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  bool _parentalBlocked = false;
  int _selectedCharacter = 0;

  final List<AiChatSceneItem> _scenes = const [
    AiChatSceneItem(
      id: 'greeting',
      name: '通用对话',
      desc: '自由交流、畅所欲言',
      icon: Icons.sentiment_satisfied_alt,
      iconColor: Color(0xFF1565C0),
      iconBg: Color(0xFFE3F2FD),
      difficulty: '⭐',
      locked: false,
    ),
    AiChatSceneItem(
      id: 'toy-sharing',
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

  List<AiChatRecentChat> _recentChats = [];

  @override
  void initState() {
    super.initState();
    _refreshParentalControl();
    _loadCharacter();
    _loadRecentChats();
  }

  Future<void> _loadCharacter() async {
    final selected = (await UserPrefs.getSelectedCharacter()) ?? 0;
    if (!mounted) return;
    setState(() => _selectedCharacter = selected);
  }

  Future<void> _refreshParentalControl() async {
    final result = await ParentalControlGuard.checkCanStartAction();
    if (!mounted) return;
    setState(() => _parentalBlocked = !result.allowed);
  }
  Future<void> _loadRecentChats() async {
    final list = await UserPrefs.getRecentChats();
    if (!mounted) return;
    setState(() => _recentChats = list);
  }

  void _onSceneTap(AiChatSceneItem scene) {
    if (scene.locked) {
      ToastUtils.showToast(context, '请先完成更多关卡解锁此场景');
      return;
    }

    () async {
      final guard = await ParentalControlGuard.checkCanStartAction();
      if (!guard.allowed) {
        if (!mounted) return;
        await showParentalControlBlockedSheet(context: context, result: guard);
        return;
      }

      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        '/ai-chat/detail',
        arguments: {'sceneId': scene.id, 'sceneName': scene.name},
      );
      _loadRecentChats();
    }();
  }

  Future<void> _onTeacherTap() async {
    final initialValue = await UserPrefs.getSelectedCharacter();
    if (!mounted) return;

    final selected = await showSelectCharacterDialog(
      context: context,
      initialValue: initialValue,
    );
    if (selected == null || !mounted) return;

    await UserPrefs.setSelectedCharacter(selected);
    if (!mounted) return;

    setState(() => _selectedCharacter = selected);

    ToastUtils.showToast(context, selected == 0 ? '已切换为 阿依莫' : '已切换为 阿牛惹');
  }

  @override
  Widget build(BuildContext context) {
    final warmRed = const Color(0xFFC00003);

    final teacherAvatar = _selectedCharacter == 0
        ? 'lib/assets/ayimo.webp'
        : 'lib/assets/aniure.webp';
    final teacherName = _selectedCharacter == 0 ? '阿依莫老师' : '阿牛惹老师';
    final teacherDesc = _selectedCharacter == 0
        ? '温柔耐心，陪你练习普通话'
        : '热情开朗，陪你练习普通话';

    return CustomScrollView(
      slivers: [
        const AiChatHeaderSliver(),
        AiChatTeacherIntroSliver(
          avatarAsset: teacherAvatar,
          name: teacherName,
          desc: teacherDesc,
          onTap: _onTeacherTap,
        ),
        AiChatSectionHeaderSliver(
          icon: Icons.apps,
          iconColor: warmRed,
          title: '选择对话场景',
        ),
        AiChatSceneGridSliver(
          scenes: _scenes,
          blocked: _parentalBlocked,
          onSceneTap: _onSceneTap,
        ),
        AiChatSectionHeaderSliver(
          icon: Icons.history,
          iconColor: warmRed,
          title: '最近聊天',
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        AiChatRecentListSliver(chats: _recentChats.take(5).toList()),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}
