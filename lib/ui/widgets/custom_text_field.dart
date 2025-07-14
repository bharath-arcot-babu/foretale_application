import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator; // Add validator function
  final bool isEnabled;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField(
      {super.key,
      required this.controller,
      required this.label,
      this.obscureText = false,
      this.maxLines = 1,
      this.validator, // Add the validator parameter
      required this.isEnabled,
      this.onChanged,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        enabled: isEnabled,
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        style: TextStyles.inputMainTextStyle(context),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
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
              color:
                  BorderColors.secondaryColor, // Highlight color when focused
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color:
                  BorderColors.secondaryColor, // Border color when not focused
              width: 0.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 12), // Reduced padding
          hintText: '', // Dynamic hint text
          hintStyle: TextStyles.inputHintTextStyle(context),
        ),
        validator: validator, // Assign the validator function
        onChanged: onChanged);
  }
}
