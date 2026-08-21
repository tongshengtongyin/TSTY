import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/custom_eval_store.dart';

/// Category label mapping for display.
String _categoryLabel(String category) {
  switch (category) {
    case 'read_syllable':
      return '字';
    case 'read_word':
      return '词';
    case 'read_sentence':
      return '句';
    case 'read_chapter':
      return '篇';
    default:
      return '字';
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'read_syllable':
      return const Color(0xFFE53935);
    case 'read_word':
      return const Color(0xFFFF9800);
    case 'read_sentence':
      return const Color(0xFF43A047);
    case 'read_chapter':
      return const Color(0xFF1E88E5);
    default:
      return const Color(0xFFE53935);
  }
}

class EvalItemCard extends StatelessWidget {
  final CustomEvalItem item;
  final VoidCallback onTap;
  final VoidCallback onDeleted;

  const EvalItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final catLabel = _categoryLabel(item.category);
    final catColor = _categoryColor(item.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: yellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3D2800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: catColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          catLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () async {
                final confirmed = await showYiConfirmDialog(
                  context: context,
                  title: '删除测评',
                  message: '确定要删除"${item.title}"吗？',
                  danger: true,
                  confirmText: '删除',
                );
                if (confirmed == true) {
                  onDeleted();
                }
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.withValues(alpha: 0.55),
                size: 22,
              ),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
