import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/viewmodels/learn.dart';

class LevelAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  bool _isShengmuContent(LevelContent content) {
    final s = content.contentType.trim().toLowerCase();
    return s.contains('shengmu') || content.contentType.contains('声母');
  }

  String _shengmuAssetKey(String raw) {
    return raw.trim().toLowerCase();
  }

  String _shengmuAudioAsset(String key) {
    return 'lib/assets/learn/shengmu/audio/$key.mp3';
  }

  Future<void> playStandard({
    required LevelContent content,
    VoidCallback? onUnsupported,
    VoidCallback? onMissingAsset,
  }) async {
    if (!_isShengmuContent(content)) {
      onUnsupported?.call();
      return;
    }

    final key = _shengmuAssetKey(content.contentValue);
    if (key.isEmpty) {
      onMissingAsset?.call();
      return;
    }

    try {
      final bytes = await rootBundle.load(_shengmuAudioAsset(key));
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
