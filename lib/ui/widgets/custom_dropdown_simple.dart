import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomDropdownSimple<T> extends StatelessWidget {
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;
  final bool isEnabled;
  final String? label;
  final String? errorText;
  final bool compact;

  const CustomDropdownSimple({
    super.key,
    this.hint,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.isEnabled = true,
    this.label,
    this.errorText,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 28 : 32,
      decoration: BoxDecoration(
        color: FillColors.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: errorText != null 
              ? ErrorColors.errorTextColor 
              : BorderColors.tertiaryColor,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Container(
                  height: compact ? 20 : 24,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 4 : 6,
                    vertical: 0,
                  ),
                  child: Center(
                    child: Text(
                      itemToString(item),
                      style: compact 
                          ? TextStyles.inputMainTextStyle(context).copyWith(
                              fontSize: 10,
                              height: 1.0,
                            )
                          : TextStyles.inputMainTextStyle(context).copyWith(
                              fontSize: 11,
                              height: 1.1,
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: isEnabled ? onChanged : null,
            hint: hint != null ? Center(
              child: Text(
                hint!,
                style: compact 
                    ? TextStyles.inputHintTextStyle(context).copyWith(
                        fontSize: 10,
                        height: 1.0,
                      )
                    : TextStyles.inputHintTextStyle(context).copyWith(
                        fontSize: 11,
                        height: 1.1,
                      ),
              ),
            ) : null,
            icon: Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: TextColors.hintTextColor,
                size: compact ? 14 : 16,
              ),
            ),
            dropdownColor: FillColors.secondaryColor,
            style: compact 
                ? TextStyles.inputMainTextStyle(context).copyWith(
                    fontSize: 10,
                    height: 1.0,
                  )
                : TextStyles.inputMainTextStyle(context).copyWith(
                    fontSize: 11,
                    height: 1.1,
                  ),
            isExpanded: true,
            menuMaxHeight: compact ? 80 : 100,
            alignment: AlignmentDirectional.topStart,
            elevation: 1,
            borderRadius: BorderRadius.circular(2),
            padding: EdgeInsets.only(
              left: compact ? 6 : 8,
              right: compact ? 6 : 8,
              top: compact ? 2 : 3,
              bottom: compact ? 2 : 3,
            ),
          ),
        ),
      ),
    );
  }
}
