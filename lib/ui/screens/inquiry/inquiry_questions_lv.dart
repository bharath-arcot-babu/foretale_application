import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/create_project/project_questions.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
// Themes
import 'package:foretale_application/ui/themes/text_styles.dart';
// Utils
// Models
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
// Widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';

class QuestionsInquiryLv extends StatefulWidget {
  const QuestionsInquiryLv({super.key});

  @override
  State<QuestionsInquiryLv> createState() => _QuestionsInquiryLvState();
}

class _QuestionsInquiryLvState extends State<QuestionsInquiryLv> {
  final String _currentFileName = "inquiry_questions_lv.dart";
  late InquiryQuestionModel inquiryQuestionModel;
  late InquiryResponseModel inquiryResponseModel;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel =
        Provider.of<InquiryQuestionModel>(context, listen: false);
    inquiryResponseModel =
        Provider.of<InquiryResponseModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<InquiryQuestionModel>(
      builder: (context, model, child) {
        final allQuestions = model.getFilteredQuestionsList;
        final questions = allQuestions
            .where((q) => q.questionText.toLowerCase().contains(_searchQuery))
            .toList();

        if (questions.isEmpty) return _buildEmptyState();

        final openCount = allQuestions
            .where((q) => q.questionStatus.toLowerCase() == 'open')
            .length;
        final closeCount = allQuestions
            .where((q) => q.questionStatus.toLowerCase() == 'close')
            .length;
        final deferCount = allQuestions
            .where((q) => q.questionStatus.toLowerCase() == 'defer')
            .length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusMetric(context, "Open", openCount, Colors.green),
                  _buildStatusMetric(context, "Close", closeCount, Colors.red),
                  _buildStatusMetric(
                      context, "Defer", deferCount, Colors.orange),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      controller: _searchController,
                      label: "Search...",
                      isEnabled: true,
                      onChanged: (value) {
                        model.filterData(value.trim());
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomIconButton(
                    icon: Icons.add,
                    iconSize: 15,
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  padding: const EdgeInsets.all(16.0),
                                  child: QuestionsScreen(isNew: true),),
                          actionsAlignment: MainAxisAlignment.end,
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Close",
                                style: TextStyles.footerLinkTextSmall(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final isSelected =
                      question.questionId == model.getSelectedInquiryQuestionId;

                  return FadeAnimator(
                    child: Material(
                      color:
                          isSelected ? Colors.blue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          model.updateQuestionIdSelection(question
                              .questionId); // Only select, don't load responses
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      question.questionText,
                                      style: TextStyles.titleText(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _iconText(Icons.work_outline_rounded,
                                      question.topic,
                                      maxLines: 2),
                                  const Spacer(),
                                  _iconText(Icons.calendar_today_outlined,
                                      question.createdDate,
                                      iconSize: 12),
                                ],
                              ),
                              if (isSelected) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(height: 1, thickness: 1),
                                ),
                                Row(
                                  children: [
                                    _buildStatusIconButton(
                                      context,
                                      icon: Icons.lock_open_rounded,
                                      tooltip: "Mark as Open",
                                      color: Colors.green,
                                      statusValue: 'Open',
                                      question: question,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusIconButton(
                                      context,
                                      icon: Icons.check_circle_outline_rounded,
                                      tooltip: "Mark as Close",
                                      color: Colors.red,
                                      statusValue: 'Close',
                                      question: question,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusIconButton(
                                      context,
                                      icon: Icons.access_time_rounded,
                                      tooltip: "Mark as Defer",
                                      color: Colors.orange,
                                      statusValue: 'Defer',
                                      question: question,
                                    ),
                                    const Spacer(),
                                    _buildIconButton(
                                      Icons.question_answer_outlined,
                                      theme.colorScheme.primary,
                                      "View conversation",
                                      model,
                                      question.questionId,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconText(IconData icon, String text,
      {double iconSize = 14, int? maxLines}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: Colors.grey),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyles.smallSupplementalInfo(context),
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.question_answer_outlined,
                  size: 40, color: Colors.blue.shade500),
            ),
            const SizedBox(height: 20),
            Text(
              "No Questions Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, Color color, String tooltip, var model, int questionId) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconButton(
          icon: icon,
          iconSize: 15,
          onPressed: () async {
            await inquiryResponseModel
                .fetchResponsesByQuestion(context); // only here
          },
        ),
      ),
    );
  }

  Widget _buildStatusIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color color,
    required String statusValue,
    required dynamic question,
  }) {
    final isSelected =
        question.questionStatus.toLowerCase() == statusValue.toLowerCase();

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          try {
            int resultId = await inquiryQuestionModel.updateQuestionStatus(
                context, question, statusValue);
            if (resultId > 0) setState(() {});
          } catch (e) {
            SnackbarMessage.showErrorMessage(context, e.toString());
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
            border: isSelected ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _buildStatusMetric(
      BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _loadPage() async {
    try {
      await inquiryQuestionModel.fetchQuestionsByProject(context);

      if (inquiryQuestionModel.getSelectedInquiryQuestionId > 0) {
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
    await inquiryResponseModel.fetchResponsesByQuestion(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
