import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/api/learn.dart';
import 'package:tsty_app/api/ise.dart';
import 'package:tsty_app/components/common/YiSun.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_card.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_evaluate_card.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_eval_dialog.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_header.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/routes/route_observer.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/services/learning_duration_tracker.dart';
import 'package:tsty_app/services/level_evaluation_flow.dart';
import 'package:tsty_app/services/level_audio_player.dart';
import 'package:tsty_app/viewmodels/level_detail_view_model.dart';
import 'package:tsty_app/utils/yi_recorder.dart';
import 'package:tsty_app/viewmodels/learn.dart';


class LevelDetailPage extends StatefulWidget {
  final int? levelIndex;
  final int? totalLevels;
  final String? unitId;
  final String? lessonId;
  final String? levelId;
  final LevelContent? levelContent;
  final List<String>? levelIds;

  const LevelDetailPage({
    super.key,
    this.levelIndex,
    this.totalLevels,
    this.unitId,
    this.lessonId,
    this.levelId,
    this.levelContent,
    this.levelIds,
  });

  static LevelDetailPage fromArgs(Object? args) {
    if (args is Map) {
      final levelIndex = args['levelIndex'];
      final totalLevels = args['totalLevels'];
      final unitId = args['unitId'];
      final lessonId = args['lessonId'];
      final levelId = args['levelId'];
      final levelContent = args['levelContent'];
      final levelIds = args['levelIds'];

      final parsedLevelIds = levelIds is List
          ? levelIds
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList(growable: false)
          : null;
      return LevelDetailPage(
        levelIndex: levelIndex is int ? levelIndex : null,
        totalLevels: totalLevels is int ? totalLevels : null,
        unitId: unitId is String ? unitId : null,
        lessonId: lessonId is String ? lessonId : null,
        levelId: levelId is String ? levelId : null,
        levelContent: levelContent is LevelContent ? levelContent : null,
        levelIds: parsedLevelIds,
      );
    }
    return const LevelDetailPage();
  }

  @override
  State<LevelDetailPage> createState() => _LevelDetailPageState();
}

class _LevelDetailPageState extends State<LevelDetailPage>
    with WidgetsBindingObserver, RouteAware {
  late final LevelDetailViewModel _vm;
  late final LearningDurationTracker _durationTracker;
  late final LevelAudioPlayer _audioPlayer;
  late final LevelEvaluationFlow _evaluationFlow;
  final YiRecorderController _recorder = YiRecorderController();
  StreamSubscription<Duration>? _recordDurationSub;

  bool _recording = false;
  String _recordStatus = '长按录音，学说 "b"';

  @override
  void initState() {
    super.initState();
    _vm = LevelDetailViewModel(
      currentLevel: widget.levelIndex ?? 1,
      totalLevels: widget.totalLevels ?? 23,
      levelIds: widget.levelIds ?? const [],
    );
    _durationTracker = LearningDurationTracker(activityType: ActivityType.learn);
    _audioPlayer = LevelAudioPlayer();
    _evaluationFlow = LevelEvaluationFlow(
      levelId: widget.levelId ?? '',
      unitId: widget.unitId ?? '',
      lessonId: widget.lessonId,
      content: widget.levelContent ?? LevelContent.empty,
      currentLevel: _vm.currentLevel,
      totalLevels: _vm.totalLevels,
      levelIds: _vm.levelIds,
      onEvaluationCompleted: _onEvaluationCompleted,
      onNavigateToNext: _navigateToNext,
    );
    _vm.setContent(widget.levelContent);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _durationTracker.start();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _durationTracker.onAppLifecycleChanged(state);
  }

  @override
  void didPush() {
    _durationTracker.onRouteVisibilityChanged(true);
  }

  @override
  void didPopNext() {
    _durationTracker.onRouteVisibilityChanged(true);
  }

  @override
  void didPushNext() {
    _durationTracker.onRouteVisibilityChanged(false);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _durationTracker.dispose();
    _audioPlayer.dispose();
    _recordDurationSub?.cancel();
    _recordDurationSub = null;
    _recorder.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LevelDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelContent != widget.levelContent) {
      _vm.setContent(widget.levelContent);
      _evaluationFlow = LevelEvaluationFlow(
        levelId: widget.levelId ?? '',
        unitId: widget.unitId ?? '',
        lessonId: widget.lessonId,
        content: widget.levelContent ?? LevelContent.empty,
        currentLevel: _vm.currentLevel,
        totalLevels: _vm.totalLevels,
        levelIds: _vm.levelIds,
        onEvaluationCompleted: _onEvaluationCompleted,
        onNavigateToNext: _navigateToNext,
      );
    }
  }

  void _onEvaluationCompleted() {
    setState(() {
      _recordStatus = '长按录音，学说 "${_vm.character}"';
    });
  }

  Future<void> _navigateToNext() async {
    if (_vm.currentLevel >= _vm.totalLevels) {
      _toast('暂无下一关');
      return;
    }

    final nextIndex = _vm.currentLevel + 1;
    if (_vm.levelIds.isEmpty) {
      _toast('无法获取下一关');
      return;
    }

    final nextPos = nextIndex - 1;
    if (nextPos < 0 || nextPos >= _vm.levelIds.length) {
      _toast('暂无下一关');
      return;
    }

    final nextLevelId = _vm.levelIds[nextPos];
    if (nextLevelId.isEmpty) {
      _toast('下一关未解锁');
      return;
    }

    final localContext = context;
    final rootNavigator = Navigator.of(localContext, rootNavigator: true);
    showDialog<void>(
      context: localContext,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final content = await getLevelDetailsAPI(nextLevelId);
      if (!localContext.mounted) return;

      if (rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      Navigator.of(localContext).pushReplacementNamed(
        '/learn/level-detail',
        arguments: {
          'unitId': widget.unitId,
          'levelId': nextLevelId,
          'levelIndex': nextIndex,
          'totalLevels': _vm.totalLevels,
          'levelContent': content,
          'levelIds': _vm.levelIds,
        },
      );
    } catch (_) {
      if (!localContext.mounted) return;

      if (rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      ToastUtils.showToast(localContext, '获取关卡详情失败');
    }
  }

  void _toast(String msg) {
    ToastUtils.showToast(context, msg);
  }

  void _playStandard() {
    _audioPlayer.playStandard(
      content: _vm.content ?? LevelContent.empty,
      onUnsupported: () => _toast('播放标准音（示例）'),
      onMissingAsset: () => _toast('暂无标准音'),
    );
  }

  void _playTip() {
    final tip = _vm.nextTip();
    if (tip.isEmpty) {
      ToastUtils.showToast(context, '暂无提示');
      return;
    }
    ToastUtils.showToast(context, tip);
  }

  void _startRecording() {
    if (_recording) return;
    () async {
      try {
        if (!mounted) return;
        setState(() {
          _recording = true;
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
              _recording = false;
              _recordStatus = '长按录音，学说 "${_vm.character}"';
            });
          },
        );
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _recording = false;
          _recordStatus = '长按录音，学说 "${_vm.character}"';
        });
        ToastUtils.showToast(context, '录音开始失败');
      }
    }();
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;

    _recordDurationSub?.cancel();
    _recordDurationSub = null;

    YiRecorderResult? recordResult;
    try {
      recordResult = await _recorder.stop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _recordStatus = '长按录音，学说 "${_vm.character}"';
      });
      ToastUtils.showToast(context, '录音结束失败');
      return;
    }

    setState(() {
      _recording = false;
      _recordStatus = '录音结束，正在测评...';
    });

    if (recordResult == null || _vm.content == null) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _recordStatus = '长按录音，学说 "${_vm.character}"';
      });
      return;
    }

    if (kIsWeb) {
      if (!mounted) return;
      ToastUtils.showToast(context, 'Web 暂不支持语音测评');
      if (!mounted) return;
      setState(() {
        _recordStatus = '长按录音，学说 "${_vm.character}"';
      });
      return;
    }

    await _evaluationFlow.evaluateAndShowDialog(
      context: context,
      recordResult: recordResult,
    );
    _onEvaluationCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.yiYellow.value.withValues(alpha: 0.06);

    final title = _vm.content?.levelName ?? '关卡 ${_vm.currentLevel}';

    return Scaffold(
      backgroundColor: bg,
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
              LevelDetailHeader(
                title: title,
                current: _vm.currentLevel,
                total: _vm.totalLevels,
              ),
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
                            LevelDetailCard(
                              character: _vm.character,
                              pinyin: _vm.pinyin,
                              hintImageAsset: _vm.hintImage,
                              hintLabel: _vm.hintLabel,
                              exampleText: _vm.exampleText,
                              onPlayStandard: _playStandard,
                              onPlayTip: _playTip,
                            ),
                            const SizedBox(height: 30),
                            LevelDetailEvaluateCard(
                              recording: _recording,
                              statusText: _recordStatus,
                              onLongPressStart: _startRecording,
                              onLongPressEnd: _stopRecording,
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
          const YiSun(
            size: 120,
            top: 70,
            right: 15,
            imageAsset: 'lib/assets/sun.webp',
          ),
        ],
      ),
    );
  }
}
