//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

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
  final CRUD _crudService = CRUD();
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
      "record_status": "A",
      "created_by": userDetailsModel.getUserMachineId,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_project_settings',
      params,
    );

    return insertedId; 
  }

  Future<void> fetchProjectSettingsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
        'project_id' : projectDetailsModel.getActiveProjectId,
        'user_machine_id' : userDetailsModel.getUserMachineId
    };

    projectSettingsList = await _crudService.getRecords<ProjectSettings>(
      context,
      'dbo.sproc_get_project_settings_by_user_machine_id',
      params,
      (json) => ProjectSettings.fromJson(json),
    );

    projectSettings = projectSettingsList.firstOrNull??ProjectSettings();
    notifyListeners();
  }
}
