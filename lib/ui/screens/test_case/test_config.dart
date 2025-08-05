//core
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/screens/create_test/create_test.dart';
import 'package:foretale_application/ui/screens/test_case/test_service.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//listviews
//widgets
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/mixins/polling_mixin.dart';
//llms

class TestConfigPage extends StatefulWidget {
  const TestConfigPage({super.key});

  @override
  State<TestConfigPage> createState() => _TestConfigPageState();
}

class TestConfigPollingController extends ChangeNotifier with PollingMixin {}

class _TestConfigPageState extends State<TestConfigPage> {
  final String _currentFileName = "test_config.dart";
  bool _isPageLoading = false;
  String loadText = 'Loading...';


  final TextEditingController _searchController = TextEditingController();
  FilePickerResult? filePickerResult;

  late TestsModel testsModel;
  late UserDetailsModel userDetailsModel;
  late ProjectDetailsModel projectDetailsModel;
  late InquiryResponseModel inquiryResponseModel;
  bool _isCodeEditorMaximized = false;
  late TestConfigPollingController _pollingController;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    _pollingController = TestConfigPollingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {     
      if (mounted) {
        setState(() {
          _isPageLoading = true;
          loadText = "Loading test cases...";
        });
      }
      
      await _loadPage();
      
      if (mounted) {
        setState(() {
          _isPageLoading = false;
        });
        
        //check if there are any running tests
        _pollingController.setPollingInterval(const Duration(seconds: 30));
        _pollingController.startPolling(context, _fetchTestExecutionStatus);
        
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isPageLoading
        ? Center(
            child: LinearLoadingIndicator(
            isLoading: _isPageLoading,
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
                                  _showCreateTestDialog(context);
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
                              return TestService.showTestList(context);
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
                                  return TestService.showSqlQueryDialog(context, selectedTest, _toggleCodeEditorMaximized);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (!_isCodeEditorMaximized)
                            Expanded(
                              flex: 2,
                              child: CustomContainer(
                                title: "Details / Configuration",
                                child: Selector<TestsModel, int>(
                                  selector: (context, model) => model.getSelectedTestId,
                                  builder: (context, selectedTestId, __) {
                                    return TestService.showChatScreen(context, testsModel.getSelectedTest);
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

  void _toggleCodeEditorMaximized() {
    setState(() {
      _isCodeEditorMaximized = !_isCodeEditorMaximized;
    });
  }

  void _showCreateTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        content: const CreateTest(
          isNew: true,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyles.footerLinkTextSmall(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPage() async {
    try {
      //callMistral("what is your context length?");
      await testsModel.fetchTestsByProject(context);

      if (testsModel.getSelectedTestId > 0) {
        await _loadResponses();
      }

      //use exisitng polling mechanism to fetch test execution status
      

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

  Future<void> _fetchTestExecutionStatus(BuildContext context) async {
    print("fetchTestExecutionStatus");
    await testsModel.fetchTestExecutionStatus(context);
  }

  @override
  void dispose() {
    _pollingController.stopPolling();
    _pollingController.dispose();
    super.dispose();
  }
}
