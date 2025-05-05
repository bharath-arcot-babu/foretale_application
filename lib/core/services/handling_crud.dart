import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class CRUD {
  Future<int> addRecord(BuildContext context, String storedProcedure, Map<String, dynamic> params) async {
    try {
      var jsonResponse = await FlaskApiService().insertRecord(storedProcedure, params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      if (insertedId > 0) {
        return insertedId;
      } else {
        throw Exception('Failed to add record');
      }
    } catch (e, error_stack_trace) {
      _handleError(context, e, error_stack_trace, storedProcedure, 'insertRecord');
      return 0;
    }
  }

  Future<int> updateRecord(BuildContext context, String storedProcedure, Map<String, dynamic> params) async {
    try {
      var jsonResponse = await FlaskApiService().updateRecord(storedProcedure, params);
      int updatedId = int.parse(jsonResponse['data'][0]['updated_id'].toString());

      if (updatedId > 0) {
        return updatedId;
      } else {
        throw Exception('Failed to update record');
      }
    } catch (e, error_stack_trace) {
      _handleError(context, e, error_stack_trace, storedProcedure, 'updateRecord');
      return 0;
    }
  }

  Future<int> deleteRecord(BuildContext context, String storedProcedure, Map<String, dynamic> params) async {
    try {
      var jsonResponse = await FlaskApiService().deleteRecord(storedProcedure, params);
      int deletedId = int.parse(jsonResponse['data'][0]['deleted_id'].toString());

      if (deletedId > 0) {
        return deletedId;
      } else {
        throw Exception('Failed to delete record');
      }
    } catch (e, error_stack_trace) {
      _handleError(context, e, error_stack_trace, storedProcedure, 'deleteRecord');
      return 0;
    }
  }

  Future<List<T>> getRecords<T>(BuildContext context, String storedProcedure, Map<String, dynamic> params, T Function(Map<String, dynamic>) fromJson) async {
    try {
      var jsonResponse = await FlaskApiService().readRecord(storedProcedure, params);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];

        if(data is! List){
          return [];
        }

        return data.map<T?>((json) {
          try {
            return fromJson(json)!;
          } catch (e) {
            print(e);
            return null;
          }

        }).whereType<T>().toList();
        
      } else {
        return [];
      }
    } catch (e, error_stack_trace) {
      print(e.toString());
      _handleError(context, e, error_stack_trace, storedProcedure, 'readRecord');
      return [];
    }
  }

  Future<List<T>> getJsonRecords<T>(BuildContext context, String storedProcedure, Map<String, dynamic> params, T Function(Map<String, dynamic>) fromJson) async {
    try {
      var jsonResponse = await FlaskApiService().readJsonRecord(storedProcedure, params);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];

        if(data is! List){
          return [];
        }
        
        return data.map<T?>((json) {
          try {
            return fromJson(json)!;
          } catch (e) {
            print(e);
            print("Error in JSON mapping: $json");
            return null;
          }

        }).whereType<T>().toList();
        
      } else {
        return [];
      }
    } catch (e, error_stack_trace) {
      print(e.toString());
      _handleError(context, e, error_stack_trace, storedProcedure, 'readJsonRecord');
      return [];
    }
  }

  // Handle errors and show messages to users
  void _handleError(BuildContext context, dynamic error, StackTrace stackTrace, String storedProcedure, String action) {
    SnackbarMessage.showErrorMessage(
        context,
        'Unable to complete the action. Please contact support for assistance.',
        logError: true,
        errorMessage: error.toString(),
        errorStackTrace: stackTrace.toString(),
        errorSource: storedProcedure,
        severityLevel: 'Critical',
        requestPath: action,
      );
  }
}
