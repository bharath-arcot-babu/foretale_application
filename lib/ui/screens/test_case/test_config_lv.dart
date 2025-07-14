import 'package:flutter/material.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/test_case/test_card_widgets.dart';
import 'package:foretale_application/ui/screens/test_case/category_list_widget.dart';
import 'package:foretale_application/ui/screens/test_case/test_actions_service.dart';
import 'package:foretale_application/ui/screens/test_case/test_selection_service.dart';

class TestsListView extends StatefulWidget {
  const TestsListView({super.key});

  @override
  _TestsListViewState createState() => _TestsListViewState();
}

class _TestsListViewState extends State<TestsListView> {
  final String _currentFileName = "test_config_lv";
  late final TestsModel testsModel;
  String selectedCategory = "All";
  late InquiryResponseModel inquiryResponseModel;
  late UserDetailsModel userModel;
  late ProjectDetailsModel projectModel;
  late PollingController pollingController;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    pollingController = PollingController();
    inquiryResponseModel.responseList.clear();
  }

  @override
  void dispose() {
    pollingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ModernContainer(
          width: 220,
          child: CategoryListWidget.buildCategoryList(
            selectedCategory,
            (cat) => setState(() => selectedCategory = cat),
          ),
        ),
        Expanded(
          child: Consumer<TestsModel>(
            builder: (context, model, child) {
              final testsList = selectedCategory == "All" 
                                ? model.filteredTestsList 
                                : model.filteredTestsList.where((test) => test.testCategory == selectedCategory).toList();

              return testsList.isEmpty
                  ? TestCardWidgets.buildNoTestsFound(context)
                  : CustomAnimatedSwitcher(
                      child: ListView.builder(
                        key: ValueKey<String>(selectedCategory),
                        itemCount: testsList.length,
                        itemBuilder: (context, index) {
                          final test = testsList[index];
                          return TestCardWidgets.buildTestCard(
                            context,
                            testsModel,
                            test,
                            _onTestTap,
                            _onTestSelection,
                            pollingController: pollingController,
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onTestTap(Test test) async {
    // Use Future.microtask to ensure this runs after the current build phase
    Future.microtask(() async {
      await inquiryResponseModel.setIsPageLoading(true);
      await testsModel.updateTestIdSelection(test.testId);
      await inquiryResponseModel.fetchResponsesByReference(context, test.testId, 'test');
      await inquiryResponseModel.setIsPageLoading(false);
    });
  }

  Future<void> _onTestSelection(Test test) async {
    await TestSelectionService.handleTestSelection(context, test);
    setState(() {}); // refresh UI if needed
  }
}
