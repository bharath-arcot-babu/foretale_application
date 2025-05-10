//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/industry_list_model.dart';
import 'package:foretale_application/models/organization_list_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/project_type_list_model.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/custom_future_dropdown.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:foretale_application/ui/widgets/custom_grid_menu.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class ProjectDetailsScreen extends StatefulWidget {
  bool isNew;

  ProjectDetailsScreen({super.key, required this.isNew});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final String _currentFileName = "project_details.dart";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  String? _selectedProjectType;
  String? _selectedOrganization;
  String? _selectedIndustry;

  late UserDetailsModel _userDetailsModel;
  late ProjectDetailsModel _projectDetailsModel;

  List<String> _projectTypes = [];
  List<String> _organizations = [];
  List<String> _industries = [];

  bool _isLoadingProjectTypes = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    _projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });

      try {
        await _loadInitialData();
        if (!widget.isNew) {
          await _loadPage();
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchOrganizations(),
      _fetchIndustries(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: LinearLoadingIndicator(
              isLoading: true,
              loadingText: 'Loading project details...',
              width: 200,
              height: 6,
              color: AppColors.primaryColor,
            ),
          )
        : SingleChildScrollView(
            child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        width: 120,
                        height: 40,
                        text: 'Save',
                        textSize: 14,
                        onPressed: () {
                          _saveProjectDetails(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // First Section - Project Classification
                  CustomContainer(
                    title: 'Project Classification',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Organization and Industry)
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDropdownSearch(
                                    items: _organizations,
                                    isEnabled: widget.isNew,
                                    hintText: 'Choose Organization',
                                    title: "Organization",
                                    selectedItem: _selectedOrganization,
                                    onChanged: (String? selectedItem) {
                                      setState(() {
                                        _selectedOrganization = selectedItem;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  CustomDropdownSearch(
                                    items: _industries,
                                    isEnabled: widget.isNew,
                                    hintText: 'Choose Industry',
                                    title: "Industry",
                                    selectedItem: _selectedIndustry,
                                    onChanged: (String? selectedItem) {
                                      setState(() {
                                        _selectedIndustry = selectedItem;
                                        _fetchProjectTypes(selectedItem ?? '');
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Column (Project Type)
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomContainer(
                                    title: 'Project Type',
                                    child: _isLoadingProjectTypes
                                        ? const Center(
                                            child: LinearLoadingIndicator(
                                              isLoading: true,
                                              width: 200,
                                              height: 6,
                                              color: AppColors.primaryColor,
                                            ),
                                          )
                                        : _projectTypes.isEmpty
                                            ? Center(
                                                child: Text(
                                                  _selectedIndustry == null
                                                      ? "Select an industry to view project types"
                                                      : "No project types available for selected industry",
                                                  style: TextStyles
                                                          .inputHintTextStyle(
                                                              context)
                                                      .copyWith(
                                                    color: Colors.black54,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              )
                                            : LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  return SingleChildScrollView(
                                                    child: CustomGridMenu(
                                                      isEnabled: widget.isNew,
                                                      items: _projectTypes,
                                                      labelText: "Project Type",
                                                      selectedItem:
                                                          _selectedProjectType,
                                                      onItemSelected: (String
                                                          selectedItem) {
                                                        setState(() {
                                                          _selectedProjectType =
                                                              selectedItem;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Second Section - Project Information
                  CustomContainer(
                    title: 'Project Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        CustomTextField(
                          isEnabled: widget.isNew,
                          controller: _projectNameController,
                          label: 'Project Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Project name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          isEnabled: true,
                          controller: _projectDescriptionController,
                          label: 'Project Description',
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Project description is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
  }

  Future<void> _fetchOrganizations() async {
    if (_organizations.isEmpty) {
      List<Organization> lkpList =
          await OrganizationList().fetchAllActiveOrganizations(context);
      setState(() {
        _organizations = lkpList.map((obj) => obj.name).toList();
      });
    }
  }

  Future<void> _fetchIndustries() async {
    if (_industries.isEmpty) {
      List<Industry> lkpList =
          await IndustryList().fetchAllActiveIndustries(context);
      setState(() {
        _industries = lkpList.map((obj) => obj.name).toList();
      });
    }
  }

  Future<void> _fetchProjectTypes(String selectedIndustry) async {
    if (selectedIndustry.isEmpty) {
      setState(() {
        _projectTypes = [];
        _selectedProjectType = null;
      });
      return;
    }

    if (!_isLoadingProjectTypes) {
      setState(() {
        _isLoadingProjectTypes = true;
      });

      try {
        List<ProjectType> lkpList = await ProjectTypeList()
            .fetchAllActiveProjectTypes(context, selectedIndustry);
        setState(() {
          _projectTypes = lkpList.map((obj) => obj.name).toList();
          _selectedProjectType = null;
        });
      } finally {
        setState(() {
          _isLoadingProjectTypes = false;
        });
      }
    }
  }

  Future<void> _fetchProjectDetails(BuildContext context) async {
    await _fetchProjectTypes(_projectDetailsModel.getIndustry);

    await _projectDetailsModel.fetchProjectsByUserMachineId(context);

    if (mounted) {
      setState(() {
        _selectedOrganization = _projectDetailsModel.getOrganization;
        _selectedIndustry = _projectDetailsModel.getIndustry;
        _selectedProjectType = _projectDetailsModel.getProjectType;
      });
    }

    _projectNameController.text = _projectDetailsModel.getName;
    _projectDescriptionController.text = _projectDetailsModel.getDescription;
  }

  Future<void> _saveProjectDetails(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _projectDetailsModel.projectDetails = ProjectDetails(
            name: _projectNameController.text.trim(),
            description: _projectDescriptionController.text.trim(),
            organization: _selectedOrganization!.trim(),
            recordStatus: 'A',
            createdBy: _userDetailsModel.getUserMachineId!,
            activeProjectId:
                widget.isNew ? 0 : _projectDetailsModel.getActiveProjectId,
            projectType: _selectedProjectType!,
            createdByName: _userDetailsModel.getName!,
            createdByEmail: _userDetailsModel.getEmail!,
            industry: _selectedIndustry!);

        int resultId = await _projectDetailsModel.saveProjectDetails(context);

        if (resultId > 0) {
          await _projectDetailsModel.fetchProjectsByUserMachineId(context);

          setState(() {
            widget.isNew = false;
          });

          SnackbarMessage.showSuccessMessage(context,
              'Project "${_projectNameController.text.trim()}" has been saved successfully.');
        }
      } catch (e, error_stack_trace) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveProjectDetails");
      }
    }
  }

  Future<void> _loadPage() async {
    try {
      await _fetchProjectDetails(context);
    } catch (e, error_stack_trace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_saveProjectDetails");
    }
  }
}
