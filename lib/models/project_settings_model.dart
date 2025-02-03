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


class ProjectSettingsModel with ChangeNotifier {
  String sqlHost = '';
  int sqlPort = 0;
  String sqlDatabase = '';
  String sqlUsername = '';
  String sqlPassword = '';
  String s3Url = '';
  String s3Username = '';
  String s3Password = '';

  // Function to handle form submission
  Future<int> saveProjectSettings(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try{
      Map<String, dynamic> params = {
        "project_id": projectDetailsModel.activeProjectId,
        "host_name": sqlHost,
        "port": sqlPort,
        "database_name": sqlDatabase,
        "username": sqlUsername,
        "password_hash": sqlPassword,
        "s3_file_storage": s3Url,
        "s3_username": s3Username,
        "s3_password_hash": s3Password,
        "record_status": "Active",
        "created_by": userDetailsModel.userId,
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
}
