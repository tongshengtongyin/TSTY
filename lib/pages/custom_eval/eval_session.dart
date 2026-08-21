import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/yi_top_bar.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_evaluate_card.dart';
import 'package:tsty_app/services/custom_evaluation_flow.dart';
import 'package:tsty_app/services/flutter_tts_service.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/toast_utils.dart';
import 'package:tsty_app/utils/custom_eval_store.dart';
import 'package:tsty_app/utils/yi_recorder.dart';

enum _SessionUiState { idle, ttsLoading, ttsPlaying, recording, evaluating }

class CustomEvalSessionPage extends StatefulWidget {
  final CustomEvalItem item;

  const CustomEvalSessionPage({super.key, required this.item});

  static CustomEvalSessionPage fromArgs(Object? args) {
    if (args is Map) {
      final item = args['item'];
      if (item is CustomEvalItem) {
        return CustomEvalSessionPage(item: item);
      }
    }
    return CustomEvalSessionPage(
      item: CustomEvalItem(
        id: '',
        title: '测评',
        text: '',
        category: 'read_syllable',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  State<CustomEvalSessionPage> createState() => _CustomEvalSessionPageState();
}

class _CustomEvalSessionPageState extends State<CustomEvalSessionPage> {
  late final FlutterTtsService _ttsPlayer;
  late final CustomEvaluationFlow _evaluationFlow;
  final YiRecorderController _recorder = YiRecorderController();
  StreamSubscription<Duration>? _recordDurationSub;

  _SessionUiState _uiState = _SessionUiState.idle;
  String _recordStatus = '';

  bool _longPressActive = false;

  @override
  void initState() {
    super.initState();
    _ttsPlayer = FlutterTtsService();
    _evaluationFlow = CustomEvaluationFlow(
      item: widget.item,
      onEvaluationCompleted: _onEvaluationCompleted,
      onFinish: _onFinish,
      ttsPlayer: _ttsPlayer,
    );
    _recordStatus = _defaultRecordHint;
  }

  String get _defaultRecordHint => '长按录音，朗读 "${_displayText()}"';

  String _displayText() {
    final text = widget.item.text;
    if (text.length > 10) return '${text.substring(0, 10)}...';
    return text;
  }

  String _categoryLabel() {
    switch (widget.item.category) {
      case 'read_syllable':
        return '字';
      case 'read_word':
        return '词';
      case 'read_sentence':
        return '句';
      case 'read_chapter':
        return '篇';
      default:
        return '字';
    }
  }

  Color _categoryColor() {
    switch (widget.item.category) {
      case 'read_syllable':
        return const Color(0xFFE53935);
      case 'read_word':
        return const Color(0xFFFF9800);
      case 'read_sentence':
        return const Color(0xFF43A047);
      case 'read_chapter':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFFE53935);
    }
  }

  void _onEvaluationCompleted() {
    if (!mounted) return;
    setState(() {
      _uiState = _SessionUiState.idle;
      _recordStatus = _defaultRecordHint;
    });
  }

  void _onFinish() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  void _playText() {
    if (_uiState != _SessionUiState.idle) return;
    setState(() => _uiState = _SessionUiState.ttsLoading);

    () async {
      await _ttsPlayer.speak(
        context: context,
        text: widget.item.text,
        onComplete: () {
          if (!mounted) return;
          setState(() => _uiState = _SessionUiState.idle);
        },
      );
      if (!mounted) return;
      if (_uiState == _SessionUiState.ttsLoading) {
        setState(() => _uiState = _SessionUiState.idle);
      }
    }();
  }

  void _startRecording() {
    if (_uiState != _SessionUiState.idle) return;
    _longPressActive = true;

    () async {
      final hasPermission = await _recorder.hasPermission(request: true);
      if (!hasPermission) {
        _longPressActive = false;
        if (!mounted) return;
        ToastUtils.showToast(context, '需要麦克风权限才能录音');
        return;
      }

      if (!_longPressActive || !mounted) return;

      try {
        setState(() {
          _uiState = _SessionUiState.recording;
          _recordStatus = '正在录音中...';
        });

        _recordDurationSub?.cancel();
        await _recorder.start(
          config: const YiRecorderConfig(
            format: YiRecorderFormat.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        _recordDurationSub = _recorder.durationStream.listen(
          (duration) {
            if (!mounted) return;
            setState(() {
              _recordStatus = '录音中 ${duration.inSeconds}s';
            });
          },
          onError: (_) {
            if (!mounted) return;
            setState(() {
              _uiState = _SessionUiState.idle;
              _recordStatus = _defaultRecordHint;
            });
          },
        );
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _uiState = _SessionUiState.idle;
          _recordStatus = _defaultRecordHint;
        });
        ToastUtils.showToast(context, '录音开始失败');
      }
    }();
  }

  Future<void> _stopRecording() async {
    _longPressActive = false;
    if (_uiState != _SessionUiState.recording) return;

    _recordDurationSub?.cancel();
    _recordDurationSub = null;

    YiRecorderResult? recordResult;
    try {
      recordResult = await _recorder.stop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uiState = _SessionUiState.idle;
        _recordStatus = _defaultRecordHint;
      });
      ToastUtils.showToast(context, '录音结束失败');
      return;
    }

    setState(() {
      _uiState = _SessionUiState.evaluating;
      _recordStatus = '正在测评...';
    });

    if (recordResult == null) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _uiState = _SessionUiState.idle;
        _recordStatus = _defaultRecordHint;
      });
      return;
    }

    if (kIsWeb) {
      if (!mounted) return;
      ToastUtils.showToast(context, 'Web 暂不支持语音测评');
      setState(() {
        _uiState = _SessionUiState.idle;
        _recordStatus = _defaultRecordHint;
      });
      return;
    }

    if (!mounted) return;
    await _evaluationFlow.evaluateAndShowDialog(
      context: context,
      recordResult: recordResult,
    );
    _onEvaluationCompleted();
  }

  @override
  void dispose() {
    _recordDurationSub?.cancel();
    _recordDurationSub = null;
    _recorder.dispose();
    _ttsPlayer.dispose();
    super.dispose();
  }

  Widget _buildListenButton(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    switch (_uiState) {
      case _SessionUiState.ttsLoading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: red.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '请稍等...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      case _SessionUiState.ttsPlaying:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded, size: 20, color: red),
              const SizedBox(width: 8),
              Text(
                '注意听...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: red,
                ),
              ),
            ],
          ),
        );
      default:
        final enabled = _uiState == _SessionUiState.idle;
        return TextButton.icon(
          onPressed: enabled ? _playText : null,
          icon: const Icon(Icons.volume_up_rounded, size: 20),
          label: const Text(
            '听一听',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: TextButton.styleFrom(
            foregroundColor: enabled
                ? const Color(0xFF3D2800)
                : Colors.grey.withValues(alpha: 0.4),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final catColor = _categoryColor();
    final isRecording = _uiState == _SessionUiState.recording;
    final recordCardLocked = _uiState != _SessionUiState.idle && !isRecording;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/learn_background.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFFF5E6).withValues(alpha: 0.65),
            ),
          ),

          Column(
            children: [
              YiTopBar(title: widget.item.title),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: yellow, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: catColor.withValues(alpha: 0.4),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      _categoryLabel(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: catColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Text(
                                    widget.item.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: widget.item.text.length > 20
                                          ? 22
                                          : 36,
                                      fontWeight: FontWeight.w900,
                                      height: 1.5,
                                      color: const Color(0xFF3D2800),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  _buildListenButton(context),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            AnimatedOpacity(
                              opacity: recordCardLocked ? 0.45 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AbsorbPointer(
                                absorbing: recordCardLocked,
                                child: LevelDetailEvaluateCard(
                                  recording: isRecording,
                                  statusText: _recordStatus,
                                  onLongPressStart: _startRecording,
                                  onLongPressEnd: _stopRecording,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
