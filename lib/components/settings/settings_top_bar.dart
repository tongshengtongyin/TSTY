import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class SettingsTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SettingsTopBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: yellow, width: 3)),
      ),
      child: Row(
        children: [
          _SettingsBackButton(onBack: onBack, brown: const Color(0xFF3D2800)),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF3D2800),
              ),
            ),
          ),
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }
}

class _SettingsBackButton extends StatelessWidget {
  final Color brown;
  final VoidCallback? onBack;

  const _SettingsBackButton({required this.brown, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: const Color(0xFFFFF5E6),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Icon(Icons.arrow_back, color: brown),
        ),
      ),
    );
  }
}
