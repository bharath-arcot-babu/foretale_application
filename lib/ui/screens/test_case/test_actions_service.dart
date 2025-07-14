import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/core/utils/test_config_parser.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_code_formatter.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';

class PollingController extends ChangeNotifier with PollingMixin {}

class TestActionsService {
  static const String _currentFileName = "test_actions_service";

  static Future<void> aiMagicGenerateQuery(BuildContext context, Test test, {PollingController? pollingController}) async {
    try {
      final inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
      final userModel = Provider.of<UserDetailsModel>(context, listen: false);
      final projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      final testsModel = Provider.of<TestsModel>(context, listen: false);

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
            "test_case": test.testName,
            "test_description": test.technicalDescription,
            "past_user_responses": inquiryResponseModel.getSortedResponseTexts.join("\n"),
            "schema_name": test.relevantSchemaName,
            "project_id": projectModel.getActiveProjectId,
            "test_id": test.testId.toString(),
            "last_updated_by": userModel.getUserMachineId,
            "default_config": test.config,
            "select_clause": test.selectClause,
            "financial_impact_statement": ""
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

          // Update the test config update status --listener
          await testsModel.updateTestConfigGenerationStatus(
            test.testId,
            "Started"
          );

          // Start polling if pollingController is provided
          if (pollingController != null) {
            pollingController.startPolling(context, (BuildContext ctx) async {
              await testsModel.fetchTestsByProject(context);
              final stillPending = testsModel.testsList.any((x) => x.testConfigGenerationStatus == "Started");
              if (!stillPending) {
                pollingController.stopPolling(); // ✅ Stop polling if nothing left
              }
            });
          }
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

  static Future<void> showSqlQueryDialog(BuildContext context, Test test) async {
    String formattedQuery = TestConfigParser.parseFormattedSql(test.config);
    late CodeController _codeController;
    _codeController = CodeController(
      text: '',
      language: sql
    );

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
                    await _saveSqlQuery(context, test, _codeController);
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Save',
                  iconSize: 18.0,
                ),
                const SizedBox(width: 4),
                CustomIconButton(
                  icon: Icons.play_arrow,
                  onPressed: () async {
                    await _saveAndRunSqlQuery(context, test, _codeController);
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

  static Future<int> _saveSqlQuery(BuildContext context, Test test, CodeController codeController) async {
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
      
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
        test.config = TestConfigParser.createConfigJson(codeController.text);
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

  static Future<void> _saveAndRunSqlQuery(BuildContext context, Test test, CodeController codeController) async {
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
      
      int updatedId = await _saveSqlQuery(context, test, codeController);

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

  static Future<void> showFlaggedTransactionsDialog(BuildContext context, Test test) async {
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
              pageTitle: 'Test',
            ),
          ),
        );
      },
    );
  }
} 