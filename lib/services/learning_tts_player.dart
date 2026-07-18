import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/api/tts.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/services/flutter_tts_service.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/user_prefs.dart';
import 'package:tsty_app/utils/yi_speech_evaluator.dart';
import 'package:tsty_app/utils/yi_tts_synthesizer.dart';

class LearningTtsPlayer {
  final AudioPlayer _player = AudioPlayer();
  final Map<String, Uint8List> _memCache = <String, Uint8List>{};
  final FlutterTtsService _flutterTts = FlutterTtsService();

  Future<void>? _current;

  static final Uri _ttsEndpoint = Uri.parse(
    'wss://cbm01.cn-huabei-1.xf-yun.com/v1/private/mcd9m97e6',
  );
  static const String _defaultVcn = 'x6_lingyouyou_pro';

  Future<TtsAuthCache?> _ensureAuth() async {
    final cached = await UserPrefs.getTtsAuthCache();
    if (cached != null) {
      final ageMs = DateTime.now().millisecondsSinceEpoch - cached.timestamp;
      final ttlMs = const Duration(minutes: 4).inMilliseconds;
      if (ageMs >= 0 && ageMs <= ttlMs) {
        return cached;
      }
      await UserPrefs.clearTtsAuthCache();
    }

    try {
      final auth = await getTtsAuthAPI();
      await UserPrefs.setTtsAuthCache(auth);
      return auth;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getTtsAuthAPI failed: $e');
      }
      return null;
    }
  }

  String _cacheKey({required String text}) {
    return '$_defaultVcn|$text';
  }

  Future<void> speak({
    required BuildContext context,
    required String text,
    VoidCallback? onComplete,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final engine = await UserPrefs.getTtsEngine();
    if (engine == 'flutter_tts') {
      await _flutterTts.speak(
        context: context,
        text: trimmed,
        onComplete: onComplete,
      );
      return;
    }

    final prev = _current;
    _current = () async {
      try {
        await _player.stop();
      } catch (_) {}

      final key = _cacheKey(text: trimmed);
      final cachedBytes = _memCache[key];
      if (cachedBytes != null && cachedBytes.isNotEmpty) {
        await _player.play(BytesSource(cachedBytes));
        onComplete?.call();
        return;
      }

      final auth = await _ensureAuth();
      if (auth == null) {
        if (kDebugMode) {
          debugPrint('TTS auth failed, fallback to flutter_tts');
        }
        await _flutterTts.speak(
          context: context,
          text: trimmed,
          onComplete: onComplete,
        );
        return;
      }

      final authQuery = YiIseAuthQuery(
        authorization: auth.authorization,
        host: auth.host,
        date: auth.date,
      );

      final synthesizer = YiTtsSynthesizer(
        YiTtsConfig(
          endpoint: _ttsEndpoint,
          appId: auth.appId,
          vcn: _defaultVcn,
          serviceType: auth.serviceType.isEmpty ? 'tts' : auth.serviceType,
        ),
      );

      Uint8List bytes;
      try {
        bytes = await synthesizer.synthesizeToBytes(
          text: trimmed,
          authQuery: authQuery,
          timeout: GlobalConstants.timeoutDuration,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('TTS synthesize failed, fallback to flutter_tts: $e');
        }
        await _flutterTts.speak(
          context: context,
          text: trimmed,
          onComplete: onComplete,
        );
        return;
      }

      _memCache[key] = bytes;
      await _player.play(BytesSource(bytes));
      onComplete?.call();
    }();

    if (prev != null) {
      try {
        await prev;
      } catch (_) {}
    }
    try {
      await _current;
    } catch (_) {}
  }

  void dispose() {
    _memCache.clear();
    _flutterTts.dispose();
    try {
      _player.dispose();
    } catch (_) {}
  }
}
