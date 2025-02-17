import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart'; // Assuming AppColors are defined here

class TextStyles {
  static double _getFontSize(BuildContext context, double factor) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Define the base screen width (for scaling), minimum and maximum font size
    double baseWidth = 360.0;
    double minFontSize = 9.0;
    double maxFontSize = factor;

    // Calculate the scaling factor based on the screen width
    double scalingFactor = (screenWidth - baseWidth) / (1920 - baseWidth);

    // Linearly interpolate between minFontSize and maxFontSize based on screen width
    double fontSize = minFontSize + (scalingFactor * (maxFontSize - minFontSize));

    // Optionally, clamp the value within the min and max range to ensure it doesn't go out of bounds
    return fontSize.clamp(minFontSize, maxFontSize);   
  }

  static TextStyle subjectText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w700,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 16.0),
      letterSpacing: 1.2
    );
  }

  static TextStyle titleText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w700,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 16.0), // Responsive font size
    );
  }

  static TextStyle subtitleText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w600,
      color: TextColors.secondaryTextColor,
      fontSize: _getFontSize(context, 12.0), // Responsive font size
    );
  }
  static TextStyle topicText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w400,
      color: TextColors.tertiaryTextColor,
      fontSize: _getFontSize(context, 10.0), // Responsive font size
    );
  }

  static TextStyle enclosureText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w600,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 10.0), // Responsive font size
    );
  }

  // Global AppBar Title Text Style
  static TextStyle appBarLogo(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w900,
      color: TextColors.logoColor,
      letterSpacing: 3,
      fontSize: _getFontSize(context, 24.0), // Responsive font size
    );
  }

  // Global AppBar Title Text Style
  static TextStyle appBarTitleStyle(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w700,
      color: TextColors.titleColor,
      fontSize: _getFontSize(context, 16.0), // Responsive font size
    );
  }

  static TextStyle leftPanelControlsText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: LeftPaneControlColors.leftPanelIconTextColor,
      fontSize: _getFontSize(context, 9.0), // Responsive font size
    );
  }

  static TextStyle elevatedButtonTextStyle (BuildContext context){
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: ButtonColors.buttonTextColor,
    );
  }

  static TextStyle inputMainTextStyle (BuildContext context){
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: FillColors.primaryColor,
      fontSize: 12.0
    );
  }

  static TextStyle inputHintTextStyle (BuildContext context){
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.normal,
      color: FillColors.primaryColor,
      fontSize: 12.0
    );
  }

  static TextStyle footerTextSmall(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 16.0), // Responsive font size
    );
  }

  static TextStyle footerLinkTextSmall(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: TextColors.linkTextColor,
      fontSize: _getFontSize(context, 16.0), // Responsive font size
    );
  }

  static TextStyle gridHeaderText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w600,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 12.0), // Responsive font size
    );
  }

  static TextStyle gridText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 11.0), // Responsive font size
    );
  }

  static TextStyle gridFilterText() {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: TextColors.primaryTextColor,
      fontSize: 10.0, // Responsive font size
    );
  }

  static TextStyle responseText(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w500,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 10.0), // Responsive font size
    );
  }

  static TextStyle smallSupplementalInfo(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w400,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 9.0), // Responsive font size
    );
  }

  static TextStyle responseTextFileInfo(BuildContext context) {
    return GoogleFonts.poppins( // Apply Google Font
      fontWeight: FontWeight.w400,
      color: TextColors.primaryTextColor,
      fontSize: _getFontSize(context, 9.0), // Responsive font size
    );
  }
}