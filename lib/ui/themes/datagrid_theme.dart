import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SFDataGridTheme {
  static SfDataGridThemeData sfCustomDataGridTheme = SfDataGridThemeData( 
    headerColor: const Color(0xFFFAFBFC), // Very light, almost white header
    headerHoverColor: const Color(0xFFF5F6F7), // Subtle hover effect
    selectionColor: const Color(0xFFE3F2FD).withOpacity(0.3), // Very light blue selection
    gridLineColor: const Color(0xFFE8EAED), // Very light grey grid lines
    gridLineStrokeWidth: 0.3, // Ultra-thin grid lines for sleek look
    rowHoverColor: const Color(0xFFF8F9FA), // Minimal hover effect
    sortIcon: const Icon(
      Icons.keyboard_arrow_up,
      size: 16,
      color: Color(0xFF5F6368), // Subtle grey sort icon
    ),
    filterPopupTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    filterPopupDisabledTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF9AA0A6),
    ),
  );  
}
