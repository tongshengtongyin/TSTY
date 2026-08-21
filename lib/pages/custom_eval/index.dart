import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/yi_side_stripe.dart';
import 'package:tsty_app/components/common/yi_top_bar.dart';
import 'package:tsty_app/components/custom_eval/add_eval_dialog.dart';
import 'package:tsty_app/components/custom_eval/eval_item_card.dart';
import 'package:tsty_app/utils/custom_eval_store.dart';

class CustomEvalListPage extends StatefulWidget {
  const CustomEvalListPage({super.key});

  @override
  State<CustomEvalListPage> createState() => _CustomEvalListPageState();
}

class _CustomEvalListPageState extends State<CustomEvalListPage> {
  List<CustomEvalItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await CustomEvalStore.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    final item = await showAddEvalDialog(context);
    if (item == null) return;
    await CustomEvalStore.add(item);
    await _loadItems();
  }

  Future<void> _deleteItem(String id) async {
    await CustomEvalStore.delete(id);
    await _loadItems();
  }

  void _openSession(CustomEvalItem item) async {
    await Navigator.of(
      context,
    ).pushNamed('/custom-eval/session', arguments: {'item': item});
    // Refresh list when returning (item might have been deleted elsewhere)
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'lib/assets/learn_background.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFFF5E6).withValues(alpha: 0.65),
            ),
          ),

          // Main content
          Column(
            children: [
              YiTopBar(
                title: '课堂测评',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '还没有测评内容',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '点击右下角按钮添加测评吧！',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 80),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return EvalItemCard(
                            item: item,
                            onTap: () => _openSession(item),
                            onDeleted: () => _deleteItem(item.id),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Side decorations
          const YiSideStripe(direction: 'left', topRatio: 0.35),
          const YiSideStripe(direction: 'right', topRatio: 0.45),

          // FAB
          Positioned(
            right: 20,
            bottom: 24,
            child: FloatingActionButton.extended(
              heroTag: 'addEval',
              onPressed: _addItem,
              backgroundColor: red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                '添加测评',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
