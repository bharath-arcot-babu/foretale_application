import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

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
}

class TeamContactsModel with ChangeNotifier {
  final List<TeamContact> _teamContacts = [];

  List<TeamContact> get getTeamContacts => _teamContacts;

  Future<int> addUpdateContact(BuildContext context,TeamContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {

      if(_teamContacts.where((con) => con.email == contact.email).isEmpty)
      {
          final params = {
          'selected_project_id': projectDetailsModel.activeProjectId,
          'name': contact.name,
          'position': contact.position,
          'function': contact.function,
          'email': contact.email,
          'phone': contact.phone,
          'is_client': contact.isClient,
          'record_status': 'Active',
          'created_by': userDetailsModel.userId,
        };

        var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_update_user_project_mapping', params);
        int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

        if(insertedId>0){
          contact.id = insertedId;
          _teamContacts.add(contact);
          notifyListeners();
        }
        return insertedId;
      } else{
        throw Exception("<ERR_START>${contact.name} has been assigned already.<ERR_END>");
      }
    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {

            SnackbarMessage.showErrorMessage(
              context,
              'Unable to save the team contact. Please contact support for assistance.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'team_contacts.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  void removeContact(BuildContext context, TeamContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'team_contact_id': contact.id,
      'selected_project_id': projectDetailsModel.activeProjectId,
      'last_updated_by': userDetailsModel.userId
    };

    var jsonResponse = await FlaskApiService().deleteRecord('dbo.sproc_delete_team_contact', params);
    int deletedId = int.parse(jsonResponse['data'][0]['deleted_id'].toString());
    
    if(deletedId>0){
      _teamContacts.remove(contact);
      notifyListeners();
    }
  }
}