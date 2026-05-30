// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ToastUtils {
  static void showToast(BuildContext context, String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        );

    final mediaQuery = MediaQuery.of(context);
    final maxWidth = (mediaQuery.size.width - 32).clamp(180.0, 360.0);

    final painter = TextPainter(
      text: TextSpan(text: msg, style: textStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth - 36);

    final width = (painter.width + 36).clamp(140.0, maxWidth);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: width,
        elevation: 10,
        backgroundColor: colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
