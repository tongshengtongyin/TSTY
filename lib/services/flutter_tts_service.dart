import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts_dart/edge_tts_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/utils/toast_utils.dart';

class FlutterTtsService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;
  Future<void>? _currentPlay;

  Future<void> _ensureInit() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<void> speak({
    required BuildContext context,
    required String text,
    VoidCallback? onComplete,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      await _ensureInit();

      if (_currentPlay != null) {
        try {
          await _player.stop();
        } catch (_) {}
      }

      final audioChunks = <int>[];
      bool success = false;

      final voices = ['zh-CN-YunxiaNeural', 'zh-CN-XiaoxiaoNeural'];

      for (final voice in voices) {
        audioChunks.clear();
        try {
          final communicate = Communicate(
            text: trimmed,
            voice: voice,
            rate: '-15%',
            volume: '+10%',
            pitch: '+5Hz',
          );

          _currentPlay = () async {
            try {
              await for (final chunk in communicate.stream()) {
                if (chunk.type == 'audio' && chunk.audioData != null) {
                  audioChunks.addAll(chunk.audioData!);
                }
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Edge TTS stream failed for $voice: $e');
              }
            }
          }();

          await _currentPlay;

          if (audioChunks.isNotEmpty) {
            success = true;
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Edge TTS failed for $voice: $e');
          }
          continue;
        }
      }

      if (!success || audioChunks.isEmpty) {
        if (context.mounted) {
          ToastUtils.showToast(context, '语音合成失败：无音频数据');
        }
        onComplete?.call();
        return;
      }

      final audioBytes = Uint8List.fromList(audioChunks);
      await _player.play(BytesSource(audioBytes));
      onComplete?.call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Edge TTS speak failed: $e');
      }
      if (context.mounted) {
        ToastUtils.showToast(context, '语音合成失败');
      }
      onComplete?.call();
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    try {
      _player.stop();
      _player.dispose();
    } catch (_) {}
    _isInitialized = false;
    _currentPlay = null;
  }
}
