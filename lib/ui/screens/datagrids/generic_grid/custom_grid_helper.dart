import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';

List<CustomGridColumn> getColumnsOrderedByFirstColumnName(List<CustomGridColumn> columns, String? firstColumnName) {
  List<CustomGridColumn> orderedColumns = List.from(columns); //make a shallow copy of the columns list
  
  if (firstColumnName != null && firstColumnName.isNotEmpty) {
    final firstColumnIndex = orderedColumns.indexWhere(
      (col) => col.columnName == firstColumnName
    );
    
    if (firstColumnIndex != -1) {
      final firstColumn = orderedColumns.removeAt(firstColumnIndex); //remove the first column from the list
      orderedColumns.insert(0, firstColumn); //insert the first column at the beginning of the list
    }
  }
  
  return orderedColumns; //return the ordered list of columns
}

