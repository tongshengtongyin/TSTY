import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatHeaderSliver extends StatelessWidget {
  const AiChatHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final warmRed = const Color(0xFFC00003);

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: yellow,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: warmRed,
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 14),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'AI 小老师',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
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
      ),
    );
  }
}
