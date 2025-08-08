import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/core/services/http_nonstreaming_service.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/create_test_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_future.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
import 'package:provider/provider.dart';

class BasicInformationSection extends StatefulWidget {
  final TextEditingController industryController;
  final TextEditingController topicController;
  final TextEditingController projectTypeController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController technicalDescriptionController;
  final TextEditingController potentialImpactController;

  const BasicInformationSection({
    super.key,
    required this.industryController,
    required this.topicController,
    required this.projectTypeController,
    required this.nameController,
    required this.descriptionController,
    required this.technicalDescriptionController,
    required this.potentialImpactController,
  });

  @override
  State<BasicInformationSection> createState() => _BasicInformationSectionState();
}

class _BasicInformationSectionState extends State<BasicInformationSection> {
  bool _isAiMagicProcessing = false;
  late CreateTestModel createTestModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      createTestModel = Provider.of<CreateTestModel>(context, listen: false);
    });
  }

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
                    createTestModel.setTopic(value);
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
                onChanged: (value){
                  createTestModel.setTestName(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            AiMagicIconButton(
              onPressed: () async {
                try{
                  await _handleAiMagicPressed(context);
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
                } finally {
                  setState(() {
                    _isAiMagicProcessing = false;
                  });
                }
              },
              isProcessing: _isAiMagicProcessing,
              tooltip: 'Generate test case with AI Magic',
            ),
          ],
        ),
        const SizedBox(height: 15),
        CustomTextField(
          controller: widget.descriptionController,
          label: 'Description',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
          isEnabled: true,
          onChanged: (value){
            createTestModel.setTestDescription(value);
          },
        ),
        const SizedBox(height: 15),
        CustomTextField(
          controller: widget.technicalDescriptionController,
          label: 'Technical Description',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Technical description is required';
            }
            return null;
          },
          isEnabled: true,
          onChanged: (value){
            createTestModel.setTechnicalDescription(value);
          },
        ),
        const SizedBox(height: 15),
        CustomTextField(
          controller: widget.potentialImpactController,
          label: 'Potential Impact',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Potential impact is required';
            }
            return null;
          },
          isEnabled: true,
          onChanged: (value){
            createTestModel.setPotentialImpact(value);
          },
        ),
      ],
    );
  }



  Future<void> _handleAiMagicPressed(BuildContext context) async {
    if (widget.projectTypeController.text.isEmpty || widget.topicController.text.isEmpty || widget.nameController.text.isEmpty) {
      SnackbarMessage.showErrorMessage(context, 'Please choose a project type, topic and enter a test name');
      return;
    }

    setState(() {
      _isAiMagicProcessing = true;
    });

    // Create HTTP non-streaming service for AI magic generation
    final nonStreamingService = HttpNonStreamingService(
      HttpNonStreamingForFinancialImpact.nonStreamingFi, 
      timeout: const Duration(seconds: 30));

    // Build the test case text
    String testCaseText = '''
      Test case name: '${widget.nameController.text}'
      Industry: '${widget.industryController.text}' 
      Business Process: '${widget.projectTypeController.text}' 
      Function:'${widget.topicController.text}' 
    ''';

    // Create the request body as a Map instead of JSON string
    final Map<String, dynamic> requestBody = {
      'test_case': testCaseText,
      'test_description': widget.descriptionController.text,
    };

    // Send the data for AI magic generation
    final response = await nonStreamingService.post('', body: requestBody);

    if (response.isSuccess) {
      // Handle successful response
      // Parse the AI response using the utility method
      final messageJson = response.parseAiResponse();

      if (messageJson != null) {
        // Update description if available
        if (messageJson['impact_summary'] != null && messageJson['impact_summary'].toString().isNotEmpty) {
          createTestModel.setTestDescription(messageJson['impact_summary'].toString());
          widget.descriptionController.text = messageJson['impact_summary'].toString();
        }

        // Update technical description if available
        if (messageJson['technical_description'] != null && messageJson['technical_description'].toString().isNotEmpty) {
          createTestModel.setTechnicalDescription(messageJson['technical_description'].toString());
          widget.technicalDescriptionController.text = messageJson['technical_description'].toString();
        }

        if(messageJson['chosen_metric_type'] != null && messageJson['chosen_metric_type'].toString().isNotEmpty) {
          createTestModel.setChosenMetricType(messageJson['chosen_metric_type'].toString());
        }

        // Update potential impact if available
        if (messageJson['metric_details'] != null && messageJson['metric_details'].toString().isNotEmpty) {
          createTestModel.setPotentialImpact(messageJson['metric_details'].toString());
          widget.potentialImpactController.text =   messageJson['metric_details'].toString();
        }

        if(messageJson['business_risks'] != null && messageJson['business_risks'] is List) {
          List<dynamic> risksList = messageJson['business_risks'] as List<dynamic>;
          for(var risk in risksList) {
            if (risk is String) {
              createTestModel.addBusinessRisk(risk);
            }
          }
        }

        if(messageJson['recommended_actions'] != null && messageJson['recommended_actions'] is List) {
          List<dynamic> actionsList = messageJson['recommended_actions'] as List<dynamic>;
          for(var action in actionsList) {
            if (action is String) {
              createTestModel.addBusinessAction(action);
            }
          }
        }

      } else {
        SnackbarMessage.showErrorMessage(context, 'Unable to parse AI response.');
      }
    } else {
      // Handle error response
      throw Exception("HTTP Error: ${response.error}");
    }
  }
} 