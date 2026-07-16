import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatSceneCard extends StatelessWidget {
  final AiChatSceneItem scene;
  final bool blocked;
  final VoidCallback onTap;

  const AiChatSceneCard({
    super.key,
    required this.scene,
    required this.blocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shouldGrey = blocked && !scene.locked;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Opacity(
          opacity: shouldGrey ? 0.55 : 1,
          child: ColorFiltered(
            colorFilter: shouldGrey
                ? const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
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
                    color: Colors.black.withValues(alpha: 0.06),
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
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
        ),
      ),
    );
  }
}
