import 'package:flutter/material.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_dropdown_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:intl/intl.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class GenericGridCellBuilder {
  final BuildContext context;
  final MultiCheckboxManager? multiCheckboxManager;
  final MultiDropdownManager? multiDropdownManager;
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowSave;

  GenericGridCellBuilder({
    required this.context,
    this.multiCheckboxManager,
    this.multiDropdownManager,
    this.onRowSave,
  });

  Widget buildCell(dynamic value, GenericGridColumn columnDef, int rowIndex, Map<String, dynamic>? rowData) {
    Widget cellWidget;
    
    switch (columnDef.cellType) {
      case CustomCellType.checkbox:
        cellWidget = _buildCheckboxCell(value, columnDef, rowIndex);
        break;
      case CustomCellType.dropdown:
        cellWidget = _buildDropdownCell(value, columnDef, rowIndex);
        break;
      case CustomCellType.save:
        cellWidget = _buildSaveCell(value, columnDef, rowIndex, rowData);
        break;
      case CustomCellType.number:
        cellWidget = _buildNumberCell(value);
        break;
      case CustomCellType.date:
        cellWidget = _buildDateCell(value);
        break;
      case CustomCellType.categorical:
        cellWidget = _buildCategoricalCell(value);
        break;
      case CustomCellType.text:
      default:
        cellWidget = _buildTextCell(value);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      alignment: Alignment.center,
      child: cellWidget,
    );
  }

  Widget _buildCheckboxCell(dynamic value, GenericGridColumn columnDef, int rowIndex) {
    if (multiCheckboxManager != null) {
      return AnimatedBuilder(
        animation: multiCheckboxManager!,
        builder: (context, child) {
          return multiCheckboxManager!.buildRowCheckbox(columnDef.columnName, rowIndex);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDropdownCell(dynamic value, GenericGridColumn columnDef, int rowIndex) {
    if (multiDropdownManager != null) {
      return AnimatedBuilder(
        animation: multiDropdownManager!,
        builder: (context, child) {
          return multiDropdownManager!.buildRowDropdown(columnDef.columnName, rowIndex);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSaveCell(dynamic value, GenericGridColumn columnDef, int rowIndex, Map<String, dynamic>? rowData) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onRowSave != null && rowData != null) {
                onRowSave!(rowData, rowIndex);
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.save_outlined,
                size: 18,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: TextStyles.gridText(context).copyWith(
        fontSize: 10,
        color: Colors.grey.shade800,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNumberCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: TextStyles.gridText(context).copyWith(
        fontSize: 11,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDateCell(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    String formattedDate;
    try {
      // Try to parse as DateTime first
      if (value is DateTime) {
        formattedDate = DateFormat('MMM dd, yyyy').format(value);
      } else if (value is String) {
        // Try to parse the string using the existing utility function
        formattedDate = convertToDateString(value);
        if (formattedDate.isEmpty) {
          // If the utility function fails, try direct DateTime parsing
          DateTime dateTime = DateTime.parse(value);
          formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
        } else {
          // Convert the yyyy-MM-dd format to a more readable format
          DateTime dateTime = DateFormat('yyyy-MM-dd').parse(formattedDate);
          formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
        }
      } else {
        // For other types, try to convert to string and parse
        DateTime dateTime = DateTime.parse(value.toString());
        formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      }
    } catch (e) {
      // If parsing fails, return the original value as text
      return _buildTextCell(value);
    }

    return Text(
      formattedDate,
      style: TextStyles.gridText(context).copyWith(
        fontSize: 11,
        color: Colors.grey.shade700,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBadgeCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$value',
          style: TextStyles.gridText(context).copyWith(
            fontSize: 10,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAvatarCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value.toString().isNotEmpty 
                ? value.toString().substring(0, 1).toUpperCase()
                : '?',
            style: TextStyles.gridText(context).copyWith(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined, 
              size: 14,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              // Handle edit action
            },
            padding: const EdgeInsets.all(2),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline, 
              size: 14,
              color: Colors.red.shade500,
            ),
            onPressed: () {
              // Handle delete action
            },
            padding: const EdgeInsets.all(2),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoricalCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade200, width: 1),
        ),
        child: Text(
          '$value',
          style: TextStyles.gridText(context).copyWith(
            fontSize: 10,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 