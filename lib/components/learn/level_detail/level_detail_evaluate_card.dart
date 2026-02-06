import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiRadialBubble.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_record_section.dart';
import 'package:tsty_app/style/app_theme.dart';

class LevelDetailEvaluateCard extends StatelessWidget {
  final bool recording;
  final String statusText;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const LevelDetailEvaluateCard({
    super.key,
    required this.recording,
    required this.statusText,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;
    const radius = 18.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: yellow, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -70,
              top: -60,
              child: YiRadialBubble(
                size: 160,
                color: yellow.withValues(alpha: 0.22),
                highlightAlignment: const Alignment(0.4, 0.4),
              ),
            ),
            Positioned(
              right: -60,
              bottom: -70,
              child: YiRadialBubble(
                size: 170,
                color: red.withValues(alpha: 0.14),
                highlightAlignment: const Alignment(-0.4, -0.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '测评',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: LevelDetailRecordSection(
                      recording: recording,
                      statusText: statusText,
                      onLongPressStart: onLongPressStart,
                      onLongPressEnd: onLongPressEnd,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
