import 'package:flutter/foundation.dart';
import 'package:foretale_application/core/services/sql_server_api.dart';

class ProjectDetailsModel with ChangeNotifier {
  String name = '';
  String description = '';
  String recordStatus = 'active';
  String createdBy = '';

  Future<void> saveData() async {
    try {
      final params = {
        'name': name,
        'description': description,
        'record_status': recordStatus,
        'created_by': createdBy
      };

      await FlaskApiService().insertRecord('dbo.sproc_insert_project', params);
      notifyListeners();
    } catch (e) {
      print('Error saving data: $e');
    }
  }
}
