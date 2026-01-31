import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/mine/parent_center/parent_center_models.dart';
import 'package:tsty_app/components/mine/parent_center/parent_center_segmented_control.dart';
import 'package:tsty_app/components/mine/parent_center/parent_control_section.dart';
import 'package:tsty_app/components/mine/parent_center/parent_report_section.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
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

    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;

    ParentReportData mock;
    switch (period) {
      case ParentReportPeriod.week:
        mock = _mockReport(
          totalMinutes: 180,
          avgDaily: 26,
          activeDays: 5,
          avgScore: 85,
          completionRate: 0.118,
          dates: const [
            '10-14',
            '10-15',
            '10-16',
            '10-17',
            '10-18',
            '10-19',
            '10-20'
          ],
          minutes: const [30, 25, 35, 20, 40, 30, 0],
          scores: const [82, 85, 88, 80, 90, 85, 0],
          evaluation: const ParentReportEvaluation(
            level: '优秀',
            comment: '本周学习积极，发音准确度有明显提升！',
            suggestions: ['可以增加每日学习时间', '多练习韵母发音'],
          ),
        );
        break;
      case ParentReportPeriod.month:
        mock = _mockReport(
          totalMinutes: 720,
          avgDaily: 24,
          activeDays: 20,
          avgScore: 84,
          completionRate: 0.21,
          dates: const ['第1周', '第2周', '第3周', '第4周', ''],
          minutes: const [180, 210, 160, 170, 0],
          scores: const [83, 84, 86, 82, 0],
          evaluation: const ParentReportEvaluation(
            level: '良好',
            comment: '本月整体学习稳定，建议保持练习频率。',
            suggestions: ['保持每周学习节奏', '针对薄弱音节做专项训练'],
          ),
        );
        break;
      case ParentReportPeriod.all:
        mock = _mockReport(
          totalMinutes: 1980,
          avgDaily: 22,
          activeDays: 90,
          avgScore: 86,
          completionRate: 0.32,
          dates: const ['1月', '2月', '3月', '4月', '5月', '6月'],
          minutes: const [300, 280, 360, 310, 340, 390],
          scores: const [84, 85, 86, 87, 86, 88],
          evaluation: const ParentReportEvaluation(
            level: '优秀',
            comment: '持续进步明显，口语表达自信度提升。',
            suggestions: ['继续保持学习习惯', '适当提高每日学习时长'],
          ),
        );
        break;
    }

    setState(() {
      _report = mock;
      _reportLoading = false;
    });
  }

  ParentReportData _mockReport({
    required int totalMinutes,
    required int avgDaily,
    required int activeDays,
    required int avgScore,
    required double completionRate,
    required List<String> dates,
    required List<int> minutes,
    required List<int> scores,
    required ParentReportEvaluation evaluation,
  }) {
    return ParentReportData(
      summary: ParentReportSummary(
        totalLearningMinutes: totalMinutes,
        avgDailyMinutes: avgDaily,
        activeDays: activeDays,
        completedLevels: 15,
        earnedStars: 22,
        avgScore: avgScore,
      ),
      progress: ParentReportProgress(
        totalLevels: 127,
        completedLevels: 15,
        completionRate: completionRate,
      ),
      trend: ParentReportTrend(
        learningMinutes: minutes,
        scores: scores,
        dates: dates,
      ),
      evaluation: evaluation,
    );
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
