import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/parent_center_prefs.dart';

class ParentControlSection extends StatelessWidget {
  final ParentControlSettings settings;
  final ValueChanged<ParentControlSettings> onChanged;
  final VoidCallback onSave;

  const ParentControlSection({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controlsEnabled = settings.enabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TipCard(),
          const SizedBox(height: 14),
          _EnableCard(
            enabled: controlsEnabled,
            onChanged: (v) => onChanged(settings.copyWith(enabled: v)),
          ),
          const SizedBox(height: 14),
          _DailyLimitCard(
            enabled: controlsEnabled,
            minutes: settings.dailyLimitMinutes,
            onChanged: (m) =>
                onChanged(settings.copyWith(dailyLimitMinutes: m)),
          ),
          const SizedBox(height: 14),
          _TimeRangeCard(
            enabled: controlsEnabled && settings.timeEnabled,
            startTime: settings.startTime,
            endTime: settings.endTime,
            onEnabledChanged: (v) {
              if (!controlsEnabled) return;
              onChanged(settings.copyWith(timeEnabled: v));
            },
            onStartPick: () async {
              if (!controlsEnabled || !settings.timeEnabled) return;
              final picked = await _pickTime(context, settings.startTime);
              if (picked != null) {
                onChanged(settings.copyWith(startTime: picked));
              }
            },
            onEndPick: () async {
              if (!controlsEnabled || !settings.timeEnabled) return;
              final picked = await _pickTime(context, settings.endTime);
              if (picked != null) {
                onChanged(settings.copyWith(endTime: picked));
              }
            },
          ),
          const SizedBox(height: 14),
          _RestCard(
            enabled: controlsEnabled && settings.restEnabled,
            interval: settings.restIntervalMinutes,
            duration: settings.restDurationMinutes,
            onEnabledChanged: (v) {
              if (!controlsEnabled) return;
              onChanged(settings.copyWith(restEnabled: v));
            },
            onIntervalChanged: (v) {
              if (!controlsEnabled) return;
              onChanged(settings.copyWith(restIntervalMinutes: v));
            },
            onDurationChanged: (v) {
              if (!controlsEnabled) return;
              onChanged(settings.copyWith(restDurationMinutes: v));
            },
          ),
          const SizedBox(height: 10),
          _SaveButton(onSave: onSave),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _EnableCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _EnableCard({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final red = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: yellow, width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: yellow, width: 2),
            ),
            child: const Icon(Icons.lock_clock, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '启用家长管控',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A1E00),
              ),
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Material(
      color: red,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onSave,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: red.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: yellow, size: 18),
              const SizedBox(width: 8),
              const Text(
                '保存设置',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _pickTime(BuildContext context, String current) async {
  final parts = current.split(':');
  final h = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
  final m = parts.length >= 2 ? int.tryParse(parts[1]) : null;

  final initial = TimeOfDay(hour: h ?? 18, minute: m ?? 0);
  final picked = await showTimePicker(context: context, initialTime: initial);
  if (picked == null) return null;

  final hh = picked.hour.toString().padLeft(2, '0');
  final mm = picked.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: AppTheme.yiYellow.value, width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lightbulb, color: Color(0xFFF0C000), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '合理设置使用时间，保护孩子视力健康，推荐每日学习15-30分钟',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget header;
  final Widget child;

  const _CardShell({required this.header, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, const SizedBox(height: 12), child],
      ),
    );
  }
}

class _DailyLimitCard extends StatelessWidget {
  final bool enabled;
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DailyLimitCard({
    required this.enabled,
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return _CardShell(
      header: Row(
        children: [
          Icon(Icons.schedule, color: red),
          const SizedBox(width: 10),
          const Text(
            '每日时长限制',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2800),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '每日最多使用',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '达到限制后将暂停学习功能',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$minutes分钟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: red,
              thumbColor: red,
              overlayColor: red.withValues(alpha: 0.15),
              inactiveTrackColor: red.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 15,
              max: 120,
              divisions: (120 - 15) ~/ 5,
              onChanged: enabled
                  ? (v) => onChanged(((v / 5).round() * 5).clamp(15, 120))
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15分钟',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF999999),
                ),
              ),
              Text(
                '30分钟',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC00003),
                ),
              ),
              Text(
                '60分钟',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF999999),
                ),
              ),
              Text(
                '120分钟',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRangeCard extends StatelessWidget {
  final bool enabled;
  final String startTime;
  final String endTime;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onStartPick;
  final VoidCallback onEndPick;

  const _TimeRangeCard({
    required this.enabled,
    required this.startTime,
    required this.endTime,
    required this.onEnabledChanged,
    required this.onStartPick,
    required this.onEndPick,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return _CardShell(
      header: Row(
        children: [
          Icon(Icons.calendar_month, color: red),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '可用时段设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D2800),
              ),
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: red,
            activeTrackColor: red.withValues(alpha: 0.35),
            onChanged: onEnabledChanged,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '时段外将显示"XX点再来吧"提示',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Row(
              children: [
                Expanded(
                  child: _TimeBox(
                    text: startTime,
                    onTap: enabled ? onStartPick : null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '至',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
                Expanded(
                  child: _TimeBox(
                    text: endTime,
                    onTap: enabled ? onEndPick : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _TimeBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final canTap = onTap != null;

    return Material(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canTap
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFFE0E0E0).withValues(alpha: 0.7),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D2800),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestCard extends StatelessWidget {
  final bool enabled;
  final int interval;
  final int duration;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onIntervalChanged;
  final ValueChanged<int> onDurationChanged;

  const _RestCard({
    required this.enabled,
    required this.interval,
    required this.duration,
    required this.onEnabledChanged,
    required this.onIntervalChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    Widget option(int v, {bool recommend = false}) {
      final active = interval == v;

      return Expanded(
        child: GestureDetector(
          onTap: enabled ? () => onIntervalChanged(v) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 14),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? red.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? red : const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$v分钟',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: active ? red : const Color(0xFF666666),
                  ),
                ),
                if (recommend) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0C000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '推荐',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return _CardShell(
      header: Row(
        children: [
          Icon(Icons.visibility, color: red),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '休息提醒',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D2800),
              ),
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: red,
            activeTrackColor: red.withValues(alpha: 0.35),
            onChanged: onEnabledChanged,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '连续使用后强制休息$duration分钟',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Row(
              children: [option(10), option(15, recommend: true), option(20)],
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Row(
              children: [
                Expanded(
                  child: _OptionChip(
                    text: '休息3分钟',
                    active: duration == 3,
                    onTap: enabled ? () => onDurationChanged(3) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OptionChip(
                    text: '休息5分钟',
                    active: duration == 5,
                    onTap: enabled ? () => onDurationChanged(5) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OptionChip(
                    text: '休息10分钟',
                    active: duration == 10,
                    onTap: enabled ? () => onDurationChanged(10) : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback? onTap;

  const _OptionChip({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    return Material(
      color: active ? red.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? red : const Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: active ? red : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
