import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class AiMagicIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final Color? iconColor;
  final double iconSize;
  final bool isProcessing;
  final Color? sparkleColor;

  const AiMagicIconButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'AI Magic',
    this.iconColor,
    this.iconSize = 18.0,
    this.isProcessing = false,
    this.sparkleColor,
  });

  @override
  State<AiMagicIconButton> createState() => _AiMagicIconButtonState();
}

class _AiMagicIconButtonState extends State<AiMagicIconButton>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AiMagicIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _sparkleController.repeat();
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _sparkleController.stop();
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: widget.tooltip,
          icon: const Icon(Icons.auto_awesome),
          color: widget.iconColor ?? AppColors.primaryColor,
          iconSize: widget.iconSize,
          onPressed: widget.isProcessing ? null : widget.onPressed,
        ),
        if (widget.isProcessing)
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _sparkleAnimation.value * 2 * 3.14159,
                child: Container(
                  width: widget.iconSize + 8,
                  height: widget.iconSize + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (widget.sparkleColor ?? Colors.blue).withOpacity(0.8 * _sparkleAnimation.value),
                        (widget.sparkleColor ?? Colors.blue).withOpacity(0.4 * _sparkleAnimation.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        if (widget.isProcessing)
          Positioned(
            top: -2,
            right: -2,
            child: AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + 0.5 * _sparkleAnimation.value,
                  child: Icon(
                    Icons.star,
                    size: 8,
                    color: (widget.sparkleColor ?? Colors.blue).withOpacity(_sparkleAnimation.value),
                  ),
                );
              },
            ),
          ),
        if (widget.isProcessing)
          Positioned(
            bottom: -2,
            left: -2,
            child: AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + 0.5 * (1 - _sparkleAnimation.value),
                  child: Icon(
                    Icons.star,
                    size: 6,
                    color: (widget.sparkleColor ?? Colors.blue).withOpacity(1 - _sparkleAnimation.value),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
