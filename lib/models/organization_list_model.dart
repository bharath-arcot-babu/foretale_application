import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class Organization {
  final int id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  // Factory constructor for creating an instance from JSON
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',  // Providing default value in case key is missing
      name: json['name'] ?? '',  // Default to empty string if name is missing
    );
  }

  // Method to convert Organization instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class OrganizationList {
  Future<List<Organization>> fetchAllActiveOrganizations(BuildContext context) async {
    try {
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_organizations', {});

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var organizationData = jsonResponse['data'];
        return organizationData.map((json) {
          try {
            return Organization.fromJson(json);  
          } catch (e) {
            return null;
          }
        }).whereType<Organization>().toList();  // Filter out any null values
      } else {
        return [];  // Return an empty list if data or response is null
      }
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        // Show error message if it's not a "Not Found" error
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // More detailed error message with logging for 'NOT_FOUND' error
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the organizations list. Please contact support for assistance.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'organization_list_model.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      return []; 
    }
  }
}

