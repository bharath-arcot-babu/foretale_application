import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/datagrid_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';

class GenericGridCellBuilder {
  final BuildContext context;
  final DatagridCheckboxManager? checkboxManager;

  GenericGridCellBuilder({
    required this.context,
    this.checkboxManager,
  });

  Widget buildCell(
    dynamic value,
    GenericGridColumn columnDef,
    int rowIndex,
  ) {
    Widget cellWidget;
    switch (columnDef.cellType) {
      case GenericGridCellType.checkbox:
        cellWidget = _buildCheckboxCell(value, rowIndex);
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
      case GenericGridCellType.text:
      default:
        cellWidget = _buildTextCell(value);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      alignment: _getAlignment(columnDef.textAlign),
      child: cellWidget,
    );
  }

  Widget _buildCheckboxCell(dynamic value, int rowIndex) {
    if (checkboxManager == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: checkboxManager!,
      builder: (context, child) {
        return checkboxManager!.buildRowCheckbox(rowIndex);
      },
    );
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