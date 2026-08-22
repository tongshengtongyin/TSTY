import 'package:flutter/material.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/custom_eval_store.dart';

/// Category option definition.
class _CategoryOption {
  final String label;
  final String value;
  const _CategoryOption(this.label, this.value);
}

const _categories = [
  _CategoryOption('字', 'read_syllable'),
  _CategoryOption('词', 'read_word'),
  _CategoryOption('句', 'read_sentence'),
  _CategoryOption('篇', 'read_chapter'),
];

/// Shows the add-evaluation dialog. Returns the created item or null.
Future<CustomEvalItem?> showAddEvalDialog(BuildContext context) {
  return showGeneralDialog<CustomEvalItem>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _AddEvalDialogContent();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final t = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: t,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(t),
          child: child,
        ),
      );
    },
  );
}

class _AddEvalDialogContent extends StatefulWidget {
  const _AddEvalDialogContent();

  @override
  State<_AddEvalDialogContent> createState() => _AddEvalDialogContentState();
}

class _AddEvalDialogContentState extends State<_AddEvalDialogContent> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String? _titleError;
  String? _textError;

  String get _selectedCategory => _categories[_selectedCategoryIndex].value;

  String _hintForCategory() {
    switch (_selectedCategory) {
      case 'read_syllable':
        return '请输入1个汉字，如：花';
      case 'read_word':
        return '请输入2-4个汉字，如：你好';
      case 'read_sentence':
        return '请输入一句话（≥5个字符）';
      case 'read_chapter':
        return '请输入一段话（≥10个字符）';
      default:
        return '请输入测评内容';
    }
  }

  /// Count Chinese characters in text.
  int _chineseCharCount(String text) {
    int count = 0;
    for (final rune in text.runes) {
      if (rune >= 0x4E00 && rune <= 0x9FFF) count++;
    }
    return count;
  }

  String? _validateText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '请输入测评内容';

    final chineseCount = _chineseCharCount(trimmed);

    switch (_selectedCategory) {
      case 'read_syllable':
        if (chineseCount != 1) return '字类型需要恰好1个汉字';
        break;
      case 'read_word':
        if (chineseCount < 2 || chineseCount > 4) return '词类型需要2-4个汉字';
        break;
      case 'read_sentence':
        if (trimmed.length < 5) return '句类型至少需要5个字符';
        break;
      case 'read_chapter':
        if (trimmed.length < 10) return '篇类型至少需要10个字符';
        break;
    }
    return null;
  }

  void _submit() {
    final titleText = _titleController.text.trim();
    final evalText = _textController.text.trim();

    String? titleErr;
    if (titleText.isEmpty) titleErr = '请输入测评名称';

    final textErr = _validateText(evalText);

    setState(() {
      _titleError = titleErr;
      _textError = textErr;
    });

    if (titleErr != null || textErr != null) return;

    final item = CustomEvalItem(
      id: CustomEvalItem.generateId(),
      title: titleText,
      text: evalText,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(item);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '添加测评',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title input
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '测评名称',
                        hintText: '请输入测评名称',
                        errorText: _titleError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: red, width: 2),
                        ),
                      ),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 12),

                    // Category chips
                    const Text(
                      '类型',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: List.generate(_categories.length, (i) {
                        final selected = i == _selectedCategoryIndex;
                        return ChoiceChip(
                          label: Text(_categories[i].label),
                          selected: selected,
                          selectedColor: red.withValues(alpha: 0.18),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? red
                                : yellow.withValues(alpha: 0.6),
                            width: selected ? 2 : 1.5,
                          ),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected ? red : const Color(0xFF3D2800),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryIndex = i;
                              _textError = null;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Text input
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: '测评内容',
                        hintText: _hintForCategory(),
                        errorText: _textError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: red, width: 2),
                        ),
                      ),
                      maxLines: 4,
                      minLines: 2,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              side: BorderSide(color: yellow, width: 2),
                              foregroundColor: const Color(0xFF3D2800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.of(context).pop(null),
                            child: const Text(
                              '取消',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              '添加',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
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
