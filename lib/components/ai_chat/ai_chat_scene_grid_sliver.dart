import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_scene_card.dart';

class AiChatSceneGridSliver extends StatelessWidget {
  final List<AiChatSceneItem> scenes;
  final bool blocked;
  final ValueChanged<AiChatSceneItem> onSceneTap;

  const AiChatSceneGridSliver({
    super.key,
    required this.scenes,
    required this.blocked,
    required this.onSceneTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final s = scenes[index];
          return AiChatSceneCard(
            scene: s,
            blocked: blocked,
            onTap: () => onSceneTap(s),
          );
        }, childCount: scenes.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
        ),
      ),
    );
  }
}
