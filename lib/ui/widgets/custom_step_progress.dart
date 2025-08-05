import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<StepData> steps;
  final Function(int)? onStepTap;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BorderColors.tertiaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Steps
          Row(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              final isClickable = onStepTap != null && index <= currentStep + 1;

              return Expanded(
                child: _buildStepItem(
                  context,
                  step,
                  index,
                  isCompleted,
                  isCurrent,
                  isClickable,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    StepData step,
    int index,
    bool isCompleted,
    bool isCurrent,
    bool isClickable,
  ) {
    final accentColor = isCurrent 
        ? AppColors.primaryColor 
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: isClickable ? () => onStepTap?.call(index) : null,
      child: Column(
        children: [
          // Step circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrent 
                  ? AppColors.primaryColor 
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: isCurrent 
                  ? Border.all(color: AppColors.primaryColor, width: 2)
                  : null,
            ),
            child: Icon(
              step.icon ?? Icons.circle,
              color: isCurrent ? Colors.white : Colors.grey.shade600,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Step title
          Text(
            step.title,
            style: TextStyles.smallSupplementalInfo(context).copyWith(
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: accentColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StepData {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const StepData({
    required this.title,
    this.subtitle,
    this.icon,
  });
} 