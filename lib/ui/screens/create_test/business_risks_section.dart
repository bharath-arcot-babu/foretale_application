import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

class BusinessRisk {
  final String id;
  final String description;

  BusinessRisk({
    required this.id,
    required this.description,
  });
}

class BusinessRisksSection extends StatefulWidget {
  final List<BusinessRisk> risks;
  final Function(List<BusinessRisk>) onRisksChanged;

  const BusinessRisksSection({
    super.key,
    required this.risks,
    required this.onRisksChanged,
  });

  @override
  State<BusinessRisksSection> createState() => _BusinessRisksSectionState();
}

class _BusinessRisksSectionState extends State<BusinessRisksSection> {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addRisk() {
    if (_formKey.currentState?.validate() ?? false) {
      final newRisk = BusinessRisk(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text.trim(),
      );

      final updatedRisks = List<BusinessRisk>.from(widget.risks)..add(newRisk);
      widget.onRisksChanged(updatedRisks);

      // Clear form
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business risk added successfully!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void _deleteRisk(String riskId) {
    final updatedRisks = widget.risks.where((risk) => risk.id != riskId).toList();
    widget.onRisksChanged(updatedRisks);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Business risk removed successfully!'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Future<void> _generateRisksWithAI() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: "AI Magic",
      cancelText: "NO",
      confirmText: "YES",
      confirmTextColor: Colors.green,
      content: "AI Magic will attempt to generate business risks based on your test details. This will add new risks to your list. Would you like to continue?",
    );

    if (confirmed == true) {
      
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI Magic button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Risks',
                style: TextStyles.subtitleText(context),
              ),
              AiMagicIconButton(
                onPressed: _generateRisksWithAI,
                tooltip: 'Generate risks with AI',
                iconSize: 18.0,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add new risk form
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Risk Description',
                  maxLines: 2,
                  isEnabled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Risk description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      width: 120,
                      height: 40,
                      text: 'Add',
                      textSize: 14,
                      onPressed: _addRisk,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List of existing risks
          Text(
            'Current Risks (${widget.risks.length})',
            style: TextStyles.subtitleText(context),
          ),
          const SizedBox(height: 12),

          if (widget.risks.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_outlined,
                    size: 48,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No business risks added yet',
                    style: TextStyle(
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: widget.risks.length,
                itemBuilder: (context, index) {
                  final risk = widget.risks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                   risk.description,
                                   style: TextStyles.responseText(context),
                                 ),
                              ),
                              CustomIconButton(
                                icon: Icons.delete,
                                onPressed: () => _deleteRisk(risk.id),
                                tooltip: 'Delete risk',
                                iconSize: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }


} 