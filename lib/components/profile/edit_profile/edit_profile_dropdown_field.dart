import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class EditProfileDropdownOption {
  final String label;
  final String value;

  const EditProfileDropdownOption({required this.label, required this.value});
}

class EditProfileDropdownField extends StatelessWidget {
  final String? value;
  final String placeholder;
  final List<EditProfileDropdownOption> options;
  final ValueChanged<String?> onChanged;

  const EditProfileDropdownField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    final decoration = InputDecoration(
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
    );

    return InputDecorator(
      decoration: decoration,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: Colors.white,
          hint: Text(
            placeholder,
            style: const TextStyle(color: Color(0xFF999999)),
          ),
          style: const TextStyle(
            color: Color(0xFF3D2800),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          items: options
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o.value,
                  child: Text(o.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
