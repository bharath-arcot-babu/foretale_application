import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class ProjectDetailsModel with ChangeNotifier {
  String name = '';
  String description = '';
  String organization = '';
  String recordStatus = 'Active';
  String createdBy = '';
  int activeProjectId = 0;
  String projectType = "";
  String userName = "";
  String userEmail = "";

  Future<int> saveProjectDetails(BuildContext context) async {
    try {
      final params = {
        'name': name,
        'description': description,
        'organization_name': organization,
        'record_status': recordStatus,
        'created_by': createdBy,
        'selected_project_id': activeProjectId,
        'project_type': projectType,
        'user_name': userName,
        'user_email': userEmail
      };

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_update_project', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());
      activeProjectId = insertedId; 

      // After successfully saving the project, notify listeners to update UI
      notifyListeners();

      return insertedId;
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
              errorSource: 'project_detials.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }
}
