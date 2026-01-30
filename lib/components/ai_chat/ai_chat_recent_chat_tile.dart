import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';

class AiChatRecentChatTile extends StatelessWidget {
  final AiChatRecentChat chat;
  final bool showDivider;
  final VoidCallback onTap;

  const AiChatRecentChatTile({
    super.key,
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
                decoration: BoxDecoration(
                  color: chat.bgColor,
                  shape: BoxShape.circle,
                ),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
