import 'package:flutter/material.dart';

class EditProfileSubmitButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onPressed;

  const EditProfileSubmitButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: loading ? null : onPressed,
      child: SizedBox(
        height: 44,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
