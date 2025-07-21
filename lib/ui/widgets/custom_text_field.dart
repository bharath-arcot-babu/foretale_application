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
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: FillColors.tertiaryColor,
              width: 0.5, // Very thin border
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BorderColors.secondaryColor,
              width: 1.0, // Thin focused border
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: FillColors.tertiaryColor,
              width: 0.5, // Very thin enabled border
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: FillColors.tertiaryColor,
              width: 0.3, // Even thinner for disabled state
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 0.5, // Thin error border
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0, // Thin focused error border
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 16), // Increased padding for modern look
          hintText: '',
          hintStyle: TextStyles.inputHintTextStyle(context),
        ),
        validator: validator,
        onChanged: onChanged);
  }
}
