import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class YiTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? right;

  const YiTopBar({super.key, required this.title, this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final yellow = AppTheme.yiYellow.value;

    final primary = scheme.primary;
    final primaryContainer = scheme.primaryContainer;
    final secondary = scheme.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primary,
            Color.lerp(primary, secondary, 0.35) ?? primary,
            primaryContainer,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border(bottom: BorderSide(color: yellow, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _YiBackButton(
            onBack: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 44, height: 44, child: right),
        ],
      ),
    );
  }
}

class _YiBackButton extends StatelessWidget {
  final VoidCallback onBack;

  const _YiBackButton({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: CircleBorder(side: BorderSide(color: yellow, width: 2)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onBack,
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }
}
