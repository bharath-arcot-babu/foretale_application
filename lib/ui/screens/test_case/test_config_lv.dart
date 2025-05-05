import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/ui/widgets/test_config_popup.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class TestsListView extends StatefulWidget {
  const TestsListView({super.key});

  @override
  _TestsListViewState createState() => _TestsListViewState();
}

class _TestsListViewState extends State<TestsListView> {
  late final TestsModel testsModel;
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
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
                  : model.filteredTestsList
                      .where((test) => test.testCategory == selectedCategory)
                      .toList();

              return testsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No tests found in this category",
                            style: TextStyles.subjectText(context).copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ListView.builder(
                        key: ValueKey<String>(selectedCategory),
                        padding: const EdgeInsets.all(16),
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

  Widget _buildTestCard(
      BuildContext context, TestsModel testsModel, Test test) {
    final isSelected = test.isSelected;

    return Hero(
      tag: 'test-${test.testName}',
      child: Material(
        type: MaterialType.transparency,
        child: FadeAnimator(
          child: Card(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.05) // Highlight selected
                : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppColors.primaryColor, width: 1)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            try {
                              testsModel.updateTestIdSelection(test.testId);
                              int resultId = test.isSelected
                                  ? await showConfirmDialog(
                                      context: context,
                                      title: 'Remove Test',
                                      content:
                                          'Are you sure you want to remove this test? This action will reset the test configurations.',
                                      cancelText: 'Cancel',
                                      confirmText: 'Remove',
                                      confirmTextColor: AppColors.primaryColor,
                                    ).then((confirmed) => confirmed
                                      ? testsModel.removeTest(context, test)
                                      : Future.value(-1))
                                  : await testsModel.selectTest(context, test);

                              if (resultId > 0) {
                                setState(() {});
                              }
                            } catch (e) {
                              SnackbarMessage.showErrorMessage(
                                  context, e.toString());
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: test.isSelected
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: test.isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: test.isSelected
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            test.testName,
                            style: TextStyles.subjectText(context),
                          ),
                        ),
                        CustomIconButton(
                          icon: Icons.settings_outlined,
                          onPressed: () =>
                              showConfigPopup(context, test, testsModel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomChip(label: test.testCategory),
                    const SizedBox(height: 12),
                    Text(
                      test.testDescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.gridText(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = [
          "All",
          ...model.getTestsList.map((e) => e.testCategory).toSet()
        ];

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
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: categories.map((category) {
                  bool isSelected = selectedCategory == category;
                  int itemCount = category == "All"
                      ? model.getTestsList.length
                      : model.getTestsList
                          .where((test) => test.testCategory == category)
                          .length;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyles.gridText(context).copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey[700],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.2)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                itemCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
