//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';

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
  final CRUD _crudService = CRUD();
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

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_project',
      params,
    );

    if(insertedId>0){
      params = {
          'project_id' : insertedId
      };

      projectsList = await _crudService.getRecords<ProjectDetails>(
        context,
        'dbo.sproc_get_project_by_id',
        params,
        (json) => ProjectDetails.fromJson(json),
      );

      projectDetails = projectsList.firstOrNull??ProjectDetails();
      notifyListeners();
    }
  
    return getActiveProjectId;
  }

  Future<void> fetchProjectsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    final params = {'user_machine_id': userDetailsModel.getUserMachineId};

    projectListByUser = await _crudService.getRecords<ProjectDetails>(
      context,
      'dbo.sproc_get_projects_by_user_machine_id',
      params,
      (json) => ProjectDetails.fromJson(json),
    );

    notifyListeners();
  }
}
