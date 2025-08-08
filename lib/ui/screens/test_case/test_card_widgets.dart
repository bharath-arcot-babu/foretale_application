import 'package:flutter/material.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/screens/test_case/test_service.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart';
import 'package:provider/provider.dart';

class TestCardWidgets {
  static Widget buildTestCard(
    BuildContext context,
    TestsModel testsModel,
    Test test,
    Function(Test) onTestTap,
    Function(Test) onTestSelection,
  ) {
    return Hero(
      tag: 'test-${test.testName}',
      child: StatefulBuilder(
        builder: (context, setState) {
          final isSelected = (testsModel.getSelectedTestId == test.testId);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTestTap(test),
                child: FadeAnimator(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftSideOfCard(context, test),
                        const SizedBox(width: 20),
                        _buildRightSideOfCard(context, test, onTestTap),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildLeftSideOfCard(
    BuildContext context,
    Test test
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
                onTap: () => TestService.handleTestSelection(context, test),
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
              CustomChip(label: test.module, backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700),
              CustomChip(label: test.testCategory, backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700),
              CustomChip(label: test.testRunType, backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700),
              CustomChip(label: test.testCriticality, backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700),
              CustomChip(label: test.testRunProgram, backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildRightSideOfCard(BuildContext context, Test test, Function(Test) onTestTap) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildShowResultsWidget(context, test, onTestTap),
        ],
      ),
    );
  }

  static Widget _buildShowResultsWidget(BuildContext context, Test test, Function(Test) onTestTap) {
    bool showResults = test.testConfigExecutionStatus == "Completed";
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
            onPressed: () {
              onTestTap(test);
              if(showResults){
                TestService.showFlaggedTransactionsDialog(context, test);
              } 
            },
            tooltip: showResults ? 'Show results' : test.testConfigExecutionMessage.replaceAll('<ERR_START>', '').replaceAll('<ERR_END>', ''),
            isProcessing: false,
            iconSize: 18.0,
            backgroundColor: Colors.white,
            iconColor: Colors.grey.shade700,
            padding: 8.0,
          ),
          const SizedBox(height: 8),
          // Status indicator with modern design
          _buildStatusIndicator(context, test.testConfigExecutionStatus),
        ],
      ),
    );
  }

  static Widget _buildStatusIndicator(BuildContext context, String status) {
    const statusConfig = {
      "Completed": {
        "label": "Results",
        "backgroundColor": Colors.green,
      },
      "Running": {
        "label": "Running", 
        "backgroundColor": Colors.orange,
      },
      "Failed": {
        "label": "Failed",
        "backgroundColor": Colors.red,
      },
    };

    final config = statusConfig[status];
    final color = config?["backgroundColor"] as MaterialColor? ?? Colors.grey;
    final label = config?["label"] as String? ?? status;

    return Container(
      width: 80, // Fixed width for consistency
      height: 24, // Fixed height for consistency
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.shade200,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyles.gridText(context).copyWith(
            color: color.shade700,
            fontSize: 11, // Consistent font size
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
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

  // Category List Widget Methods
  static Widget buildCategoryList(String selectedCategory, Function(String) onCategorySelected) {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = ["All", ...model.getTestsList.map((e) => e.testCategory).toSet()];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header
            _buildCategoryHeader(context),
            // Category list
            Expanded(
              child: _buildCategoryList(categories, selectedCategory, onCategorySelected, model),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildCategoryHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.category_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Categories",
              style: TextStyles.topicText(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategoryList(
    List<String> categories,
    String selectedCategory,
    Function(String) onCategorySelected,
    TestsModel model,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SelectableAnimatedList<String>(
          items: categories,
          selectedItem: selectedCategory,
          getLabel: (cat) => cat,
          getCount: (cat) => cat == 'All' 
              ? model.getTestsList.length 
              : model.getTestsList.where((t) => t.testCategory == cat).length,
          onItemSelected: onCategorySelected,
          selectedColor: AppColors.primaryColor,
        ),
      ),
    );
  }
} 