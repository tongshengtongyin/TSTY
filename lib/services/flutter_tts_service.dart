import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts_dart/edge_tts_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/utils/ToastUtils.dart';

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

      final communicate = Communicate(
        text: trimmed,
        voice: 'zh-CN-XiaoxiaoNeural',
        rate: '+0%',
        volume: '+0%',
        pitch: '+0Hz',
      );

      final audioChunks = <int>[];

      _currentPlay = () async {
        try {
          await for (final chunk in communicate.stream()) {
            if (chunk.type == 'audio' && chunk.audioData != null) {
              audioChunks.addAll(chunk.audioData!);
            }
          }

          if (audioChunks.isEmpty) {
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
            debugPrint('Edge TTS play failed: $e');
          }
          if (context.mounted) {
            ToastUtils.showToast(context, '语音合成失败');
          }
          onComplete?.call();
        }
      }();

      await _currentPlay;
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
