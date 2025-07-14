import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

/// Manages multiple checkbox selection states for datagrids
class MultiCheckboxManager<T> extends ChangeNotifier {
  final Map<String, Set<int>> _selectedRows = <String, Set<int>>{};
  final Map<String, void Function(Set<int> selectedRows)> _callbacks = <String, void Function(Set<int> selectedRows)>{};
  List<T> _data;
  bool _isInitializing = false;

  MultiCheckboxManager({
    required List<T> data,
    Map<String, void Function(Set<int> selectedRows)>? callbacks,
  })  : _data = List<T>.from(data) {
    if (callbacks != null) {
      _callbacks.addAll(callbacks);
      // Initialize empty sets for each checkbox column
      for (String columnName in callbacks.keys) {
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
    _isInitializing = true;
    _selectedRows[columnName] = <int>{};
    for (int i = 0; i < _data.length; i++) {
      if (shouldSelect(_data[i])) {
        _selectedRows[columnName]!.add(i);
      }
    }
    _isInitializing = false;
    notifyListeners(); // Only update UI, don't trigger callback
  }

  /// Toggle selection for a specific row in a specific checkbox column
  void toggleRowSelection(String columnName, int rowIndex) {
    if (!_selectedRows.containsKey(columnName)) {
      _selectedRows[columnName] = <int>{};
    }
    
    if (_selectedRows[columnName]!.contains(rowIndex)) {
      _selectedRows[columnName]!.remove(rowIndex);
    } else {
      _selectedRows[columnName]!.add(rowIndex);
    }
    _notifySelectionChanged(columnName);
  }

  /// Select all rows for a specific checkbox column
  void selectAll(String columnName) {
    if (!_selectedRows.containsKey(columnName)) {
      _selectedRows[columnName] = <int>{};
    }
    _selectedRows[columnName]!.clear();
    _selectedRows[columnName]!.addAll(List.generate(_data.length, (i) => i));
    _notifySelectionChanged(columnName);
  }

  /// Clear all selections for a specific checkbox column
  void clearSelection(String columnName) {
    _selectedRows[columnName]?.clear();
    _notifySelectionChanged(columnName);
  }

  /// Update data and clean invalid selections
  void updateData(List<T> newData, {Map<String, bool Function(T item)>? shouldSelectMap}) {
    _data = List<T>.from(newData);
    
    // Clear all selections when data changes
    for (String columnName in _selectedRows.keys) {
      _selectedRows[columnName]!.clear();
    }
    
    // Reinitialize selections if predicates are provided
    if (shouldSelectMap != null) {
      for (String columnName in shouldSelectMap.keys) {
        if (!_selectedRows.containsKey(columnName)) {
          _selectedRows[columnName] = <int>{};
        }
        final shouldSelect = shouldSelectMap[columnName]!;
        for (int i = 0; i < _data.length; i++) {
          if (shouldSelect(_data[i])) {
            _selectedRows[columnName]!.add(i);
          }
        }
      }
    }
    
    // Only notify UI changes, don't trigger selection callbacks
    notifyListeners();
  }

  void _notifySelectionChanged(String columnName) {
    if (!_isInitializing) {
      _callbacks[columnName]?.call(_selectedRows[columnName] ?? <int>{});
    }
    notifyListeners(); // Notify UI to rebuild
  }

  /// Build header checkbox for a specific column
  Widget buildHeaderCheckbox(String columnName) {
    return Center(
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
    );
  }

  /// Build row checkbox for a specific column
  Widget buildRowCheckbox(String columnName, int rowIndex) {
    return Center(
      child: Checkbox(
        value: isRowSelected(columnName, rowIndex),
        onChanged: (_) => toggleRowSelection(columnName, rowIndex),
        activeColor: AppColors.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Get the boolean value for a checkbox cell (used in DataGridCell)
  bool getCheckboxValue(String columnName, int rowIndex) {
    return isRowSelected(columnName, rowIndex);
  }

  /// Get all checkbox column names
  Set<String> get checkboxColumnNames => _callbacks.keys.toSet();
} 