import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle (){
    double elevatedButtonBorderRadius = 10.0;
    return ElevatedButton.styleFrom(
      backgroundColor: ButtonColors.primaryButtonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(elevatedButtonBorderRadius)
      )
    );
  }

}
