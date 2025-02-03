import 'package:flutter/widgets.dart';

class SizeConfig {
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockSizeHorizontal = 0.0;
  static double blockSizeVertical = 0.0;
  static double textMultiplier = 0.0;
  static double imageSizeMultiplier = 0.0;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    blockSizeHorizontal = screenWidth / 100;  // 1 block is 1% of screen width
    blockSizeVertical = screenHeight / 100;   // 1 block is 1% of screen height

    textMultiplier = blockSizeVertical;  // You can define text sizes based on vertical blocks
    imageSizeMultiplier = blockSizeHorizontal; // You can define image sizes based on horizontal blocks
  }

  // Get sizes dynamically based on percentage
  static double getWidth(double percent) {
    return screenWidth * (percent / 100);
  }

  static double getHeight(double percent) {
    return screenHeight * (percent / 100);
  }

  static double getTextSize(double percent) {
    return textMultiplier * percent;
  }

  static double getImageSize(double percent) {
    return imageSizeMultiplier * percent;
  }
}
