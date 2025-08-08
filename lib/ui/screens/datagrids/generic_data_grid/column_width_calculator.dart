import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';

class ColumnWidthCalculator {
  /// Calculates the optimal width for a column based on its label and cell type
  static double calculateOptimalWidth({
    required String label,
    required CustomCellType cellType,
    double? customWidth,
  }) {
    // If custom width is provided, use it
    if (customWidth != null) {
      return customWidth;
    }

    // More accurate width calculation based on label length and font characteristics
    double baseWidth = label.length * 8.5; // Increased character width for better header visibility
    
    // Add padding for the container
    baseWidth += 48.0; // Increased padding (12px on each side) for better header visibility
    
    // Adjust based on cell type
    switch (cellType) {
      case CustomCellType.checkbox:
        baseWidth = 60.0; // Fixed width for checkbox column
        break;
      case CustomCellType.dropdown:
        baseWidth = 140.0; // Reduced width for dropdown column
        break;
      case CustomCellType.save:
        baseWidth = 80.0; // Fixed width for save button
        break;
      case CustomCellType.number:
        baseWidth += 16.0; // Extra space for numbers and alignment
        break;
      case CustomCellType.categorical:
        baseWidth += 20.0; // Extra space for categorical data
        break;
      case CustomCellType.text:
      default:
        // Add some buffer for text overflow
        baseWidth += 8.0;
        break;
    }
    
    // Ensure minimum and maximum width constraints
    return baseWidth.clamp(100.0, 300.0);
  }
} 