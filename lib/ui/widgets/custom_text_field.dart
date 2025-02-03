import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator; // Add validator function

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator, // Add the validator parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14, // Smaller text size
        color: Colors.black87, // Sharp text color
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12, // Smaller label size
          color: Colors.grey, // Subtle label color
        ),
        filled: true,
        fillColor: Colors.grey.shade100, // Light background for the text field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
          borderSide: const BorderSide(
            color: Colors.grey, // Border color
            width: 1.2, // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blueAccent, // Highlight color when focused
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey, // Border color when not focused
            width: 1.2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
        hintText: 'Enter $label', // Dynamic hint text
        hintStyle: const TextStyle(
          fontSize: 12, // Small hint text
          color: Colors.grey, // Hint color
        ),
      ),
      validator: validator, // Assign the validator function
    );
  }
}
