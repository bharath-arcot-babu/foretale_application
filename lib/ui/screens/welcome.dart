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
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomContainer(
                      title: "Your Projects",
                      child: Consumer<ProjectDetailsModel>(
                        builder: (context, model, child) {
                          List<ProjectDetails> projects = model.getFilteredProjectsList;
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
                                            ProjectDetails project = projects[index];
                                            return _buildProjectCard(context, project);
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildNewProjectSection(),
                        const SizedBox(height: 20),
                        _buildResourcesSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildSearchBar(ProjectDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomTextField(
        controller: _searchController,
        label: "Search...",
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
            //backgroundColor: isSelected ? AppColors.primaryColor.withOpacity(0.4) : Colors.white,
            elevation: isSelected ? 2 : 1,
            borderRadius: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onProjectSelection(context, project),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: TextStyles.titleText(context).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      project.organization,
                      style: TextStyles.subtitleText(context).copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          Icons.business_outlined,
                          project.industry,
                          isSelected: isSelected,
                        ),
                        _buildInfoChip(
                          Icons.category_outlined,
                          project.projectType,
                          isSelected: isSelected,
                        ),
                        _buildInfoChip(
                          Icons.calendar_today_outlined,
                          "Started: ${project.createdDate.toString()}",
                          iconSize: 12,
                          isSelected: isSelected,
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

  Widget _buildInfoChip(IconData icon, String text, {double iconSize = 14, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withOpacity(0.3) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isSelected ? AppColors.primaryColor.withOpacity(0.3) : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyles.gridText(context).copyWith(
              color: isSelected ? Colors.black : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_outlined,
                  size: 48, color: Colors.blue.shade600),
            ),
            const SizedBox(height: 24),
            Text(
              "No Projects Found",
              style: TextStyles.subjectText(context).copyWith(
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start by creating a new project",
              style: TextStyles.subtitleText(context).copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProjectSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Start a New Project",
            style: TextStyles.titleText(context).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create a new forensic analytics project",
            textAlign: TextAlign.center,
            style: TextStyles.subtitleText(context).copyWith(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          CustomElevatedButton(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 48,
            text: "Create New Project",
            textSize: 14,
            onPressed: () => _showCreateProjectDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Learn More",
            style: TextStyles.titleText(context).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Explore our resources to get started",
            textAlign: TextAlign.center,
            style: TextStyles.subtitleText(context).copyWith(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          const ResourceCard(
            title: "Documentation",
            url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
          ),
          const SizedBox(height: 12),
          const ResourceCard(
            title: "Tutorials",
            url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
          ),
          const SizedBox(height: 12),
          const ResourceCard(
            title: "Support",
            url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
          ),
        ],
      ),
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
