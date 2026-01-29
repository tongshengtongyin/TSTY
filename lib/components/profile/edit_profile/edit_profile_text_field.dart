import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class EditProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;

  const EditProfileTextField({
    super.key,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFF3D2800),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: yellow, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: yellow, width: 2),
        ),
      ),
    );
  }
}
