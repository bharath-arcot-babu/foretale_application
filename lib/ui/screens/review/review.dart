//core
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//listviews
import 'package:foretale_application/ui/screens/review/review_test_list_lv.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
//llms

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final String _currentFileName = "review.dart";
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
        : Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
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
                                  onChanged: (value) =>
                                      testsModel.filterData(value.trim()),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    testsModel.filterData('');
                                  },
                                  tooltip: 'Clear search',
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
