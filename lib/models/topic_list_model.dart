//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

class Topic {
  final int id;
  final String name;

  Topic({
    required this.id,
    required this.name,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class TopicList {
  final CRUD _crudService = CRUD();
  List<Topic> topicList = [];

  Future<List<Topic>> fetchAllActiveTopics(BuildContext context) async {
    ProjectDetailsModel projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'industry': projectDetailsModel.getIndustry,
      'project_type': projectDetailsModel.getProjectType
    };

    topicList = await _crudService.getRecords<Topic>(
      context,
      'dbo.sproc_get_subtopics',
      params,
      (json) => Topic.fromJson(json),
    );
    return topicList;
  }
}

