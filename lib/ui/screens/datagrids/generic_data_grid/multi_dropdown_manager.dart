import 'package:flutter/material.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';

/// Manages multiple dropdown selection states for datagrids
class MultiDropdownManager<T> extends ChangeNotifier {
  final Map<String, Map<int, String>> _selectedValues = <String, Map<int, String>>{};
  final Map<String, List<String>> _dropdownOptions = <String, List<String>>{};
  final Map<String, void Function(Map<int, String> selectedValues)> _callbacks = <String, void Function(Map<int, String> selectedValues)>{};
  List<T> _data;
  bool _isInitializing = false;

  MultiDropdownManager({
    required List<T> data,
    Map<String, List<String>>? dropdownOptions,
    Map<String, void Function(Map<int, String> selectedValues)>? callbacks,
  })  : _data = List<T>.from(data) {
    if (dropdownOptions != null) {
      _dropdownOptions.addAll(dropdownOptions);
    }
    if (callbacks != null) {
      _callbacks.addAll(callbacks);
      // Initialize empty maps for each dropdown column
      for (String columnName in callbacks.keys) {
        _selectedValues[columnName] = <int, String>{};
      }
    }
  }

  /// Get selected values for a specific dropdown column
  Map<int, String> getSelectedValues(String columnName) {
    return Map<int, String>.from(_selectedValues[columnName] ?? <int, String>{});
  }

  /// Get selected value for a specific row in a specific dropdown column
  String? getSelectedValue(String columnName, int rowIndex) {
    return _selectedValues[columnName]?[rowIndex];
  }

  /// Get dropdown options for a specific column
  List<String> getDropdownOptions(String columnName) {
    return List<String>.from(_dropdownOptions[columnName] ?? <String>[]);
  }

  /// Set dropdown options for a specific column
  void setDropdownOptions(String columnName, List<String> options) {
    _dropdownOptions[columnName] = List<String>.from(options);
    notifyListeners();
  }

  /// Initialize selections for a specific dropdown column based on a predicate function
  void initializeSelections(String columnName, String? Function(T item) getValue) {
    _isInitializing = true;
    _selectedValues[columnName] = <int, String>{};
    for (int i = 0; i < _data.length; i++) {
      final value = getValue(_data[i]);
      if (value != null) {
        _selectedValues[columnName]![i] = value;
      }
    }
    _isInitializing = false;
    notifyListeners(); // Only update UI, don't trigger callback
  }

  /// Set selection for a specific row in a specific dropdown column
  void setRowSelection(String columnName, int rowIndex, String? value) {
    if (!_selectedValues.containsKey(columnName)) {
      _selectedValues[columnName] = <int, String>{};
    }
    
    if (value != null) {
      _selectedValues[columnName]![rowIndex] = value;
    } else {
      _selectedValues[columnName]!.remove(rowIndex);
    }
    _notifySelectionChanged(columnName);
  }

  /// Clear all selections for a specific dropdown column
  void clearSelection(String columnName) {
    _selectedValues[columnName]?.clear();
    _notifySelectionChanged(columnName);
  }

  /// Update data and clean invalid selections
  void updateData(List<T> newData, {Map<String, String? Function(T item)>? getValueMap}) {
    _data = List<T>.from(newData);
    
    // Clear all selections when data changes
    for (String columnName in _selectedValues.keys) {
      _selectedValues[columnName]!.clear();
    }
    
    // Reinitialize selections if predicates are provided
    if (getValueMap != null) {
      for (String columnName in getValueMap.keys) {
        if (!_selectedValues.containsKey(columnName)) {
          _selectedValues[columnName] = <int, String>{};
        }
        final getValue = getValueMap[columnName]!;
        for (int i = 0; i < _data.length; i++) {
          final value = getValue(_data[i]);
          if (value != null) {
            _selectedValues[columnName]![i] = value;
          }
        }
      }
    }
    
    // Only notify UI changes, don't trigger selection callbacks
    notifyListeners();
  }

  void _notifySelectionChanged(String columnName) {
    if (!_isInitializing) {
      _callbacks[columnName]?.call(_selectedValues[columnName] ?? <int, String>{});
    }
    notifyListeners(); // Notify UI to rebuild
  }

  /// Build dropdown for a specific row and column
  Widget buildRowDropdown(String columnName, int rowIndex) {
    final options = getDropdownOptions(columnName);
    final selectedValue = getSelectedValue(columnName, rowIndex);
    
    // Validate that the selected value exists in the options list
    final validSelectedValue = selectedValue != null && options.contains(selectedValue) 
        ? selectedValue 
        : null;
    
    return Material(
      color: Colors.transparent,
      child: CustomDropdownSearch(
          items: options,
          title: "",
          hintText: 'Select...',
          selectedItem: validSelectedValue,
          onChanged: (String? newValue) {
            setRowSelection(columnName, rowIndex, newValue);
          },
          isEnabled: true,
          showSearchBox: false,
        ),
      
    );
  }

  /// Get the string value for a dropdown cell (used in DataGridCell)
  String? getDropdownValue(String columnName, int rowIndex) {
    return getSelectedValue(columnName, rowIndex);
  }

  /// Get all dropdown column names
  Set<String> get dropdownColumnNames => _callbacks.keys.toSet();
} 