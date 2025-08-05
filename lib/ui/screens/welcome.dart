//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_resource_card.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/widgets/animation/custom_animator.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';

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
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomContainer(
                  title: "Choose a project",
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
        );
  }

  Widget _buildSearchBar(ProjectDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
    final isSelected = project.activeProjectId == Provider.of<ProjectDetailsModel>(context).getActiveProjectId;

    return Hero(
      tag: 'project-${project.activeProjectId}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onProjectSelection(context, project),
            child: FadeAnimator(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftSideOfCard(context, project, isSelected),
                    const SizedBox(width: 20),
                    _buildRightSideOfCard(context, project, isSelected),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSideOfCard(BuildContext context, ProjectDetails project, bool isSelected) {
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name
          Text(
            project.name,
            style: TextStyles.subjectText(context).copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          // Organization name
          Text(
            project.organization,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.gridText(context).copyWith(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Project metadata chips with modern styling
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              CustomChip(
                label: project.industry, 
                backgroundColor: Colors.grey.shade200, 
                textColor: Colors.grey.shade700,
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
              ),
              CustomChip(
                label: project.projectType, 
                backgroundColor: Colors.grey.shade200, 
                textColor: Colors.grey.shade700,
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
              ),
              CustomChip(
                label: "Started: ${project.createdDate.toString()}", 
                backgroundColor: Colors.grey.shade200, 
                textColor: Colors.grey.shade700,
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightSideOfCard(BuildContext context, ProjectDetails project, bool isSelected) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isSelected)
            CustomChip(
              label: "Active", 
              backgroundColor: AppColors.primaryColor, 
              textColor: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 1,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCreateProjectDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.folder_open_rounded,
                    size: 20,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Start a New Project",
                      style: TextStyles.subjectText(context).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Create",
                          style: TextStyles.gridText(context).copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Create a new R&A project",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.gridText(context).copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildResourcesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Learn More",
                    style: TextStyles.subjectText(context).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Explore our resources to get started",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.gridText(context).copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
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
      if (mounted) {
        setState(() => _isLoading = true);
      }
      await Provider.of<ProjectDetailsModel>(context, listen: false)
          .fetchProjectsByUserMachineId(context);
    } catch (e, error_stack_trace) {
      if (mounted) {
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
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
