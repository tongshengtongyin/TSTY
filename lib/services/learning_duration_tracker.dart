import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:tsty_app/api/learn.dart';
import 'package:tsty_app/utils/user_prefs.dart';

enum ActivityType { learn, aiChat }

String _activityTypeToString(ActivityType type) {
  switch (type) {
    case ActivityType.learn:
      return 'learn';
    case ActivityType.aiChat:
      return 'ai_chat';
  }
}

class LearningDurationTracker {
  final ActivityType activityType;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _flushTimer;
  int _bufferedMs = 0;
  bool _flushInProgress = false;
  bool _appInForeground = true;
  bool _routeVisible = true;

  LearningDurationTracker({required this.activityType});

  void onAppLifecycleChanged(AppLifecycleState state) {
    _appInForeground = state == AppLifecycleState.resumed;
    _syncActive();
  }

  void onRouteVisibilityChanged(bool visible) {
    _routeVisible = visible;
    _syncActive();
  }

  void _ensureFlushTimerRunning() {
    _flushTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => _flush(includeRunning: true),
    );
  }

  void _stopFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  void _captureMillis({required bool keepRunning}) {
    if (!_stopwatch.isRunning) return;
    _bufferedMs += _stopwatch.elapsedMilliseconds;
    if (keepRunning) {
      _stopwatch.reset();
    } else {
      _stopwatch
        ..stop()
        ..reset();
    }
  }

  Future<void> _flush({required bool includeRunning}) async {
    if (_flushInProgress) return;
    if (includeRunning) {
      _captureMillis(keepRunning: true);
    }

    final seconds = _bufferedMs ~/ 1000;
    if (seconds <= 0) return;

    final sendMs = seconds * 1000;
    _bufferedMs -= sendMs;

    _flushInProgress = true;
    try {
      final token = await UserPrefs.getAccessToken();
      await recordLearningDurationAPI(
        duration: seconds,
        activityType: _activityTypeToString(activityType),
        accessToken: token,
      );
    } catch (_) {
      _bufferedMs += sendMs;
    } finally {
      _flushInProgress = false;
    }
  }

  void _syncActive() {
    final shouldRun = _appInForeground && _routeVisible;
    if (shouldRun) {
      if (!_stopwatch.isRunning) {
        _stopwatch.start();
      }
      _ensureFlushTimerRunning();
      return;
    }

    _captureMillis(keepRunning: false);
    _stopFlushTimer();
    _flush(includeRunning: false);
  }

  void start() {
    _syncActive();
  }

  Future<void> dispose() async {
    _captureMillis(keepRunning: false);
    _stopFlushTimer();
    await _flush(includeRunning: false);
  }
}
