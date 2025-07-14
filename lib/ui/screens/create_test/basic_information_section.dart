import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/llms/api/llm_api.dart';
import 'package:foretale_application/core/services/llms/prompts/test_config_prompt.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_future_dropdown.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';

class BasicInformationSection extends StatefulWidget {
  final TextEditingController industryController;
  final TextEditingController topicController;
  final TextEditingController projectTypeController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController technicalDescriptionController;
  final TextEditingController financialImpactController;

  const BasicInformationSection({
    super.key,
    required this.industryController,
    required this.topicController,
    required this.projectTypeController,
    required this.nameController,
    required this.descriptionController,
    required this.technicalDescriptionController,
    required this.financialImpactController,
  });

  @override
  State<BasicInformationSection> createState() => _BasicInformationSectionState();
}

class _BasicInformationSectionState extends State<BasicInformationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Industry
            Expanded(
              flex: 1,
              child: CustomTextField(
                controller: widget.industryController,
                label: 'Industry',
                isEnabled: false,
                onChanged: (value) {
                  // Project type is disabled, no change handler needed
                },
              ),
            ),
            const SizedBox(width: 16),
            // Topic
            Expanded(
              flex: 1,
              child: CustomTextField(
                controller: widget.projectTypeController,
                label: 'Project Type',
                isEnabled: false,
                onChanged: (value) {
                  // Project type is disabled, no change handler needed
                },
              ),
            ),
            const SizedBox(width: 16),
            // Project Type
            Expanded(
              flex: 1,
              child: FutureDropdownSearch(
                fetchData: () async {
                  TopicList topicList = TopicList();
                  await topicList.fetchAllActiveTopics(context);
                  return topicList.topicList.map((topic) => topic.name).toList();
                },
                labelText: "Topic",
                hintText: 'Choose Topic',
                isEnabled: true,
                selectedItem: widget.topicController.text.isEmpty ? null : widget.topicController.text,
                onChanged: (value) {
                  if (value != null) {
                    widget.topicController.text = value;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.nameController,
                label: 'Name',
                isEnabled: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Project type is disabled, no change handler needed
                },
              ),
            ),
            const SizedBox(width: 8),
            AiMagicIconButton(
              onPressed: () {
                try{
                  _handleAiMagicPressed(context);
                } catch (e) {
                  SnackbarMessage.showErrorMessage(
                    context, 
                    "Error in generating test name, description and technical description with AI", 
                    logError: true,
                    errorMessage: e.toString(),
                    errorStackTrace: e.toString(),
                    errorSource: "BasicInformationSection",
                    severityLevel: 'Critical',
                    requestPath: "_handleAiMagicPressed",
                    );
                }
              },
              tooltip: 'Generate test name with AI',
            ),
          ],
        ),
      ],
    );
  }

  void _handleAiMagicPressed(BuildContext context) async {
    TestCasePrompts prompts = TestCasePrompts();

    if (widget.projectTypeController.text.isEmpty || widget.topicController.text.isEmpty || widget.nameController.text.isEmpty) {
      SnackbarMessage.showErrorMessage(context, 'Please choose a project type, topic and enter a test name');
      return;
    }

    String callingPrompt = prompts.generateDescriptions.buildPromptForTestConfig(
      widget.projectTypeController.text, 
      widget.topicController.text, 
      widget.nameController.text
      );
      
    final modelOuput = await LLMService().callLLMGeneralPurpose(prompt: callingPrompt, maxTokens: 2000);

    print("modelOuput: $modelOuput");
    
    widget.nameController.text = modelOuput['rewritten_test_name'] ?? widget.nameController.text;
    widget.descriptionController.text = modelOuput['business_description'] ?? widget.descriptionController.text;
    widget.technicalDescriptionController.text = modelOuput['technical_description'] ?? widget.technicalDescriptionController.text;
    widget.financialImpactController.text = modelOuput['financial_impact_formula'] ?? widget.financialImpactController.text;
    
  }
} 