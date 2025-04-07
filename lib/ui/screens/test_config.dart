//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//listviews
import 'package:foretale_application/ui/screens/listviews/test_config_lv.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
//llms
import 'package:foretale_application/core/services/llms/llm_api.dart';

class TestConfigPage extends StatefulWidget {
  const TestConfigPage({super.key});

  @override
  State<TestConfigPage> createState() => _TestConfigPageState();
}

class _TestConfigPageState extends State<TestConfigPage> {
  final String _currentFileName = "test_config.dart";
  final TextEditingController _searchController = TextEditingController();
  late TestsModel testsModel;
  late UserDetailsModel userDetailsModel;
  late ProjectDetailsModel projectDetailsModel;

  @override
  void initState() {
    super.initState();
    testsModel = Provider.of<TestsModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Row(
        children: [
          Expanded( // Ensure Expanded is directly inside Row
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
                      onChanged: (value) => testsModel.filterData(value.trim()),
                    ),
                  ),
                  const Expanded(child: TestsListView()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPage() async {
    try{
      callMistral("what is your context length?");

      await testsModel.fetchTestsByProject(context);

      if (testsModel.getSelectedTestId > 0) {
        //await _loadResponses();
      }
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_loadPage");
    }
  }
}
