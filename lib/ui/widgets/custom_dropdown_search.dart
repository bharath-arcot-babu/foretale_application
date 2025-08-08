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
      hintStyle: TextStyles.inputMainTextStyle(context).copyWith(
        fontSize: 10,
        color: TextColors.hintTextColor,
      ),
      labelStyle: TextStyles.inputMainTextStyle(context),
      filled: true,
      fillColor: Colors.transparent, // Light background for the text field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4), // Smaller radius for datagrid
        borderSide: const BorderSide(
          color: FillColors.tertiaryColor, // Border color
          width: 0.8, // Border width
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: BorderColors.secondaryColor, // Highlight color when focused
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: BorderColors.secondaryColor, // Border color when not focused
          width: 0.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5), // Added left padding for visible text
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

      dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: TextStyles.inputMainTextStyle(context).copyWith(
            fontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
          dropdownSearchDecoration: _buildInputDecoration(context),
        ),
      clearButtonProps: ClearButtonProps(
        padding: const EdgeInsets.all(0),
        isVisible: selectedItem != null && isEnabled,
        icon: const Icon(Icons.close, size: 12, color: BorderColors.secondaryColor),
        splashRadius: 16,
        splashColor: BorderColors.secondaryColor.withOpacity(0.1),
        highlightColor: BorderColors.secondaryColor.withOpacity(0.05),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      ),
      dropdownButtonProps: const DropdownButtonProps(
        padding: EdgeInsets.all(0),
        icon: Icon(Icons.arrow_drop_down_rounded, size: 24, color: BorderColors.secondaryColor),
        splashRadius: 16,
        splashColor: BorderColors.secondaryColor,
        highlightColor: BorderColors.secondaryColor,
        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
      ),
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: showSearchBox,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 300),
        itemBuilder: (context, item, isSelected) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          height: 28,
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
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyles.inputMainTextStyle(context).copyWith(
              fontSize: 10,
              color: TextColors.hintTextColor,
            ),
            prefixIcon: const Icon(Icons.search, size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: BorderColors.secondaryColor.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        menuProps: MenuProps(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          elevation: 8,
        ),
      ),
    );
  }
}
