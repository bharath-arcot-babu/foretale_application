//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/organization_list_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class ProjectDetails extends StatefulWidget {
  const ProjectDetails({super.key});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  // Form key to manage validation state
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController(); 

  final List<String> _projectTypeNames = [
    'P2P Procure to Pay Analytics',
    'Vendor Assessment',
    'Material Assessment',
    'Expense Analytics',
  ];

  String? _selectedProjectType = "";
  String? _selectedOrganization = "";

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
                  width: 80, // Adjusted width to fit the text
                  height: 50,
                  text: 'Save',
                  textSize: 15,
                  onPressed: () {
                    _saveProjectDetails(context);
                  },
                ),
              ],
            ),
            const SizedBox(
                height: 15), // Add spacing between the button and form fields
            // Form Fields
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name and Company Name Fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
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
                    const SizedBox(width: 15), // Add space between the two text fields
                    Expanded(
                      child: FutureBuilder<List<String>>(
                        future: _fetchOrganizations(), 
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No organizations found.'));
                          } else {
                            List<String> organizationNames = snapshot.data!;
                            return CustomDropdownSearch(
                              items: organizationNames,
                              hintText: '',
                              labelText: 'Organization',
                              onChanged: (String? selectedItem) {
                                _selectedOrganization = selectedItem;
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25), // Space between rows

                // Project Description Field
                CustomTextField(
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
                CustomDropdownSearch(
                  items: _projectTypeNames,
                  hintText: '',
                  labelText: 'Project',
                  onChanged: (String? selectedItem) {
                    _selectedProjectType = selectedItem;
                  },
                ) // Space between description and new field
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _fetchOrganizations() async {
    List<Organization> organizationList = await OrganizationList().fetchAllActiveOrganizations(context);
    return organizationList.map((org) => org.name).toList();
  }

  Future<void> _saveProjectDetails(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    // Validate form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      try {
        projectDetailsModel.name = _projectNameController.text.trim();
        projectDetailsModel.description = _projectDescriptionController.text.trim();
        projectDetailsModel.organization = _selectedOrganization!.trim();
        projectDetailsModel.recordStatus = 'Active';
        projectDetailsModel.createdBy = userDetailsModel.userId!;
        projectDetailsModel.activeProjectId = 0;
        projectDetailsModel.projectType = _selectedProjectType!;
        projectDetailsModel.userName = userDetailsModel.name!;
        projectDetailsModel.userEmail = userDetailsModel.email!;

        int resultId = await projectDetailsModel.saveProjectDetails(context);
        if (resultId > 0) {
          SnackbarMessage.showSuccessMessage(context,
              'Project ${_projectNameController.text.trim()} has been created successfully.');
        }
      } catch (e) {
        SnackbarMessage.showErrorMessage(context, e.toString());
      }
    } else {
      SnackbarMessage.showErrorMessage(
          context, 'Please fill in all required fields.');
    }
  }
}
