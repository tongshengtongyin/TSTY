import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsty_app/utils/parent_center_prefs.dart';

enum ParentalControlReason { outOfTimeWindow, dailyLimit, restCooldown }

enum ParentalControlBlockType { none, hard }

class ParentalControlGuardResult {
  final bool allowed;
  final ParentalControlBlockType blockType;
  final ParentalControlReason? reason;
  final DateTime? nextAllowedAt;
  final int remainingTodaySeconds;

  const ParentalControlGuardResult({
    required this.allowed,
    required this.blockType,
    required this.reason,
    required this.nextAllowedAt,
    required this.remainingTodaySeconds,
  });

  const ParentalControlGuardResult.allowed({
    required this.remainingTodaySeconds,
  }) : allowed = true,
       blockType = ParentalControlBlockType.none,
       reason = null,
       nextAllowedAt = null;
}

class ParentalControlGuard {
  static const _kUsedSeconds = 'parentalControl.usedSeconds';
  static const _kSessionSeconds = 'parentalControl.sessionSeconds';
  static const _kRestUntilMs = 'parentalControl.restUntilMs';
  static const _kLastResetDate = 'parentalControl.lastResetDate';

  static Future<void> _ensureResetIfNeeded(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = _dateKey(now);
    final last = prefs.getString(_kLastResetDate);
    if (last == today) return;

    await prefs.setString(_kLastResetDate, today);
    await prefs.setInt(_kUsedSeconds, 0);
    await prefs.setInt(_kSessionSeconds, 0);
    await prefs.setInt(_kRestUntilMs, 0);
  }

  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static int _parseHmToMinutes(String hm) {
    final parts = hm.split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return (h.clamp(0, 23) * 60) + m.clamp(0, 59);
  }

  static bool _inWindow({
    required DateTime now,
    required String startHm,
    required String endHm,
  }) {
    final startMin = _parseHmToMinutes(startHm);
    final endMin = _parseHmToMinutes(endHm);
    final nowMin = now.hour * 60 + now.minute;

    if (startMin == endMin) return true;

    if (startMin < endMin) {
      return nowMin >= startMin && nowMin <= endMin;
    }

    return nowMin >= startMin || nowMin <= endMin;
  }

  static DateTime _nextStart({required DateTime now, required String startHm}) {
    final startMin = _parseHmToMinutes(startHm);
    final target = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(minutes: startMin));
    if (now.isBefore(target)) return target;
    return target.add(const Duration(days: 1));
  }

  static Future<ParentalControlGuardResult> checkCanStartAction() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureResetIfNeeded(prefs);

    final settings = await ParentCenterPrefs.getControlSettings();
    if (!settings.enabled) {
      return const ParentalControlGuardResult.allowed(
        remainingTodaySeconds: 1 << 30,
      );
    }
    if (!settings.timeEnabled && settings.dailyLimitMinutes <= 0) {
      return const ParentalControlGuardResult.allowed(
        remainingTodaySeconds: 1 << 30,
      );
    }

    final now = DateTime.now();

    if (settings.timeEnabled &&
        !_inWindow(
          now: now,
          startHm: settings.startTime,
          endHm: settings.endTime,
        )) {
      final next = _nextStart(now: now, startHm: settings.startTime);
      return ParentalControlGuardResult(
        allowed: false,
        blockType: ParentalControlBlockType.hard,
        reason: ParentalControlReason.outOfTimeWindow,
        nextAllowedAt: next,
        remainingTodaySeconds: _remainingTodaySeconds(prefs, settings),
      );
    }

    final restUntilMs = prefs.getInt(_kRestUntilMs) ?? 0;
    if (restUntilMs > 0) {
      final restUntil = DateTime.fromMillisecondsSinceEpoch(restUntilMs);
      if (now.isBefore(restUntil)) {
        return ParentalControlGuardResult(
          allowed: false,
          blockType: ParentalControlBlockType.hard,
          reason: ParentalControlReason.restCooldown,
          nextAllowedAt: restUntil,
          remainingTodaySeconds: _remainingTodaySeconds(prefs, settings),
        );
      }
    }

    final used = prefs.getInt(_kUsedSeconds) ?? 0;
    final limitSeconds = (settings.dailyLimitMinutes.clamp(0, 24 * 60)) * 60;
    if (limitSeconds > 0 && used >= limitSeconds) {
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      return ParentalControlGuardResult(
        allowed: false,
        blockType: ParentalControlBlockType.hard,
        reason: ParentalControlReason.dailyLimit,
        nextAllowedAt: tomorrow,
        remainingTodaySeconds: 0,
      );
    }

    return ParentalControlGuardResult.allowed(
      remainingTodaySeconds: _remainingTodaySeconds(prefs, settings),
    );
  }

  static int _remainingTodaySeconds(
    SharedPreferences prefs,
    ParentControlSettings settings,
  ) {
    final used = prefs.getInt(_kUsedSeconds) ?? 0;
    final limitSeconds = (settings.dailyLimitMinutes.clamp(0, 24 * 60)) * 60;
    if (limitSeconds <= 0) return 1 << 30;
    return (limitSeconds - used).clamp(0, limitSeconds);
  }
}

class ParentalControlUsageTracker with WidgetsBindingObserver {
  static const _kUsedSeconds = 'parentalControl.usedSeconds';
  static const _kSessionSeconds = 'parentalControl.sessionSeconds';
  static const _kRestUntilMs = 'parentalControl.restUntilMs';

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _active = false;

  Future<void> start() async {
    if (_active) return;
    _active = true;
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> stop() async {
    if (!_active) return;
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    await _flush();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active) return;
    if (state == AppLifecycleState.resumed) {
      if (!_stopwatch.isRunning) _stopwatch.start();
      return;
    }
    _flush();
  }

  Future<void> _tick() async {
    if (!_active) return;
    await _flush();
  }

  Future<void> _flush() async {
    final elapsed = _stopwatch.elapsed;
    if (elapsed < const Duration(milliseconds: 900)) return;

    final seconds = elapsed.inSeconds;
    if (seconds <= 0) return;

    _stopwatch.reset();

    final prefs = await SharedPreferences.getInstance();
    await ParentalControlGuard._ensureResetIfNeeded(prefs);

    final settings = await ParentCenterPrefs.getControlSettings();
    if (!settings.enabled) {
      return;
    }

    final used = prefs.getInt(_kUsedSeconds) ?? 0;
    final session = prefs.getInt(_kSessionSeconds) ?? 0;

    final nextUsed = used + seconds;
    final nextSession = session + seconds;

    await prefs.setInt(_kUsedSeconds, nextUsed);
    await prefs.setInt(_kSessionSeconds, nextSession);

    if (settings.restEnabled) {
      final intervalSeconds =
          settings.restIntervalMinutes.clamp(1, 24 * 60) * 60;
      if (nextSession >= intervalSeconds) {
        final restSeconds = settings.restDurationMinutes.clamp(1, 60) * 60;
        final until = DateTime.now().add(Duration(seconds: restSeconds));
        await prefs.setInt(_kRestUntilMs, until.millisecondsSinceEpoch);
        await prefs.setInt(_kSessionSeconds, 0);
      }
    }

    final limitSeconds = settings.dailyLimitMinutes.clamp(0, 24 * 60) * 60;
    if (limitSeconds > 0 && nextUsed >= limitSeconds) {
      await prefs.setInt(_kSessionSeconds, 0);
    }
  }
}

class ParentalControlSoftBannerStatus {
  final bool show;
  final String message;

  const ParentalControlSoftBannerStatus({
    required this.show,
    required this.message,
  });
}

Future<ParentalControlSoftBannerStatus?>
getParentalControlSoftBannerStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await ParentalControlGuard._ensureResetIfNeeded(prefs);
  final settings = await ParentCenterPrefs.getControlSettings();

  if (!settings.enabled) return null;

  final limitSeconds = (settings.dailyLimitMinutes.clamp(0, 24 * 60)) * 60;
  final used = prefs.getInt('parentalControl.usedSeconds') ?? 0;
  final remainingToday = limitSeconds <= 0
      ? (1 << 30)
      : (limitSeconds - used).clamp(0, limitSeconds);

  if (remainingToday <= 0) return null;

  if (limitSeconds > 0 && remainingToday <= 5 * 60) {
    final mins = (remainingToday / 60).ceil().clamp(1, 24 * 60);
    return ParentalControlSoftBannerStatus(
      show: true,
      message: '今天还可以使用$mins分钟',
    );
  }

  if (settings.restEnabled) {
    final intervalSeconds = settings.restIntervalMinutes.clamp(1, 24 * 60) * 60;
    final session = prefs.getInt('parentalControl.sessionSeconds') ?? 0;
    final remainingToRest = (intervalSeconds - session).clamp(
      0,
      intervalSeconds,
    );

    if (remainingToRest <= 60) {
      final restMins = settings.restDurationMinutes.clamp(1, 60);
      final mins = (remainingToRest / 60).ceil().clamp(1, 60);
      return ParentalControlSoftBannerStatus(
        show: true,
        message: '再使用$mins分钟后需要休息$restMins分钟',
      );
    }
  }

  return null;
}

class ParentalControlSoftBanner extends StatelessWidget {
  const ParentalControlSoftBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return FutureBuilder<ParentalControlSoftBannerStatus?>(
      future: getParentalControlSoftBannerStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null || !status.show) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.message,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> showParentalControlBlockedSheet({
  required BuildContext context,
  required ParentalControlGuardResult result,
}) async {
  if (result.allowed) return;

  String title;
  String message;

  switch (result.reason) {
    case ParentalControlReason.outOfTimeWindow:
      title = '还没到学习时间';
      message = '请在允许的时间段再来学习';
      break;
    case ParentalControlReason.dailyLimit:
      title = '今天学得很棒';
      message = '今日学习时间已用完，明天再来吧';
      break;
    case ParentalControlReason.restCooldown:
      title = '休息一下吧';
      message = '休息一会儿，稍后继续更有效';
      break;
    default:
      title = '暂时不可用';
      message = '请稍后再试';
  }

  String? nextText;
  final next = result.nextAllowedAt;
  if (next != null) {
    final hh = next.hour.toString().padLeft(2, '0');
    final mm = next.minute.toString().padLeft(2, '0');
    nextText = '${next.month}月${next.day}日 $hh:$mm';
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFC00003),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF666666),
              ),
            ),
            if (nextText != null) ...[
              const SizedBox(height: 10),
              Text(
                '下次可用：$nextText',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF999999),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC00003),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '我知道了',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
