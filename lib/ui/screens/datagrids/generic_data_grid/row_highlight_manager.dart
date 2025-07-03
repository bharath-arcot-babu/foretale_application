import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

/// Manages row highlighting state for datagrids
class RowHighlightManager extends ChangeNotifier {
  int? _highlightedRowIndex;

  /// Get the currently highlighted row index
  int? get highlightedRowIndex => _highlightedRowIndex;

  /// Check if a specific row is highlighted
  bool isRowHighlighted(int rowIndex) => _highlightedRowIndex == rowIndex;

  /// Highlight a specific row
  void highlightRow(int rowIndex) {
    _highlightedRowIndex = rowIndex;
    notifyListeners();
  }

  /// Clear row highlighting
  void clearHighlight() {
    _highlightedRowIndex = null;
    notifyListeners();
  }

  /// Get the background color for a row based on its state
  Color getRowBackgroundColor(int rowIndex, {Color? baseColor, Color? alternateColor}) {
    // If this row is highlighted, return highlight color
    if (isRowHighlighted(rowIndex)) {
      return AppColors.primaryColor.withOpacity(0.15);
    }
    
    // Otherwise return alternating row colors
    return rowIndex % 2 == 0 
        ? (baseColor ?? Colors.white) 
        : (alternateColor ?? Colors.grey.shade50);
  }
} 