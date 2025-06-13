import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/button_styles.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final double textSize;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.textSize,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.trim().isNotEmpty;
    final hasIcon = icon != null;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyles.elevatedButtonStyle(),
        child: isLoading
            ? SizedBox(
                width: textSize + 2,
                height: textSize + 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : _buildContent(context, hasText, hasIcon),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasText, bool hasIcon) {
    final textWidget = Text(
      text,
      style: TextStyles.elevatedButtonTextStyle(context).copyWith(
        fontSize: textSize,
      ),
    );

    if (hasIcon && hasText) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: textSize + 2),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else if (hasIcon) {
      return Icon(icon, size: textSize + 2);
    } else {
      return textWidget;
    }
  }
}
