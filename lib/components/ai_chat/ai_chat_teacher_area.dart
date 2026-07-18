import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AiChatTeacherArea extends StatefulWidget {
  final String teacherAsset;
  final String waitingVideoAsset;
  final String answeringVideoAsset;
  final String statusText;
  final bool isSpeaking;

  const AiChatTeacherArea({
    super.key,
    required this.teacherAsset,
    required this.waitingVideoAsset,
    required this.answeringVideoAsset,
    required this.statusText,
    required this.isSpeaking,
  });

  @override
  State<AiChatTeacherArea> createState() => _AiChatTeacherAreaState();
}

class _AiChatTeacherAreaState extends State<AiChatTeacherArea> {
  VideoPlayerController? _waitingController;
  VideoPlayerController? _answeringController;
  bool _waitingInitialized = false;
  bool _answeringInitialized = false;
  bool _disposed = false;
  bool _waitingSeeking = false;
  bool _answeringSeeking = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    final waiting = VideoPlayerController.asset(widget.waitingVideoAsset);
    final answering = VideoPlayerController.asset(widget.answeringVideoAsset);
    _waitingController = waiting;
    _answeringController = answering;

    waiting.addListener(() => _onVideoChanged(waiting, isWaiting: true));
    answering.addListener(() => _onVideoChanged(answering, isWaiting: false));

    try {
      await waiting.initialize();
      if (_disposed) return;
      waiting.setLooping(false);
      setState(() => _waitingInitialized = true);
    } catch (e) {
      if (kDebugMode) debugPrint('Waiting video init failed: $e');
    }

    try {
      await answering.initialize();
      if (_disposed) return;
      answering.setLooping(false);
      setState(() => _answeringInitialized = true);
      if (widget.isSpeaking) {
        answering.play();
      } else {
        waiting.play();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Answering video init failed: $e');
    }
  }

  void _onVideoChanged(
    VideoPlayerController controller, {
    required bool isWaiting,
  }) {
    if (_disposed || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration.inMilliseconds <= 0) return;

    final seekFlag = isWaiting ? _waitingSeeking : _answeringSeeking;
    if (seekFlag) return;

    final isNearEnd = position.inMilliseconds >= duration.inMilliseconds - 150;
    final isCompleted = controller.value.isCompleted;

    if (isNearEnd || isCompleted) {
      if (isWaiting) {
        _waitingSeeking = true;
      } else {
        _answeringSeeking = true;
      }

      final wasPlaying = controller.value.isPlaying;
      controller.seekTo(Duration.zero).then((_) {
        if (_disposed) return;
        if (wasPlaying || isCompleted) {
          controller.play();
        }
        if (isWaiting) {
          _waitingSeeking = false;
        } else {
          _answeringSeeking = false;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant AiChatTeacherArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.waitingVideoAsset != widget.waitingVideoAsset ||
        oldWidget.answeringVideoAsset != widget.answeringVideoAsset) {
      _disposeControllers();
      _waitingInitialized = false;
      _answeringInitialized = false;
      _waitingSeeking = false;
      _answeringSeeking = false;
      _initControllers();
      return;
    }

    if (oldWidget.isSpeaking != widget.isSpeaking) {
      _switchVideo();
    }
  }

  void _switchVideo() {
    if (widget.isSpeaking) {
      _waitingController?.pause();
      if (_answeringInitialized && _answeringController != null) {
        _answeringSeeking = true;
        _answeringController!.seekTo(Duration.zero).then((_) {
          if (_disposed) return;
          _answeringController!.play();
          _answeringSeeking = false;
        });
      }
    } else {
      _answeringController?.pause();
      if (_waitingInitialized && _waitingController != null) {
        _waitingSeeking = true;
        _waitingController!.seekTo(Duration.zero).then((_) {
          if (_disposed) return;
          _waitingController!.play();
          _waitingSeeking = false;
        });
      }
    }
  }

  void _disposeControllers() {
    _waitingController?.dispose();
    _answeringController?.dispose();
    _waitingController = null;
    _answeringController = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStatus = widget.statusText.trim().isNotEmpty;
    final showVideo = _waitingInitialized || _answeringInitialized;
    final showAnswering = widget.isSpeaking && _answeringInitialized;

    return Expanded(
      child: Stack(
        children: [
          if (showVideo)
            showAnswering
                ? _buildVideo(_answeringController!)
                : _buildVideo(_waitingController!)
          else
            Positioned.fill(
              child: Image.asset(widget.teacherAsset, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }

  Widget _buildVideo(VideoPlayerController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final videoHeight = constraints.maxHeight;
        final videoWidth = controller.value.size.width * (videoHeight / controller.value.size.height);
        
        return Center(
          child: SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}
