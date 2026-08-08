import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/yi_radial_bubble.dart';
import 'package:tsty_app/style/app_theme.dart';

class LevelDetailCard extends StatelessWidget {
  final String character;
  final String pinyin;
  final String hintImageAsset;
  final String hintLabel;
  final String exampleText;
  final bool isPlayingTts;
  final VoidCallback onPlayStandard;
  final VoidCallback onPlayTip;

  const LevelDetailCard({
    super.key,
    required this.character,
    required this.pinyin,
    required this.hintImageAsset,
    required this.hintLabel,
    required this.exampleText,
    this.isPlayingTts = false,
    required this.onPlayStandard,
    required this.onPlayTip,
  });

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;
    const radius = 24.0;

    return Container(
      width: double.infinity,
      //padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: yellow, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -70,
                    top: -60,
                    child: YiRadialBubble(
                      size: 160,
                      color: yellow.withValues(alpha: 0.20),
                      highlightAlignment: const Alignment(0.4, 0.4),
                    ),
                  ),
                  Positioned(
                    right: -80,
                    top: 40,
                    child: YiRadialBubble(
                      size: 150,
                      color: const Color(0xFF6AD192).withValues(alpha: 0.14),
                      highlightAlignment: const Alignment(-0.4, 0.0),
                      highlightCenterBias: 0.35,
                      highlightAlpha: 0.95,
                      highlightStop: 0.60,
                      highlightRadius: 1.05,
                    ),
                  ),
                  Positioned(
                    right: -70,
                    bottom: -80,
                    child: YiRadialBubble(
                      size: 190,
                      color: red.withValues(alpha: 0.10),
                      highlightAlignment: const Alignment(-0.4, -0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCC0000), Color(0xFFFF6666)],
                ),
                color: red,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                character,
                style: TextStyle(
                  fontSize: 72,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: red,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pinyin,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A1E00),
                ),
              ),
              const SizedBox(height: 10),
              _HintImage(asset: hintImageAsset, label: hintLabel),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E6).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: yellow, width: 1),
                ),
                child: Text(
                  exampleText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A1E00),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleActionButton(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFCC0000), Color(0xFFFF6666)],
                    ),
                    icon: Icons.play_arrow_rounded,
                    onTap: onPlayStandard,
                    isDisabled: isPlayingTts,
                  ),
                  const SizedBox(width: 18),
                  _CircleActionButton(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF0C000), Color(0xFFFFD16E)],
                    ),
                    icon: Icons.lightbulb,
                    onTap: onPlayTip,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintImage extends StatelessWidget {
  final String asset;
  final String label;

  const _HintImage({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: yellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('lib/assets/father.webp', fit: BoxFit.cover);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _CircleActionButton extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _CircleActionButton({
    required this.gradient,
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedCircleActionButton(
      gradient: gradient,
      icon: icon,
      onTap: onTap,
      isDisabled: isDisabled,
    );
  }
}

class _AnimatedCircleActionButton extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _AnimatedCircleActionButton({
    required this.gradient,
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  State<_AnimatedCircleActionButton> createState() =>
      _AnimatedCircleActionButtonState();
}

class _AnimatedCircleActionButtonState
    extends State<_AnimatedCircleActionButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;

    final scale = _pressed ? 0.92 : 1.0;
    final shadowAlpha = _pressed ? 0.06 : 0.10;
    final blur = _pressed ? 5.0 : 8.0;
    final dy = _pressed ? 1.0 : 3.0;
    final opacity = widget.isDisabled ? 0.5 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: opacity,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: widget.isDisabled ? null : widget.onTap,
          onTapDown: widget.isDisabled ? null : (_) => _setPressed(true),
          onTapUp: widget.isDisabled ? null : (_) => _setPressed(false),
          onTapCancel: widget.isDisabled ? null : () => _setPressed(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: widget.gradient,
              border: Border.all(color: yellow, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowAlpha),
                  blurRadius: blur,
                  offset: Offset(0, dy),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
