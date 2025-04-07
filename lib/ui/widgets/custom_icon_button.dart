import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;


  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer;
    final fg = iconColor ?? Theme.of(context).colorScheme.secondary;

    final iconWidget = Container(
      width: iconSize + (iconSize * 0.4),
      height: iconSize + (iconSize * 0.4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, size: iconSize, color: fg),
    );

    final button = IconButton(
      icon: iconWidget,
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      splashRadius: (iconSize + (iconSize * 0.1)) / 2,
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}
