class MineUserInfo {
  final String name;
  final String gender;
  final int age;
  final String grade;
  final String school;
  final String className;
  final String teacherName;
  final int learningDays;

  const MineUserInfo({
    required this.name,
    required this.gender,
    required this.age,
    required this.grade,
    required this.school,
    required this.className,
    required this.teacherName,
    required this.learningDays,
  });
}

class MineStats {
  final int completedLevels;
  final double averageScore;
  final int totalStars;

  const MineStats({
    required this.completedLevels,
    required this.averageScore,
    required this.totalStars,
  });
}

enum MineMenuAction { editProfile, parentEntry, settings }

class MineStarStudent {
  final String avatar;
  final int rank;
  final String name;
  final String badge;

  const MineStarStudent({
    required this.avatar,
    required this.rank,
    required this.name,
    required this.badge,
  });
}
