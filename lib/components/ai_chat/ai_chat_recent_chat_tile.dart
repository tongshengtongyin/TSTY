import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';

class AiChatRecentChatTile extends StatelessWidget {
  final AiChatRecentChat chat;
  final bool showDivider;

  const AiChatRecentChatTile({
    super.key,
    required this.chat,
    required this.showDivider,
  });

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final diff = today.difference(date).inDays;

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (diff == 0) {
      return '今天 $timeStr';
    } else if (diff == 1) {
      return '昨天 $timeStr';
    } else if (diff < 7) {
      return '$diff天前 $timeStr';
    } else {
      final month = timestamp.month.toString().padLeft(2, '0');
      final day = timestamp.day.toString().padLeft(2, '0');
      return '$month-$day $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _formatTime(chat.timestamp),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
