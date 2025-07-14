import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/category_list_model.dart';
import 'package:foretale_application/models/modules_list_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/screens/create_test/basic_information_section.dart';
import 'package:foretale_application/ui/screens/create_test/test_configuration_section.dart';
import 'package:foretale_application/ui/screens/create_test/descriptions_section.dart';
import 'package:foretale_application/ui/screens/create_test/business_risks_section.dart';
import 'package:foretale_application/ui/screens/create_test/business_actions_section.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';

class CreateTest extends StatefulWidget {
  final bool isNew;

  const CreateTest({super.key, required this.isNew});

  @override
  State<CreateTest> createState() => _CreateTestState();
}

class _CreateTestState extends State<CreateTest>  with SingleTickerProviderStateMixin {
  final String _currentFileName = "create_test.dart";
  late TabController _tabController;
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text field controllers
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _projectTypeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _technicalDescriptionController = TextEditingController();
  final TextEditingController _financialImpactController = TextEditingController();

  // Dropdown values
  String? _selectedRunType;
  String? _selectedCriticality;
  String? _selectedCategory;
  String? _selectedModule;
  String? _selectedRunProgram;

  // Business risks and actions lists
  List<BusinessRisk> _businessRisks = [];
  List<BusinessAction> _businessActions = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      _projectTypeController.text = projectDetailsModel.getProjectType;
      _industryController.text = projectDetailsModel.getIndustry;
    });
  }
  @override
  void dispose() {
    _industryController.dispose();
    _topicController.dispose();
    _projectTypeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _technicalDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LinearLoadingIndicator(
        isLoading: true,
        width: 200,
        height: 6,
        color: AppColors.primaryColor,
      );
    }
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isNew ? 'CREATE TEST' : 'EDIT TEST',
              style: TextStyles.subjectText(context),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 4,
              labelStyle: TextStyles.tabSelectedLabelText(context),
              unselectedLabelStyle: TextStyles.tabUnselectedLabelText(context),
              tabs: [
                buildTab(icon: Icons.info, label: 'Test Details'),
                buildTab(icon: Icons.warning, label: 'Business Risks'),
                buildTab(icon: Icons.work, label: 'Business Actions'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Test Details
                  SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomElevatedButton(
                                  width: 120,
                                  height: 40,
                                  text: 'Save',
                                  textSize: 14,
                                  onPressed: () {
                                    _saveTest();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            
                            // Basic Information Section
                            CustomContainer(
                              title: 'Basic Information',
                              child: BasicInformationSection(
                                industryController: _industryController,
                                topicController: _topicController,
                                projectTypeController: _projectTypeController,
                                nameController: _nameController,
                                descriptionController: _descriptionController,
                                technicalDescriptionController: _technicalDescriptionController,
                                financialImpactController: _financialImpactController,
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Descriptions Section
                            CustomContainer(
                              title: 'Descriptions',
                              child: DescriptionsSection(
                                descriptionController: _descriptionController,
                                technicalDescriptionController: _technicalDescriptionController,
                                financialImpactController: _financialImpactController,
                                
                                onDescriptionChanged: (value) {
                                  // Handle description change
                                },
                                onTechnicalDescriptionChanged: (value) {
                                  // Handle technical description change
                                },
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Test Configuration Section
                            CustomContainer(
                              title: 'Test Configuration',
                              child: TestConfigurationSection(
                                selectedRunType: _selectedRunType,
                                selectedCriticality: _selectedCriticality,
                                selectedCategory: _selectedCategory,
                                selectedModule: _selectedModule,
                                selectedRunProgram: _selectedRunProgram,
                                topic: _topicController.text,
                                onRunTypeChanged: (value) {
                                  setState(() {
                                    _selectedRunType = value;
                                  });
                                },
                                onCriticalityChanged: (value) {
                                  setState(() {
                                    _selectedCriticality = value;
                                  });
                                },
                                onCategoryChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                                onModuleChanged: (value) {
                                  setState(() {
                                    _selectedModule = value;
                                  });
                                },
                                onRunProgramChanged: (value) {
                                  setState(() {
                                    _selectedRunProgram = value;
                                  });
                                },
                              ),
                            ),
                            
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Tab 2: Business Risks
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BusinessRisksSection(
                            risks: _businessRisks,
                            onRisksChanged: (risks) {
                              setState(() {
                                _businessRisks = risks;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Tab 3: Business Actions
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BusinessActionsSection(
                            actions: _businessActions,
                            onActionsChanged: (actions) {
                              setState(() {
                                _businessActions = actions;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _clearAllFields() {
    setState(() {
      // Clear text controllers
      _nameController.clear();
      _descriptionController.clear();
      _technicalDescriptionController.clear();
      _topicController.clear();
      
      // Clear dropdown selections
      _selectedRunType = null;
      _selectedCriticality = null;
      _selectedCategory = null;
      _selectedModule = null;
      _selectedRunProgram = null;
  
    });
  }

  void _saveTest() async {
    if (_formKey.currentState!.validate()) {
      try {
        TestsModel testsModel = TestsModel();
        await testsModel.createNewTest(
          context, 
          _nameController.text, 
          _descriptionController.text, 
          _technicalDescriptionController.text, 
          _industryController.text,
          _projectTypeController.text,
          _topicController.text, 
          _selectedRunType ?? '', 
          _selectedRunProgram ?? '',
          _selectedCategory ?? '',
          _selectedModule ?? '',
          _selectedCriticality ?? '');

        // Clear all fields after successful save
        _clearAllFields();
        
        SnackbarMessage.showSuccessMessage(context, 'Test saved successfully!');
      } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveTest");
      }
    }
  }

  Future<void> aiMagicGenerateQuery(BuildContext context, Test test) async {
    try {
      final projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      final userModel = Provider.of<UserDetailsModel>(context, listen: false);

        //Invoke the lambda function to run the embedding task
      final lambdaHelper = LambdaHelper(
        apiGatewayUrl: LambdaApiConfig.ecsConfigInvoker,
      );

      final inputState = {
          "messages": [
            {
              "role": "system",
              "content": "You are an assistant to orchestrate the generation of a SQL query for the given test case."
            }
          ],
          "test_case": test.testName,
          "test_description": test.technicalDescription,
          "past_user_responses": "",
          "schema_name": test.relevantSchemaName,
          "project_id": projectModel.getActiveProjectId,
          "test_id": test.testId.toString(),
          "last_updated_by": userModel.getUserMachineId,
          "default_config": "",
          "select_clause": "",
          "financial_impact_statement": _financialImpactController.text
        };

        final commandPayload = jsonEncode(inputState);

        final payload = {
          "action": "run_task",
          "cluster_name": TestConfigECS.clusterName,
          "task_definition": TestConfigECS.taskDefinition,
          "container_name": TestConfigECS.containerName,
          "command": [
            TestConfigECS.pythonPath,
            TestConfigECS.agentPath,
            commandPayload
          ]
        };

        await lambdaHelper.invokeLambda(payload: payload);

      
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        "An unexpected error occurred: ${e.toString()}",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Error',
        requestPath: "AI Magic",
      );
    }
  }

  Widget buildTab(
      {required IconData icon,
      required String label,
      Color color = AppColors.primaryColor}) {
    return Tab(
      child: FittedBox(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyles.subjectText(context),
          ),
        ],
      )),
    );
  }
} 