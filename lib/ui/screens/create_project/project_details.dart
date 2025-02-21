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
  final String _currentFileName = "project_details.dart";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController(); 
  String? _selectedProjectType;
  String? _selectedOrganization;
  String? _selectedIndustry;
  late UserDetailsModel _userDetailsModel;
  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState(){
    super.initState();
    _userDetailsModel =  Provider.of<UserDetailsModel>(context, listen: false);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isNew) {
          _loadPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                  width: 40,
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
                      ),),
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
                        
                        setState(() {
                          _fetchProjectTypes(_selectedIndustry??'');
                        });

                      },
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: FutureDropdownSearch(
                      fetchData: (){return _fetchProjectTypes(_selectedIndustry??'');},
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

  Future<List<String>> _fetchProjectTypes(String selectedIndustry) async {
    List<ProjectType> lkpList = await ProjectTypeList().fetchAllActiveProjectTypes(context, selectedIndustry);
    return lkpList.map((obj) => obj.name).toList();
  }

  Future<void> _fetchProjectDetails(BuildContext context) async {
    await _projectDetailsModel.fetchProjectsByUserMachineId(context);

    if (mounted) {
      setState(() {     
        _selectedOrganization = _projectDetailsModel.getOrganization;
        _selectedProjectType = _projectDetailsModel.getProjectType;
        _selectedIndustry = _projectDetailsModel.getIndustry;
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
          activeProjectId: widget.isNew? 0: _projectDetailsModel.getActiveProjectId,
          projectType: _selectedProjectType!,
          createdByName: _userDetailsModel.getName!,
          createdByEmail: _userDetailsModel.getEmail!,
          industry: _selectedIndustry!
        );

        int resultId = await _projectDetailsModel.saveProjectDetails(context);

        if (resultId > 0) {

          await _projectDetailsModel.fetchProjectsByUserMachineId(context);

          setState(() {
            widget.isNew = false;
          });

          SnackbarMessage.showSuccessMessage(context, 'Project "${_projectNameController.text.trim()}" has been saved successfully.');
        }
      } catch (e, error_stack_trace) {
         
         SnackbarMessage.showErrorMessage(context, 
            e.toString(),
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
      SnackbarMessage.showErrorMessage(context, 
            e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: error_stack_trace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_saveProjectDetails");
    }
  }
}
