import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/test_case/test_card_widgets.dart';

import 'package:foretale_application/ui/screens/test_case/test_service.dart';

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

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    userModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    inquiryResponseModel.responseList.clear();
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
          child: TestCardWidgets.buildCategoryList(
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
    try{
      await inquiryResponseModel.setIsPageLoading(true);
      await testsModel.updateTestIdSelection(test.testId);
      await inquiryResponseModel.fetchResponsesByReference(context, test.testId, 'test');
      await inquiryResponseModel.setIsPageLoading(false);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onTestTap");
    }
  }

  Future<void> _onTestSelection(Test test) async {
    try{
      await TestService.handleTestSelection(context, test);
      setState(() {}); // refresh UI if needed
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_onTestSelection");
    }
  }
}
