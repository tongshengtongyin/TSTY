import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class EditProfileFormGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const EditProfileFormGroup({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: yellow, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3D2800),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
