import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class UserDetails extends ChangeNotifier {
  String? userMachineId;
  String? userId;
  String? name;
  String? position;
  String? function;
  String? email;
  String? phone;
  String? isClient;
  String? recordStatus;
  String? createdBy;
  String? lastUpdatedBy;

  // Constructor
  UserDetails({
    this.userMachineId,
    this.userId,
    this.name,
    this.position,
    this.function,
    this.email,
    this.phone,
    this.isClient,
    this.recordStatus, 
    this.createdBy, 
    this.lastUpdatedBy, 
  });

  // Factory method to create an instance from JSON
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userMachineId: json['user_machine_id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      function: json['function'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isClient: json['is_client'] ?? '',
      recordStatus: json['record_status'] ?? 'Active',
      createdBy: json['created_by'] ?? '',
      lastUpdatedBy: json['last_updated_by'] ?? '',
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userMachineId': userMachineId,
      'userId': userId,
      'name': name,
      'position': position,
      'function': function,
      'email': email,
      'phone': phone,
      'isClient': isClient,
      'record_status': recordStatus,
      'created_by': createdBy,
      'last_updated_by': lastUpdatedBy,
    };
  }

}


class UserDetailsModel extends ChangeNotifier {
  UserDetails userDetails = UserDetails();
  
  // Getters for all properties
  String? get getUserMachineId => userDetails.userMachineId;
  String? get getUserId => userDetails.userId;
  String? get getName => userDetails.name;
  String? get getPosition => userDetails.position;
  String? get getFunction => userDetails.function;
  String? get getEmail => userDetails.email;
  String? get getPhone => userDetails.phone;
  String? get getIsClient => userDetails.isClient;
  String? get getRecordStatus => userDetails.recordStatus;
  String? get getCreatedBy => userDetails.createdBy;
  String? get getLastUpdatedBy => userDetails.lastUpdatedBy;


  // Set the user details
  void saveUserDetails(String id, String name, String email) {
    userDetails.userMachineId = id;
    userDetails.name = name;
    userDetails.email = email;
    notifyListeners();
  }

  Future<void> initializeUser(BuildContext context) async {
    try {
      if (getUserMachineId == null || getEmail == null) {
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to initialize the user settings.',
        );
        return;
      }
      
      final params = {
        'user_machine_id': getUserMachineId,
        'organization_id': null,
        'name': getName,
        'position': null,
        'function': null,
        'email': getEmail,
        'phone': null,
        'is_client': 'No',
        'record_status': 'Active',
        'created_by': getUserMachineId,
        'last_updated_by': getUserMachineId
      };

      await FlaskApiService().insertRecord('dbo.sproc_initialize_user', params);
      
    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to setup the user. Please contact support for assistance.',
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
