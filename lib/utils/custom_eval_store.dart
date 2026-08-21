import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for a custom evaluation item.
class CustomEvalItem {
  final String id;
  final String title;
  final String text;
  final String
  category; // read_syllable / read_word / read_sentence / read_chapter
  final DateTime createdAt;

  const CustomEvalItem({
    required this.id,
    required this.title,
    required this.text,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJSON() => {
    'id': id,
    'title': title,
    'text': text,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomEvalItem.fromJSON(Map<String, dynamic> json) {
    return CustomEvalItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'read_syllable',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Generate a unique ID based on timestamp + hex suffix.
  static String generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    var x = now;
    const chars = '0123456789abcdef';
    final buf = StringBuffer();
    for (var i = 0; i < 8; i++) {
      x = (x * 1103515245 + 12345) & 0x7fffffff;
      buf.write(chars[x % 16]);
    }
    return '${now}_${buf.toString()}';
  }
}

/// Persistent store for custom evaluation items using SharedPreferences.
class CustomEvalStore {
  static const _key = 'custom_eval.items.json';
  static const _maxItems = 100;

  static Future<List<CustomEvalItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => CustomEvalItem.fromJSON(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(CustomEvalItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, item);
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJSON()).toList()),
    );
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJSON()).toList()),
    );
  }
}
