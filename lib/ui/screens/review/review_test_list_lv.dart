import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_completion_button.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_selectable_list.dart';
import 'package:foretale_application/ui/widgets/custom_show_status_text.dart'; 
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/utils/message_helper.dart';



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
  late UserDetailsModel userModel;
  late ProjectDetailsModel projectModel;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
  }

  @override
  void dispose() {
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
                  // Use Future.microtask to ensure this runs after the current build phase
                  Future.microtask(() async {
                    await testsModel.updateTestIdSelection(test.testId);
                  });
                },
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
                        _buildLeftSideOfCard(context, test),
                        const SizedBox(width: 16),
                        _buildRightSideOfCard(context, test),
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

  Widget _buildLeftSideOfCard(BuildContext context, Test test) {
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with checkbox and test name
          Row(
            children: [
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

  Widget _buildRightSideOfCard(BuildContext context, Test test) {
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

  Widget _buildShowResultsWidget(BuildContext context, Test test) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Results button
        CustomIconButton(
          icon: Icons.flag,
          onPressed: () => showFlaggedTransactionsDialog(context, test),
          tooltip: 'Show flagged transactions',
          isProcessing: false,
          iconSize: 18.0,
        ),
        const SizedBox(height: 8),
        // Status indicator
        if (test.testConfigExecutionStatus == "Completed")
          StatusBadge(
            text: "Results",
          )
        else
          StatusBadge(
            text: "Pending",
          ),
        const SizedBox(height: 8),
        Selector<TestsModel, bool>(
          selector: (context, model) => model.testsList.firstWhere((t) => t.testId == test.testId).markAsCompleted,
          builder: (context, markAsCompleted, child) {
            return CustomCompletionButton(
              isCompleted: markAsCompleted,
              onToggle: () async {
                testsModel.updatedTestCompletionOffline(test, !test.markAsCompleted);
                await testsModel.updateTestCompletion(
                  context, 
                  test, 
                  !test.markAsCompleted
                );
              },
              tooltip: 'Mark review as completed',
              isProcessing: false,
              iconSize: 18.0,
            );
          },
        ),
      ],
    );
  }

  Future<void> showFlaggedTransactionsDialog(BuildContext context, Test test) async {
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
