import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SplashVideoPage extends StatefulWidget {
  const SplashVideoPage({super.key});

  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> {
  VideoPlayerController? _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset('lib/assets/video/start.mp4');
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      
      setState(() {});
      
      controller.setLooping(false);
      controller.play();
      
      controller.addListener(() {
        if (_hasNavigated) return;
        
        if (controller.value.position >= controller.value.duration) {
          _navigateToMain();
        }
      });
    } catch (e) {
      debugPrint('Splash video init failed: $e');
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            _controller != null && _controller!.value.isInitialized
                ? SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFC00003),
                    width: screenWidth,
                    height: screenHeight,
                  ),
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: _navigateToMain,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '跳过',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
