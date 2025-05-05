import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

/// A modern, lightweight container with customizable properties
class ModernContainer extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsetsGeometry margin, padding;
  final Color backgroundColor, shadowColor;
  final double borderRadius, elevation;
  final bool isClickable, isLoading;
  final VoidCallback? onTap;
  final Widget? badge;

  const ModernContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.surfaceColor,
    this.borderRadius = 8,
    this.elevation = 1,
    this.shadowColor = Colors.black54,
    this.isClickable = false,
    this.onTap,
    this.badge,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.1),
                  blurRadius: elevation,
                  spreadRadius: elevation,
                ),
              ]
            : null,
      ),
      child: isLoading ? _buildLoadingEffect() : child,
    );

    final containerWithBadge = badge != null
        ? Stack(clipBehavior: Clip.none, children: [container, Positioned(top: -8, right: -8, child: badge!)])
        : container;

    return isClickable
        ? GestureDetector(
            onTap: onTap,
            child: containerWithBadge,
          )
        : containerWithBadge;
  }

  Widget _buildLoadingEffect() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.grey.shade300),
      ),
    );
  }
}
