//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions_inquiry.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  @override
  void initState() {
    _loadPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
        child: const Row(children: [
          Expanded(
              child: CustomContainer(
                  title: "Choose a question",
                  child: QuestionsInquiryGrid()))
        ]));
  }

  Future<void> _loadPage() async {
    await Provider.of<InquiryQuestionModel>(context, listen: false).fetchQuestionsByProject(context);
  }
}
