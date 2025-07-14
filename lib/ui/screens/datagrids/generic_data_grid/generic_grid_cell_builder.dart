import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_dropdown_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:intl/intl.dart';

class GenericGridCellBuilder {
  final BuildContext context;
  final MultiCheckboxManager? multiCheckboxManager;
  final MultiDropdownManager? multiDropdownManager;

  GenericGridCellBuilder({
    required this.context,
    this.multiCheckboxManager,
    this.multiDropdownManager,
  });

  Widget buildCell(
    dynamic value,
    GenericGridColumn columnDef,
    int rowIndex,
  ) {
    Widget cellWidget;
    switch (columnDef.cellType) {
      case GenericGridCellType.checkbox:
        cellWidget = _buildCheckboxCell(value, columnDef, rowIndex);
        break;
      case GenericGridCellType.dropdown:
        cellWidget = _buildDropdownCell(value, columnDef, rowIndex);
        break;
      case GenericGridCellType.number:
        cellWidget = _buildNumberCell(value);
        break;
      case GenericGridCellType.badge:
        cellWidget = _buildBadgeCell(value);
        break;
      case GenericGridCellType.avatar:
        cellWidget = _buildAvatarCell(value);
        break;
      case GenericGridCellType.action:
        cellWidget = _buildActionCell();
        break;
      case GenericGridCellType.date:
        cellWidget = _buildDateCell(value);
        break;
      case GenericGridCellType.text:
      default:
        cellWidget = _buildTextCell(value);
        break;
    }

    // Use different padding for dropdown cells to ensure full visibility
    EdgeInsets padding;
    if (columnDef.cellType == GenericGridCellType.dropdown) {
      padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0);
    } else {
      padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    }

    return Container(
      padding: padding,
      alignment: _getAlignment(columnDef.textAlign),
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

  Widget _buildTextCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNumberCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
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
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBadgeCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatarCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value.toString().isNotEmpty 
              ? value.toString().substring(0, 1).toUpperCase()
              : '?',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_outlined, 
            size: 16,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            // Handle edit action
          },
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline, 
            size: 16,
            color: Colors.red.shade500,
          ),
          onPressed: () {
            // Handle delete action
          },
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.start:
      case TextAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }
} 