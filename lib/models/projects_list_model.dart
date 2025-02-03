import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/create_project/project_info_cards.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class Projects {
  final int projectId;
  final String projectName;
  final int organizationId;
  final String organizationName;
  final String projectStartDate;
  final String projectType;

  Projects({
    required this.projectId,
    required this.projectName,
    required this.organizationId,
    required this.organizationName,
    required this.projectStartDate,
    required this.projectType
  });

  factory Projects.fromJson(Map<String, dynamic> json) {
    return Projects(
      projectId: json['project_id'],
      projectName: json['project_name'],
      organizationId: json['organization_id'],
      organizationName: json['organization_name'],
      projectStartDate: json['project_start_date'],
      projectType: json['project_type'],
    );
  }
}

class ProjectsList{
  Future<List<Projects>> fetchProjectsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    try {
      // Ensuring user ID is available.
      if (userDetailsModel.userId == null) {
        SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
        return [];
      }

      final params = {'user_machine_id': userDetailsModel.userId};
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_projects_by_user_machine_id', params);
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var projectsListData = jsonResponse['data'];
        return projectsListData.map((json) {
          try {
            return Projects.fromJson(json);
          } catch (e) {
            return null;
          }
        }).whereType<Projects>().toList();
      } else {
        return [];
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
      return [];
    }
}

  
}
