import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

class Question {
  String questionText;  
  String industry;
  String projectType;
  String topic;
  String status;        
  String createdDate; 
  String createdBy;     
  String lastUpdatedBy;  
  String lastUpdatedDate; 
  int questionId;    
  bool isSelected;

  Question({
    this.questionText ='',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.status = '',
    this.createdDate = '',
    this.createdBy = '',
    this.lastUpdatedBy = '',
    this.lastUpdatedDate = '',
    this.questionId = 0,
    this.isSelected = false
  });

  // A method to convert a map back into a model object (e.g., when fetching data from Firestore).
  factory Question.fromJson(Map<String, dynamic> map) {
    return Question(
      questionText: map['question_text'],
      industry: map['industry'],
      projectType: map['project_type'],
      topic: map['topic'],
      status: map['status']?? 'Active',
      createdDate: map['created_date'],
      createdBy: map['created_by']??'',
      lastUpdatedBy: map['last_updated_by']??'',
      lastUpdatedDate: map['last_updated_date']??'',
      questionId: map['question_id'],
      isSelected: bool.tryParse(map['is_selected'])??false,
    );
  }
}

class QuestionsModel with ChangeNotifier {
  List<Question> questionsList = [];
  List<Question> get getQuestionsList => questionsList;

  Future<void> fetchQuestionsByProject(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    try {
      // Ensuring user ID is available.
      if (userDetailsModel.getUserMachineId == null) {
        SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
        questionsList = [];
        return;
      }

      final params = {
        'project_id': projectDetailsModel.getActiveProjectId
        };
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_questions_by_project_id', params);
      
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        questionsList = data.map((json) {
              try {
                return Question.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Question>()
            .toList()??[];   
      } else {
        questionsList = [];
      }
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the questions.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'team_contacts.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      questionsList = [];
    } finally {
      notifyListeners();
    }
  }

  Future<int> selectQuestion(BuildContext context, Question question) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
      var params = {
        'selected_project_id': projectDetailsModel.getActiveProjectId,
        'question_id': question.questionId,
        'created_by': userDetailsModel.getUserMachineId, 
      };

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_question_project', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      if(insertedId>0){
        var index = questionsList.indexWhere((q) => q.questionId == question.questionId);
        if (index != -1) {
          questionsList[index].isSelected = true;
        }
        notifyListeners();
      }
      return insertedId;

    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to assign the question.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'question_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  Future<int> addNewQuestionByProjectId(BuildContext context, String questionText, String topic) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
      var params = {
        'selected_project_id': projectDetailsModel.getActiveProjectId,
        'question_text': questionText,
        'created_by': userDetailsModel.getUserMachineId, 
        'industry': projectDetailsModel.getIndustry,
        'project_type': projectDetailsModel.getProjectType,
        'topic': topic
      };

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_new_question_by_project', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      return insertedId;

    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to add the question.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'question_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  Future<int> removeQuestion(BuildContext context, Question question) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
        final params = {
          'selected_project_id': projectDetailsModel.getActiveProjectId,
          'question_id': question.questionId,
          'last_updated_by': userDetailsModel.getUserMachineId
        };

        var jsonResponse = await FlaskApiService().deleteRecord('dbo.sproc_delete_assigned_question', params);
        int deletedId = int.parse(jsonResponse['data'][0]['deleted_id'].toString());

        if(deletedId>0){
          var index = questionsList.indexWhere((q) => q.questionId == question.questionId);
          if (index != -1) {
            questionsList[index].isSelected = false;
          }
          notifyListeners();
        }
        return deletedId;
      } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to remove the question.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'question_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
      }
  }
}
