import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<_SceneItem> _scenes = const [
    _SceneItem(
      id: 'greeting',
      name: '日常问候',
      desc: '打招呼、问好',
      icon: Icons.sentiment_satisfied_alt,
      iconColor: Color(0xFF1565C0),
      iconBg: Color(0xFFE3F2FD),
      difficulty: '⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'toys',
      name: '玩具分享',
      desc: '聊聊喜欢的玩具',
      icon: Icons.extension,
      iconColor: Color(0xFF2E7D32),
      iconBg: Color(0xFFE8F5E9),
      difficulty: '⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'food',
      name: '食物认知',
      desc: '说说爱吃的食物',
      icon: Icons.restaurant,
      iconColor: Color(0xFFE65100),
      iconBg: Color(0xFFFFF3E0),
      difficulty: '⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'weather',
      name: '天气交流',
      desc: '聊聊今天的天气',
      icon: Icons.wb_sunny,
      iconColor: Color(0xFFF9A825),
      iconBg: Color(0xFFFFFDE7),
      difficulty: '⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'family',
      name: '家庭成员',
      desc: '介绍家人',
      icon: Icons.favorite,
      iconColor: Color(0xFFC2185B),
      iconBg: Color(0xFFFCE4EC),
      difficulty: '⭐⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'kindergarten',
      name: '幼儿园生活',
      desc: '说说在幼儿园的事',
      icon: Icons.home,
      iconColor: Color(0xFF7B1FA2),
      iconBg: Color(0xFFF3E5F5),
      difficulty: '⭐⭐',
      locked: false,
    ),
    _SceneItem(
      id: 'festival',
      name: '节日庆祝',
      desc: '聊聊过节的事',
      icon: Icons.card_giftcard,
      iconColor: Color(0xFFC62828),
      iconBg: Color(0xFFFFEBEE),
      difficulty: '⭐⭐',
      locked: false,
    ),
    _SceneItem(
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

  final List<_RecentChat> _recentChats = const [
    _RecentChat(
      id: '1',
      title: '玩具分享',
      meta: '2分钟前 · 聊了5句',
      icon: Icons.extension,
      iconColor: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
    _RecentChat(
      id: '2',
      title: '日常问候',
      meta: '昨天 10:30 · 聊了8句',
      icon: Icons.sentiment_satisfied_alt,
      iconColor: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
    ),
  ];

  void _onSceneTap(_SceneItem scene) {
    if (scene.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完成更多关卡解锁此场景')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('进入场景：${scene.name}')),
    );
  }

  void _onRecentTap(_RecentChat item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看${item.title}历史记录')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;
    final deepRed = const Color(0xFF8B0002);
    final warmRed = const Color(0xFFC00003);
    final warmYellow = const Color(0xFFFFD666);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [warmRed, deepRed],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: 14,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'AI 小老师',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '选择一个场景，和小老师聊天吧～',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [yellow, warmYellow, yellow],
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF2)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: yellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: yellow, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/girl.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '阿依莫老师',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3D2800),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '温柔耐心，陪你练习普通话',
                          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(Icons.apps, color: warmRed, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '选择对话场景',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D2800),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final s = _scenes[index];
                return _SceneCard(scene: s, onTap: () => _onSceneTap(s));
              },
              childCount: _scenes.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(Icons.history, color: warmRed, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '最近聊天',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D2800),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _recentChats.length; i++)
                    _RecentChatTile(
                      chat: _recentChats[i],
                      showDivider: i != _recentChats.length - 1,
                      onTap: () => _onRecentTap(_recentChats[i]),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

class _SceneItem {
  final String id;
  final String name;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String difficulty;
  final bool locked;

  const _SceneItem({
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

class _RecentChat {
  final String id;
  final String title;
  final String meta;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _RecentChat({
    required this.id,
    required this.title,
    required this.meta,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class _SceneCard extends StatelessWidget {
  final _SceneItem scene;
  final VoidCallback onTap;

  const _SceneCard({required this.scene, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF2)],
            ),
            border: Border.all(color: const Color(0x00FFFFFF), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scene.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(scene.icon, color: scene.iconColor, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                scene.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D2800),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scene.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 8),
              Text(
                scene.difficulty,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.yiYellow.value,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentChatTile extends StatelessWidget {
  final _RecentChat chat;
  final bool showDivider;
  final VoidCallback onTap;

  const _RecentChatTile({
    required this.chat,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF2)],
            ),
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: chat.bgColor, shape: BoxShape.circle),
                child: Icon(chat.icon, color: chat.iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chat.meta,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
