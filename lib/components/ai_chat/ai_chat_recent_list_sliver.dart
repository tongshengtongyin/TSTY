import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_recent_chat_tile.dart';

class AiChatRecentListSliver extends StatelessWidget {
  final List<AiChatRecentChat> chats;

  const AiChatRecentListSliver({super.key, required this.chats});

  double _getMaxWidth(double screenWidth) {
    if (screenWidth >= 840) {
      return 600;
    } else if (screenWidth >= 600) {
      return 500;
    } else {
      return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = _getMaxWidth(constraints.maxWidth);
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: Column(
                  children: [
                    for (var i = 0; i < chats.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i != chats.length - 1 ? 10 : 0),
                        child: AiChatRecentChatTile(
                          chat: chats[i],
                          showDivider: false,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
