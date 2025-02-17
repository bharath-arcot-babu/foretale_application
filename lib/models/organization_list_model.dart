//core
import 'package:flutter/material.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';

class Organization {
  final int id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class OrganizationList {
  final CRUD _crudService = CRUD();
  List<Organization> organizationList = [];

  Future<List<Organization>> fetchAllActiveOrganizations(BuildContext context) async {
    
    organizationList = await _crudService.getRecords<Organization>(
      context,
      'dbo.sproc_get_organizations',
      {},
      (json) => Organization.fromJson(json),
    );

    return organizationList;
  }
}

