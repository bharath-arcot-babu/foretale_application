import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomDropdownSearch extends StatelessWidget {
  final List<String> items; // List of items to display
  final String labelText; // Label text for the dropdown
  final String hintText; // Hint text for the dropdown
  final String? selectedItem;
  final ValueChanged<String?> onChanged; // Callback when an item is selected
  final bool isEnabled;
  bool showSearchBox = false;

  CustomDropdownSearch(
      {super.key,
      required this.items,
      required this.hintText,
      required this.onChanged,
      required this.labelText,
      this.selectedItem,
      required this.isEnabled,
      this.showSearchBox = false
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      enabled: isEnabled,
      items: items, // Pass the list of items
      selectedItem: selectedItem,
      popupProps: PopupProps.menu(
        itemBuilder: (context, item, isSelected) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.transparent, // Highlight selected item
              border: Border(
                bottom: BorderSide(color: BorderColors.secondaryColor),
              ),
            ),
            child: Text(
              item,
              style: TextStyles.inputMainTextStyle(context),
            ),
          );
        },
        showSearchBox: showSearchBox, // Enable search bar
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search...', // Search bar hint text
            border: OutlineInputBorder(),
          ),
        ),
        menuProps: MenuProps(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyles.inputHintTextStyle(context),
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          hintText: hintText, // Hint text for the dropdown
          labelStyle: TextStyles.inputMainTextStyle(context),
          filled: true,
          fillColor: Colors.transparent, // Light background for the dropdown
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
            borderSide: const BorderSide(
              color: FillColors.tertiaryColor, // Border color
              width: 1.2, // Border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BorderColors.secondaryColor, // Highlight color when focused
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color:BorderColors.secondaryColor, // Border color when not focused
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 12), // Reduced padding
          hintStyle: TextStyles.inputHintTextStyle(context),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText is required.'; // Custom validation error message
        }
        return null; // No error
      },
    );
  }
}
