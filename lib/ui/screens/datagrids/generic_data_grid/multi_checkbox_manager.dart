import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

/// Manages multiple checkbox selection states for datagrids
class MultiCheckboxManager<T> extends ChangeNotifier {
  final Map<String, Set<int>> _selectedRows = <String, Set<int>>{};
  List<T> _data;
  bool _isUpdating = false; // Add flag to prevent concurrent updates

  MultiCheckboxManager({required List<T> data}) : _data = List<T>.from(data) {
    // Initialize empty sets for each checkbox column
    // This will be populated when columns are added
  }

  /// Initialize checkbox columns
  void initializeColumns(Set<String> columnNames) {
    for (String columnName in columnNames) {
      if (!_selectedRows.containsKey(columnName)) {
        _selectedRows[columnName] = <int>{};
      }
    }
  }

  /// Get selected row indices for a specific checkbox column
  Set<int> getSelectedRowIndices(String columnName) {
    return Set<int>.from(_selectedRows[columnName] ?? <int>{});
  }

  /// Get selected items for a specific checkbox column
  List<T> getSelectedItems(String columnName) {
    final indices = _selectedRows[columnName] ?? <int>{};
    return indices.map((index) => _data[index]).toList();
  }

  /// Check if all rows are selected for a specific checkbox column
  bool isAllSelected(String columnName) {
    final selected = _selectedRows[columnName] ?? <int>{};
    return selected.length == _data.length && _data.isNotEmpty;
  }

  /// Check if some rows are selected for a specific checkbox column
  bool isPartiallySelected(String columnName) {
    final selected = _selectedRows[columnName] ?? <int>{};
    return selected.isNotEmpty && selected.length < _data.length;
  }

  /// Check if a specific row is selected for a specific checkbox column
  bool isRowSelected(String columnName, int rowIndex) {
    return (_selectedRows[columnName] ?? <int>{}).contains(rowIndex);
  }

  /// Initialize selections for a specific checkbox column based on a predicate function
  void initializeSelections(String columnName, bool Function(T item) shouldSelect) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _selectedRows[columnName] = <int>{};
    
    // Create a copy of data to avoid concurrent modification
    final dataCopy = List<T>.from(_data);
    for (int i = 0; i < dataCopy.length; i++) {
      if (shouldSelect(dataCopy[i])) {
        _selectedRows[columnName]!.add(i);
      }
    }
    notifyListeners(); // Only update UI, don't trigger callback
  }

  /// Toggle selection for a specific row in a specific checkbox column
  void toggleRowSelection(String columnName, int rowIndex) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    if (!_selectedRows.containsKey(columnName)) {
      _selectedRows[columnName] = <int>{};
    }
    
    if (_selectedRows[columnName]!.contains(rowIndex)) {
      _selectedRows[columnName]!.remove(rowIndex);
    } else {
      _selectedRows[columnName]!.add(rowIndex);
    }
    notifyListeners(); // Notify UI to rebuild
  }

  /// Select all rows for a specific checkbox column
  void selectAll(String columnName) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    if (!_selectedRows.containsKey(columnName)) {
      _selectedRows[columnName] = <int>{};
    }
    _selectedRows[columnName]!.clear();
    _selectedRows[columnName]!.addAll(List.generate(_data.length, (i) => i));
    notifyListeners(); // Notify UI to rebuild
  }

  /// Clear all selections for a specific checkbox column
  void clearSelection(String columnName) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _selectedRows[columnName]?.clear();
    notifyListeners(); // Notify UI to rebuild
  }

  /// Update data and clean invalid selections
  void updateData(List<T> newData, {Map<String, bool Function(T item)>? shouldSelectMap}) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isUpdating = true;
    
    try {
      // Create a copy of the new data to avoid concurrent modification
      _data = List<T>.from(newData);
      
      // Create a copy of selected rows to work with
      final selectedRowsCopy = Map<String, Set<int>>.from(_selectedRows);
      
      // Clear all selections when data changes
      for (String columnName in selectedRowsCopy.keys) {
        selectedRowsCopy[columnName]!.clear();
      }
      
      // Reinitialize selections if predicates are provided
      if (shouldSelectMap != null) {
        for (String columnName in shouldSelectMap.keys) {
          if (!selectedRowsCopy.containsKey(columnName)) {
            selectedRowsCopy[columnName] = <int>{};
          }
          final shouldSelect = shouldSelectMap[columnName]!;
          
          // Use a copy of data for iteration
          final dataCopy = List<T>.from(_data);
          for (int i = 0; i < dataCopy.length; i++) {
            if (shouldSelect(dataCopy[i])) {
              selectedRowsCopy[columnName]!.add(i);
            }
          }
        }
      }
      
      // Update the actual selected rows map
      _selectedRows.clear();
      _selectedRows.addAll(selectedRowsCopy);
      
    } finally {
      _isUpdating = false;
      // Only notify UI changes, don't trigger selection callbacks
      notifyListeners();
    }
  }

  /// Build header checkbox for a specific column
  Widget buildHeaderCheckbox(String columnName, {bool isFeedbackColumn = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: isFeedbackColumn ? BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 2.0,
          ),
          right: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),
      ) : null,
      child: Center(
        child: Transform.scale(
          scale: 0.6, // Changed from 0.8 to 0.6 to match row checkbox size
          child: Checkbox(
            value: isAllSelected(columnName),
            tristate: true,
            onChanged: (bool? newValue) {
              newValue == true ? selectAll(columnName) : clearSelection(columnName);
            },
            activeColor: AppColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }

  /// Build row checkbox for a specific column
  Widget buildRowCheckbox(String columnName, int rowIndex) {
    return Center(
      child: Transform.scale(
        scale: 0.6,
        child: Checkbox(
          value: isRowSelected(columnName, rowIndex),
          onChanged: (_) => toggleRowSelection(columnName, rowIndex),
          activeColor: AppColors.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  /// Get the boolean value for a checkbox cell (used in DataGridCell)
  bool getCheckboxValue(String columnName, int rowIndex) {
    return isRowSelected(columnName, rowIndex);
  }

  /// Get all checkbox column names
  Set<String> get checkboxColumnNames => _selectedRows.keys.toSet();
} 