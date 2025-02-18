
//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';



class TeamContact {
  int id = 0;
  final String name;
  final String position;
  final String function;
  final String email;
  final String phone;
  final String isClient;

  TeamContact({
    required this.name,
    required this.position,
    required this.function,
    required this.email,
    required this.phone,
    required this.isClient
  });

    factory TeamContact.fromJson(Map<String, dynamic> json) {
    return TeamContact(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      function: json['function'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isClient: json['is_client'] ?? 'No',
    )..id = json['user_id'] ?? 0;
  }
}

class TeamContactsModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<TeamContact> teamContacts = [];
  List<TeamContact> get getTeamContacts => teamContacts;

  Future<int> addUpdateContact(BuildContext context, TeamContact contact) async{

    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    Set<String> emailSet = teamContacts.map((con) => con.email).toSet();
    if(!emailSet.contains(contact.email))
    {
        final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'name': contact.name.trim(),
        'position': contact.position.trim(),
        'function': contact.function.trim(),
        'email': contact.email.trim(),
        'phone': contact.phone.trim(),
        'is_client': contact.isClient.trim(),
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
        teamContacts.add(contact);
        notifyListeners();
      }

      return insertedId;
      
    } else{
      throw Exception("<ERR_START>${contact.name} has been assigned already.<ERR_END>");
    } 
  }

  Future<void> fetchTeamByProjectId(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId
      };

    teamContacts = await _crudService.getRecords<TeamContact>(
      context,
      'dbo.sproc_get_users_by_project_id',
      params,
      (json) => TeamContact.fromJson(json),
    );

    notifyListeners();
  }

  void removeContact(BuildContext context, TeamContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'team_contact_id': contact.id,
      'project_id': projectDetailsModel.getActiveProjectId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_team_contact',
      params,
    );

    if (deletedId > 0) {
      teamContacts.remove(contact);
      notifyListeners();
    }
  }
}