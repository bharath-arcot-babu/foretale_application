import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const AnimatedCheckbox({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
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
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : null,
        ),
      ),
    );
  }
}
