import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SFDataGridTheme {
  static SfDataGridThemeData sfCustomDataGridTheme = SfDataGridThemeData( 
    headerColor: DatagridColors.datagridHeaderColor, // Light blue header background for better readability
    headerHoverColor: DatagridColors.datagridHeaderColor, // Subtle hover effect for the header
    selectionColor: DatagridColors.datagridRowSelectionColor,
    //gridLineColor: BorderColors.secondaryColor, // Light grey grid lines for a softer look
    //gridLineStrokeWidth: 0.5, // Slightly thicker grid lines for better visibility
    rowHoverColor: Colors.transparent, // Light row hover color for a clean effect
    sortIcon: const Icon(
      Icons.sort,
      size: 8,
      color: Colors.black, // Neutral, elegant blue-grey sort icon color
    ),
    filterPopupTextStyle: TextStyles.gridFilterText(),
    filterPopupDisabledTextStyle: TextStyles.gridFilterText(),
  );

  
}

class DatagridTheme {
  
}
