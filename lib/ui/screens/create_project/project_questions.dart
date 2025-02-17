//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_future_dropdown.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
//widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  bool isNew;

  QuestionsScreen({super.key, required this.isNew});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // Form key to manage validation state
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _industryTextController = TextEditingController();
  final TextEditingController _projectTypeTextController =
      TextEditingController();
  final TextEditingController _questionTextController = TextEditingController();
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    ProjectDetailsModel projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    _industryTextController.text = projectDetailsModel.getIndustry;
    _projectTypeTextController.text = projectDetailsModel.getProjectType;

    return Form(
      key: _formKey, // Assign the form key for validation
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              title: "Add a new question",
            child:Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        flex: 2,
                        child: CustomTextField(
                      isEnabled: false,
                      controller: _industryTextController,
                      label: 'Industry',
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: CustomTextField(
                      isEnabled: false,
                      controller: _projectTypeTextController,
                      label: 'Project Type',
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: FutureDropdownSearch(
                      fetchData: _fetchTopics,
                      isEnabled: widget.isNew,
                      hintText: '',
                      labelText: "Topic",
                      selectedItem: _selectedTopic,
                      onChanged: (String? selectedItem) {
                        _selectedTopic = selectedItem;
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 5,
                        child: CustomTextField(
                      isEnabled: true,
                      controller: _questionTextController,
                      label: 'Type your question.',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Question is required';
                        }
                        return null;
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: CustomElevatedButton(
                        width: double.infinity, // Adjusted width to fit the text
                        height: 40,
                        text: '+',
                        textSize: 14,
                        onPressed: () {
                          _saveQuestion(context);
                        },
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),    
            const QuestionsDataGrid()
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuestion(BuildContext context) async {
    var questionModel = Provider.of<QuestionsModel>(context, listen: false);

    // Validate form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      try {
        int resultId = await questionModel.addNewQuestionByProjectId(
          context, 
          _questionTextController.text.trim(), 
          _selectedTopic!);

        if (resultId > 0) {
          await _fetchQuestions(context);

          setState(() {
            _questionTextController.text = '';
          });

          SnackbarMessage.showSuccessMessage(context,
              'Question has been saved successfully.');
        }
      } catch (e) {
        SnackbarMessage.showErrorMessage(context, e.toString());
      }
    } else {
      SnackbarMessage.showErrorMessage(
          context, 'Fill in all required fields.');
    }
  }

  Future<List<String>> _fetchTopics() async {

    List<Topic> lkpList = await TopicList().fetchAllActiveTopics(context);
    return lkpList.map((obj) => obj.name).toList();
  }

  Future<void> _fetchQuestions(BuildContext context) async {
    await Provider.of<QuestionsModel>(context, listen: false).fetchQuestionsByProject(context);
  }

  Future<void> _loadPage() async {
    try {
      await _fetchQuestions(context);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context,
          'Something went wrong! Please contact support for assistance.');
    }
  }
}
