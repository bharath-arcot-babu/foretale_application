
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
  List<TeamContact> teamContacts = [];
  List<TeamContact> get getTeamContacts => teamContacts;

  Future<int> addUpdateContact(BuildContext context,TeamContact contact) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {

      if(teamContacts.where((con) => con.email == contact.email).isEmpty)
      {
          final params = {
          'selected_project_id': projectDetailsModel.getActiveProjectId,
          'name': contact.name,
          'position': contact.position,
          'function': contact.function,
          'email': contact.email,
          'phone': contact.phone,
          'is_client': contact.isClient,
          'record_status': 'Active',
          'created_by': userDetailsModel.getUserMachineId,
        };

        var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_update_user_project_mapping', params);
        int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

        if(insertedId>0){
          contact.id = insertedId;
          teamContacts.add(contact);
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
      'selected_project_id': projectDetailsModel.getActiveProjectId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    var jsonResponse = await FlaskApiService().deleteRecord('dbo.sproc_delete_team_contact', params);
    int deletedId = int.parse(jsonResponse['data'][0]['deleted_id'].toString());
    
    if(deletedId>0){
      teamContacts.remove(contact);
      notifyListeners();
    }
  }

  Future<void> fetchTeamByProjectId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
      // Ensuring user ID is available.
      if (userDetailsModel.getUserMachineId == null) {
        SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
        teamContacts = [];
        return;
      }

      final params = {
        'project_id': projectDetailsModel.getActiveProjectId
        };
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_users_by_project_id', params);
      
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        teamContacts = data.map((json) {
              try {
                return TeamContact.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<TeamContact>()
            .toList()??[];      
      } else {
        teamContacts = [];
      }
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the team list. Please contact support for assistance.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'team_contacts.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      teamContacts = [];
    } finally {
      notifyListeners();
    }
  }
}