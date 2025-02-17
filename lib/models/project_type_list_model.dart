//core
import 'package:flutter/material.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';


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

  Future<List<ProjectType>> fetchAllActiveProjectTypes(BuildContext context) async {

    projectTypeList = await _crudService.getRecords<ProjectType>(
      context,
      'dbo.sproc_get_topic',
      {},
      (json) => ProjectType.fromJson(json),
    );

    return projectTypeList;
  }
}

