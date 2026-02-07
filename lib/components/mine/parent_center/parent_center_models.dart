class ParentChildInfo {
  final String nickname;
  final String className;
  final String avatarAsset;

  const ParentChildInfo({
    required this.nickname,
    required this.className,
    required this.avatarAsset,
  });
}

enum ParentReportPeriod { week, month, all }

enum ParentReportUnit { shengmu, yunmu, hanzi, ciyu }

class ParentReportSummary {
  final int totalLearningMinutes;
  final int totalAiChatMinutes;
  final int avgDailyMinutes;
  final int activeDays;
  final int completedLevels;
  final int earnedStars;
  final int avgScore;
  final String lastActivityAt;
  final String lastStudyDate;

  const ParentReportSummary({
    required this.totalLearningMinutes,
    required this.totalAiChatMinutes,
    required this.avgDailyMinutes,
    required this.activeDays,
    required this.completedLevels,
    required this.earnedStars,
    required this.avgScore,
    this.lastActivityAt = '',
    this.lastStudyDate = '',
  });
}

class ParentReportProgress {
  final int totalLevels;
  final int completedLevels;
  final double completionRate;

  const ParentReportProgress({
    required this.totalLevels,
    required this.completedLevels,
    required this.completionRate,
  });
}

class ParentReportTrend {
  final List<int> learningMinutes;
  final List<int> scores;
  final List<String> dates;

  const ParentReportTrend({
    required this.learningMinutes,
    required this.scores,
    required this.dates,
  });
}

class ParentReportEvaluation {
  final String level;
  final String comment;
  final List<String> suggestions;

  const ParentReportEvaluation({
    required this.level,
    required this.comment,
    required this.suggestions,
  });
}

class ParentReportData {
  final ParentReportSummary summary;
  final ParentReportProgress progress;
  final ParentReportProgress shengmuProgress;
  final ParentReportProgress yunmuProgress;
  final ParentReportProgress hanziProgress;
  final ParentReportProgress ciyuProgress;
  final ParentReportTrend trend;
  final ParentReportEvaluation evaluation;

  const ParentReportData({
    required this.summary,
    required this.progress,
    required this.shengmuProgress,
    required this.yunmuProgress,
    required this.hanziProgress,
    required this.ciyuProgress,
    required this.trend,
    required this.evaluation,
  });
}
