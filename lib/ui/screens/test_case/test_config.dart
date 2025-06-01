//core
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
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
    projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);
    inquiryResponseModel =
        Provider.of<InquiryResponseModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  // Ensure Expanded is directly inside Row
                  child: CustomContainer(
                    title: "Choose a test",
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: _searchController,
                            label: "Search...",
                            isEnabled: true,
                            onChanged: (value) =>
                                testsModel.filterData(value.trim()),
                          ),
                        ),
                        const Expanded(child: TestsListView()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: CustomContainer(
                    title: "Details / Configuration",
                    child: Selector<TestsModel, int>(
                      selector: (context, model) => model.getSelectedTestId,
                      builder: (context, selectedTestId, __) {
                        return ChatScreen(
                          drivingModel: testsModel,
                          isChatEnabled: selectedTestId > 0,
                        );
                      },
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
    await inquiryResponseModel.fetchResponsesByTest(context);
  }
}
