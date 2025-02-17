import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class ProjectDetails {
  String name;
  String description;
  int organizationId;
  String organization;
  String recordStatus;
  String createdBy;
  int activeProjectId;
  String projectType;
  String createdDate;
  String createdByName;
  String createdByEmail;
  String industry;

  // Constructor with default values
  ProjectDetails({
    this.name = '',
    this.description = '',
    this.organizationId = 0,
    this.organization = '',
    this.recordStatus = 'Active',
    this.createdBy = '',
    this.activeProjectId = 0,
    this.projectType = '',
    this.createdDate = '',
    this.createdByName = '',
    this.createdByEmail = '',
    this.industry = ''
  });

  // Factory method to create an instance from a JSON map
  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      organizationId: json['organization_id']?? 0,
      organization: json['organization_name'] ?? '',
      recordStatus: json['record_status'] ?? 'Active',
      createdBy: json['created_by'] ?? '',
      activeProjectId: json['selected_project_id'] ?? 0,
      projectType: json['project_type'] ?? '',
      createdDate: json['created_date'] ?? '',
      createdByName: json['user_name'] ?? '',
      createdByEmail: json['user_email'] ?? '',
      industry: json['industry'] ?? '',
    );
  }
}


class ProjectDetailsModel with ChangeNotifier { 
  ProjectDetails projectDetails = ProjectDetails();
  List<ProjectDetails> projectListByUser = [];

  // Getters for all fields
  bool get getHasProject => (projectDetails.activeProjectId > 0)?true:false;
  String get getName => projectDetails.name;
  String get getDescription => projectDetails.description;
  String get getOrganization => projectDetails.organization;
  String get getRecordStatus => projectDetails.recordStatus;
  String get getCreatedBy => projectDetails.createdBy;
  int get getActiveProjectId => projectDetails.activeProjectId;
  String get getProjectType => projectDetails.projectType;
  String get getCreatedByName => projectDetails.createdByName;
  String get getCreatedByEmail => projectDetails.createdByEmail;
  String get getIndustry => projectDetails.industry;

  void updateProjectDetails(BuildContext context, ProjectDetails projDetails) {
    projectDetails = projDetails;
    notifyListeners();
  }
  
  Future<int> saveProjectDetails(BuildContext context) async {
    try {
      var projectsList = [];
      var params = {
        'name': getName,
        'description': getDescription,
        'organization_name': getOrganization,
        'record_status': getRecordStatus,
        'created_by': getCreatedBy, 
        'selected_project_id': getActiveProjectId,
        'project_type': getProjectType,
        'user_name': getCreatedByName,
        'user_email': getCreatedByEmail,
        'industry': getIndustry
      };

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_update_project', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      params = {
          'project_id' : insertedId
      };

      jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_project_by_id', params);
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        projectsList = data
            .map((json) {
              try {
                return ProjectDetails.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<ProjectDetails>()
            .toList();      
      } else {
        return 0;
      }

      projectDetails = projectsList.firstOrNull??ProjectDetails();
      notifyListeners();
      return getActiveProjectId;

    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to save project details. Please contact support for assistance.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'project_details.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  Future<void> fetchProjectsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    try {
      // Ensuring user ID is available.
      if (userDetailsModel.getUserMachineId == null) {
        SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
        projectListByUser = [];
        return;
      }

      final params = {'user_machine_id': userDetailsModel.getUserMachineId};
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_projects_by_user_machine_id', params);
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var projectsListData = jsonResponse['data'];
        projectListByUser = projectsListData.map((json) {
              try {
                return ProjectDetails.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<ProjectDetails>()
            .toList()??[];      
      } else {
        projectListByUser = [];
      }
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the projects list. Please contact support for assistance.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'projects_list.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      projectListByUser = [];
    } finally {
      notifyListeners();
    }
  }

}
