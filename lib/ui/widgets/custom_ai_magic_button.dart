import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class AiMagicIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final Color? iconColor;
  final double iconSize;

  const AiMagicIconButton({
    Key? key,
    required this.onPressed,
    this.tooltip = 'AI Magic',
    this.iconColor,
    this.iconSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.auto_awesome), // AI Magic style icon
      color: AppColors.primaryColor,
      iconSize: iconSize,
      onPressed: onPressed,
    );
  }
}
