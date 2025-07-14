//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CategoryList {
  final CRUD _crudService = CRUD();
  List<Category> categoryList = [];

  Future<List<Category>> fetchAllActiveCategories(BuildContext context) async {
    ProjectDetailsModel projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'industry': projectDetailsModel.getIndustry,
      'project_type': projectDetailsModel.getProjectType
    };

    categoryList = await _crudService.getRecords<Category>(
      context,
      'dbo.sproc_get_test_categories',
      params,
      (json) => Category.fromJson(json),
    );
    return categoryList;
  }
}

