import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class CRUD {
  Future<int> addUpdateRecord(BuildContext context, String storedProcedure, Map<String, dynamic> params) async {
    try {
      var jsonResponse = await FlaskApiService().insertRecord(storedProcedure, params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      if (insertedId > 0) {
        return insertedId;
      } else {
        throw Exception('Failed to add/update record');
      }
    } catch (e, error_stack_trace) {
      _handleError(context, e, error_stack_trace, storedProcedure, 'insertRecord');
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
            return null;
          }

        }).whereType<T>().toList();
        
      } else {
        return [];
      }
    } catch (e, error_stack_trace) {
      _handleError(context, e, error_stack_trace, storedProcedure, 'readRecord');
      return [];
    }
  }

  // Handle errors and show messages to users
  void _handleError(BuildContext context, dynamic error, StackTrace stackTrace, String storedProcedure, String action) {
    String errMessage = SnackbarMessage.extractErrorMessage(error.toString());

    if (errMessage != 'NOT_FOUND') {
      SnackbarMessage.showErrorMessage(context, errMessage);
    } else {
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
}
