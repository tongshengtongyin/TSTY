import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatTopBar extends StatelessWidget {
  final String title;
  final String timeText;
  final VoidCallback onExit;

  const AiChatTopBar({
    super.key,
    required this.title,
    required this.timeText,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: yellow, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Material(
                  color: red,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onExit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '结束',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, color: red, size: 18),
                const SizedBox(width: 8),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D2800),
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
