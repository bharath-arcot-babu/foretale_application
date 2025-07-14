import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

class BusinessAction {
  final String id;
  final String description;

  BusinessAction({
    required this.id,
    required this.description,
  });
}

class BusinessActionsSection extends StatefulWidget {
  final List<BusinessAction> actions;
  final Function(List<BusinessAction>) onActionsChanged;

  const BusinessActionsSection({
    super.key,
    required this.actions,
    required this.onActionsChanged,
  });

  @override
  State<BusinessActionsSection> createState() => _BusinessActionsSectionState();
}

class _BusinessActionsSectionState extends State<BusinessActionsSection> {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addAction() {
    if (_formKey.currentState?.validate() ?? false) {
      final newAction = BusinessAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text.trim(),
      );

      final updatedActions = List<BusinessAction>.from(widget.actions)..add(newAction);
      widget.onActionsChanged(updatedActions);

      // Clear form
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business action added successfully!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void _deleteAction(String actionId) {
    final updatedActions = widget.actions.where((action) => action.id != actionId).toList();
    widget.onActionsChanged(updatedActions);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Business action removed successfully!'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Future<void> _generateActionsWithAI() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: "AI Magic",
      cancelText: "NO",
      confirmText: "YES",
      confirmTextColor: Colors.green,
      content: "AI Magic will attempt to generate business actions based on your test details. This will add new actions to your list. Would you like to continue?",
    );

    if (confirmed == true) {
      // TODO: Implement AI generation logic
      // For now, add some sample actions
      final sampleActions = [
        BusinessAction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: "Implement data validation checks",
        ),
        BusinessAction(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          description: "Update system documentation",
        ),
        BusinessAction(
          id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
          description: "Conduct user training sessions",
        ),
      ];

      final updatedActions = List<BusinessAction>.from(widget.actions)..addAll(sampleActions);
      widget.onActionsChanged(updatedActions);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Magic has generated business actions!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
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
                'Business Actions',
                style: TextStyles.subtitleText(context),
              ),
              AiMagicIconButton(
                onPressed: _generateActionsWithAI,
                tooltip: 'Generate actions with AI',
                iconSize: 18.0,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add new action form
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Action Description',
                  maxLines: 2,
                  isEnabled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Action description is required';
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
                      onPressed: _addAction,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List of existing actions
          Text(
            'Current Actions (${widget.actions.length})',
            style: TextStyles.subtitleText(context),
          ),
          const SizedBox(height: 12),

          if (widget.actions.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No business actions added yet',
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
                itemCount: widget.actions.length,
                itemBuilder: (context, index) {
                  final action = widget.actions[index];
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
                                  action.description,
                                  style: TextStyles.responseText(context),
                                ),
                              ),
                              CustomIconButton(
                                icon: Icons.delete,
                                onPressed: () => _deleteAction(action.id),
                                tooltip: 'Delete action',
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