import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/create_project/project_questions.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
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
import 'package:foretale_application/core/utils/message_helper.dart';

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
  String _searchQuery = '';
  // Track loading state for each button using a map
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InquiryQuestionModel>(
      builder: (context, model, child) {
        final questions = model.getFilteredQuestionsList;

        return Column(
          children: [
            _buildStatusMetrics(model),
            _buildSearchAndAddBar(model),
            Expanded(
              child: questions.isEmpty
                  ? _buildEmptyState()
                  : CustomAnimatedSwitcher(
                      child: ListView.builder(
                        key: ValueKey<String>(_searchQuery),
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) => _buildQuestionCard(
                            context, model, questions[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusMetrics(InquiryQuestionModel model) {
    final allQuestions = model.getFilteredQuestionsList;
    final openCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'open')
        .length;
    final closeCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'close')
        .length;
    final deferCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'defer')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusMetric(context, "Open", openCount, Colors.green),
          _buildStatusMetric(context, "Closed", closeCount, Colors.red),
          _buildStatusMetric(context, "Deferred", deferCount, Colors.orange),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              icon: Icons.add,
              tooltip: "Create a new question",
              iconSize: 15,
              onPressed: () => _showAddQuestionDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndAddBar(InquiryQuestionModel model) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
              controller: _searchController,
              label: "Search...",
              isEnabled: true,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
                model.filterData(_searchQuery);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, InquiryQuestionModel model, dynamic question) {
    final isSelected =
        question.questionId == model.getSelectedInquiryQuestionId;

    return Hero(
      tag: 'question-${question.questionId}',
      child: Material(
        type: MaterialType.transparency,
        child: FadeAnimator(
          child: ModernContainer(
            margin: const EdgeInsets.only(bottom: 12),
            backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: 12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                model.updateQuestionIdSelection(question.questionId);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                            Icons.work_outline_rounded, question.topic),
                        const Spacer(),
                        _buildInfoChip(
                            Icons.calendar_today_outlined, question.createdDate,
                            iconSize: 12),
                      ],
                    ),
                    if (isSelected) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, thickness: 1),
                      ),
                      _buildActionButtons(context, model, question),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, InquiryQuestionModel model, dynamic question) {
    return Row(
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
          Theme.of(context).colorScheme.primary,
          "View conversation",
          model,
          question.questionId,
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {double iconSize = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyles.gridText(context).copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatusMetric(
      BuildContext context, String label, int count, Color color) {
    return ModernContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 8),
          Text(
            "$label: $count",
            style: TextStyles.gridText(context).copyWith(color: color),
          ),
        ],
      ),
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
              style: TextStyles.subjectText(context).copyWith(
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
            // Use Future.microtask to ensure this runs after the current build phase
            Future.microtask(() async {
              await inquiryResponseModel.setIsPageLoading(true);
              await inquiryResponseModel.fetchResponsesByReference(context, questionId, 'question');
              await inquiryResponseModel.setIsPageLoading(false);
            });
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
    // Create a unique key for this button's loading state
    final loadingKey = '${question.questionId}_$statusValue';
    final isLoading = _loadingStates[loadingKey] ?? false;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isLoading
            ? null
            : () async {
                try {
                  setState(() {
                    _loadingStates[loadingKey] = true;
                  });

                  int resultId = await inquiryQuestionModel
                      .updateQuestionStatus(context, question, statusValue);

                  if (resultId > 0) {
                    setState(() {
                      _loadingStates[loadingKey] = false;
                    });
                  }
                } catch (e) {
                  setState(() {
                    _loadingStates[loadingKey] = false;
                  });
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
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: const QuestionsScreen(isNew: true),
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
    await inquiryResponseModel.fetchResponsesByReference(context, inquiryQuestionModel.getSelectedInquiryQuestionId, 'question');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
