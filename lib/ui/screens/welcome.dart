//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_resource_card.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final String _currentFileName = "welcome.dart";

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: LinearLoadingIndicator(
              isLoading: _isLoading,
              width: 200,
              height: 6,
              color: AppColors.primaryColor,
              loadingText: "Loading projects...",
            ),
          )
        : Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomContainer(
                    title: "Choose an existing project",
                    child: Consumer<ProjectDetailsModel>(
                      builder: (context, model, child) {
                        List<ProjectDetails> projects =
                            model.getFilteredProjectsList;

                        return Column(
                          children: [
                            _buildSearchBar(model),
                            Expanded(
                              child: projects.isEmpty
                                  ? _buildEmptyState()
                                  : CustomAnimatedSwitcher(
                                      child: ListView.builder(
                                        key: ValueKey<String>(_searchQuery),
                                        itemCount: projects.length,
                                        itemBuilder: (context, index) {
                                          ProjectDetails project =
                                              projects[index];
                                          return _buildProjectCard(
                                              context, project);
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.08),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNewProjectSection(),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildResourcesSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSearchBar(ProjectDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomTextField(
        controller: _searchController,
        label: "Search projects...",
        isEnabled: true,
        onChanged: (value) {
          setState(() => _searchQuery = value.trim());
          model.filterData(_searchQuery);
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectDetails project) {
    final isSelected = project.activeProjectId ==
        Provider.of<ProjectDetailsModel>(context).getActiveProjectId;

    return Hero(
      tag: 'project-${project.activeProjectId}',
      child: Material(
        type: MaterialType.transparency,
        child: FadeAnimator(
          child: ModernContainer(
            backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onProjectSelection(context, project),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyles.titleText(context),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      project.organization,
                      style: TextStyles.subtitleText(context),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(
                            Icons.business_outlined, project.industry),
                        _buildInfoChip(
                            Icons.category_outlined, project.projectType),
                        _buildInfoChip(
                          Icons.calendar_today_outlined,
                          "Started on: ${project.createdDate.toString()}",
                          iconSize: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
              child: Icon(Icons.folder_outlined,
                  size: 40, color: Colors.blue.shade500),
            ),
            const SizedBox(height: 20),
            Text(
              "No Projects Found",
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

  Widget _buildNewProjectSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: CustomElevatedButton(
        width: MediaQuery.of(context).size.width * 0.07,
        height: 60,
        text: "Start a new project",
        textSize: 14,
        onPressed: () => _showCreateProjectDialog(context),
      ),
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      children: [
        Text(
          "Learn More About This Tool:",
          style: TextStyles.titleText(context).copyWith(letterSpacing: 4.0),
        ),
        const SizedBox(height: 10),
        const ResourceCard(
          title: "Flutter Documentation",
          url: "https://flutter.dev/docs",
        ),
        const ResourceCard(
          title: "Flutter YouTube Channel",
          url: "https://www.youtube.com/c/FlutterDev",
        ),
        const ResourceCard(
          title: "Flutter Community",
          url: "https://flutter.dev/community",
        ),
      ],
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        content: const CreateProject(
          isNew: true,
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

  void _onProjectSelection(
      BuildContext context, ProjectDetails projectDetails) {
    try {
      Provider.of<ProjectDetailsModel>(context, listen: false)
          .updateProjectDetails(context, projectDetails);
    } catch (e) {
      SnackbarMessage.showErrorMessage(
        context,
        "Invalid project selection.",
        logError: true,
        errorMessage: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_onProjectSelection",
      );
    }
  }

  Future<void> _loadPage() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ProjectDetailsModel>(context, listen: false)
          .fetchProjectsByUserMachineId(context);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(
        context,
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: error_stack_trace.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_loadPage",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
