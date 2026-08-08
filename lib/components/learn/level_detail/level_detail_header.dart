import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class LevelDetailHeader extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final VoidCallback? onBack;

  const LevelDetailHeader({
    super.key,
    required this.title,
    required this.current,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Material(
      color: Colors.white,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Color(0xFFCC0000),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$current/$total',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
