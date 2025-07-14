import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isEnabled;

  const AnimatedCheckbox({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading || !isEnabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
        ),
      ),
    );
  }
}
