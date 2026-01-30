import 'package:flutter/material.dart';

class AiChatSectionHeaderSliver extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final EdgeInsetsGeometry padding;

  const AiChatSectionHeaderSliver({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D2800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
