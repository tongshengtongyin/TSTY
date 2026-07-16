import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String text;

  const SettingsSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFFCC0000),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
