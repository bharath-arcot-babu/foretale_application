import 'package:flutter/material.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_show_status_text.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/screens/test_case/test_actions_service.dart';
import 'package:foretale_application/ui/screens/test_case/test_selection_service.dart';

class TestCardWidgets {
  static Widget buildTestCard(
    BuildContext context,
    TestsModel testsModel,
    Test test,
    Function(Test) onTestTap,
    Function(Test) onTestSelection, {
    PollingController? pollingController,
  }) {
    return Hero(
      tag: 'test-${test.testName}',
      child: Material(
        type: MaterialType.transparency,
        child: FadeAnimator(
          child: StatefulBuilder(
            builder: (context, setState) {
              final isSelected = (testsModel.getSelectedTestId == test.testId);
              return InkWell(
                onTap: () => onTestTap(test),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.blue.shade200 
                          : Colors.grey.shade200,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftSideOfCard(context, test, onTestSelection),
                        const SizedBox(width: 20),
                        _buildRightSideOfCard(context, test, pollingController),
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

  static Widget _buildLeftSideOfCard(
    BuildContext context,
    Test test,
    Function(Test) onTestSelection,
  ) {
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with checkbox and test name
          Row(
            children: [
              AnimatedCheckbox(
                isSelected: test.isSelected,
                onTap: () => TestSelectionService.handleTestSelection(context, test),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  test.testName,
                  style: TextStyles.subjectText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Test description
          Text(
            test.testDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.gridText(context).copyWith(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Test metadata chips with modern styling
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              CustomChip(label: test.testCategory, backgroundColor: Colors.blue.shade100, textColor: Colors.blue.shade700),
              CustomChip(label: test.testRunType, backgroundColor: Colors.green.shade100, textColor: Colors.green.shade700),
              CustomChip(label: test.testCriticality, backgroundColor: Colors.orange.shade100, textColor: Colors.orange.shade700),
              CustomChip(label: test.testRunProgram, backgroundColor: Colors.red.shade100, textColor: Colors.red.shade700),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildRightSideOfCard(BuildContext context, Test test, PollingController? pollingController) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildShowResultsWidget(context, test),
        ],
      ),
    );
  }

  static Widget _buildShowResultsWidget(BuildContext context, Test test) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Results button with custom icon button
          CustomIconButton(
            icon: Icons.flag,
            onPressed: () => TestActionsService.showFlaggedTransactionsDialog(context, test),
            tooltip: 'Show flagged transactions',
            isProcessing: false,
            iconSize: 18.0,
            backgroundColor: Colors.white,
            iconColor: Colors.grey.shade700,
            padding: 8.0,
          ),
          const SizedBox(height: 8),
          // Status indicator with modern design
          if (test.testConfigExecutionStatus == "Completed")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 0.5,
                ),
              ),
              child: Text(
                "Results",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildNoTestsFound(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.search_off, 
                size: 32, 
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No tests found in this category",
              style: TextStyles.subjectText(context).copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try selecting a different category or create a new test",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 