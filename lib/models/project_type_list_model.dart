//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';



class ProjectType {
  final int id;
  final String name;

  ProjectType({
    required this.id,
    required this.name,
  });

  factory ProjectType.fromJson(Map<String, dynamic> json) {
    return ProjectType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class ProjectTypeList {
  final CRUD _crudService = CRUD();
  List<ProjectType> projectTypeList = [];
  
  Future<List<ProjectType>> fetchAllActiveProjectTypes(BuildContext context, String selectedIndustry) async {

    if(selectedIndustry.isNotEmpty){
      var params = {
        'industry': selectedIndustry
      };

      projectTypeList = await _crudService.getRecords<ProjectType>(
        context,
        'dbo.sproc_get_topics',
        params,
        (json) => ProjectType.fromJson(json),
      );
    }

    return projectTypeList;
  }
}

