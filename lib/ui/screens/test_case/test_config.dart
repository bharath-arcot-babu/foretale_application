//core
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/screens/test_case/test_actions_service.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//listviews
import 'package:foretale_application/ui/screens/test_case/test_config_lv.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
//llms

class TestConfigPage extends StatefulWidget {
  const TestConfigPage({super.key});

  @override
  State<TestConfigPage> createState() => _TestConfigPageState();
}

class _TestConfigPageState extends State<TestConfigPage> {
  final String _currentFileName = "test_config.dart";
  bool isPageLoading = false;
  String loadText = 'Loading...';

  final TextEditingController _searchController = TextEditingController();
  FilePickerResult? filePickerResult;

  late TestsModel testsModel;
  late UserDetailsModel userDetailsModel;
  late ProjectDetailsModel projectDetailsModel;
  late InquiryResponseModel inquiryResponseModel;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Set loading state after the first frame is built
      await inquiryResponseModel.setIsPageLoading(false);
      
      setState(() {
        isPageLoading = true;
        loadText = "Loading test cases...";
      });
      await _loadPage();
      setState(() {
        isPageLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isPageLoading
        ? Center(
            child: LinearLoadingIndicator(
            isLoading: isPageLoading,
            width: 200,
            height: 6,
            color: AppColors.primaryColor,
            loadingText: loadText,
          ))
        : Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomContainer(
                    title: "Choose a test",
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _searchController,
                                  label: "Search tests...",
                                  isEnabled: true,
                                  onChanged: (value) async =>
                                      await testsModel.filterData(value.trim()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              CustomIconButton(
                                icon: Icons.clear,
                                onPressed: () {
                                  _searchController.clear();
                                  testsModel.filterData('');
                                },
                                tooltip: 'Clear search',
                              ),
                              const SizedBox(width: 16),
                              CustomIconButton(
                                icon: Icons.add,
                                onPressed: () {
                                  _searchController.clear();
                                  testsModel.filterData('');
                                },
                                tooltip: 'Add a new test',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Selector<TestsModel, List<dynamic>>(
                            selector: (context, model) => model.getFilteredTestList,
                            builder: (context, filteredTests, __) {
                              if (filteredTests.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 48,
                                        color: AppColors.primaryColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isEmpty
                                            ? 'No tests available'
                                            : 'No tests found matching "${_searchController.text}"',
                                        style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const TestsListView();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Selector<TestsModel, int>(
                  selector: (context, model) => model.getSelectedTestId,
                  builder: (context, selectedTestId, __) {
                    return selectedTestId > 0 
                    ? Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Selector<TestsModel, Test>(
                                selector: (context, model) => model.getSelectedTest,
                                builder: (context, selectedTest, __) {
                                  return TestActionsService.showSqlQueryDialog(context, selectedTest);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              flex: 2,
                              child: CustomContainer(
                                title: "Details / Configuration",
                                child: Selector<TestsModel, int>(
                                  selector: (context, model) => model.getSelectedTestId,
                                  builder: (context, selectedTestId, __) {
                                    return ChatScreen(
                                      key: ValueKey('test_config_$selectedTestId'),
                                      drivingModel: testsModel,
                                      isChatEnabled: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : const SizedBox.shrink();
                  },
                ),
                
              ],
            );
  }

  Future<void> _loadPage() async {
    try {
      //callMistral("what is your context length?");
      await testsModel.fetchTestsByProject(context);

      if (testsModel.getSelectedTestId > 0) {
        await _loadResponses();
      }
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    }
  }

  Future<void> _loadResponses() async {
    await inquiryResponseModel.fetchResponsesByReference(context, testsModel.getSelectedTestId, 'test');
  }
}
