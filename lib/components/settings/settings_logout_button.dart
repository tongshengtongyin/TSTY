import 'package:flutter/material.dart';

class SettingsLogoutButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const SettingsLogoutButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFCC0000),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: loading ? null : onPressed,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!loading)
              const Icon(Icons.logout, size: 30, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              loading ? '退出中...' : '退出登录',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
