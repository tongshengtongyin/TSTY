import 'package:flutter/material.dart';

/// 彝族侧边竖条纹组件（支持左侧/右侧）
class YiSideStripe extends StatelessWidget {
  /// 条纹方向（left/right）
  final String direction;

  /// 条纹顶部偏移（占屏幕高度的比例，默认左侧0.3，右侧0.4）
  final double topRatio;

  /// 条纹宽度（默认15px，响应式下8px）
  final double width;

  /// 条纹高度（默认200px，响应式下120px）
  final double height;

  /// 条纹透明度（默认0.8）
  final double opacity;

  /// 条纹配色（默认左侧[红,黄,黑]，右侧[黑,黄,红]）
  final List<Color> colors;

  const YiSideStripe({
    super.key,
    required this.direction,
    this.topRatio = 0.3,
    this.width = 15,
    this.height = 200,
    this.opacity = 0.8,
    List<Color>? colors,
  }) : colors =
           colors ??
           (direction == 'left'
               ? const [Color(0xFFc00000), Color(0xFFf0c000), Color(0xFF3d2800)]
               : const [
                   Color(0xFF3d2800),
                   Color(0xFFf0c000),
                   Color(0xFFc00000),
                 ]);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLeft = direction == 'left';

    return Positioned(
      top: screenHeight * topRatio,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 1 / 3, 1 / 3, 2 / 3, 2 / 3, 1.0],
              colors: [
                colors[0],
                colors[0],
                colors[1],
                colors[1],
                colors[2],
                colors[2],
              ],
              tileMode: TileMode.repeated,
            ),
            borderRadius: BorderRadius.only(
              topRight: isLeft ? const Radius.circular(10) : Radius.zero,
              bottomRight: isLeft ? const Radius.circular(10) : Radius.zero,
              topLeft: isLeft ? Radius.zero : const Radius.circular(10),
              bottomLeft: isLeft ? Radius.zero : const Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
