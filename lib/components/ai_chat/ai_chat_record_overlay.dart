import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/style/app_theme.dart';

class AiChatRecordOverlay extends StatefulWidget {
  final bool isRecording;
  final bool isDisabled;
  final int recordSeconds;
  final double? amplitude;
  final String statusText;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;

  const AiChatRecordOverlay({
    super.key,
    required this.isRecording,
    required this.isDisabled,
    required this.recordSeconds,
    this.amplitude,
    this.statusText = '',
    required this.onRecordStart,
    required this.onRecordEnd,
  });

  @override
  State<AiChatRecordOverlay> createState() => _AiChatRecordOverlayState();
}

class _AiChatRecordOverlayState extends State<AiChatRecordOverlay> {
  final _rnd = Random();
  Timer? _waveTimer;
  bool _isPressed = false;

  late List<_WaveBar> _bars;

  @override
  void initState() {
    super.initState();
    _bars = List.generate(
      7,
      (_) => const _WaveBar(height: 18, color: Color(0xFFC00003)),
    );

    if (widget.isRecording) {
      if (widget.amplitude == null) {
        _startWave();
      } else {
        _setBarsByAmplitude(widget.amplitude!);
      }
    }
  }

  @override
  void didUpdateWidget(covariant AiChatRecordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        if (widget.amplitude == null) {
          _startWave();
        } else {
          _stopWave();
          _setBarsByAmplitude(widget.amplitude!);
        }
      } else {
        _stopWave();
      }
    }

    if (widget.isRecording && widget.amplitude != null) {
      if (oldWidget.amplitude != widget.amplitude) {
        _stopWave();
        _setBarsByAmplitude(widget.amplitude!);
      }
    }
  }

  void _setBarsByAmplitude(double a) {
    final amp = a.clamp(0.0, 1.0);
    const factors = [0.55, 0.78, 1.0, 0.70, 0.92, 0.66, 0.48];
    setState(() {
      _bars = List.generate(factors.length, (i) {
        final h = 10 + amp * 42 * factors[i];
        Color c = const Color(0xFFC00003);
        if (h > 35) {
          c = const Color(0xFFFF5722);
        } else if (h > 25) {
          c = const Color(0xFFFFC107);
        }
        return _WaveBar(height: h, color: c);
      });
    });
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
                bottom: 140,
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
              bottom: 26,
              child: Center(
                child: Listener(
                  onPointerDown: (_) {
                    if (widget.isDisabled) return;
                    HapticFeedback.mediumImpact();
                    setState(() => _isPressed = true);
                  },
                  onPointerUp: (_) {
                    setState(() => _isPressed = false);
                    widget.onRecordEnd();
                  },
                  onPointerCancel: (_) {
                    setState(() => _isPressed = false);
                    widget.onRecordEnd();
                  },
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
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
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
                              blurRadius: _isPressed ? 12 : 18,
                              offset: Offset(0, _isPressed ? 4 : 10),
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
                              widget.statusText.isNotEmpty
                                  ? widget.statusText
                                  : (widget.isRecording ? '松开发送' : '长按说话~'),
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
