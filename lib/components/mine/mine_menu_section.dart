import 'package:flutter/material.dart';
import 'package:tsty_app/components/mine/models.dart';
import 'package:tsty_app/style/app_theme.dart';

class MineMenuSection extends StatelessWidget {
  final ValueChanged<MineMenuAction>? onTap;

  const MineMenuSection({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person,
            iconBg: yellow,
            iconColor: red,
            title: '修改个人信息',
            borderStyle: _MenuBorderStyle.dashedYellow,
            right: const Icon(
              Icons.chevron_right,
              color: Color(0xFF3D2800),
              size: 28,
            ),
            onTap: () => onTap?.call(MineMenuAction.editProfile),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.admin_panel_settings,
            iconBg: red,
            iconColor: Colors.white,
            title: '家长入口',
            borderStyle: _MenuBorderStyle.solidRed,
            right: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '查看学习报告',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Color(0xFF3D2800), size: 28),
              ],
            ),
            onTap: () => onTap?.call(MineMenuAction.parentEntry),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.settings,
            iconBg: yellow,
            iconColor: red,
            title: '设置',
            borderStyle: _MenuBorderStyle.dashedYellow,
            right: const Icon(
              Icons.chevron_right,
              color: Color(0xFF3D2800),
              size: 28,
            ),
            onTap: () => onTap?.call(MineMenuAction.settings),
          ),
        ],
      ),
    );
  }
}

enum _MenuBorderStyle { dashedYellow, solidRed }

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final _MenuBorderStyle borderStyle;
  final Widget right;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.borderStyle,
    required this.right,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    final radius = BorderRadius.circular(16);
    final bg = borderStyle == _MenuBorderStyle.solidRed
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.85);

    return CustomPaint(
      painter: borderStyle == _MenuBorderStyle.dashedYellow
          ? _DashedRoundRectBorderPainter(
              color: yellow,
              strokeWidth: 2,
              radius: 16,
              dashWidth: 8,
              dashSpace: 5,
            )
          : null,
      foregroundPainter: borderStyle == _MenuBorderStyle.solidRed
          ? _SolidRoundRectBorderPainter(color: red, strokeWidth: 2, radius: 16)
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                  ],
                ),
                right,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundRectBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const _DashedRoundRectBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundRectBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

class _SolidRoundRectBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  const _SolidRoundRectBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SolidRoundRectBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
