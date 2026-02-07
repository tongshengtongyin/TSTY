import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/mine/parent_center/parent_center_models.dart';
import 'package:tsty_app/components/mine/parent_center/parent_center_segmented_control.dart';
import 'package:tsty_app/components/mine/parent_center/parent_control_section.dart';
import 'package:tsty_app/components/mine/parent_center/parent_report_section.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/api/parent_report.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/parent_center_prefs.dart';

class ParentCenterPage extends StatefulWidget {
  const ParentCenterPage({super.key});

  @override
  State<ParentCenterPage> createState() => _ParentCenterPageState();
}

class _ParentCenterPageState extends State<ParentCenterPage> {
  int _tabIndex = 0;
  ParentReportPeriod _period = ParentReportPeriod.week;

  bool _checkingLogin = true;
  bool _reportLoading = false;

  ParentControlSettings _controlSettings = const ParentControlSettings(
    dailyLimitMinutes: 30,
    timeEnabled: true,
    startTime: '18:00',
    endTime: '20:00',
    restEnabled: true,
    restIntervalMinutes: 15,
  );

  final ParentChildInfo _child = const ParentChildInfo(
    nickname: '阿依彝',
    className: '向阳幼儿园二班',
    avatarAsset: 'lib/assets/avatar01.webp',
  );

  ParentReportData _report = const ParentReportData(
    summary: ParentReportSummary(
      totalLearningMinutes: 0,
      totalAiChatMinutes: 0,
      avgDailyMinutes: 0,
      activeDays: 0,
      completedLevels: 0,
      earnedStars: 0,
      avgScore: 0,
    ),
    progress: ParentReportProgress(
      totalLevels: 0,
      completedLevels: 0,
      completionRate: 0,
    ),
    shengmuProgress: ParentReportProgress(
      totalLevels: 0,
      completedLevels: 0,
      completionRate: 0,
    ),
    yunmuProgress: ParentReportProgress(
      totalLevels: 0,
      completedLevels: 0,
      completionRate: 0,
    ),
    hanziProgress: ParentReportProgress(
      totalLevels: 0,
      completedLevels: 0,
      completionRate: 0,
    ),
    ciyuProgress: ParentReportProgress(
      totalLevels: 0,
      completedLevels: 0,
      completionRate: 0,
    ),
    trend: ParentReportTrend(
      learningMinutes: [0, 0, 0, 0, 0, 0, 0],
      scores: [0, 0, 0, 0, 0, 0, 0],
      dates: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    ),
    evaluation: ParentReportEvaluation(level: '', comment: '', suggestions: []),
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loggedIn = await ParentCenterPrefs.isParentLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      setState(() => _checkingLogin = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ToastUtils.showToast(context, '请先验证家长身份');
        Navigator.of(context).pushReplacementNamed('/mine/parent-entry');
      });
      return;
    }

    final settings = await ParentCenterPrefs.getControlSettings();
    if (!mounted) return;
    setState(() {
      _controlSettings = settings;
      _checkingLogin = false;
    });

    await _loadReport(period: _period);
  }

  Future<void> _loadReport({required ParentReportPeriod period}) async {
    if (_reportLoading) return;

    setState(() {
      _reportLoading = true;
      _period = period;
    });

    final periodParam = switch (period) {
      ParentReportPeriod.week => 'week',
      ParentReportPeriod.month => 'month',
      ParentReportPeriod.all => 'all',
    };

    int asInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is double) return v.round();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    double asDouble(dynamic v, {double fallback = 0}) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? fallback;
    }

    ParentReportProgress parseProgress(dynamic raw) {
      if (raw is! Map) {
        return const ParentReportProgress(
          totalLevels: 0,
          completedLevels: 0,
          completionRate: 0,
        );
      }
      final m = Map<String, dynamic>.from(raw);
      final total = asInt(m['totalLevels']);
      final done = asInt(m['completedLevels']);
      final rateRaw = asDouble(m['completionRate']);
      final rate = rateRaw > 0
          ? rateRaw
          : (total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0));
      return ParentReportProgress(
        totalLevels: total,
        completedLevels: done,
        completionRate: rate,
      );
    }

    try {
      final data = await getParentReportOverviewAPI(period: periodParam);

      final summaryRaw = data['summary'];
      final summaryMap = summaryRaw is Map
          ? Map<String, dynamic>.from(summaryRaw)
          : const <String, dynamic>{};

      final trendRaw = data['trend'];
      final trendMap = trendRaw is Map
          ? Map<String, dynamic>.from(trendRaw)
          : const <String, dynamic>{};

      final minutesRaw = trendMap['learningMinutes'];
      final minutes = minutesRaw is List
          ? minutesRaw.map((e) => asInt(e)).toList(growable: false)
          : const <int>[];

      final datesRaw = trendMap['dates'];
      final dates = datesRaw is List
          ? datesRaw.map((e) => e?.toString() ?? '').toList(growable: false)
          : const <String>[];

      final scores = List<int>.filled(minutes.length, 0, growable: false);

      final unitProgressRaw = data['unitProgress'];
      final unitProgressMap = unitProgressRaw is Map
          ? Map<String, dynamic>.from(unitProgressRaw)
          : const <String, dynamic>{};

      final report = ParentReportData(
        summary: ParentReportSummary(
          totalLearningMinutes: asInt(summaryMap['totalLearningMinutes']),
          totalAiChatMinutes: asInt(summaryMap['totalAiChatMinutes']),
          avgDailyMinutes: asInt(summaryMap['avgDailyMinutes']),
          activeDays: asInt(summaryMap['activeDays']),
          completedLevels: 0,
          earnedStars: asInt(summaryMap['earnedStars']),
          avgScore: asInt(summaryMap['avgScore']),
          lastActivityAt: summaryMap['lastActivityAt']?.toString() ?? '',
          lastStudyDate: summaryMap['lastStudyDate']?.toString() ?? '',
        ),
        progress: parseProgress(data['progress']),
        shengmuProgress: parseProgress(unitProgressMap['shengmu']),
        yunmuProgress: parseProgress(unitProgressMap['yunmu']),
        hanziProgress: parseProgress(unitProgressMap['hanzi']),
        ciyuProgress: parseProgress(unitProgressMap['ciyu']),
        trend: ParentReportTrend(
          learningMinutes: minutes,
          scores: scores,
          dates: dates,
        ),
        evaluation: const ParentReportEvaluation(
          level: '',
          comment: '',
          suggestions: <String>[],
        ),
      );

      if (!mounted) return;
      setState(() {
        _report = report;
        _reportLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reportLoading = false);
      ToastUtils.showToast(context, '学习报告加载失败');
    }
  }

  void _onBarTap(int index) {
    if (index < 0 || index >= _report.trend.learningMinutes.length) return;
    final minutes = _report.trend.learningMinutes[index];
    if (minutes == 0) return;

    final date = index < _report.trend.dates.length ? _report.trend.dates[index] : '';
    final score = index < _report.trend.scores.length ? _report.trend.scores[index] : 0;

    ToastUtils.showToast(context, '$date: $minutes分钟, 得分$score分');
  }

  Future<void> _onExit() async {
    final ok = await showYiConfirmDialog(
      context: context,
      title: '退出确认',
      message: '确定要退出家长中心吗？',
      danger: true,
      cancelText: '取消',
      confirmText: '确定',
    );

    if (ok != true || !mounted) return;

    await ParentCenterPrefs.clearParentSession();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _onSaveControl() async {
    await ParentCenterPrefs.setControlSettings(_controlSettings);
    if (!mounted) return;

    ToastUtils.showToast(context, '设置已保存');
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: YiBaseBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              YiTopBar(title: '家长中心', onBack: _onExit),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ParentCenterSegmentedControl(
                  selectedIndex: _tabIndex,
                  labels: const ['学习报告', '使用管控'],
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    ParentReportSection(
                      child: _child,
                      period: _period,
                      onPeriodChanged: (p) => _loadReport(period: p),
                      data: _report,
                      loading: _reportLoading,
                      onBarTap: _onBarTap,
                    ),
                    ParentControlSection(
                      settings: _controlSettings,
                      onChanged: (s) => setState(() => _controlSettings = s),
                      onSave: _onSaveControl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
