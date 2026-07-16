import 'package:flutter/material.dart';

class ParentCenterPlaceholderPage extends StatelessWidget {
  const ParentCenterPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家长中心')),
      body: const Center(child: Text('家长中心功能开发中')),
    );
  }
}
