//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//services
import 'package:foretale_application/core/services/database_connect.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';

class ProjectSettings {
  String sqlHost;
  int sqlPort;
  String sqlDatabase;
  String sqlUsername;
  String sqlPassword;
  String s3Url;
  String s3Username;
  String s3Password;

  ProjectSettings({
    this.sqlHost = '',
    this.sqlPort = 0,
    this.sqlDatabase = '',
    this.sqlUsername = '',
    this.sqlPassword = '',
    this.s3Url = '',
    this.s3Username = '',
    this.s3Password = '',
  });

  // Factory method to create an instance from a JSON map
  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      sqlHost: json['host_name'] ?? '',
      sqlPort: json['port_name'] ?? 0,
      sqlDatabase: json['database_name'] ?? '',
      sqlUsername: json['username'] ?? '',
      sqlPassword: json['password_hash'] ?? '',
      s3Url: json['s3_file_storage'] ?? '',
      s3Username: json['s3_username'] ?? '',
      s3Password: json['s3_password_hash'] ?? '',
    );
  }
}


class ProjectSettingsModel with ChangeNotifier {
  ProjectSettings projectSettings = ProjectSettings();
  List<ProjectSettings> projectSettingsList = [];

  String get getSqlHost => projectSettings.sqlHost;
  int get getSqlPort => projectSettings.sqlPort;
  String get getSqlDatabase => projectSettings.sqlDatabase;
  String get getSqlUsername => projectSettings.sqlUsername;
  String get getSqlPassword => projectSettings.sqlPassword;
  String get getS3Url => projectSettings.s3Url;
  String get getS3Username => projectSettings.s3Username;
  String get getS3Password => projectSettings.s3Password;

  // Function to handle form submission
  Future<int> saveProjectSettings(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try{
      Map<String, dynamic> params = {
        "project_id": projectDetailsModel.getActiveProjectId,
        "host_name": getSqlHost,
        "port": getSqlPort,
        "database_name": getSqlDatabase,
        "username": getSqlUsername,
        "password_hash": getSqlPassword,
        "s3_file_storage": getS3Url,
        "s3_username": getS3Username,
        "s3_password_hash": getS3Password,
        "record_status": "Active",
        "created_by": userDetailsModel.getUserMachineId,
      };
      var jsonResponse = await FlaskApiService().insertRecord("dbo.SPROC_INSERT_UPDATE_PROJECT_SETTINGS", params); 
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());
      return insertedId; 
    } 
    catch(e, error_stack_trace){
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to save project settings. Please contact support for assistance.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'project_settings.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  Future<void> fetchProjectSettingsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
        // Ensuring user ID is available.
        if (userDetailsModel.getUserMachineId == null) {
          SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
          return;
        }

        var params = {
            'selected_project_id' : projectDetailsModel.getActiveProjectId,
            'user_machine_id' : userDetailsModel.getUserMachineId
        };

        var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_project_settings_by_user_machine_id', params);
        if (jsonResponse != null && jsonResponse['data'] != null) {
          var data = jsonResponse['data'];
          projectSettingsList = data
              .map((json) {
                try {
                  return ProjectSettings.fromJson(json);
                } catch (e) {
                  return null;
                }
              })
              .whereType<ProjectSettings>()
              .toList();   
        } else {
          projectSettings = ProjectSettings();
          return;
        }

        projectSettings = projectSettingsList.firstOrNull??ProjectSettings();

    } catch (e, error_stack_trace) {
      projectSettings = ProjectSettings();
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the project settings. Please contact support for assistance.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'projects_settings.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }     
    } finally {
      notifyListeners();
    }
  }
}
