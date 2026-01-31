import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/style/app_theme.dart';

Future<int?> showSelectCharacterDialog({
  required BuildContext context,
  int? initialValue,
}) {
  return showYiDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return SelectCharacterDialog(initialValue: initialValue);
    },
  );
}

class SelectCharacterDialog extends StatefulWidget {
  /// 0 = girl, 1 = boy
  final int? initialValue;

  const SelectCharacterDialog({super.key, this.initialValue});

  @override
  State<SelectCharacterDialog> createState() => _SelectCharacterDialogState();
}

class _SelectCharacterDialogState extends State<SelectCharacterDialog> {
  int? _selected;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    Future<void> submit() async {
      if (_selected == null || _submitting) return;
      setState(() => _submitting = true);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!context.mounted) return;
      Navigator.of(context).pop(_selected);
    }

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFDF9), Color(0xFFFFF2E6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '选择你的学习伙伴',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '他们将陪你一起探索彝族文化！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: yellow.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _CharacterOption(
                            selected: _selected == 0,
                            title: '阿依莫',
                            asset: 'lib/assets/girl.webp',
                            borderColor: yellow,
                            highlightColor: red,
                            onTap: () => setState(() => _selected = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CharacterOption(
                            selected: _selected == 1,
                            title: '阿牛惹',
                            asset: 'lib/assets/boy.webp',
                            borderColor: yellow,
                            highlightColor: red,
                            onTap: () => setState(() => _selected = 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: (_selected == null || _submitting)
                          ? null
                          : submit,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: _submitting
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('就选他/她了！', key: ValueKey('text')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String asset;
  final Color borderColor;
  final Color highlightColor;
  final VoidCallback onTap;

  const _CharacterOption({
    required this.selected,
    required this.title,
    required this.asset,
    required this.borderColor,
    required this.highlightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? highlightColor.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.75);
    final border = selected
        ? highlightColor
        : borderColor.withValues(alpha: 0.7);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: selected ? 2.2 : 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.12 : 0.08),
              blurRadius: selected ? 18 : 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 0.54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D2800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
