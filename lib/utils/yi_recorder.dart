import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum YiRecorderFormat { pcm16, wav }

enum YiRecorderState { idle, recording, stopping, error }

class YiRecorderConfig {
  final YiRecorderFormat format;
  final int sampleRate;
  final int numChannels;
  final Duration amplitudeInterval;
  final Duration durationTick;

  const YiRecorderConfig({
    this.format = YiRecorderFormat.wav,
    this.sampleRate = 16000,
    this.numChannels = 1,
    this.amplitudeInterval = const Duration(milliseconds: 100),
    this.durationTick = const Duration(milliseconds: 200),
  });
}

class YiRecorderResult {
  final String path;
  final Duration duration;
  final YiRecorderFormat format;
  final int sampleRate;
  final int numChannels;

  const YiRecorderResult({
    required this.path,
    required this.duration,
    required this.format,
    required this.sampleRate,
    required this.numChannels,
  });
}

class YiRecorderController {
  final AudioRecorder _recorder = AudioRecorder();

  final ValueNotifier<YiRecorderState> state = ValueNotifier<YiRecorderState>(
    YiRecorderState.idle,
  );

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  Stream<Duration> get durationStream => _durationController.stream;

  Stream<double> get amplitudeStream => _amplitudeController.stream;

  YiRecorderConfig _config = const YiRecorderConfig();

  Timer? _durationTimer;
  Stopwatch? _stopwatch;
  StreamSubscription<Amplitude>? _amplitudeSub;

  String? _currentPath;

  bool get isRecording => state.value == YiRecorderState.recording;

  Future<bool> hasPermission({bool request = true}) {
    return _recorder.hasPermission(request: request);
  }

  Future<String> _defaultOutputPath(YiRecorderFormat format) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = format == YiRecorderFormat.wav ? 'wav' : 'pcm';
    if (kIsWeb) {
      return 'rec_$ts.$ext';
    }
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, 'rec_$ts.$ext');
  }

  Future<void> start({
    YiRecorderConfig config = const YiRecorderConfig(),
    String? path,
  }) async {
    if (isRecording) return;

    final ok = await hasPermission();
    if (!ok) {
      state.value = YiRecorderState.error;
      throw StateError('no_microphone_permission');
    }

    _config = config;
    _currentPath = path ?? await _defaultOutputPath(config.format);

    state.value = YiRecorderState.recording;
    _stopwatch = Stopwatch()..start();

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(_config.durationTick, (_) {
      final sw = _stopwatch;
      if (sw == null) return;
      if (!_durationController.isClosed) {
        _durationController.add(sw.elapsed);
      }
    });

    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder
        .onAmplitudeChanged(_config.amplitudeInterval)
        .listen((amp) {
          final db = amp.current;
          final normalized = _normalizeDb(db);
          if (!_amplitudeController.isClosed) {
            _amplitudeController.add(normalized);
          }
        });

    final encoder = _config.format == YiRecorderFormat.wav
        ? AudioEncoder.wav
        : AudioEncoder.pcm16bits;

    try {
      await _recorder.start(
        RecordConfig(
          encoder: encoder,
          sampleRate: _config.sampleRate,
          numChannels: _config.numChannels,
        ),
        path: _currentPath ?? await _defaultOutputPath(config.format),
      );
    } catch (_) {
      _durationTimer?.cancel();
      _durationTimer = null;

      await _amplitudeSub?.cancel();
      _amplitudeSub = null;

      _stopwatch?.stop();
      _stopwatch = null;

      state.value = YiRecorderState.error;
      try {
        await _recorder.cancel();
      } catch (_) {}
      state.value = YiRecorderState.idle;
      rethrow;
    }
  }

  Future<YiRecorderResult?> stop() async {
    if (!isRecording) return null;
    state.value = YiRecorderState.stopping;

    _durationTimer?.cancel();
    _durationTimer = null;

    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    final sw = _stopwatch;
    sw?.stop();

    final path = await _recorder.stop();
    final duration = sw?.elapsed ?? Duration.zero;

    _stopwatch = null;

    state.value = YiRecorderState.idle;

    final effectivePath = path ?? _currentPath;
    if (effectivePath == null || effectivePath.isEmpty) return null;

    return YiRecorderResult(
      path: effectivePath,
      duration: duration,
      format: _config.format,
      sampleRate: _config.sampleRate,
      numChannels: _config.numChannels,
    );
  }

  Future<void> cancel() async {
    if (!isRecording) return;

    _durationTimer?.cancel();
    _durationTimer = null;

    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    _stopwatch?.stop();
    _stopwatch = null;

    await _recorder.cancel();
    state.value = YiRecorderState.idle;
  }

  void dispose() {
    _durationTimer?.cancel();
    _durationTimer = null;

    _amplitudeSub?.cancel();
    _amplitudeSub = null;

    _stopwatch?.stop();
    _stopwatch = null;

    _recorder.dispose();

    state.dispose();
    _durationController.close();
    _amplitudeController.close();
  }

  double _normalizeDb(double db) {
    if (db.isNaN || db.isInfinite) return 0.0;
    const floor = -50.0;
    if (db <= floor) return 0.0;
    if (db >= 0.0) return 1.0;
    return (db - floor) / (0.0 - floor);
  }
}
