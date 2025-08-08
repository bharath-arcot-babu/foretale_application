import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/test_config_parser.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/screens/test_case/test_list_widget.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/test_case/sql_query_dialog_widget.dart';

class TestService {
  static const String _currentFileName = "test_service";

  // Test Selection Methods
  static Future<void> handleTestSelection(BuildContext context, dynamic test) async {
    int resultId;
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
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
        // refresh UI if needed - this will be handled by the parent widget
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

  // Test Actions Methods
  static Widget showSqlQueryDialog(BuildContext context, Test test, Function() onMaximizeChanged) {
    return SqlQueryDialogWidget(test: test, onMaximizeChanged: onMaximizeChanged);
  }

  static Future<void> showFlaggedTransactionsDialog(BuildContext context, Test test) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: SizedBox(
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

  static Widget showChatScreen(BuildContext context, Test test) {
    final testsModel = Provider.of<TestsModel>(context, listen: false);
    final userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    return ChatScreen(
      key: ValueKey('test_config_chat_${test.testId}'),
      drivingModel: testsModel,
      isChatEnabled: true,
      userId: userDetailsModel.getUserMachineId ?? "",
      enableWebSocket: true,
    );
  }

  static Widget showTestList(BuildContext context) {
    return const TestsListView();
  }

  // Public methods for SQL operations
  static Future<int> saveSqlQuery(BuildContext context, Test test, CodeController codeController) async {
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
      SnackbarMessage.showErrorMessage(
        context, 
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "saveSqlQuery");
    }
    return 0;
  }

  static Future<void> saveAndRunSqlQuery(BuildContext context, Test test, CodeController codeController) async {
    try {
      final testsModel = Provider.of<TestsModel>(context, listen: false);
      
      int updatedId = await saveSqlQuery(context, test, codeController);

      if(updatedId > 0){
        try{
            testsModel.executeTest(context, test);
            SnackbarMessage.showSuccessMessage(context, "Test is running in the background.");
            await testsModel.updateTestExecutionStatusToRunning(context, test);
        } catch (e) {
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
}