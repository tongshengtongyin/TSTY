import 'package:flutter/material.dart';

class AiChatTeacherArea extends StatelessWidget {
  final String teacherAsset;
  final String statusText;
  final double topOffset;

  const AiChatTeacherArea({
    super.key,
    required this.teacherAsset,
    required this.statusText,
    this.topOffset = -140,
  });

  @override
  Widget build(BuildContext context) {
    final showStatus = statusText.trim().isNotEmpty;

    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: Offset(0, topOffset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                teacherAsset,
                width: 320,
                height: 480,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: Center(
                  child: IgnorePointer(
                    ignoring: !showStatus,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: showStatus ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          showStatus ? statusText : '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
