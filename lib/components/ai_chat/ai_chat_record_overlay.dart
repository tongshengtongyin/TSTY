import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatRecordOverlay extends StatefulWidget {
  final bool isRecording;
  final bool isDisabled;
  final int recordSeconds;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;

  const AiChatRecordOverlay({
    super.key,
    required this.isRecording,
    required this.isDisabled,
    required this.recordSeconds,
    required this.onRecordStart,
    required this.onRecordEnd,
  });

  @override
  State<AiChatRecordOverlay> createState() => _AiChatRecordOverlayState();
}

class _AiChatRecordOverlayState extends State<AiChatRecordOverlay> {
  final _rnd = Random();
  Timer? _waveTimer;

  late List<_WaveBar> _bars;

  @override
  void initState() {
    super.initState();
    _bars = List.generate(
      7,
      (_) => const _WaveBar(height: 18, color: Color(0xFFC00003)),
    );

    if (widget.isRecording) {
      _startWave();
    }
  }

  @override
  void didUpdateWidget(covariant AiChatRecordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        _startWave();
      } else {
        _stopWave();
      }
    }
  }

  void _startWave() {
    _stopWave();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _bars = _bars.map((bar) {
          final h = 10 + _rnd.nextDouble() * 40;
          Color c = const Color(0xFFC00003);
          if (h > 35) {
            c = const Color(0xFFFF5722);
          } else if (h > 25) {
            c = const Color(0xFFFFC107);
          }
          return _WaveBar(height: h, color: c);
        }).toList();
      });
    });
  }

  void _stopWave() {
    _waveTimer?.cancel();
    _waveTimer = null;
  }

  @override
  void dispose() {
    _stopWave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            if (widget.isRecording)
              Positioned(
                left: 0,
                right: 0,
                bottom: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _bars
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 6,
                            height: b.height,
                            decoration: BoxDecoration(
                              color: b.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (widget.isRecording)
              Positioned(
                left: 0,
                right: 0,
                bottom: 190,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D2800),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${widget.recordSeconds}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 86,
              child: Center(
                child: Listener(
                  onPointerUp: (_) => widget.onRecordEnd(),
                  onPointerCancel: (_) => widget.onRecordEnd(),
                  child: GestureDetector(
                    onLongPressStart: (_) {
                      if (widget.isDisabled) return;
                      widget.onRecordStart();
                    },
                    onLongPressEnd: (_) {
                      widget.onRecordEnd();
                    },
                    onLongPressCancel: () {
                      widget.onRecordEnd();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: widget.isDisabled
                            ? const Color(0xFFCCCCCC)
                            : (widget.isRecording
                                ? const Color(0xFFAA0000)
                                : red),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: yellow,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isRecording
                            ? Icons.radio_button_checked
                            : Icons.lightbulb_outline,
                        size: 18,
                        color: widget.isRecording
                            ? red
                            : const Color(0xFF3D2800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isRecording ? '松开发送' : '长按说话~',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3D2800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBar {
  final double height;
  final Color color;

  const _WaveBar({required this.height, required this.color});
}
