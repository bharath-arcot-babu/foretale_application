import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdownSearch extends StatelessWidget {
  final List<String> items; // List of items to display
  final String labelText; // Label text for the dropdown
  final String hintText; // Hint text for the dropdown
  final ValueChanged<String?> onChanged; // Callback when an item is selected

  const CustomDropdownSearch(
      {super.key,
      required this.items,
      required this.hintText,
      required this.onChanged,
      required this.labelText});

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: items, // Pass the list of items
      popupProps: PopupProps.menu(
        showSearchBox: false, // Enable search bar
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search...', // Search bar hint text
            border: OutlineInputBorder(),
          ),
        ),
        menuProps: MenuProps(
          elevation: 4, // Add elevation to the menu
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          hintText: hintText, // Hint text for the dropdown
          border: const OutlineInputBorder(),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText is required.'; // Custom validation error message
        }
        return null; // No error
      }, // Callback when an item is selected
    );
  }
}
