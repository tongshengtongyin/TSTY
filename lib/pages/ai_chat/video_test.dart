import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTestPage extends StatefulWidget {
  const VideoTestPage({super.key});

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'lib/assets/video/AniuRe-waiting.mp4',
    );
    _controller.addListener(() {
      print('Video listener:');
      print('  isInitialized: ${_controller.value.isInitialized}');
      print('  isPlaying: ${_controller.value.isPlaying}');
      print('  hasError: ${_controller.value.hasError}');
      print('  errorDescription: ${_controller.value.errorDescription}');
    });
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      print('Initializing video...');
      await _controller.initialize();
      _controller.setLooping(true);
      setState(() => _initialized = true);
      print('Video initialized!');
      print('  duration: ${_controller.value.duration}');
      print('  size: ${_controller.value.size}');
      print('  aspectRatio: ${_controller.value.aspectRatio}');
      await _controller.play();
      print('Video playing!');
    } catch (e) {
      print('Video init failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Test')),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Text('Loading...'),
      ),
    );
  }
}
