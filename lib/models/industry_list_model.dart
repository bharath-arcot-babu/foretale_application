//core
import 'package:flutter/material.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';

class Industry {
  final int id;
  final String name;

  Industry({
    required this.id,
    required this.name,
  });

  factory Industry.fromJson(Map<String, dynamic> json) {
    return Industry(
      id: json['id'] ?? '',
      name: json['name'] ?? '', 
    );
  }
}

class IndustryList {
  final CRUD _crudService = CRUD();
  List<Industry> industryList = [];

  Future<List<Industry>> fetchAllActiveIndustries(BuildContext context) async {
    industryList = await _crudService.getRecords<Industry>(
      context,
      'dbo.sproc_get_industry',
      {},
      (json) => Industry.fromJson(json),
    );

    return industryList;
  }
}

