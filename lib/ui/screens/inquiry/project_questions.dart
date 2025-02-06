//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions.dart';
//widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  bool isNew;

  QuestionsScreen({
      super.key,
      required this.isNew
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // Form key to manage validation state
  final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Assign the form key for validation
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionsDataGrid()
          ],
        ),
      ),
    );
  }

  Future<void>  _fetchQuestions(BuildContext context) async {
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
