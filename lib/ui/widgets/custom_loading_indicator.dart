import 'package:flutter/material.dart';

class LinearLoadingIndicator extends StatefulWidget {
  final bool isLoading;
  final double height;
  final double width;
  final Color color;
  final Color backgroundColor;
  final Duration duration;
  final BorderRadius? borderRadius;
  final bool pulse;
  final String? loadingText;
  final TextStyle? textStyle;
  final Widget? trailingWidget;
  final MainAxisAlignment alignment;

  const LinearLoadingIndicator({
    super.key,
    required this.isLoading,
    this.height = 4.0,
    this.width = 200.0,
    this.color = Colors.blueAccent,
    this.backgroundColor = Colors.transparent,
    this.duration = const Duration(milliseconds: 1500),
    this.borderRadius,
    this.pulse = true,
    this.loadingText,
    this.textStyle,
    this.trailingWidget,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  State<LinearLoadingIndicator> createState() => _LinearLoadingIndicatorState();
}

class _LinearLoadingIndicatorState extends State<LinearLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _barAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));

    _opacityAnimation = widget.pulse 
        ? TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.6),
              weight: 1,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.6, end: 1.0),
              weight: 1,
            ),
          ]).animate(_controller)
        : ConstantTween<double>(1.0).animate(_controller);

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LinearLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(widget.height);
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: widget.color,
      fontWeight: FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bar indicator
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              // Background
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: borderRadius,
                ),
              ),
              
              // Animated bar
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Calculate position
                  final double position = _barAnimation.value;
                  final double opacity = _opacityAnimation.value;
                  
                  return Opacity(
                    opacity: opacity,
                    child: Container(
                      width: widget.width * 0.5, // Bar is half the width
                      height: widget.height,
                      margin: EdgeInsets.only(
                        left: ((position + 1) / 2) * (widget.width - widget.width * 0.5),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withOpacity(0.5),
                            widget.color,
                            widget.color.withOpacity(0.5),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Text and optional trailing widget
        if (widget.loadingText != null || widget.trailingWidget != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.alignment,
              children: [
                if (widget.loadingText != null)
                  Text(
                    widget.loadingText!,
                    style: widget.textStyle ?? defaultTextStyle,
                  ),
                if (widget.loadingText != null && widget.trailingWidget != null)
                  const SizedBox(width: 8),
                if (widget.trailingWidget != null)
                  widget.trailingWidget!,
              ],
            ),
          ),
      ],
    );
  }
}