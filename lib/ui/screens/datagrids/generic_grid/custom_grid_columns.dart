import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomGridColumn {
  final String columnName; //technical name of the column
  final String label; //display name of the column
  final CustomCellType cellType; //type of the cell (text, checkbox, dropdown, etc.)
  final double? width; //width of the column
  final bool allowSorting; //whether the column can be sorted
  final bool allowFiltering; //whether the column can be filtered
  final bool visible; //whether the column is visible
  final TextAlign textAlign; //alignment of the text (left, right, center, justify, start, end)
  final bool isFeedbackColumn; //whether the column is a feedback column
  final List<String> allowedValues; //allowed values for the column
  final Map<String, Function(String, bool)> checkboxUpdateCallback; //callback function for final update
  final Map<String, Function(String, String)> dropdownUpdateCallback; //callback function for dropdown update

  CustomGridColumn({
    required this.columnName,
    required this.label,
    required this.cellType,
    this.width,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.textAlign = TextAlign.start,
    this.isFeedbackColumn = false,
    this.allowedValues = const [],
    required this.checkboxUpdateCallback,
    required this.dropdownUpdateCallback,
  });

  GridColumn toGridColumn(BuildContext context){
    return GridColumn(
      columnName: columnName,
      width: width ?? _calculateOptimalWidth(label: label, cellType: cellType),
      allowSorting: allowSorting,
      allowFiltering: allowFiltering,
      visible: visible,
      label: _buildConsistentHeader(context, label, isFeedbackColumn),
    );
  }

  double _calculateOptimalWidth({required String label, required CustomCellType cellType}) {
    double baseWidth = label.length * 8.5; //increased character width for better header visibility
    
    baseWidth += 48.0; //padding
    
    switch (cellType) {
      case CustomCellType.text:
        baseWidth += 150.0; //extra space for text
        break;
      case CustomCellType.number: 
        baseWidth += 16.0; //extra space for numbers and alignment
        break;
      case CustomCellType.date:
        baseWidth += 20.0; //extra space for date
        break;
      case CustomCellType.currency:
        baseWidth += 16.0; //extra space for currency
        break;
      case CustomCellType.percentage:
        baseWidth += 16.0; //extra space for percentage
        break;
      case CustomCellType.checkbox:
        baseWidth = 140.0; //fixed width for checkbox column
        break;
      case CustomCellType.dropdown:
        baseWidth = 140.0; //fixed width for dropdown column
        break;
      case CustomCellType.categorical:
        baseWidth += 20.0; //extra space for categorical data
        break;
      default:
        baseWidth += 8.0;
        break;
    }
    
    return baseWidth.clamp(100.0, 300.0); //minimum and maximum width constraints
  }

  Widget _buildConsistentHeader(BuildContext context, String label, bool isFeedbackColumn) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Center(
        child: Text(
          label,
          style: isFeedbackColumn ? 
                TextStyles.gridHeaderText(context).copyWith(height: 1.2, color: AppColors.primaryColor) : 
                TextStyles.gridHeaderText(context).copyWith(height: 1.2),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}