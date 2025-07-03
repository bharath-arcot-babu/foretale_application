import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';

class ColumnWidthCalculator {
  /// Calculates the optimal width for a column based on its label and cell type
  static double calculateOptimalWidth({
    required String label,
    required GenericGridCellType cellType,
    double? customWidth,
  }) {
    // If custom width is provided, use it
    if (customWidth != null) {
      return customWidth;
    }

    // More accurate width calculation based on label length and font characteristics
    double baseWidth = label.length * 9.5; // Better character width estimation for Inter font
    
    // Add padding for the container
    baseWidth += 64.0; // 16px padding on each side
    
    // Adjust based on cell type
    switch (cellType) {
      case GenericGridCellType.checkbox:
        baseWidth = 60.0; // Fixed width for checkbox column
        break;
      case GenericGridCellType.badge:
        baseWidth += 24.0; // Extra space for badge padding and border
        break;
      case GenericGridCellType.avatar:
        baseWidth = 64.0; // Fixed width for avatar with some margin
        break;
      case GenericGridCellType.action:
        baseWidth = 120.0; // Fixed width for action buttons (2 icons + spacing)
        break;
      case GenericGridCellType.number:
        baseWidth += 16.0; // Extra space for numbers and alignment
        break;
      case GenericGridCellType.text:
      default:
        // Add some buffer for text overflow
        baseWidth += 8.0;
        break;
    }
    
    // Ensure minimum and maximum width constraints
    return baseWidth.clamp(100.0, 400.0);
  }

  /// Calculates optimal widths for multiple columns, considering content distribution
  static List<double> calculateOptimalWidthsForColumns({
    required List<GenericGridColumn> columns,
    required double availableWidth,
  }) {
    List<double> widths = [];
    
    // Calculate individual optimal widths
    for (var column in columns) {
      double optimalWidth = calculateOptimalWidth(
        label: column.label,
        cellType: column.cellType,
        customWidth: column.width,
      );
      widths.add(optimalWidth);
    }
    
    // Calculate total optimal width
    double totalOptimalWidth = widths.fold(0.0, (sum, width) => sum + width);
    
    // If total optimal width fits within available width, use optimal widths
    if (totalOptimalWidth <= availableWidth) {
      return widths;
    }
    
    // Otherwise, distribute available width proportionally
    return _distributeWidthProportionally(widths, availableWidth);
  }

  /// Distributes available width proportionally among columns
  static List<double> _distributeWidthProportionally(
    List<double> optimalWidths,
    double availableWidth,
  ) {
    double totalOptimalWidth = optimalWidths.fold(0.0, (sum, width) => sum + width);
    double ratio = availableWidth / totalOptimalWidth;
    
    return optimalWidths.map((width) {
      double distributedWidth = width * ratio;
      // Ensure minimum width constraint
      return distributedWidth.clamp(100.0, width);
    }).toList();
  }

  /// Calculates width based on content analysis (for dynamic content)
  static double calculateWidthFromContent({
    required List<String> content,
    required GenericGridCellType cellType,
    double? minWidth,
    double? maxWidth,
  }) {
    if (content.isEmpty) {
      return minWidth ?? 100.0;
    }

    // Find the longest content item
    String longestContent = content.reduce((a, b) => a.length > b.length ? a : b);
    
    // Calculate width based on content length
    double baseWidth = longestContent.length * 9.5;
    baseWidth += 64.0; // Padding
    
    // Apply cell type adjustments
    switch (cellType) {
      case GenericGridCellType.checkbox:
        baseWidth = 60.0;
        break;
      case GenericGridCellType.badge:
        baseWidth += 24.0;
        break;
      case GenericGridCellType.avatar:
        baseWidth = 64.0;
        break;
      case GenericGridCellType.action:
        baseWidth = 120.0;
        break;
      case GenericGridCellType.number:
        baseWidth += 16.0;
        break;
      case GenericGridCellType.text:
      default:
        baseWidth += 8.0;
        break;
    }
    
    // Apply constraints
    double minConstraint = minWidth ?? 100.0;
    double maxConstraint = maxWidth ?? 400.0;
    
    return baseWidth.clamp(minConstraint, maxConstraint);
  }
} 