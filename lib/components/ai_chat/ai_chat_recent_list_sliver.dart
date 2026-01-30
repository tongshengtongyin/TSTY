import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_recent_chat_tile.dart';

class AiChatRecentListSliver extends StatelessWidget {
  final List<AiChatRecentChat> chats;
  final ValueChanged<AiChatRecentChat> onTap;

  const AiChatRecentListSliver({
    super.key,
    required this.chats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < chats.length; i++)
                AiChatRecentChatTile(
                  chat: chats[i],
                  showDivider: i != chats.length - 1,
                  onTap: () => onTap(chats[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
