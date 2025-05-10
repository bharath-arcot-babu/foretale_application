import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart';
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
  late InquiryResponseModel inquiryResponseModel;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    inquiryResponseModel =
        Provider.of<InquiryResponseModel>(context, listen: false);

    inquiryResponseModel.responseList.clear();
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

  Widget _buildTestCard(
      BuildContext context, TestsModel testsModel, Test test) {
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
                  margin: const EdgeInsets.only(bottom: 12),
                  backgroundColor:
                      isSelected ? Colors.blue.shade50 : Colors.white,
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
                              onTap: () async {
                                int resultId;
                                try {
                                  testsModel.updateTestIdSelection(test.testId);

                                  if (test.isSelected) {
                                    final confirmed = await showConfirmDialog(
                                      context: context,
                                      title: 'Remove Test',
                                      content:
                                          'Are you sure you want to remove this test? This action will reset the test configurations.',
                                      cancelText: 'Cancel',
                                      confirmText: 'Remove',
                                      confirmTextColor: AppColors.primaryColor,
                                    );

                                    resultId = confirmed
                                        ? await testsModel.removeTest(
                                            context, test)
                                        : -1;
                                  } else {
                                    resultId = await testsModel.selectTest(
                                        context, test);
                                  }

                                  if (resultId > 0) {
                                    setState(() {}); // refresh UI if needed
                                  }
                                } catch (e) {
                                  SnackbarMessage.showErrorMessage(
                                      context, e.toString());
                                }
                              },
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
              );
            },
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
                child: SelectableAnimatedList<String>(
              items: categories,
              selectedItem: selectedCategory,
              getLabel: (cat) => cat,
              getCount: (cat) => cat == 'All'
                  ? model.getTestsList.length
                  : model.getTestsList
                      .where((t) => t.testCategory == cat)
                      .length,
              onItemSelected: (cat) => setState(() => selectedCategory = cat),
              selectedColor: AppColors.primaryColor,
            )),
          ],
        );
      },
    );
  }
}
