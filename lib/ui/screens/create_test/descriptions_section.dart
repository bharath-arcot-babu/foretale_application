import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';

class DescriptionsSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController technicalDescriptionController;
  final TextEditingController financialImpactController;
  final TextEditingController estimatedImpactScenariosController;
  final TextEditingController financialImpactProxyMetricsController;
  final TextEditingController financialImpactIndustryBenchmarksController;
  final TextEditingController qualitativeImpactFramingController;
  final Function(String)? onDescriptionChanged;
  final Function(String)? onTechnicalDescriptionChanged;
  final Function(String)? onFinancialImpactChanged;
  final Function(String)? onEstimatedImpactScenariosChanged;
  final Function(String)? onFinancialImpactProxyMetricsChanged;
  final Function(String)? onFinancialImpactIndustryBenchmarksChanged;
  final Function(String)? onQualitativeImpactFramingChanged;

  const DescriptionsSection({
    super.key,
    required this.descriptionController,
    required this.technicalDescriptionController,
    required this.financialImpactController,
    required this.estimatedImpactScenariosController,
    required this.financialImpactProxyMetricsController,
    required this.financialImpactIndustryBenchmarksController,
    required this.qualitativeImpactFramingController,
    this.onDescriptionChanged,
    this.onTechnicalDescriptionChanged,
    this.onFinancialImpactChanged,
    this.onEstimatedImpactScenariosChanged,
    this.onFinancialImpactProxyMetricsChanged,
    this.onFinancialImpactIndustryBenchmarksChanged,
    this.onQualitativeImpactFramingChanged,
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
        const SizedBox(height: 20),
        CustomTextField(
          controller: estimatedImpactScenariosController,
          label: 'Estimated Impact Using Scenarios',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Estimated Impact Using Scenarios is required';
            }
            return null;
          },
          onChanged: onEstimatedImpactScenariosChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: financialImpactProxyMetricsController,
          label: 'Financial Impact Using Proxy Metrics',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Financial Impact Using Proxy Metrics is required';
            }
            return null;
          },
          onChanged: onFinancialImpactProxyMetricsChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: financialImpactIndustryBenchmarksController,
          label: 'Financial Impact Estimation Using Industry Benchmarks',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Financial Impact Estimation Using Industry Benchmarks is required';
            }
            return null;
          },
          onChanged: onFinancialImpactIndustryBenchmarksChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: qualitativeImpactFramingController,
          label: 'Qualitative Impact Framing',
          isEnabled: true,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Qualitative Impact Framing is required';
            }
            return null;
          },
          onChanged: onQualitativeImpactFramingChanged,
        ),
      ],
    );
  }
} 