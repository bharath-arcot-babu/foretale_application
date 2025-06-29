import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/core/utils/test_config_parser.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_code_formatter.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart'; 
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';


class PollingController extends ChangeNotifier with PollingMixin {}

class TestsListView extends StatefulWidget {
  const TestsListView({super.key});

  @override
  _TestsListViewState createState() => _TestsListViewState();
}

class _TestsListViewState extends State<TestsListView> {
  final String _currentFileName = "test_config_lv";
  late final TestsModel testsModel;
  String selectedCategory = "All";
  late InquiryResponseModel inquiryResponseModel;
  late UserDetailsModel userModel;
  late ProjectDetailsModel projectModel;
  late PollingController pollingController;
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    pollingController = PollingController();
    _codeController = CodeController(
      text: '',
      language: sql
    );
    inquiryResponseModel.responseList.clear();
  }

  @override
  void dispose() {
    pollingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ModernContainer(
          width: 220,
          child: _buildCategoryList(),
        ),
        Expanded(
          child: Consumer<TestsModel>(
            builder: (context, model, child) {
              final testsList = selectedCategory == "All" 
                                ? model.filteredTestsList 
                                : model.filteredTestsList.where((test) => test.testCategory == selectedCategory).toList();

              return testsList.isEmpty
                  ? _noTestsFound()
                  : CustomAnimatedSwitcher(
                      child: ListView.builder(
                        key: ValueKey<String>(selectedCategory),
                        itemCount: testsList.length,
                        itemBuilder: (context, index) {
                          final test = testsList[index];
                          return _buildTestCard(context, testsModel, test);
                        },
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }


  Widget _noTestsFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No tests found in this category",
            style: TextStyles.subjectText(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, TestsModel testsModel, Test test) {
    return Hero(
      tag: 'test-${test.testName}',
      child: Material(
        type: MaterialType.transparency,
        child: FadeAnimator(
          child: StatefulBuilder(
            builder: (context, setState) {
              final isSelected = (testsModel.getSelectedTestId == test.testId);
              return InkWell(
                onTap: () async {
                  await inquiryResponseModel.setIsPageLoading(true);
                  await testsModel.updateTestIdSelection(test.testId);
                  await inquiryResponseModel.fetchResponsesByTest(context);
                  await inquiryResponseModel.setIsPageLoading(false);
                },
                borderRadius: BorderRadius.circular(12),
                child: ModernContainer(
                  //margin: const EdgeInsets.only(bottom: 12),
                  backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedCheckbox(
                              isSelected: test.isSelected,
                              onTap: () => _handleTestSelection(test),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                test.testName,
                                style: TextStyles.subjectText(context),
                              ),
                            ),

                            
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        Text(
                            test.testDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.gridText(context),
                          ),
                        
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CustomChip(label: test.testCategory),
                            const SizedBox(width: 12),
                            CustomChip(label: test.testRunType),
                            const SizedBox(width: 12),
                            CustomChip(label: test.testCriticality),
                            const Spacer(),
                            Column(
                              children: [
                                AiMagicIconButton(
                                  onPressed: () async {                               
                                    //Invoke the AI Magic to generate the query
                                    await aiMagicGenerateQuery(
                                      context = context, 
                                      test.testName, 
                                      test.testDescription, 
                                      test.technicalDescription,
                                      inquiryResponseModel.getSortedResponseTexts.join("\n"), 
                                      test.relevantSchemaName, 
                                      test.testId.toString(),
                                      test.config,
                                      test.selectClause
                                    );

                                    //Update the test config update status --listener
                                    await testsModel.updateTestConfigGenerationStatus(
                                      test.testId,
                                      "Started"
                                    );

                                    //Start polling
                                    pollingController.startPolling(context, (BuildContext ctx) async {
                                      await testsModel.fetchTestsByProject(context);
                                      final stillPending = testsModel.testsList.any((x) => x.testConfigGenerationStatus == "Started");
                                      if (!stillPending) {
                                        pollingController.stopPolling(); // ✅ Stop polling if nothing left
                                      }
                                    });
                                    
                                  },
                                  tooltip: 'AI Magic - Generate query',
                                  iconSize: 18.0,
                                ),
                                const SizedBox(height: 1),
                                if (test.testConfigGenerationStatus == "Started")
                                LinearLoadingIndicator(
                                  isLoading: true,
                                  color: AppColors.primaryColor,
                                  backgroundColor: Colors.grey[300]!,
                                  loadingText: test.testConfigGenerationStatus,
                                  textStyle: TextStyles.tinySupplementalInfo(context),
                                  width: 30,
                                  height: 4,
                                ),
                                if (test.testConfigGenerationStatus != "Started")
                                Text(
                                  test.testConfigGenerationStatus,
                                  style: TextStyles.tinySupplementalInfo(context),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                CustomIconButton(
                                  icon: Icons.query_stats,
                                  onPressed: () => showSqlQueryDialog(context, test),
                                  tooltip: 'Show SQL query',
                                  isProcessing: false,
                                  iconSize: 18.0,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  test.testConfigExecutionStatus,
                                  style: TextStyles.tinySupplementalInfo(context),
                                ),
                              ],
                            ),
                            
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                CustomIconButton(
                                  icon: Icons.flag,
                                  onPressed: () => showFlaggedTransactionsDialog(context, test),
                                  tooltip: 'Show flagged transactions',
                                  isProcessing: false,
                                  iconSize: 18.0,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  test.testConfigExecutionStatus == "Completed" ? "Show Results" : " ",
                                  style: TextStyles.tinySupplementalInfo(context),
                                ),
                              ],
                            ),
                            
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> aiMagicGenerateQuery(
    BuildContext context,
    String testName,
    String testDescription,
    String technicalDescription,
    String pastUserResponses,
    String relevantSchemaName,
    String testId,
    String defaultConfig,
    String selectClause) async {

    try {
        const content = "Queries are generated using an AI language model and may not be fully accurate. Users must review, validate, and test all queries before execution. The system does not guarantee compliance with business or regulatory rules. This tool is intended to assist, not replace, expert judgment. Would you like to continue?";
      //Show the confirmation dialog
        final confirmed = await showConfirmDialog(
          context: context,
          title: "AI Magic",
          cancelText: "NO",
          confirmText: "YES",
          confirmTextColor: Colors.green,
          content: content,
        );

        //Run the embedding task
        if (confirmed) {
          print("confirmed: $confirmed");
          SnackbarMessage.showSuccessMessage(context, "AI Magic is working in the background to generate the query.");

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
              "test_case": testName,
              "test_description": technicalDescription,
              "past_user_responses": pastUserResponses,
              "schema_name": relevantSchemaName,
              "project_id": projectModel.getActiveProjectId,
              "test_id": testId,
              "last_updated_by": userModel.getUserMachineId,
              "default_config": defaultConfig,
              "select_clause": selectClause
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

        }
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

  Future<void> showSqlQueryDialog(BuildContext context, Test test) async {
    String formattedQuery = TestConfigParser.parseFormattedSql(test.config);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.query_stats, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Text('SQL Query', style: TextStyles.topicText(context)),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Name: ${test.testName}',
                      style: TextStyles.subjectText(context),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                        child: CustomCodeFormatter(
                          initialCode: formattedQuery,
                          onCodeChanged: (code) {
                            _codeController.text = code;
                          },
                        ),
                    ),
                  ],
                ),
              ),
              actions: [
                CustomIconButton(
                  icon: Icons.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cancel',
                  iconSize: 18.0,
                ),
                const SizedBox(width: 4),
                CustomIconButton(
                  icon: Icons.save,
                  onPressed: () async {
                    await _saveSqlQuery(context, test);
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Save',
                  iconSize: 18.0,
                ),
                const SizedBox(width: 4),
                CustomIconButton(
                  icon: Icons.play_arrow,
                  onPressed: () async {
                    await _saveAndRunSqlQuery(context, test);
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Save & Run',
                  iconSize: 18.0,
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<int> _saveSqlQuery(BuildContext context, Test test) async {
    try {
      const content = "The result of the query will replace the existing analysis. Would you like to continue with the execution?";
      //Show the confirmation dialog
      final confirmed = await showConfirmDialog(
        context: context,
        title: "Execute SQL Query",
        cancelText: "NO",
        confirmText: "YES",
        confirmTextColor: Colors.green,
        content: content,
      );

      int updatedId = 0;
      if (confirmed == true) {
        test.config = TestConfigParser.createConfigJson(_codeController.text);
        updatedId = await testsModel.updateProjectTestConfig(context, test);
        if(updatedId > 0){
          SnackbarMessage.showSuccessMessage(context, "SQL query saved successfully");
        }
      }
      
      return updatedId;
    } catch (e) {
      print("Error: $e");
      SnackbarMessage.showErrorMessage(
        context, 
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_saveSqlQuery");
    }
    return 0;
  }

  Future<void> _saveAndRunSqlQuery(BuildContext context, Test test) async {
    try {
      int updatedId = await _saveSqlQuery(context, test);

      if(updatedId > 0){
        try{
          int executionLogId = await testsModel.insertTestExecutionLog(context, test);
          if(executionLogId > 0){
            try{
              testsModel.executeTest(context, executionLogId);
              SnackbarMessage.showSuccessMessage(context, "Test is running in the background.");
            } catch (e) {
              print("executeTest: $e");
              SnackbarMessage.showErrorMessage(
                context, 
                "Unable to execute the test. Please try again later.",
                logError: true,
                errorMessage: e.toString(),
                errorSource: _currentFileName,
                severityLevel: 'Critical',
                requestPath: "_saveAndRunSqlQuery"
              );
            }
          }
        } catch (e) {
          print("saveAndRunSqlQuery: $e");
          SnackbarMessage.showErrorMessage(
            context, 
            "Unable to execute the test. Please try again later.",
            logError: true,
            errorMessage: e.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveAndRunSqlQuery"
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      SnackbarMessage.showErrorMessage(
        context, 
        "Unable to save and execute the test. Please try again later.",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_saveAndRunSqlQuery");
    }
  }

  Future<void> showFlaggedTransactionsDialog(BuildContext context, Test test) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: ResultScreen(
              test: test,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTestSelection(dynamic test) async {
    int resultId;
    try {
      testsModel.updateTestIdSelection(test.testId);

      if (test.isSelected) {
        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Remove Test',
          content: 'Are you sure you want to remove this test? This action will reset the test configurations.',
          cancelText: 'Cancel',
          confirmText: 'Remove',
          confirmTextColor: AppColors.primaryColor,
        );

        resultId = confirmed ? await testsModel.removeTest(context, test) : -1;

      } else {
        resultId = await testsModel.selectTest(context, test);
      }

      if (resultId > 0) {
        setState(() {}); // refresh UI if needed
      }
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context, 
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_handleTestSelection");
    }
  }

  Widget _buildCategoryList() {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = ["All", ...model.getTestsList.map((e) => e.testCategory).toSet()];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                "Categories",
                style: TextStyles.topicText(context),
              ),
            ),
            Expanded(
                child: SelectableAnimatedList<String>(
              items: categories,
              selectedItem: selectedCategory,
              getLabel: (cat) => cat,
              getCount: (cat) => cat == 'All' ? model.getTestsList.length : model.getTestsList.where((t) => t.testCategory == cat).length,
              onItemSelected: (cat) => setState(() => selectedCategory = cat),
              selectedColor: AppColors.primaryColor,
            )),
          ],
        );
      },
    );
  }
  
}
