import 'package:flutter/material.dart';
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
      size: 12,
      color: Color(0xFF5F6368), // Subtle grey sort icon
    ),
    filterIcon: const Icon(
      Icons.filter_list,
      size: 12,
      color: Color(0xFF5F6368), // Subtle grey filter icon
    ),
    filterPopupTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF1E212B),
    ),
    filterPopupDisabledTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF9AA0A6),
    ),
  );  

  // Custom theme for feedback columns
  static SfDataGridThemeData sfFeedbackDataGridTheme = SfDataGridThemeData( 
    headerColor: const Color(0xFFEE4266).withOpacity(0.1), // Feedback column header background
    headerHoverColor: const Color(0xFFEE4266).withOpacity(0.15), // Feedback column hover effect
    selectionColor: const Color(0xFFE3F2FD).withOpacity(0.3), // Very light blue selection
    gridLineColor: const Color(0xFFE8EAED), // Very light grey grid lines
    gridLineStrokeWidth: 0.3, // Ultra-thin grid lines for sleek look
    rowHoverColor: const Color(0xFFF8F9FA), // Minimal hover effect
    sortIcon: const Icon(
      Icons.keyboard_arrow_up,
      size: 12,
      color: Color(0xFFEE4266), // Feedback color sort icon
    ),
    filterIcon: const Icon(
      Icons.filter_list,
      size: 12,
      color: Color(0xFFEE4266), // Feedback color filter icon
    ),
    filterPopupTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF1E212B),
    ),
    filterPopupDisabledTextStyle: TextStyles.gridFilterText().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF9AA0A6),
    ),
  );  
}
