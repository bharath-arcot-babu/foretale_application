import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class UserDetailsModel extends ChangeNotifier {
  String? userId;
  String? name;
  String? email;
  
  // Set the user details
  void saveUserDetails(String id, String name, String email) {
    userId = id;
    this.name = name;
    this.email = email;
    notifyListeners();
  }

  // Reset the user details when signed out
  void resetUser() {
    userId = null;
    name = null;
    email = null;
    notifyListeners();
  }

  Future<void> initializeUser(BuildContext context) async {
    try {
      if (userId == null || email == null) {
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to initialize the user settings.',
        );
        return;
      }
      
      final params = {
        'user_machine_id': userId,
        'organization_id': null,
        'name': name,
        'position': null,
        'function': null,
        'email': email,
        'phone': null,
        'is_client': 'No',
        'record_status': 'Active',
        'created_by': userId,
        'last_updated_by': userId
      };

      await FlaskApiService().insertRecord('dbo.sproc_initialize_user', params);
      
    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Error initializing the tool. Please contact support for assistance.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'user_details_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
    }
  }
}
