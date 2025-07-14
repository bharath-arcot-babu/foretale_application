import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/ui/widgets/custom_show_status_text.dart';
import 'package:foretale_application/ui/widgets/custom_ai_magic_button.dart';
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
                borderRadius: BorderRadius.circular(12),
                child: ModernContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(8),
                  backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftSideOfCard(context, test, onTestSelection),
                        const SizedBox(width: 16),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  test.testName,
                  style: TextStyles.subjectText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Test description
          Text(
            test.testDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.gridText(context),
          ),
          const SizedBox(height: 16),
          // Test metadata chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              CustomChip(label: test.testCategory ?? ''),
              CustomChip(label: test.testRunType ?? ''),
              CustomChip(label: test.testCriticality ?? ''),
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
          _buildScriptGenerationWidget(context, test, pollingController),
          const SizedBox(height: 12),
          _buildScriptExecutionWidget(context, test),
          const SizedBox(height: 12),
          _buildShowResultsWidget(context, test),
        ],
      ),
    );
  }

  static Widget _buildScriptGenerationWidget(BuildContext context, Test test, PollingController? pollingController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AI Magic button
        AiMagicIconButton(
          onPressed: () async {
            await TestActionsService.aiMagicGenerateQuery(context, test, pollingController: pollingController);
          },
          tooltip: 'AI Magic - Generate query',
          iconSize: 18.0,
        ),
        const SizedBox(height: 5),
        // Status indicators
        if (test.testConfigGenerationStatus == "Started")
          LinearLoadingIndicator(
            isLoading: true,
            color: AppColors.primaryColor,
            backgroundColor: Colors.grey[300]!,
            loadingText: test.testConfigGenerationStatus ?? '',
            textStyle: TextStyles.tinySupplementalInfo(context),
            width: 30,
            height: 3,
          ),
        if (test.testConfigGenerationStatus != null && test.testConfigGenerationStatus != "Started")
          StatusBadge(
            text: test.testConfigGenerationStatus ?? '',
          ),
      ],
    );
  }

  static Widget _buildScriptExecutionWidget(BuildContext context, Test test) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SQL Query button
        CustomIconButton(
          icon: Icons.query_stats,
          onPressed: () => TestActionsService.showSqlQueryDialog(context, test),
          tooltip: 'Show SQL query',
          isProcessing: false,
          iconSize: 18.0,
        ),
        const SizedBox(height: 8),
        // Status indicator
        if (test.testConfigExecutionStatus == "Completed")
          StatusBadge(
            text: test.testConfigExecutionStatus ?? '',
          ),
      ],
    );
  }

  static Widget _buildShowResultsWidget(BuildContext context, Test test) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Results button
        CustomIconButton(
          icon: Icons.flag,
          onPressed: () => TestActionsService.showFlaggedTransactionsDialog(context, test),
          tooltip: 'Show flagged transactions',
          isProcessing: false,
          iconSize: 18.0,
        ),
        const SizedBox(height: 8),
        // Status indicator
        if (test.testConfigExecutionStatus == "Completed")
          StatusBadge(
            text: "Results",
          ),
      ],
    );
  }

  static Widget buildNoTestsFound(BuildContext context) {
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
} 