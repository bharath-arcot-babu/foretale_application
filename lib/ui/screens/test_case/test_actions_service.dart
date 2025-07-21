import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/test_config_parser.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
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

  static Widget showSqlQueryDialog(BuildContext context, Test test) {
    String formattedQuery = TestConfigParser.parseFormattedSql(test.config);
    late CodeController _codeController;
    _codeController = CodeController(
      text: formattedQuery.isNotEmpty ? formattedQuery : '-- No SQL query available --',
      language: sql
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Row(
                  children: [
                      const Icon(Icons.query_stats, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40, // Approx height for 2 lines
                        width: constraints.maxWidth * 0.8,
                        child: Text(
                          'SQL Query - ${test.testName}',
                          style: TextStyles.tinySupplementalInfo(context),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const Spacer(),
                      CustomIconButton(
                        icon: Icons.save,
                        onPressed: () async {
                          await _saveSqlQuery(context, test, _codeController);
                        },
                        tooltip: 'Save',
                        iconSize: 18.0,
                      ),
                      const SizedBox(width: 4),
                      CustomIconButton(
                        icon: Icons.play_arrow,
                        onPressed: () async {
                          await _saveAndRunSqlQuery(context, test, _codeController);
                        },
                        tooltip: 'Save & Run',
                        iconSize: 18.0,
                      )
                  ],
                ),
                Expanded(
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomCodeFormatter(
                      initialCode: formattedQuery.isNotEmpty ? formattedQuery : '-- No SQL query available --',
                      onCodeChanged: (code) {
                        _codeController.text = code;
                      },
                      width: constraints.maxWidth,
                    ),
                  ),
                ),
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
} 