import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class ParentEntryTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ParentEntryTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: yellow, width: 3)),
      ),
      child: Row(
        children: [
          Material(
            color: const Color(0xFFFFF5E6),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 26,
                  color: Color(0xFF3D2800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D2800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }
}
