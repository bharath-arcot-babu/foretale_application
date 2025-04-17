import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomContainer({
    super.key, 
    required this.title, 
    required this.child
    });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: BorderColors.tertiaryColor, width: 0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: -10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyles.enclosureText(context),
            ),
          ),
        ),
      ],
    );
  }
}
