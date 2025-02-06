import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SFDataGridTheme {
  static SfDataGridThemeData sfCustomDataGridTheme = SfDataGridThemeData(
    headerColor: DatagridColors.datagridHeaderColor, // Light blue header background for better readability
    headerHoverColor: DatagridColors.datagridHeaderHoverColor, // Subtle hover effect for the header
    selectionColor: Colors.transparent,
    gridLineColor: const Color(0xFFE0E0E0), // Light grey grid lines for a softer look
    gridLineStrokeWidth: 0.8, // Slightly thicker grid lines for better visibility
    rowHoverColor: Colors.transparent, // Light row hover color for a clean effect
    sortIcon: const Icon(
      Icons.sort,
      size: 12,
      color: Colors.black, // Neutral, elegant blue-grey sort icon color
    ),
  );

  
}

class DatagridTheme {
  
}
