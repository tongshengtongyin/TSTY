import 'package:tsty_app/viewmodels/learn.dart';

String _formatPinyinForDisplay(String input) {
  var s = input.trim();
  if (s.isEmpty) return s;

  s = s.replaceAll('u:', 'ü').replaceAll('U:', 'Ü');
  s = s.replaceAll('v', 'ü').replaceAll('V', 'Ü');

  return s.replaceAllMapped(RegExp(r'([A-Za-zÜü]+)([0-5])'), (m) {
    final syllable = m.group(1) ?? '';
    final tone = int.tryParse(m.group(2) ?? '') ?? 0;
    return _applyToneToSyllable(syllable, tone);
  });
}

String _applyToneToSyllable(String syllable, int tone) {
  if (tone <= 0 || tone >= 5) {
    return syllable;
  }

  final lower = syllable.toLowerCase();

  int vowelIndex = -1;
  if (lower.contains('a')) {
    vowelIndex = lower.indexOf('a');
  } else if (lower.contains('e')) {
    vowelIndex = lower.indexOf('e');
  } else if (lower.contains('ou')) {
    vowelIndex = lower.indexOf('o');
  } else if (lower.contains('o')) {
    vowelIndex = lower.indexOf('o');
  } else if (lower.contains('iu')) {
    vowelIndex = lower.indexOf('u');
  } else if (lower.contains('ui')) {
    vowelIndex = lower.indexOf('i');
  } else {
    const vowels = 'aeiouü';
    for (var i = lower.length - 1; i >= 0; i--) {
      if (vowels.contains(lower[i])) {
        vowelIndex = i;
        break;
      }
    }
  }

  if (vowelIndex < 0) return syllable;
  final chars = syllable.split('');
  chars[vowelIndex] = _toneVowel(chars[vowelIndex], tone);
  return chars.join();
}

String _toneVowel(String vowel, int tone) {
  const toneMap = {
    'a': ['ā', 'á', 'ǎ', 'à'],
    'e': ['ē', 'é', 'ě', 'è'],
    'i': ['ī', 'í', 'ǐ', 'ì'],
    'o': ['ō', 'ó', 'ǒ', 'ò'],
    'u': ['ū', 'ú', 'ǔ', 'ù'],
    'ü': ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
    'A': ['Ā', 'Á', 'Ǎ', 'À'],
    'E': ['Ē', 'É', 'Ě', 'È'],
    'I': ['Ī', 'Í', 'Ǐ', 'Ì'],
    'O': ['Ō', 'Ó', 'Ǒ', 'Ò'],
    'U': ['Ū', 'Ú', 'Ǔ', 'Ù'],
    'Ü': ['Ǖ', 'Ǘ', 'Ǚ', 'Ǜ'],
  };
  final list = toneMap[vowel];
  if (list == null) return vowel;
  final idx = tone - 1;
  if (idx < 0 || idx >= list.length) return vowel;
  return list[idx];
}

bool _isShengmuContent(LevelContent content) {
  final s = content.contentType.trim().toLowerCase();
  return s.contains('shengmu') || content.contentType.contains('声母');
}

bool _isYunmuContent(LevelContent content) {
  final s = content.contentType.trim().toLowerCase();
  return s.contains('yunmu') || content.contentType.contains('韵母');
}

bool _isHanziContent(LevelContent content) {
  final s = content.contentType.trim().toLowerCase();
  return s.contains('hanzi') || content.contentType.contains('汉字');
}

bool _isCiyuContent(LevelContent content) {
  final s = content.contentType.trim().toLowerCase();
  return s.contains('ciyu') ||
      s.contains('word') ||
      content.contentType.contains('词语');
}

String _hanziImageAsset(String value) {
  final key = value.trim();
  return 'lib/assets/learn/hanzi/$key.webp';
}

String _ciyuImageAsset(String value) {
  final key = value.trim();
  return 'lib/assets/learn/ciyu/$key.webp';
}

String _shengmuAssetKey(String raw) {
  return raw.trim().toLowerCase();
}

String _shengmuImageAsset(String key) {
  return 'lib/assets/learn/shengmu/image/$key.webp';
}

String _yunmuAssetKey(String raw) {
  var s = raw.trim().toLowerCase();
  s = s.replaceAll('v', 'ü');
  return s;
}

String _yunmuImageAsset(String key) {
  return 'lib/assets/learn/yunmu/image/$key.webp';
}

class LevelDetailViewModel {
  late final int currentLevel;
  late final int totalLevels;
  final List<String> levelIds;

  LevelContent? content;
  int tipIndex = 0;

  String get character => content?.contentValue ?? '';

  String get pinyin {
    final c = content;
    if (c == null) return '';
    if (_isShengmuContent(c) || _isYunmuContent(c)) {
      return '';
    }
    return _formatPinyinForDisplay(c.pinyinText);
  }

  String get hintImage {
    final c = content;
    if (c == null) return 'lib/assets/father.webp';
    if (_isShengmuContent(c)) {
      final key = _shengmuAssetKey(c.contentValue);
      if (key.isNotEmpty) {
        return _shengmuImageAsset(key);
      }
    }
    if (_isYunmuContent(c)) {
      final key = _yunmuAssetKey(c.contentValue);
      if (key.isNotEmpty) {
        return _yunmuImageAsset(key);
      }
    }
    if (_isHanziContent(c)) {
      final key = c.contentValue.trim();
      if (key.isNotEmpty) {
        return _hanziImageAsset(key);
      }
    }
    if (_isCiyuContent(c)) {
      final key = c.contentValue.trim();
      if (key.isNotEmpty) {
        return _ciyuImageAsset(key);
      }
    }
    return 'lib/assets/father.webp';
  }

  String get hintLabel => content?.exampleWord ?? '';

  String get exampleText {
    final c = content;
    if (c == null) return '';
    return '${c.exampleWord} 的 ${c.contentValue}';
  }

  List<String> get tips => content?.tips ?? const [];

  LevelDetailViewModel({
    required this.currentLevel,
    required this.totalLevels,
    required this.levelIds,
  });

  void setContent(LevelContent? newContent) {
    content = newContent;
    if (newContent == null) return;
    tipIndex = 0;
  }

  String nextTip() {
    final list = tips;
    if (list.isEmpty) return '';
    final idx = tipIndex % list.length;
    final result = list[idx];
    tipIndex = (tipIndex + 1) % list.length;
    return result;
  }
}
