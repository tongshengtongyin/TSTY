import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tsty_app/utils/ToastUtils.dart';

class FlutterTtsService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  Completer<void>? _speakCompleter;

  Future<void> _ensureInit() async {
    if (_isInitialized && _flutterTts != null) return;

    _flutterTts = FlutterTts();

    await _flutterTts!.setLanguage('zh-CN');
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(1.0);

    _flutterTts!.setCompletionHandler(() {
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    _flutterTts!.setErrorHandler((msg) {
      if (kDebugMode) {
        debugPrint('FlutterTts error: $msg');
      }
      _speakCompleter?.completeError(Exception(msg));
      _speakCompleter = null;
    });

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

      await _flutterTts!.stop();

      _speakCompleter = Completer<void>();
      await _flutterTts!.speak(trimmed);

      await _speakCompleter?.future;
      onComplete?.call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FlutterTts speak failed: $e');
      }
      if (context.mounted) {
        ToastUtils.showToast(context, '语音合成失败');
      }
      onComplete?.call();
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }

  void dispose() {
    _flutterTts?.stop();
    _flutterTts = null;
    _isInitialized = false;
    _speakCompleter = null;
  }
}
