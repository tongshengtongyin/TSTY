import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiSideStripe.dart';
import 'package:tsty_app/components/mine/mine_class_stars_card.dart';
import 'package:tsty_app/components/mine/mine_menu_section.dart';
import 'package:tsty_app/components/mine/mine_profile_header.dart';
import 'package:tsty_app/components/mine/models.dart';
import 'package:tsty_app/api/child.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Map<String, dynamic>? _profile;
  int _avatarIndex = 0;
  List<MineStarStudent> _classStars = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await UserPrefs.getChildProfile();
    final avatarIndex = await UserPrefs.getSelectedAvatarIndex();
    List<MineStarStudent> stars = const [];
    try {
      stars = await _loadClassRanking();
    } catch (_) {
      stars = const [];
    }
    if (!mounted) return;
    setState(() {
      _profile = p;
      _avatarIndex = avatarIndex;
      _classStars = stars;
    });
  }

  Future<void> _refresh() async {
    final data = await getChildProfileAPI();
    await UserPrefs.setChildProfile(data);
    final avatarIndex = await UserPrefs.getSelectedAvatarIndex();
    List<MineStarStudent> stars = const [];
    try {
      stars = await _loadClassRanking();
    } catch (_) {
      stars = const [];
    }
    if (!mounted) return;
    setState(() {
      _profile = data;
      _avatarIndex = avatarIndex;
      _classStars = stars;
    });
  }

  Future<List<MineStarStudent>> _loadClassRanking() async {
    const avatarPool = <String>[
      'lib/assets/avatar01.webp',
      'lib/assets/avatar02.webp',
      'lib/assets/avatar03.webp',
      'lib/assets/avatar04.webp',
      'lib/assets/avatar05.webp',
    ];

    final topList = await getChildClassRankingAPI();
    if (topList.isEmpty) return const [];

    final indices = List<int>.generate(avatarPool.length, (i) => i)..shuffle();
    final picked = indices.take(3).toList();

    final out = <MineStarStudent>[];
    for (var i = 0; i < topList.length && i < 3; i++) {
      final item = topList[i];
      final fullName = (item['fullName']?.toString() ?? '').trim();
      final totalStars = item['totalStars'];
      final stars = totalStars is int
          ? totalStars
          : int.tryParse(totalStars?.toString() ?? '') ?? 0;

      out.add(
        MineStarStudent(
          avatar: avatarPool[picked[i % picked.length]],
          rank: i + 1,
          name: fullName.isEmpty ? '同学' : fullName,
          badge: '$stars颗',
        ),
      );
    }
    return out;
  }

  String _pickString(String key, {String fallback = ''}) {
    final v = _profile?[key];
    final s = v?.toString() ?? '';
    return s.trim().isEmpty ? fallback : s.trim();
  }

  int _pickInt(String key, {int fallback = 0}) {
    final v = _profile?[key];
    if (v is int) return v;
    final s = v?.toString() ?? '';
    return int.tryParse(s) ?? fallback;
  }

  String _normalizeGender(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    final lower = s.toLowerCase();
    if (lower == 'male' || lower == 'm') return '男生';
    if (lower == 'female' || lower == 'f') return '女生';
    if (s.contains('男')) return '男生';
    if (s.contains('女')) return '女生';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    const avatars = <String>[
      'lib/assets/avatar01.webp',
      'lib/assets/avatar02.webp',
      'lib/assets/avatar03.webp',
      'lib/assets/avatar04.webp',
      'lib/assets/avatar05.webp',
    ];
    final safeIndex = (_avatarIndex >= 0 && _avatarIndex < avatars.length) ? _avatarIndex : 0;
    final avatarAsset = avatars[safeIndex];

    final nickname = _pickString('nickname', fallback: '小朋友');
    final gender = _normalizeGender(_pickString('gender', fallback: ''));
    final ageYears = _pickInt('ageYears', fallback: 0);
    final classInfo = _profile?['classInfo'];
    final classInfoMap = classInfo is Map ? Map<String, dynamic>.from(classInfo) : <String, dynamic>{};
    final grade = (classInfoMap['grade']?.toString() ?? '').trim();
    final schoolName = (classInfoMap['schoolName']?.toString() ?? '').trim();
    final className = (classInfoMap['className']?.toString() ?? '').trim();
    final teacherName = (classInfoMap['teacherName']?.toString() ?? '').trim();
    final school = [schoolName].where((e) => e.trim().isNotEmpty).join(' · ');

    final statsObj = _profile?['stats'];
    final statsMap = statsObj is Map ? Map<String, dynamic>.from(statsObj) : <String, dynamic>{};
    final completedLevels = (statsMap['completedLevels'] is int)
        ? statsMap['completedLevels'] as int
        : int.tryParse(statsMap['completedLevels']?.toString() ?? '') ?? 0;
    final totalStars = (statsMap['totalStars'] is int)
        ? statsMap['totalStars'] as int
        : int.tryParse(statsMap['totalStars']?.toString() ?? '') ?? 0;
    final avgScoreRaw = statsMap.containsKey('avgScore')
        ? statsMap['avgScore']
        : statsMap['averageScore'];
    final averageScore = (avgScoreRaw is num)
        ? avgScoreRaw.toDouble()
        : double.tryParse(avgScoreRaw?.toString() ?? '') ?? 0;
    final consecutiveDays = (statsMap['consecutiveDays'] is int)
        ? statsMap['consecutiveDays'] as int
        : int.tryParse(statsMap['consecutiveDays']?.toString() ?? '') ?? 0;

    final user = MineUserInfo(
      name: nickname,
      gender: gender.isEmpty ? '未设置' : gender,
      age: ageYears <= 0 ? 0 : ageYears,
      grade: grade.isEmpty ? '未设置' : grade,
      school: school.isEmpty ? '未设置' : school,
      className: className,
      teacherName: teacherName,
      learningDays: consecutiveDays,
    );
    final stats = MineStats(
      completedLevels: completedLevels,
      averageScore: averageScore,
      totalStars: totalStars,
    );

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    MineProfileHeader(user: user, stats: stats, avatarAsset: avatarAsset),
                    const SizedBox(height: 24),
                    MineClassStarsCard(stars: _classStars),
                    const SizedBox(height: 24),
                    MineMenuSection(
                      onTap: (action) {
                        switch (action) {
                          case MineMenuAction.editProfile:
                            Navigator.of(context)
                                .pushNamed('/mine/edit-profile')
                                .then((v) {
                                  if (v == true) {
                                    _load();
                                  }
                                });
                            break;
                          case MineMenuAction.parentEntry:
                            Navigator.of(context).pushNamed('/mine/parent-entry');
                            break;
                          case MineMenuAction.settings:
                            Navigator.of(context).pushNamed('/settings');
                            break;
                        }
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
        const YiSideStripe(
          direction: 'left',
          topRatio: 0.52,
          width: 14,
          height: 200,
          opacity: 0.7,
          colors: [Color(0xFFC00003), Color(0xFFF0C000), Color(0xFF3D2800)],
        ),
        const YiSideStripe(
          direction: 'right',
          topRatio: 0.58,
          width: 14,
          height: 200,
          opacity: 0.7,
          colors: [Color(0xFF3D2800), Color(0xFFF0C000), Color(0xFFC00003)],
        ),
      ],
    );
  }
}
