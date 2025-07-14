//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

class Module {
  final int id;
  final String name;
  final String abbreviation;

  Module({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
    );
  }
}

class ModuleList {
  final CRUD _crudService = CRUD();
  List<Module> moduleList = [];

  Future<List<Module>> fetchAllActiveModules(BuildContext context, String subtopicName) async {
    ProjectDetailsModel projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'industry': projectDetailsModel.getIndustry,
      'project_type': projectDetailsModel.getProjectType,
      //'subtopic_name': subtopicName
    };

    moduleList = await _crudService.getRecords<Module>(
      context,
      'dbo.sproc_get_test_modules',
      params,
      (json) => Module.fromJson(json),
    );
    return moduleList;
  }
}

