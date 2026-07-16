import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LevelDetailRecordSection extends StatefulWidget {
  final bool recording;
  final String statusText;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const LevelDetailRecordSection({
    super.key,
    required this.recording,
    required this.statusText,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  State<LevelDetailRecordSection> createState() =>
      _LevelDetailRecordSectionState();
}

class _LevelDetailRecordSectionState extends State<LevelDetailRecordSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.recording) {
      _rippleController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LevelDetailRecordSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.recording != widget.recording) {
      if (widget.recording) {
        _rippleController.repeat();
      } else {
        _rippleController.stop();
        _rippleController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = widget.recording ? 78.0 : 70.0;
    final ringSize = baseSize + 54.0;

    return Column(
      children: [
        Listener(
          onPointerDown: (_) {
            HapticFeedback.mediumImpact();
            setState(() => _isPressed = true);
          },
          onPointerUp: (_) {
            setState(() => _isPressed = false);
            widget.onLongPressEnd();
          },
          onPointerCancel: (_) {
            setState(() => _isPressed = false);
            widget.onLongPressEnd();
          },
          child: GestureDetector(
            onLongPressStart: (_) => widget.onLongPressStart(),
            onLongPressEnd: (_) => widget.onLongPressEnd(),
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.recording)
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        final t = _rippleController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: List.generate(3, (i) {
                            final p = (t + i / 3) % 1.0;
                            final scale =
                                (1.0 + p * 0.95) * (_isPressed ? 0.92 : 1.0);
                            final alpha = (1.0 - p) * 0.22;
                            final c = const Color(
                              0xFF6AD192,
                            ).withValues(alpha: alpha);

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: baseSize,
                                height: baseSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: c, width: 3),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  AnimatedScale(
                    scale: _isPressed ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: baseSize,
                      height: baseSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6AD192), Color(0xFF82E0AA)],
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6AD192,
                            ).withValues(alpha: widget.recording ? 0.75 : 0.4),
                            blurRadius: _isPressed
                                ? 10
                                : (widget.recording ? 22 : 15),
                            offset: Offset(0, _isPressed ? 2 : 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.statusText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D2800),
          ),
        ),
      ],
    );
  }
}
