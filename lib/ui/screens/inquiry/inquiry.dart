//core
import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry_chat_screen.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry_questions_lv.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget padding = Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
        child: Row(children: [
          const Expanded(
              flex: 3,
              child: CustomContainer(
                  title: "Choose a question",
                  child: Column(
                      children: [
                        Expanded(child: QuestionsInquiryLv())
                        ])
                      )),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            flex: 2, 
            child: InquiryChatScreen(callingFrom: 'inquiry')
            )
        ]));
    return padding;
  }
}
