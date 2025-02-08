//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/industry_list_model.dart';
import 'package:foretale_application/models/organization_list_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/project_type_list_model.dart';
import 'package:foretale_application/ui/widgets/custom_future_dropdown.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class ProjectDetailsScreen extends StatefulWidget {
  bool isNew;

  ProjectDetailsScreen({
      super.key,
      required this.isNew
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // Form key to manage validation state
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController(); 
  String? _selectedProjectType;
  String? _selectedOrganization;
  String? _selectedIndustry;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isNew) {
          _loadPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Assign the form key for validation
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Save Button - Positioned at the top-right corner
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  width: 40, // Adjusted width to fit the text
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name and Company Name Fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
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
                    ),
                    const SizedBox(
                        width: 15),
                        
                    Expanded(
                        child: FutureDropdownSearch(
                      fetchData: _fetchOrganizations,
                      isEnabled: widget.isNew,
                      hintText: '',
                      labelText: "Organization",
                      selectedItem: _selectedOrganization,
                      onChanged: (String? selectedItem) {
                        _selectedOrganization = selectedItem;

                      },
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: FutureDropdownSearch(
                      fetchData: _fetchIndustries,
                      isEnabled: widget.isNew,
                      hintText: '',
                      labelText: "Industry",
                      selectedItem: _selectedIndustry,
                      onChanged: (String? selectedItem) {
                        _selectedIndustry = selectedItem;
                      },
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: FutureDropdownSearch(
                      fetchData: _fetchProjectTypes,
                      isEnabled: widget.isNew,
                      hintText: '',
                      labelText: "Project Type",
                      selectedItem: _selectedProjectType,
                      onChanged: (String? selectedItem) {
                        _selectedProjectType = selectedItem;
                      },
                    ))
                  ],
                ),
                const SizedBox(height: 25), // Space between rows
                // Project Description Field
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
                const SizedBox(height: 25),
                // Space between description and new field
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _fetchOrganizations() async {
    List<Organization> lkpList = await OrganizationList().fetchAllActiveOrganizations(context);
    return lkpList.map((obj) => obj.name).toList();
  }

  Future<List<String>> _fetchIndustries() async {
    List<Industry> lkpList = await IndustryList().fetchAllActiveIndustries(context);
    return lkpList.map((obj) => obj.name).toList();
  }

  Future<List<String>> _fetchProjectTypes() async {
    List<ProjectType> lkpList = await ProjectTypeList().fetchAllActiveProjectTypes(context);
    return lkpList.map((obj) => obj.name).toList();
  }

  Future<void> _fetchProjectDetails(BuildContext context) async {
    ProjectDetailsModel projDetails = Provider.of<ProjectDetailsModel>(context, listen: false);
    await projDetails.fetchProjectsByUserMachineId(context);

    if (mounted) {
      setState(() {     
        _selectedOrganization = projDetails.getOrganization;
        _selectedProjectType = projDetails.getProjectType;
        _selectedIndustry = projDetails.getIndustry;
      });
    }

    _projectNameController.text = projDetails.getName;
    _projectDescriptionController.text = projDetails.getDescription;

  }

  Future<void> _saveProjectDetails(BuildContext context) async {
    var userDetailsModel =  Provider.of<UserDetailsModel>(context, listen: false);
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    // Validate form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      try {
        projectDetailsModel.projectDetails = ProjectDetails(
          name: _projectNameController.text.trim(),
          description: _projectDescriptionController.text.trim(),
          organization: _selectedOrganization!.trim(),
          recordStatus: 'Active',
          createdBy: userDetailsModel.getUserMachineId!,
          activeProjectId: widget.isNew? 0: projectDetailsModel.getActiveProjectId,
          projectType: _selectedProjectType!,
          createdByName: userDetailsModel.getName!,
          createdByEmail: userDetailsModel.getEmail!,
          industry: _selectedIndustry!
        );

        int resultId = await projectDetailsModel.saveProjectDetails(context);

        if (resultId > 0) {
          await projectDetailsModel.fetchProjectsByUserMachineId(context);
          setState(() {
            widget.isNew = false;
          });

          SnackbarMessage.showSuccessMessage(context,
              'Project ${_projectNameController.text.trim()} has been saved successfully.');
        }
      } catch (e) {
        SnackbarMessage.showErrorMessage(context, e.toString());
      }
    } else {
      SnackbarMessage.showErrorMessage(
          context, 'Please fill in all required fields.');
    }
  }

  Future<void> _loadPage() async {
    try {
      await _fetchProjectDetails(context);
    } catch (e) {
      SnackbarMessage.showErrorMessage(context,
          'Something went wrong! Please contact support for assistance.');
    }
  }
}
