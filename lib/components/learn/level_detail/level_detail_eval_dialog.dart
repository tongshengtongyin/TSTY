import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class LevelEvalPoint {
  final bool success;
  final String text;

  const LevelEvalPoint({required this.success, required this.text});
}

class LevelDetailEvalDialog extends StatelessWidget {
  final int score;
  final String accuracyText;
  final int stars;
  final int flowers;
  final List<LevelEvalPoint> points;
  final String learningTip;
  final VoidCallback onTryAgain;
  final VoidCallback? onNext;

  const LevelDetailEvalDialog({
    super.key,
    required this.score,
    required this.accuracyText,
    required this.stars,
    required this.flowers,
    required this.points,
    required this.learningTip,
    required this.onTryAgain,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogMaxHeight = (screenHeight - 48).clamp(0.0, double.infinity);
    final dialogMinHeight = (screenHeight * 0.78).clamp(460.0, 640.0);
    const successColor = Color(0xFF6AD192);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          minHeight: dialogMinHeight,
          maxHeight: dialogMaxHeight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFDF9), Color(0xFFFFF2E6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 66),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [red, red.withValues(alpha: 0.88)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '测评结果',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                accuracyText,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -42),
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.3),
                          radius: 0.95,
                          colors: [
                            Colors.white,
                            const Color(0xFFFFF1D1),
                            yellow.withValues(alpha: 0.70),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                color: red,
                              ),
                            ),
                            Text(
                              '分',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: red.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final earned = i < stars;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                size: 30,
                                color: earned
                                    ? yellow
                                    : const Color(0xFFDDDDDD),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: points.map((p) {
                            final bg = p.success
                                ? successColor.withValues(alpha: 0.14)
                                : const Color(
                                    0xFFFFC107,
                                  ).withValues(alpha: 0.16);
                            final border = p.success
                                ? successColor.withValues(alpha: 0.40)
                                : const Color(
                                    0xFFFFC107,
                                  ).withValues(alpha: 0.45);
                            final icon = p.success
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded;
                            final fg = p.success
                                ? successColor
                                : const Color(0xFFFFA000);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: border, width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 18, color: fg),
                                  const SizedBox(width: 8),
                                  Text(
                                    p.text,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3D2800),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        if (flowers > 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: yellow.withValues(alpha: 0.55),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_florist,
                                  color: Color(0xFFCC0000),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '获得了$flowers朵小红花',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF3D2800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: yellow.withValues(alpha: 0.55),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: yellow.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_rounded,
                                  size: 20,
                                  color: Color(0xFFF0C000),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  learningTip,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3D2800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(64),
                                  side: BorderSide(
                                    color: red.withValues(alpha: 0.30),
                                    width: 1.5,
                                  ),
                                  foregroundColor: red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.only(
                                    top: 14,
                                    bottom: 14,
                                  ),
                                ),
                                onPressed: onTryAgain,
                                child: const Text(
                                  '再试一次',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(64),
                                  backgroundColor: red,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFE0E0E0),
                                  disabledForegroundColor:
                                      const Color(0xFF8A8A8A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.only(
                                    top: 14,
                                    bottom: 14,
                                  ),
                                ),
                                onPressed: onNext,
                                child: const Text(
                                  '下一关',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
