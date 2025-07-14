import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';

class DescriptionsSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController technicalDescriptionController;
  final TextEditingController financialImpactController;
  final Function(String)? onDescriptionChanged;
  final Function(String)? onTechnicalDescriptionChanged;
  final Function(String)? onFinancialImpactChanged;

  const DescriptionsSection({
    super.key,
    required this.descriptionController,
    required this.technicalDescriptionController,
    required this.financialImpactController,
    this.onDescriptionChanged,
    this.onTechnicalDescriptionChanged,
    this.onFinancialImpactChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        CustomTextField(
          controller: descriptionController,
          label: 'Description',
          isEnabled: true,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
          onChanged: onDescriptionChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: technicalDescriptionController,
          label: 'Technical Description',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Technical Description is required';
            }
            return null;
          },
          onChanged: onTechnicalDescriptionChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: financialImpactController,
          label: 'Potential Financial Impact',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Potential Financial Impact is required';
            }
            return null;
          },
          onChanged: onFinancialImpactChanged,
        ),
      ],
    );
  }
} 