import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/viewmodels/learn.dart';

class LevelAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  bool _isShengmuContent(LevelContent content) {
    final s = content.contentType.trim().toLowerCase();
    return s.contains('shengmu') || content.contentType.contains('声母');
  }

  bool _isYunmuContent(LevelContent content) {
    final s = content.contentType.trim().toLowerCase();
    return s.contains('yunmu') || content.contentType.contains('韵母');
  }

  String _assetKey(String raw) {
    var s = raw.trim().toLowerCase();
    s = s.replaceAll('ü', 'v');
    return s;
  }

  String _shengmuAudioAsset(String key) {
    return 'lib/assets/learn/shengmu/audio/$key.mp3';
  }

  String _yunmuAudioAsset(String key) {
    return 'lib/assets/learn/yunmu/audio/$key.mp3';
  }

  Future<void> playStandard({
    required LevelContent content,
    VoidCallback? onUnsupported,
    VoidCallback? onMissingAsset,
  }) async {
    String? assetPath;
    if (_isShengmuContent(content)) {
      assetPath = _shengmuAudioAsset(_assetKey(content.contentValue));
    } else if (_isYunmuContent(content)) {
      assetPath = _yunmuAudioAsset(_assetKey(content.contentValue));
    }

    if (assetPath == null) {
      onUnsupported?.call();
      return;
    }

    try {
      final bytes = await rootBundle.load(assetPath);
      await _player.stop();
      await _player.play(BytesSource(bytes.buffer.asUint8List()));
    } catch (_) {
      onMissingAsset?.call();
    }
  }

  void dispose() {
    _player.dispose();
  }
}
