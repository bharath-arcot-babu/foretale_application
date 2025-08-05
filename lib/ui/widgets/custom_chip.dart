import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final IconData? leadingIcon;
  final double height;
  final bool useShadow;
  final Border? border;

  const CustomChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    this.leadingIcon,
    this.height = 28,
    this.useShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer.withOpacity(0.85);
    final fgColor = textColor ?? theme.colorScheme.onPrimaryContainer;
    
    return Container(
      height: height,
      constraints: const BoxConstraints(minWidth: 40),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: border,
        boxShadow: useShadow ? [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ] : null,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 14,
                color: fgColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}