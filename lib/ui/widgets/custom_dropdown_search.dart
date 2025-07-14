import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomDropdownSearch extends StatelessWidget {
  final List<String> items;
  final String title;
  final String hintText;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;
  final bool showSearchBox;

  const CustomDropdownSearch({
    super.key,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.title,
    this.selectedItem,
    required this.isEnabled,
    this.showSearchBox = false,
  });

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: hintText,
      labelStyle: TextStyles.inputMainTextStyle(context),
      filled: true,
      fillColor: Colors.transparent, // Light background for the text field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
        borderSide: const BorderSide(
          color: FillColors.tertiaryColor, // Border color
          width: 0.8, // Border width
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
          color: BorderColors.secondaryColor, // Border color when not focused
          width: 0.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 12), // Reduced padding
      hintStyle: TextStyles.inputHintTextStyle(context),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedItem != null && isEnabled)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onChanged(null),
            ),
          const Icon(Icons.arrow_drop_down_rounded,
              size: 28, color: BorderColors.secondaryColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      enabled: isEnabled,
      items: items,
      selectedItem: selectedItem,
      onChanged: onChanged,
      validator: (value) =>
          (value == null || value.isEmpty) ? '$title is required.' : null,
      clearButtonProps: ClearButtonProps(
        isVisible: selectedItem != null,
        icon: const Icon(Icons.clear, size: 18),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyles.inputMainTextStyle(context),
        dropdownSearchDecoration: _buildInputDecoration(context),
      ),
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: showSearchBox,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 300),
        itemBuilder: (context, item, isSelected) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? FillColors.tertiaryColor.withOpacity(0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: BorderColors.secondaryColor.withOpacity(0.15),
                width: 0.8,
              ),
            ),
          ),
          child: Text(
            item,
            style: TextStyles.inputMainTextStyle(context).copyWith(
              fontWeight:
                  isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: BorderColors.secondaryColor.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        menuProps: MenuProps(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          elevation: 8,
        ),
      ),
    );
  }
}
