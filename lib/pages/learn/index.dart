import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/api/learn.dart';
import 'package:tsty_app/components/learn/learn_header.dart';
import 'package:tsty_app/components/learn/learn_level_map.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/viewmodels/learn.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  int _selectedUnitIndex = 0;
  bool _loading = false;
  bool _pullUpRefreshing = false;
  double _pullUpExtent = 0;
  String _currentUnitId = UnitConstants.initialUnitId;
  int _totalLevels = 23;
  List<LearnLevelData> _levelData = const [];
  int _loadSeq = 0;
  List<LearnUnitProgress> _unitProgressCache = List<LearnUnitProgress>.generate(
    4,
    (_) => const LearnUnitProgress(completed: 0, total: 0),
  );

  Future<UnitProgressResponse> _getLevels(String unitId) async {
    return await getUnitProgressAPI(unitId);
  }

  Future<UnitProgressResponse> _getLevelsWithRetry(String unitId) async {
    const maxAttempts = 5;
    var delay = const Duration(milliseconds: 300);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _getLevels(unitId);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'getUnitProgressAPI failed (attempt $attempt/$maxAttempts, unitId=$unitId): $e',
          );
        }
        if (attempt >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    throw Exception('getUnitProgressAPI failed');
  }

  Future<void> _triggerPullUpRefresh() async {
    if (_pullUpRefreshing || _loading) return;

    setState(() {
      _pullUpRefreshing = true;
      _pullUpExtent = 0;
    });

    try {
      await _loadUnit(_selectedUnitIndex);
    } finally {
      if (mounted) {
        setState(() {
          _pullUpRefreshing = false;
        });
      }
    }
  }

  String _unitIdFromIndex(int index) {
    switch (index) {
      case 0:
        return UnitConstants.initialUnitId;
      case 1:
        return UnitConstants.finalUnitId;
      case 2:
        return UnitConstants.hanziUnitId;
      case 3:
        return UnitConstants.wordUnitId;
      default:
        return UnitConstants.initialUnitId;
    }
  }

  LearnLevelStatus _mapStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'perfect') {
      return LearnLevelStatus.perfect;
    }
    if (s == 'completed') {
      return LearnLevelStatus.completed;
    }
    if (s == 'unlocked' || s == 'open' || s == 'available') {
      return LearnLevelStatus.unlocked;
    }
    if (s == 'locked') {
      return LearnLevelStatus.locked;
    }

    if (s == 'passed' || s == 'complete' || s == 'done' || s == 'success') {
      return LearnLevelStatus.completed;
    }

    return LearnLevelStatus.locked;
  }

  int _uuidOrderKey(String uuid) {
    final s = uuid.trim();
    if (s.length < 4) return 1 << 30;
    final suffix = s.substring(s.length - 4);
    return int.tryParse(suffix, radix: 16) ?? int.tryParse(suffix) ?? (1 << 30);
  }

  Future<void> _loadUnit(int index) async {
    final seq = ++_loadSeq;
    final unitId = _unitIdFromIndex(index);

    setState(() {
      _selectedUnitIndex = index;
      _currentUnitId = unitId;
      _loading = true;
    });

    try {
      final resp = await _getLevelsWithRetry(unitId);
      if (!mounted || seq != _loadSeq) return;

      final nextProgress = List<LearnUnitProgress>.from(_unitProgressCache);
      if (index >= 0 && index < nextProgress.length) {
        nextProgress[index] = LearnUnitProgress(
          completed: resp.completedLevels,
          total: resp.totalLevels,
        );
      }

      final items = List<LevelProgressItem>.from(resp.levels)
        ..sort(
          (a, b) =>
              _uuidOrderKey(a.levelId).compareTo(_uuidOrderKey(b.levelId)),
        );

      final total = resp.totalLevels;
      final data = List<LearnLevelData>.generate(total, (i) {
        final id = i + 1;
        if (i >= items.length) {
          return LearnLevelData(id: id, status: LearnLevelStatus.locked);
        }

        final item = items[i];
        return LearnLevelData(
          id: id,
          levelId: item.levelId,
          status: _mapStatus(item.unlockStatus),
          flowers: item.stars.clamp(0, 3),
        );
      });

      setState(() {
        _totalLevels = total;
        _levelData = data;
        _unitProgressCache = nextProgress;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        _levelData = const [];
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadUnit(_selectedUnitIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    const pullUpTrigger = 80.0;

    return Column(
      children: [
        SizedBox(
          height: 100,
          child: LearnHeader(
            selectedIndex: _selectedUnitIndex,
            onUnitTap: _loadUnit,
            unitProgress: _unitProgressCache,
          ),
        ),
        Expanded(
          child: _loading && _levelData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _levelData.isEmpty
                  ? const Center(child: Text('暂无关卡'))
                  : Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final atBottom = notification.metrics.pixels <=
                                (notification.metrics.minScrollExtent + 0.5);

                            if (!atBottom && _pullUpExtent != 0) {
                              setState(() {
                                _pullUpExtent = 0;
                              });
                            }

                            if (notification is OverscrollNotification) {
                              if (atBottom &&
                                  notification.overscroll < 0 &&
                                  !_pullUpRefreshing &&
                                  !_loading) {
                                final next =
                                    _pullUpExtent + (-notification.overscroll);
                                if (next != _pullUpExtent) {
                                  setState(() {
                                    _pullUpExtent = next;
                                  });
                                }
                              }
                            }

                            if (notification is ScrollEndNotification) {
                              final extent = _pullUpExtent;
                              if (extent >= pullUpTrigger) {
                                _triggerPullUpRefresh();
                              } else if (extent != 0) {
                                setState(() {
                                  _pullUpExtent = 0;
                                });
                              }
                            }

                            return false;
                          },
                          child: LearnLevelMap(
                            levels: _levelData,
                            onLevelTap: (level) {
                              () async {
                                final localContext = context;
                                final levelId = level.levelId;
                                if (levelId == null || levelId.isEmpty) return;

                                final rootNavigator = Navigator.of(
                                  localContext,
                                  rootNavigator: true,
                                );
                                showDialog<void>(
                                  context: localContext,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                try {
                                  final content =
                                      await getLevelDetailsAPI(levelId);
                                  if (!localContext.mounted) return;

                                  if (rootNavigator.mounted &&
                                      rootNavigator.canPop()) {
                                    rootNavigator.pop();
                                  }

                                  Navigator.of(localContext).pushNamed(
                                    '/learn/level-detail',
                                    arguments: {
                                      'unitId': _currentUnitId,
                                      'levelId': levelId,
                                      'levelIndex': level.id,
                                      'totalLevels': _totalLevels,
                                      'levelContent': content,
                                      'levelIds': _levelData
                                          .map((e) => e.levelId ?? '')
                                          .toList(growable: false),
                                    },
                                  );
                                } catch (_) {
                                  if (!localContext.mounted) return;

                                  if (rootNavigator.mounted &&
                                      rootNavigator.canPop()) {
                                    rootNavigator.pop();
                                  }

                                  ScaffoldMessenger.of(localContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text('获取关卡详情失败'),
                                    ),
                                  );
                                }
                              }();
                            },
                          ),
                        ),
                        if (_pullUpRefreshing)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 12,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}
