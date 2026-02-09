import 'dart:async';

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
    'greeting': {'name': '日常问候', 'opening': '你好呀！今天开心吗？'},
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

  @override
  void initState() {
    super.initState();

    _durationTracker = LearningDurationTracker(activityType: ActivityType.aiChat);
    WidgetsBinding.instance.addObserver(this);

    _usageTracker.start();

    () async {
      final selected = (await UserPrefs.getSelectedCharacter()) ?? 0;
      if (!mounted) return;
      setState(() => _selectedCharacter = selected);
    }();

    () async {
      try {
        await _aiSession.start(sceneId: _sceneId);

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
    }();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOpening();
      if (!mounted) return;
      _durationTracker.start();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
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

  void _showOpening() {
    ToastUtils.showToast(context, _openingText);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _timer?.cancel();
    _timer = null;
    _recordCountdown?.cancel();
    _recordCountdown = null;
    _ampSub?.cancel();
    _ampSub = null;
    _rtcStateSub?.cancel();
    _rtcStateSub = null;
    _rtcErrSub?.cancel();
    _rtcErrSub = null;
    _recorder.dispose();
    _usageTracker.stop();
    _durationTracker.dispose();

    () async {
      try {
        await _aiSession.stop();
      } catch (_) {}
    }();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  void _onEnd() {
    () async {
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

      _timer?.cancel();
      _timer = null;
      try {
        await _aiSession.stop();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).maybePop();
    }();
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
    return Scaffold(
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
                  onBack: _onBack,
                  onEnd: _onEnd,
                ),
                const ParentalControlSoftBanner(),
                AiChatTeacherArea(
                  teacherAsset: _teacherAsset,
                  statusText: _statusText,
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
    );
  }
}
