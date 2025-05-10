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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: BorderColors.secondaryColor.withOpacity(0.7),
        width: 1.2,
      ),
    );

    return InputDecoration(
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle: TextStyles.inputHintTextStyle(context)
          .copyWith(color: Colors.black38),
      filled: true,
      fillColor: isEnabled ? Colors.white : Colors.grey[50],
      border: border,
      focusedBorder: border.copyWith(
        borderSide:
            const BorderSide(color: BorderColors.secondaryColor, width: 1.8),
      ),
      enabledBorder: border,
      disabledBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: BorderColors.tertiaryColor, width: 0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DropdownSearch<String>(
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
              baseStyle: TextStyles.inputHintTextStyle(context)
                  .copyWith(color: Colors.black87),
              dropdownSearchDecoration: _buildInputDecoration(context),
            ),
            popupProps: PopupProps.menu(
              showSelectedItems: true,
              showSearchBox: showSearchBox,
              fit: FlexFit.loose,
              itemBuilder: (context, item, isSelected) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: BorderColors.secondaryColor.withOpacity(0.3)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              menuProps: MenuProps(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white,
                elevation: 8,
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyles.enclosureText(context),
            ),
          ),
        ),
      ],
    );
  }
}
