import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_record_overlay.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_teacher_area.dart';
import 'package:tsty_app/components/ai_chat/ai_chat_top_bar.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/services/parental_control.dart';
import 'package:tsty_app/services/learning_duration_tracker.dart';
import 'package:tsty_app/services/realtime_ai_voice_chat_session.dart';
import 'package:tsty_app/services/rtc_audio_call_service.dart';
import 'package:tsty_app/routes/route_observer.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/user_prefs.dart';
import 'package:tsty_app/utils/yi_recorder.dart';
import 'package:tsty_app/utils/parent_center_prefs.dart';

class AiChatDetailPage extends StatefulWidget {
  final String? sceneId;
  final String? sceneName;

  const AiChatDetailPage({super.key, this.sceneId, this.sceneName});

  static AiChatDetailPage fromArgs(Object? args) {
    if (args is Map) {
      final sceneId = args['sceneId'];
      final sceneName = args['sceneName'];
      return AiChatDetailPage(
        sceneId: sceneId is String ? sceneId : null,
        sceneName: sceneName is String ? sceneName : null,
      );
    }
    return const AiChatDetailPage();
  }

  @override
  State<AiChatDetailPage> createState() => _AiChatDetailPageState();
}

class _AiChatDetailPageState extends State<AiChatDetailPage>
    with WidgetsBindingObserver, RouteAware {
  Timer? _timer;
  Timer? _recordCountdown;

  int _seconds = 0;
  int _recordSeconds = 10;

  bool _isRecording = false;
  bool _isDisabled = false;

  final YiRecorderController _recorder = YiRecorderController();
  StreamSubscription<double>? _ampSub;
  double _amplitude = 0.0;

  final ParentalControlUsageTracker _usageTracker = ParentalControlUsageTracker();
  late final LearningDurationTracker _durationTracker;

  final RtcAudioCallService _rtc = RtcAudioCallService();
  late final RealtimeAiVoiceChatSession _aiSession = RealtimeAiVoiceChatSession(_rtc);
  StreamSubscription<RtcAudioCallState>? _rtcStateSub;
  StreamSubscription<RtcAudioCallError?>? _rtcErrSub;

  Future<void>? _closingFuture;
  bool _allowPop = false;

  String _teacherState = 'idle';
  int _selectedCharacter = 0;

  String get _statusText {
    switch (_teacherState) {
      case 'listening':
        return '倾听中...';
      case 'thinking':
        return '思考中...';
      case 'speaking':
        return '说话中...';
      default:
        return '';
    }
  }

  final Map<String, Map<String, String>> _scenes = const {
    'greeting': {'name': '通用对话', 'opening': '小朋友，你好呀！我们来用普通话聊天吧~'},
    'toy-sharing': {'name': '玩具分享', 'opening': '你有喜欢的玩具吗？可以和我说说哦~'},
    'food': {'name': '食物认知', 'opening': '你最爱吃什么呀？'},
    'weather': {'name': '天气交流', 'opening': '今天天气怎么样？'},
    'family': {'name': '家庭成员', 'opening': '你家里都有谁呀？'},
    'kindergarten': {'name': '幼儿园生活', 'opening': '在幼儿园玩什么？'},
    'festival': {'name': '节日庆祝', 'opening': '你喜欢过什么节日？'},
    'yi-culture': {'name': '彝族文化', 'opening': '你知道火把节吗？'},
  };

  String get _sceneId => widget.sceneId ?? 'toy-sharing';

  String get _sceneTitle {
    if (widget.sceneName != null && widget.sceneName!.trim().isNotEmpty) {
      return widget.sceneName!;
    }
    return _scenes[_sceneId]?['name'] ?? '玩具分享';
  }

  String get _openingText => _scenes[_sceneId]?['opening'] ?? '你有喜欢的玩具吗？可以和我说说哦~';

  String get _teacherAsset =>
      _selectedCharacter == 0 ? 'lib/assets/girl.webp' : 'lib/assets/boy.webp';

  String get _teacherWaitingVideo => _selectedCharacter == 0
      ? 'video/AyiMo-waiting.mp4'
      : 'video/AniuRe-waiting.mp4';

  String get _teacherAnsweringVideo => _selectedCharacter == 0
      ? 'video/AyiMo-answering.mp4'
      : 'video/AniuRe-answering.mp4';

  @override
  void initState() {
    super.initState();

    _durationTracker = LearningDurationTracker(activityType: ActivityType.aiChat);
    WidgetsBinding.instance.addObserver(this);

    () async {
      final selected = (await UserPrefs.getSelectedCharacter()) ?? 0;
      if (!mounted) return;
      setState(() => _selectedCharacter = selected);
    }();

    () async {
      try {
        await _aiSession.start(sceneId: _sceneId);

        // 按住说话模式：默认不推流音频，避免 AI 自动触发
        try {
          await _rtc.setMuted(true);
        } catch (_) {}

        _rtcStateSub?.cancel();
        _rtcStateSub = _rtc.stateStream.listen((s) {
          if (!mounted) return;
          if (s == RtcAudioCallState.joining) {
            setState(() => _teacherState = 'thinking');
          } else if (s == RtcAudioCallState.joined) {
            setState(() => _teacherState = 'idle');
          } else if (s == RtcAudioCallState.error) {
            setState(() => _teacherState = 'idle');
          }
        });

        _rtcErrSub?.cancel();
        _rtcErrSub = _rtc.errorStream.listen((e) {
          if (e == null) return;
          if (!mounted) return;
          ToastUtils.showToast(context, 'AI通话异常: ${e.message}');
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _teacherState = 'idle');
        ToastUtils.showToast(context, 'AI实时对话启动失败: $e');
      }

      ParentCenterPrefs.getControlSettings().then((s) {
        if (!mounted) return;
        if (s.enabled) {
          _usageTracker.start();
        }
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _seconds++;
        });
      });
    }();
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

  void _showOpening() {
    ToastUtils.showToast(context, _openingText);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    // dispose 里不做页面跳转，只做资源回收；并且通过幂等 close 避免重复销毁。
    () async {
      try {
        await _closeSession(pop: false);
      } catch (_) {}
    }();

    _recorder.dispose();
    _usageTracker.stop();
    _durationTracker.dispose();
    super.dispose();
  }

  Future<void> _confirmExitAndClose() async {
    // If we're already closing, avoid showing dialogs / double-closing.
    if (_closingFuture != null) return;

    final ok = await showYiConfirmDialog(
      context: context,
      title: '结束对话',
      message: '本次对话时长：${_formatDuration(_seconds)}',
      cancelText: '继续',
      confirmText: '结束',
      danger: true,
      barrierDismissible: false,
    );
    if (ok != true) return;
    await _closeSession(pop: true);
  }

  Future<void> _closeSession({required bool pop}) async {
    _closingFuture ??= () async {
      // 记录最近聊天
      if (_seconds > 0) {
        final scene = _scenes[_sceneId];
        if (scene != null) {
          final recent = AiChatRecentChat(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: scene['name'] ?? '未知场景',
            timestamp: DateTime.now(),
            type: _sceneId,
            icon: _getIconForScene(_sceneId),
            iconColor: _getIconColorForScene(_sceneId),
            bgColor: _getBgColorForScene(_sceneId),
          );
          await UserPrefs.addRecentChat(recent);
        }
      }

      // Stop UI timers early to avoid setState after dispose.
      _timer?.cancel();
      _timer = null;
      _recordCountdown?.cancel();
      _recordCountdown = null;

      try {
        _ampSub?.cancel();
      } catch (_) {}
      _ampSub = null;

      try {
        _rtcStateSub?.cancel();
      } catch (_) {}
      _rtcStateSub = null;

      try {
        _rtcErrSub?.cancel();
      } catch (_) {}
      _rtcErrSub = null;

      // Ensure RTC audio upstream is stopped first.
      try {
        await _rtc.setMuted(true);
      } catch (_) {}

      // Best-effort stop local recorder.
      try {
        if (_isRecording) {
          await _recorder.stop();
        }
      } catch (_) {}

      try {
        await _aiSession.stop().timeout(
          const Duration(seconds: 5),
          onTimeout: () {},
        );
      } catch (_) {}
    }();

    await _closingFuture;

    if (mounted) {
      setState(() {
        _allowPop = true;
      });
    } else {
      _allowPop = true;
    }
    if (!pop) return;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onRecordStart() {
    if (_isRecording || _isDisabled) return;

    _recordCountdown?.cancel();
    _recordCountdown = null;

    () async {
      final guard = await ParentalControlGuard.checkCanStartAction();
      if (!guard.allowed) {
        if (!mounted) return;
        await showParentalControlBlockedSheet(context: context, result: guard);
        return;
      }

      try {
        // 开始说话：开启推流音频
        try {
          await _rtc.setMuted(false);
        } catch (_) {}

        await _recorder.start(
          config: const YiRecorderConfig(
            format: YiRecorderFormat.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        _ampSub?.cancel();
        _ampSub = _recorder.amplitudeStream.listen((v) {
          if (!mounted) return;
          setState(() => _amplitude = v);
        });

        if (!mounted) return;
        setState(() {
          _isRecording = true;
          _isDisabled = false;
          _recordSeconds = 10;
          _teacherState = 'listening';
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _amplitude = 0.0);
        ToastUtils.showToast(context, '录音失败');
      }
    }();

    _recordCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isRecording) return;

      if (_recordSeconds <= 1) {
        _onRecordEnd();
        return;
      }

      setState(() {
        _recordSeconds -= 1;
      });
    });
  }

  void _onRecordEnd() {
    if (!_isRecording) return;

    _recordCountdown?.cancel();
    _recordCountdown = null;

    () async {
      _ampSub?.cancel();
      _ampSub = null;
      _amplitude = 0.0;

      // 结束说话：先关闭推流音频，避免继续触发
      try {
        await _rtc.setMuted(true);
      } catch (_) {}

      try {
        await _recorder.stop();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _teacherState = 'idle';
          _isDisabled = false;
          _amplitude = 0.0;
        });
        ToastUtils.showToast(context, '录音结束失败');
        return;
      }

      // 发送触发新一轮对话指令给 AI Bot
      final botUserId = _aiSession.info?.botUserId;
      if (botUserId != null && botUserId.isNotEmpty) {
        try {
          await _rtc.sendFinishRecognitionMessage(botUserId: botUserId);
          if (kDebugMode) {
            debugPrint('Sent FinishSpeechRecognition to bot: $botUserId');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to send FinishSpeechRecognition: $e');
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _teacherState = 'thinking';
        _isDisabled = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _teacherState = 'speaking';
        });
      });

      Future.delayed(const Duration(milliseconds: 2400), () {
        if (!mounted) return;
        setState(() {
          _teacherState = 'idle';
          _isDisabled = false;
        });
      });
    }();
  }

  IconData _getIconForScene(String id) {
    switch (id) {
      case 'greeting': return Icons.sentiment_satisfied_alt;
      case 'toy-sharing': return Icons.extension;
      case 'food': return Icons.restaurant;
      case 'weather': return Icons.wb_sunny;
      case 'family': return Icons.favorite;
      case 'kindergarten': return Icons.home;
      case 'festival': return Icons.card_giftcard;
      case 'yi-culture': return Icons.local_fire_department;
      default: return Icons.chat;
    }
  }

  Color _getIconColorForScene(String id) {
    switch (id) {
      case 'greeting': return const Color(0xFF1565C0);
      case 'toy-sharing': return const Color(0xFF2E7D32);
      case 'food': return const Color(0xFFE65100);
      case 'weather': return const Color(0xFFF9A825);
      case 'family': return const Color(0xFFC2185B);
      case 'kindergarten': return const Color(0xFF7B1FA2);
      case 'festival': return const Color(0xFFC62828);
      case 'yi-culture': return const Color(0xFFC00003);
      default: return Colors.grey;
    }
  }

  Color _getBgColorForScene(String id) {
    switch (id) {
      case 'greeting': return const Color(0xFFE3F2FD);
      case 'toy-sharing': return const Color(0xFFE8F5E9);
      case 'food': return const Color(0xFFFFF3E0);
      case 'weather': return const Color(0xFFFFFDE7);
      case 'family': return const Color(0xFFFCE4EC);
      case 'kindergarten': return const Color(0xFFF3E5F5);
      case 'festival': return const Color(0xFFFFEBEE);
      case 'yi-culture': return const Color(0xFFF0C000);
      default: return Colors.grey.shade100;
    }
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m分$sec秒';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_allowPop) return;
        await _confirmExitAndClose();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/ai_page_background.webp',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AiChatTopBar(
                    title: _sceneTitle,
                    timeText: _formatTime(_seconds),
                    onExit: _confirmExitAndClose,
                  ),
                  const ParentalControlSoftBanner(),
                  AiChatTeacherArea(
                    teacherAsset: _teacherAsset,
                    waitingVideoAsset: _teacherWaitingVideo,
                    answeringVideoAsset: _teacherAnsweringVideo,
                    statusText: _statusText,
                    isSpeaking: !_isRecording,
                  ),
                ],
              ),
            ),
            AiChatRecordOverlay(
              isRecording: _isRecording,
              isDisabled: _isDisabled,
              recordSeconds: _recordSeconds,
              amplitude: _amplitude,
              onRecordStart: _onRecordStart,
              onRecordEnd: _onRecordEnd,
            ),
          ],
        ),
      ),
    );
  }
}
