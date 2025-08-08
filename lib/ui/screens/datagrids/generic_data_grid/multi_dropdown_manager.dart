import 'package:flutter/material.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';

/// Manages multiple dropdown selection states for datagrids
class MultiDropdownManager<T> extends ChangeNotifier {
  final Map<String, Map<int, String>> _selectedValues = <String, Map<int, String>>{};
  final Map<String, List<String>> _dropdownOptions = <String, List<String>>{};
  List<T> _data;
  bool _isInitializing = false;
  bool _isUpdating = false; // Add flag to prevent concurrent updates

  MultiDropdownManager({required List<T> data, Map<String, List<String>>? dropdownOptions}) : _data = List<T>.from(data) {
    if (dropdownOptions != null) {
      _dropdownOptions.addAll(dropdownOptions);
    }
    // Initialize empty maps for each dropdown column
    // This will be populated when columns are added
  }

  /// Initialize dropdown columns
  void initializeColumns(Set<String> columnNames) {
    for (String columnName in columnNames) {
      if (!_selectedValues.containsKey(columnName)) {
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
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isInitializing = true;
    _selectedValues[columnName] = <int, String>{};
    
    // Create a copy of data to avoid concurrent modification
    final dataCopy = List<T>.from(_data);
    for (int i = 0; i < dataCopy.length; i++) {
      final value = getValue(dataCopy[i]);
      if (value != null) {
        _selectedValues[columnName]![i] = value;
      }
    }
    _isInitializing = false;
    notifyListeners(); // Only update UI, don't trigger callback
  }

  /// Set selection for a specific row in a specific dropdown column
  void setRowSelection(String columnName, int rowIndex, String? value) {
    if (_isUpdating) return; // Prevent concurrent updates
    
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
    if (_isUpdating) return; // Prevent concurrent updates
    
    _selectedValues[columnName]?.clear();
    _notifySelectionChanged(columnName);
  }

  /// Update data and clean invalid selections
  void updateData(List<T> newData, {Map<String, String? Function(T item)>? getValueMap}) {
    if (_isUpdating) return; // Prevent concurrent updates
    
    _isUpdating = true;
    
    try {
      // Create a copy of the new data to avoid concurrent modification
      _data = List<T>.from(newData);
      
      // Create a copy of selected values to work with
      final selectedValuesCopy = Map<String, Map<int, String>>.from(_selectedValues);
      
      // Clear all selections when data changes
      for (String columnName in selectedValuesCopy.keys) {
        selectedValuesCopy[columnName]!.clear();
      }
      
      // Reinitialize selections if predicates are provided
      if (getValueMap != null) {
        for (String columnName in getValueMap.keys) {
          if (!selectedValuesCopy.containsKey(columnName)) {
            selectedValuesCopy[columnName] = <int, String>{};
          }
          final getValue = getValueMap[columnName]!;
          
          // Use a copy of data for iteration
          final dataCopy = List<T>.from(_data);
          for (int i = 0; i < dataCopy.length; i++) {
            final value = getValue(dataCopy[i]);
            if (value != null) {
              selectedValuesCopy[columnName]![i] = value;
            }
          }
        }
      }
      
      // Update the actual selected values map
      _selectedValues.clear();
      _selectedValues.addAll(selectedValuesCopy);
      
    } finally {
      _isUpdating = false;
      // Only notify UI changes, don't trigger selection callbacks
      notifyListeners();
    }
  }

  void _notifySelectionChanged(String columnName) {
    if (!_isInitializing && !_isUpdating) {
      // No callbacks to notify
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
      child: SizedBox(
        height: 28, // Constrain height for datagrid cells
        width: double.infinity, // Ensure full width usage
        child: CustomDropdownSearch(
          items: options,
          title: "",
          hintText: 'Select',
          selectedItem: validSelectedValue,
          onChanged: (String? newValue) {
            setRowSelection(columnName, rowIndex, newValue);
          },
          isEnabled: true,
          showSearchBox: false,
        ),
      ),
    );
  }

  /// Get the string value for a dropdown cell (used in DataGridCell)
  String? getDropdownValue(String columnName, int rowIndex) {
    return getSelectedValue(columnName, rowIndex);
  }

  /// Get all dropdown column names
  Set<String> get dropdownColumnNames => _dropdownOptions.keys.toSet();
} 