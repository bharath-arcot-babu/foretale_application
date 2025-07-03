import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

/// Manages checkbox selection state for datagrids
class DatagridCheckboxManager<T> extends ChangeNotifier {
  final Set<int> _selectedRows = <int>{};
  List<T> _data;
  final void Function(Set<int> selectedRows)? _onSelectionChanged;
  bool _isInitializing = false;

  DatagridCheckboxManager({
    required List<T> data,
    void Function(Set<int> selectedRows)? onSelectionChanged,
  })  : _data = List<T>.from(data),
        _onSelectionChanged = onSelectionChanged;

  /// Get selected row indices
  Set<int> get selectedRowIndices => Set<int>.from(_selectedRows);

  /// Get selected items
  List<T> get selectedItems => _selectedRows.map((index) => _data[index]).toList();

  /// Check if all rows are selected
  bool get isAllSelected => _selectedRows.length == _data.length && _data.isNotEmpty;

  /// Check if some rows are selected
  bool get isPartiallySelected => _selectedRows.isNotEmpty && _selectedRows.length < _data.length;

  /// Check if a specific row is selected
  bool isRowSelected(int rowIndex) => _selectedRows.contains(rowIndex);

  /// Initialize selections based on a predicate function
  void initializeSelections(bool Function(T item) shouldSelect) {
    _isInitializing = true;
    _selectedRows.clear();
    for (int i = 0; i < _data.length; i++) {
      if (shouldSelect(_data[i])) {
        _selectedRows.add(i);
      }
    }
    _isInitializing = false;
    notifyListeners(); // Only update UI, don't trigger callback
  }

  /// Toggle selection for a specific row
  void toggleRowSelection(int rowIndex) {
    if (_selectedRows.contains(rowIndex)) {
      _selectedRows.remove(rowIndex);
    } else {
      _selectedRows.add(rowIndex);
    }
    _notifySelectionChanged();
  }

  /// Select all rows
  void selectAll() {
    _selectedRows.clear();
    _selectedRows.addAll(List.generate(_data.length, (i) => i));
    _notifySelectionChanged();
  }

  /// Clear all selections
  void clearSelection() {
    _selectedRows.clear();
    _notifySelectionChanged();
  }

  /// Update data and clean invalid selections
  void updateData(List<T> newData, {bool Function(T item)? shouldSelect}) {
    _data = List<T>.from(newData);
    // Clear all selections when data changes
    _selectedRows.clear();
    
    // Reinitialize selections if a predicate is provided
    if (shouldSelect != null) {
      for (int i = 0; i < _data.length; i++) {
        if (shouldSelect(_data[i])) {
          _selectedRows.add(i);
        }
      }
    }
    
    // Only notify UI changes, don't trigger selection callback
    notifyListeners();
  }

  void _notifySelectionChanged() {
    if (!_isInitializing) {
      _onSelectionChanged?.call(_selectedRows);
    }
    notifyListeners(); // Notify UI to rebuild
  }

  /// Build header checkbox
  Widget buildHeaderCheckbox() {
    return Center(
      child: Checkbox(
        value: isAllSelected,
        tristate: true,
        onChanged: (bool? newValue) {
          newValue == true ? selectAll() : clearSelection();
        },
        activeColor: AppColors.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Build row checkbox
  Widget buildRowCheckbox(int rowIndex) {
    return Center(
      child: Checkbox(
        value: isRowSelected(rowIndex),
        onChanged: (_) => toggleRowSelection(rowIndex),
        activeColor: AppColors.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Get the boolean value for a checkbox cell (used in DataGridCell)
  bool getCheckboxValue(int rowIndex) {
    return isRowSelected(rowIndex);
  }
} 