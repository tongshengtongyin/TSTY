import 'package:flutter/material.dart';

/// 彝族风格太阳组件（带脉动动画）
class YiSun extends StatefulWidget {
  /// 太阳大小（默认100px）
  final double size;

  /// 顶部偏移（默认20px）
  final double top;

  /// 右侧偏移（默认20px）
  final double right;

  /// 动画时长（默认3秒，对应HTML的pulse动画）
  final Duration animationDuration;

  /// 太阳颜色（默认彝族黄，若传image则失效）
  final Color color;

  /// 太阳图片（优先级高于color，对应HTML的sun.png）
  final String? imageAsset;

  const YiSun({
    super.key,
    this.size = 100,
    this.top = 20,
    this.right = 20,
    this.animationDuration = const Duration(seconds: 3),
    this.color = const Color(0xFFf0c000),
    this.imageAsset,
  });

  @override
  State<YiSun> createState() => _YiSunState();
}

class _YiSunState extends State<YiSun> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    // 对应HTML的pulse动画：scale 1→1.05，opacity 0.8→1
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _opacityAnimation.value, child: child),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: widget.imageAsset == null
              ? BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x80f0c000),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                )
              : null,
          child: widget.imageAsset != null
              ? Image.asset(widget.imageAsset!, fit: BoxFit.contain)
              : null,
        ),
      ),
    );
  }
}
