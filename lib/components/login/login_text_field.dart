import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: Color(0xFF3D2800),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        isDense: true,
        prefixIcon: Icon(icon, color: const Color(0xFF3D2800)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.78),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: yellow.withValues(alpha: 0.75),
            width: 1.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: yellow, width: 2),
        ),
      ),
    );
  }
}
