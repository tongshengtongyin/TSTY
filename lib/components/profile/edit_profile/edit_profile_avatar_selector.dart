import 'package:flutter/material.dart';

class EditProfileAvatarSelector extends StatelessWidget {
  final List<String> avatarAssets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const EditProfileAvatarSelector({
    super.key,
    required this.avatarAssets,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(avatarAssets.length, (index) {
        final selected = index == selectedIndex;

        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? red : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(avatarAssets[index], fit: BoxFit.cover),
            ),
          ),
        );
      }),
    );
  }
}
