//core 
import 'package:flutter/material.dart';

import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

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
      recordStatus: json['record_status'] ?? 'A',
      createdBy: json['created_by'] ?? '',
      lastUpdatedBy: json['last_updated_by'] ?? '',
    );
  }
}

class UserDetailsModel extends ChangeNotifier {
  final CRUD _crudService = CRUD();
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
    final params = {
      'user_machine_id': getUserMachineId,
      'organization_id': null,
      'name': getName,
      'position': null,
      'function': null,
      'email': getEmail,
      'phone': null,
      'is_client': 'No',
      'record_status': 'A',
      'created_by': getUserMachineId,
      'last_updated_by': getUserMachineId
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_initialize_user',
      params,
    );
  }
}
