import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class ScaffoldStyles{
  static BoxDecoration layoutLeftPanelBoxDecoration(){
    double dropdownBorderRadius = 10.0;
    return BoxDecoration(
        color: LeftPaneControlColors.leftPanelBackgroundColor,
        borderRadius: BorderRadius.circular(dropdownBorderRadius)
      );
  }
  static BoxDecoration layoutBodyPanelBoxDecoration(){
    double dropdownBorderRadius = 10.0;
    return BoxDecoration(
        color: BodyColors.bodyBackgroundColor,
        borderRadius: BorderRadius.circular(dropdownBorderRadius)
      );
  }
}