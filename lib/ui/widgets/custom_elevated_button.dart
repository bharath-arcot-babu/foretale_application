import 'package:flutter/material.dart';
// Constants
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
           fit: BoxFit.scaleDown,
            child: Text(
          text,
          style: TextStyles.elevatedButtonTextStyle(context)
              .copyWith(fontSize: textSize),
        )),
      ),
    );
  }
}
