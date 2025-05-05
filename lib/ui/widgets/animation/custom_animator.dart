import 'package:flutter/material.dart';

class FadeAnimator extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeAnimator> createState() => _FadeAnimatorState();
}

class _FadeAnimatorState extends State<FadeAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}

class SlideFadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const SlideFadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0, 0.1), // Slide from bottom
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 100, offset.dy * 100),
          child: Opacity(
            opacity: 1 - offset.distance, // fade in with slide
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
