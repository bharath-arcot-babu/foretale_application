import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/create_test_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_one_line_info_card.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_collapsible_section.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_step_progress.dart';
import 'package:foretale_application/ui/screens/create_test/basic_information_section.dart';
import 'package:foretale_application/ui/screens/create_test/test_configuration_section.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class CreateTest extends StatefulWidget {
  final bool isNew;

  const CreateTest({super.key, required this.isNew});

  @override
  State<CreateTest> createState() => _CreateTestState();
}

class _CreateTestState extends State<CreateTest> {
  final String _currentFileName = "create_test.dart";  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Current step for progress indicator
  int _currentStep = 0;

  // Persistent controllers for form fields
  late TextEditingController _industryController;
  late TextEditingController _topicController;
  late TextEditingController _projectTypeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _technicalDescriptionController;
  late TextEditingController _potentialImpactController;

  // Step data for progress indicator
  final List<StepData> _steps = [
    const StepData(
      title: 'Basic Info',
    ),
    const StepData(
      title: 'Settings',
    ),  
    const StepData(
      title: 'Risks & Actions',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _industryController = TextEditingController();
    _topicController = TextEditingController();
    _projectTypeController = TextEditingController();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _technicalDescriptionController = TextEditingController();
    _potentialImpactController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      var createTestModel = Provider.of<CreateTestModel>(context, listen: false);
      
      // Initialize with project details
      createTestModel.setProjectType(projectDetailsModel.getProjectType);
      createTestModel.setIndustry(projectDetailsModel.getIndustry);
      
      // Set initial values for controllers
      _updateControllersFromModel(createTestModel);
    });
  }

  void _updateControllersFromModel(CreateTestModel createTestModel) {
    _industryController.text = createTestModel.getIndustry;
    _topicController.text = createTestModel.getTopic;
    _projectTypeController.text = createTestModel.getProjectType;
    _nameController.text = createTestModel.getTestName;
    _descriptionController.text = createTestModel.getTestDescription;
    _technicalDescriptionController.text = createTestModel.getTechnicalDescription;
    _potentialImpactController.text = createTestModel.getPotentialImpact;
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
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
    _potentialImpactController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        return _formKey.currentState?.validate() ?? false;
      case 2:
        return _validateRisksActionsStep();
      default:
        return true;
    }
  }

  bool _validateRisksActionsStep() {
    var createTestModel = Provider.of<CreateTestModel>(context, listen: false);
    bool isValid = true;
    
    if (createTestModel.getBusinessRisks.isEmpty) {
      isValid = false;
    }
    if (createTestModel.getBusinessActions.isEmpty) {
      isValid = false;
    }
    
    if (!isValid) {
      SnackbarMessage.showErrorMessage(context, 'Please add at least one business risk and one business action');
    }
    
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_task,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isNew ? 'CREATE TEST' : 'EDIT TEST',
                            style: TextStyles.subjectText(context).copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Configure your test case with detailed information',
                            style: TextStyles.subtitleText(context).copyWith(
                              color: TextColors.hintTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Removed Save button - save operation handled by Finish button
                  ],
                ),
                const SizedBox(height: 16),
                
                // Step Progress Indicator
                StepProgressIndicator(
                  currentStep: _currentStep,
                  totalSteps: _steps.length,
                  steps: _steps,
                  onStepTap: _goToStep,
                ),
                const SizedBox(height: 16),
                
                // Content based on current step
                Expanded(
                  child: _buildStepContent(),
                ),
                
                // Navigation buttons
                const SizedBox(height: 16),
                _buildNavigationButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildConfigurationStep();
      case 2:
        return _buildRisksActionsStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  Widget _buildBasicInfoStep() {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Basic Information Section
                CollapsibleSection(
                  title: 'Basic Information',
                  subtitle: 'Test name, description, and core details',
                  icon: Icons.info_outline,
                  initiallyExpanded: true,
                  child: BasicInformationSection(
                    industryController: _industryController,
                    topicController: _topicController,
                    projectTypeController: _projectTypeController,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    technicalDescriptionController: _technicalDescriptionController,
                    potentialImpactController: _potentialImpactController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigurationStep() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: const CollapsibleSection(
          title: 'Test Configuration',
          subtitle: 'Configure test parameters and settings',
          icon: Icons.settings_outlined,
          initiallyExpanded: true,
          child: TestConfigurationSection(),
        ),
      ),
    );
  }

  Widget _buildRisksActionsStep() {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Simplified Business Risks Section
              CollapsibleSection(
                title: 'Business Risks',
                subtitle: 'Identify potential business risks and impacts',
                icon: Icons.warning_outlined,
                accentColor: Colors.orange,
                child: _buildSimplifiedRisksSection(createTestModel),
              ),
              
              // Simplified Business Actions Section
              CollapsibleSection(
                title: 'Business Actions',
                subtitle: 'Define actions to mitigate identified risks',
                icon: Icons.work_outline,
                accentColor: Colors.green,
                child: _buildSimplifiedActionsSection(createTestModel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimplifiedRisksSection(CreateTestModel createTestModel) {
    final TextEditingController riskController = TextEditingController();
    final GlobalKey<FormState> riskFormKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add new risk form
          Form(
            key: riskFormKey,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                  controller: riskController,
                  label: 'Risk',
                  isEnabled: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Risk is required';
                    }
                    return null;
                  }
                ),
                ),
                const SizedBox(width: 8),
                CustomElevatedButton(
                  width: 80,
                  height: 40,
                  text: 'Add',
                  textSize: 12,
                  useGradient: true,
                  isEnabled: true,
                  onPressed: () {
                    if (riskController.text.trim().isNotEmpty) {
                      createTestModel.addBusinessRisk(riskController.text.trim());
                      riskController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display existing risks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Risks (${createTestModel.getBusinessRisks.length})',
                style: TextStyles.subtitleText(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (createTestModel.getBusinessRisks.isNotEmpty)
                CustomIconButton(
                  onPressed: () {
                    createTestModel.clearBusinessRisks();
                  },
                  icon: Icons.clear_all,
                  tooltip: 'Clear',
                  iconColor: Colors.red,
                  iconSize: 14,
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (createTestModel.getBusinessRisks.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    size: 32,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No risks added',
                    style: TextStyles.subtitleText(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: createTestModel.getBusinessRisks.length,
              itemBuilder: (context, index) {
                final risk = createTestModel.getBusinessRisks[index];
                return CustomOneLineInfoCard(
                  title: risk.riskStatement,
                  subtitle: "",
                  trailing: CustomIconButton(
                    onPressed: () {
                      createTestModel.removeBusinessRisk(risk.riskId);
                    },
                    icon: Icons.delete,
                    tooltip: 'Delete',
                    iconColor: Colors.red,
                    iconSize: 14,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedActionsSection(CreateTestModel createTestModel) {
    final TextEditingController actionController = TextEditingController();
    final GlobalKey<FormState> actionFormKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add new action form
          Form(
            key: actionFormKey,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                  controller: actionController,
                  label: 'Action',
                  isEnabled: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Action is required';
                    }
                    return null;
                  }
                ),
                ),
                const SizedBox(width: 8),
                CustomElevatedButton(
                  width: 80,
                  height: 40,
                  text: 'Add',
                  textSize: 12,
                  useGradient: true,
                  isEnabled: true,
                  onPressed: () {
                    if (actionController.text.trim().isNotEmpty) {
                      createTestModel.addBusinessAction(actionController.text.trim());
                      actionController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display existing actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actions (${createTestModel.getBusinessActions.length})',
                style: TextStyles.subtitleText(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (createTestModel.getBusinessActions.isNotEmpty)
                CustomIconButton(
                  onPressed: () {
                    createTestModel.clearBusinessActions();
                  },
                  icon: Icons.clear_all,
                  tooltip: 'Clear',
                  iconColor: Colors.red,
                  iconSize: 14,
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (createTestModel.getBusinessActions.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 32,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No actions added',
                    style: TextStyles.subtitleText(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: createTestModel.getBusinessActions.length,
              itemBuilder: (context, index) {
                final action = createTestModel.getBusinessActions[index];
                return CustomOneLineInfoCard(
                  title: action.businessAction,
                  subtitle: "",
                  trailing: CustomIconButton(
                    onPressed: () {
                      createTestModel.removeBusinessAction(action.actionId);
                    },
                    icon: Icons.delete,
                    tooltip: 'Delete',
                    iconColor: Colors.red,
                    iconSize: 14,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            if (_currentStep > 0)
              CustomElevatedButton(
                width: 120,
                height: 40,
                text: 'Previous',
                textSize: 14,
                useGradient: true,
                onPressed: _previousStep,
              )
            else
              const SizedBox(width: 120),
            
            // Next/Finish button
            CustomElevatedButton(
              width: 120,
              height: 40,
              text: _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
              textSize: 14,
              useGradient: true,
              isLoading: createTestModel.getIsLoading,
              onPressed: _currentStep == _steps.length - 1 ? _saveTest : _nextStep,
              icon: Icons.save
            ),
          ],
        );
      },
    );
  }

  void _clearAllFields() {
    var createTestModel = Provider.of<CreateTestModel>(context, listen: false);
    createTestModel.reset();
    
    setState(() {
      _currentStep = 0;
    });
  }

  void _saveTest() async {
    var createTestModel = Provider.of<CreateTestModel>(context, listen: false);

    // Validate all steps before saving
    if (_validateCurrentStep()) {
      try {
        createTestModel.setLoading(true);
        int insertedId = await createTestModel.saveTest(context);

        if (insertedId > 0) {
          // Clear all fields after successful save
          _clearAllFields();      
          Navigator.pop(context);    
          SnackbarMessage.showSuccessMessage(context, 'Test saved successfully!');

          var testsModel = Provider.of<TestsModel>(context, listen: false);
          testsModel.fetchTestsByProject(context);
        }
      } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveTest");
      } finally {
        createTestModel.setLoading(false);
      }
    }
  }
} 