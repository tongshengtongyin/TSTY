import 'package:flutter/material.dart';
import 'package:tsty_app/components/learn/learn_header.dart';
import 'package:tsty_app/components/learn/learn_level_map.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  Widget build(BuildContext context) {
    final levels = _buildDemoLevels();
    return Column(
      children: [
        const SizedBox(height: 12),
        const SizedBox(height: 120, child: LearnHeader()),
        Expanded(
          child: LearnLevelMap(
            levels: levels,
            onLevelTap: (level) {
              Navigator.of(context).pushNamed(
                '/learn/level-detail',
                arguments: {
                  'levelIndex': level.id,
                  'totalLevels': 23,
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

List<LearnLevelData> _buildDemoLevels() {
  return const [
    LearnLevelData(id: 1, status: LearnLevelStatus.passed, flowers: 3),
    LearnLevelData(id: 2, status: LearnLevelStatus.passed, flowers: 2),
    LearnLevelData(id: 3, status: LearnLevelStatus.passed, flowers: 1),
    LearnLevelData(id: 4, status: LearnLevelStatus.unlocked),
    LearnLevelData(id: 5, status: LearnLevelStatus.locked),
    LearnLevelData(id: 6, status: LearnLevelStatus.locked),
    LearnLevelData(id: 7, status: LearnLevelStatus.locked),
    LearnLevelData(id: 8, status: LearnLevelStatus.locked),
    LearnLevelData(id: 9, status: LearnLevelStatus.locked),
    LearnLevelData(id: 10, status: LearnLevelStatus.locked),
  ];
}
