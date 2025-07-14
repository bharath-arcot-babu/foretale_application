import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class TestSelectionService {
  static const String _currentFileName = "test_selection_service";

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
} 