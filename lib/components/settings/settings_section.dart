import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const SettingsSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: yellow, width: 3),
      ),
      child: Column(children: _withDividers(children, const Color(0x4DF0C000))),
    );
  }

  List<Widget> _withDividers(List<Widget> items, Color divider) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(
          Container(
            height: 1,
            color: divider,
            margin: const EdgeInsets.only(left: 16),
          ),
        );
      }
    }
    return out;
  }
}
