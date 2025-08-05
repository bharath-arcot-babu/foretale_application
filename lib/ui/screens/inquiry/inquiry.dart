//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/chat/chat_screen.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry_questions_lv.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  bool isChatEnabled = false;
  late InquiryQuestionModel inquiryQuestionModel;
  late UserDetailsModel userDetailsModel;

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel =  Provider.of<InquiryQuestionModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    isChatEnabled = inquiryQuestionModel.getSelectedId(context) > 0;
    Widget padding = Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
        child: Row(children: [
          const Expanded(
              flex: 3,
              child: CustomContainer(
                  title: "Choose a question",
                  child: Column(children: [Expanded(child: QuestionsInquiryLv())]))),
          const SizedBox(width: 30),
          Expanded(
            flex: 4,
            child: CustomContainer(
              title: "Details / Configuration",
              child: Selector<InquiryQuestionModel, int>(
                selector: (context, model) => model.getSelectedId(context),
                builder: (context, selectedId, __) {
                  return ChatScreen(
                    key: ValueKey('inquiry_$selectedId'),
                    drivingModel: inquiryQuestionModel,
                    isChatEnabled: selectedId > 0,
                    userId: userDetailsModel.getUserMachineId ?? "",
                  );
                },
              ),
            ),
          ),
        ]));
    return padding;
  }
}
