import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_questions.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_future.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  final bool isNew;

  const QuestionsScreen({super.key, required this.isNew});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _industryTextController = TextEditingController();
  final TextEditingController _projectTypeTextController =
      TextEditingController();
  final TextEditingController _questionTextController = TextEditingController();
  String? _selectedTopic;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await _loadPage());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _industryTextController.dispose();
    _projectTypeTextController.dispose();
    _questionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    _industryTextController.text = projectDetailsModel.getIndustry;
    _projectTypeTextController.text = projectDetailsModel.getProjectType;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Info Card
                    _buildProjectInfoCard(theme),
                    const SizedBox(height: 24),
                    // New Question Card
                    _buildNewQuestionCard(theme),
                    const SizedBox(height: 32),
                    // Questions Grid Header
                    _buildSectionHeader(theme, "Project Questions"),
                    const SizedBox(height: 16),
                    // Questions Grid
                    const QuestionsDataGrid(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest, width: 1),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Industry',
                    controller: _industryTextController,
                    enabled: false,
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'Project Type',
                    controller: _projectTypeTextController,
                    enabled: false,
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewQuestionCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add a New Question',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                _buildTopicDropdown(theme),
              ],
            ),
            const SizedBox(height: 20),
            _buildQuestionInputAndButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: theme.colorScheme.primary.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
  }) {
    return CustomTextField(
      isEnabled: enabled,
      controller: controller,
      label: label,
    );
  }

  Widget _buildTopicDropdown(ThemeData theme) {
    return SizedBox(
      width: 250,
      child: FutureDropdownSearch(
        fetchData: _fetchTopics,
        isEnabled: widget.isNew,
        hintText: 'Select a topic',
        labelText: 'Topic',
        selectedItem: _selectedTopic,
        onChanged: (String? selectedItem) {
          setState(() {
            _selectedTopic = selectedItem;
          });
        },
      ),
    );
  }

  Widget _buildQuestionInputAndButton(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: CustomTextField(
            isEnabled: true,
            controller: _questionTextController,
            label: 'Type your question',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Question is required';
              } else if (value.length < 10) {
                return 'Question should be at least 10 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        _buildAddButton(theme),
      ],
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          width: 56,
          child: CustomElevatedButton(
            width: 56,
            height: 56,
            text: '',
            icon: Icons.add,
            textSize: 18,
            onPressed: () => _saveQuestion(context),
          ),
        ),
      ],
    );
  }

  Future<void> _saveQuestion(BuildContext context) async {
    if (_selectedTopic == null) {
      SnackbarMessage.showErrorMessage(context, 'Please select a topic first.');
      return;
    }

    var questionModel = Provider.of<QuestionsModel>(context, listen: false);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Show loading indicator
        setState(() => _isLoading = true);

        int resultId = await questionModel.addNewQuestionByProjectId(
          context,
          _questionTextController.text.trim(),
          _selectedTopic!,
        );

        if (resultId > 0) {
          await _fetchQuestions(context);

          setState(() {
            _questionTextController.text = '';
            _isLoading = false;
          });

          SnackbarMessage.showSuccessMessage(
              context, 'Question saved successfully! 🎉');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        SnackbarMessage.showErrorMessage(context, e.toString());
      }
    } else {
      SnackbarMessage.showErrorMessage(
          context, 'Please fill in all required fields correctly.');
    }
  }

  Future<List<String>> _fetchTopics() async {
    try {
      List<Topic> lkpList = await TopicList().fetchAllActiveTopics(context);
      return lkpList.map((obj) => obj.name).toList();
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 'Failed to load topics: $e');
      return []; // Return empty list to handle no topics available scenario.
    }
  }

  Future<void> _fetchQuestions(BuildContext context) async {
    await Provider.of<QuestionsModel>(context, listen: false)
        .fetchQuestionsByProject(context);
  }

  Future<void> _loadPage() async {
    try {
      await _fetchQuestions(context);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      SnackbarMessage.showErrorMessage(
        context,
        'Something went wrong! Please contact support for assistance.',
      );
    }
  }
}
