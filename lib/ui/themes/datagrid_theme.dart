import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SFDataGridTheme {
  static SfDataGridThemeData sfCustomDataGridTheme = SfDataGridThemeData(
    headerColor: const Color(0xFFE8F1F9), // Light blue header background for better readability
    headerHoverColor: const Color(0xFFB3D9F2), // Subtle hover effect for the header
    gridLineColor: const Color(0xFFE0E0E0), // Light grey grid lines for a softer look
    gridLineStrokeWidth: 0.8, // Slightly thicker grid lines for better visibility
    rowHoverColor: const Color(0xFFFAFAFA), // Light row hover color for a clean effect
    sortIcon: const Icon(
      Icons.sort,
      size: 12,
      color: Colors.black, // Neutral, elegant blue-grey sort icon color
    ),
  );
}

class DatagridTheme {
  static TextStyle datagridHeaderText (){
    return const TextStyle(
      fontFamily: "Baloo",
      fontWeight: FontWeight.w800,
      color: DatagridColors.datagridHeaderText,
    );
  }
}
