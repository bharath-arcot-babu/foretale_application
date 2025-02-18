
//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';


class ClientContact {
  int id = 0;
  final String name;
  final String position;
  final String function;
  final String email;
  final String phone;
  final String isClient;

  ClientContact({
    required this.name,
    required this.position,
    required this.function,
    required this.email,
    required this.phone,
    required this.isClient
  });

  factory ClientContact.fromJson(Map<String, dynamic> json) {
    return ClientContact(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      function: json['function'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isClient: json['is_client'] ?? 'No',
    )..id = json['user_id'] ?? 0;
  }
}

class ClientContactsModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<ClientContact> clientContacts = [];
  List<ClientContact> get getClientContacts => clientContacts;


  Future<int> addUpdateContact(BuildContext context,ClientContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    Set<String> emailSet = clientContacts.map((con) => con.email).toSet();
    if(!emailSet.contains(contact.email))
    {
        final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'name': contact.name,
        'position': contact.position,
        'function': contact.function,
        'email': contact.email,
        'phone': contact.phone,
        'is_client': contact.isClient,
        'record_status': 'Active',
        'created_by': userDetailsModel.getUserMachineId,
      };

      int insertedId = await _crudService.addRecord(
        context,
        'dbo.sproc_insert_update_user_project_mapping',
        params,
      );

      if(insertedId>0){
        contact.id = insertedId;
        clientContacts.add(contact);
        notifyListeners();
      }

      return insertedId;

    } else{
      throw Exception("<ERR_START>${contact.name} has already been assigned.<ERR_END>");
    }
  }

  Future<void> fetchClientsByProjectId(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId
      };

    clientContacts = await _crudService.getRecords<ClientContact>(
      context,
      'dbo.sproc_get_clients_by_project_id',
      params,
      (json) => ClientContact.fromJson(json),
    );

    notifyListeners();
  }

  void removeContact(BuildContext context, ClientContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'client_contact_id': contact.id,
      'project_id': projectDetailsModel.getActiveProjectId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_client_contact',
      params,
    );

    if (deletedId > 0) {
      clientContacts.remove(contact);
      notifyListeners();
    }
  }  
}