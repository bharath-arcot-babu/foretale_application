import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class CustomToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final String? activeLabel;
  final String? inactiveLabel;
  final TextStyle? labelStyle;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primaryColor,
    this.inactiveColor = AppColors.secondaryColor,
    this.width = 60.0,
    this.height = 30.0,
    this.activeLabel,
    this.inactiveLabel,
    this.labelStyle,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          color: widget.value ? widget.activeColor : widget.inactiveColor,
        ),
        child: Stack(
          children: [
            if (widget.activeLabel != null || widget.inactiveLabel != null)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.inactiveLabel != null)
                      Text(
                        widget.inactiveLabel!,
                        style: widget.labelStyle?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    if (widget.activeLabel != null)
                      Text(
                        widget.activeLabel!,
                        style: widget.labelStyle?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _animation.value * (widget.width - widget.height),
                    0,
                  ),
                  child: Container(
                    width: widget.height,
                    height: widget.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
    );
  }
}
