import 'package:flutter/material.dart';
// Constants
import 'package:foretale_application/core/constants/colors/app_colors.dart';
// Themes
import 'package:foretale_application/ui/themes/button_styles.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

// Custom Elevated Button with icon
class CustomElevatedButton extends StatelessWidget {
  // Button customization properties
  final double width;
  final double height;
  final String text;
  final double textSize;
  final VoidCallback onPressed;
  final IconData? icon; // Optional icon parameter

  // Constructor
  const CustomElevatedButton({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.textSize,
    required this.onPressed,
    this.icon, // Optional icon parameter
  });

  // Widget
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyles.elevatedButtonStyle(),
      child: SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: textSize * 1.2,  // Scale the icon slightly larger than text
                  color: ButtonColors.buttonTextColor,
                ),
                const SizedBox(width: 8), // Space between icon and text
              ],
              Text(
                text,
                style: TextStyles.elevatedButtonTextStyle(context).copyWith(fontSize: textSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
