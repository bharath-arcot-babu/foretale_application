import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle() {
    double elevatedButtonBorderRadius = 10.0;
    return ElevatedButton.styleFrom(
      backgroundColor: ButtonColors.primaryButtonColor,
      foregroundColor: ButtonColors.buttonTextColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(elevatedButtonBorderRadius),
      ),
      elevation: 2,
    );
  }
}
