import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InquiryQuestion {
  String questionText;  
  String industry;
  String projectType;
  String topic;     
  String createdDate; 
  String createdBy;     
  String lastResponseBy;  
  String lastResponseDate; 
  int questionId;    
  String questionStatus;

  InquiryQuestion({
    this.questionText ='',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.createdDate = '',
    this.createdBy = '',
    this.lastResponseBy = '',
    this.lastResponseDate = '',
    this.questionId = 0,
    this.questionStatus = 'Open'
  });

  // A method to convert a map back into a model object (e.g., when fetching data from Firestore).
  factory InquiryQuestion.fromJson(Map<String, dynamic> map) {
    return InquiryQuestion(
      questionText: map['question_text'],
      industry: map['industry'],
      projectType: map['project_type'],
      topic: map['topic'],
      createdDate: map['created_date'],
      createdBy: map['created_by']??'',
      lastResponseBy: map['last_response_by']??'',
      lastResponseDate: map['last_response_date']??'',
      questionId: map['question_id'],
      questionStatus: map['question_status']

    );
  }
}

class InquiryQuestionModel with ChangeNotifier {
  List<InquiryQuestion> questionsList = [];
  List<InquiryQuestion> get getQuestionsList => questionsList;
  List<InquiryQuestion> filteredQuestionsList = [];
  List<InquiryQuestion> get getFilteredQuestionsList => filteredQuestionsList;

  int _selectedInquiryQuestionId = 0;
  int get getSelectedInquiryQuestionId => _selectedInquiryQuestionId;
  String _currentSortColumn = 'lastResponseDate';
  String get getCurrentSortColumn => _currentSortColumn;
  DataGridSortDirection currentSortDirection = DataGridSortDirection.descending;
  DataGridSortDirection get getCurrentSortDirection => currentSortDirection; // Default direction


  void updateQuestionIdSelection(int questionId ){
    _selectedInquiryQuestionId = questionId;
    notifyListeners();
  }

  void updateSortColumn(String sortColumnName){
    if (_currentSortColumn == sortColumnName) {
      currentSortDirection = (currentSortDirection == DataGridSortDirection.descending)
          ? DataGridSortDirection.ascending
          : DataGridSortDirection.descending;
    } else {
      _currentSortColumn = sortColumnName;
      currentSortDirection = DataGridSortDirection.descending;
    }
    notifyListeners();
  }

  void filterData(String query) {
    String lowerCaseQuery = query.trim().toLowerCase();
    
    if (query.isEmpty) {
      filteredQuestionsList = List.from(questionsList);
    } else {
      filteredQuestionsList = filteredQuestionsList.where((inquiryQuestion) {
        return inquiryQuestion.questionText.toLowerCase().contains(lowerCaseQuery) ||
               inquiryQuestion.topic.toLowerCase().contains(lowerCaseQuery) ||
               inquiryQuestion.questionStatus.toLowerCase().contains(lowerCaseQuery) ||
               inquiryQuestion.lastResponseBy.toLowerCase().contains(lowerCaseQuery);

      }).toList();
    }

    notifyListeners();
  }

  Future<void> fetchQuestionsByProject(BuildContext context) async {
    final stopwatch = Stopwatch()..start();
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
      var jsonResponse = await FlaskApiService().readRecord('dbo.sproc_get_inquiry_questions_by_project_id', params);
      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        
        questionsList = data.map((json) {
              try {
                return InquiryQuestion.fromJson(json);
              } catch (e) {

                return null;
              }
            })
            .whereType<InquiryQuestion>()
            .toList()??[];   
            
      } else {
        questionsList = [];
      }
      stopwatch.stop();
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the questions list.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'inquiry_questions_model.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      questionsList = [];
    } finally {
      filteredQuestionsList = questionsList;
      notifyListeners();
    }
  }

  Future<int> updateQuestionStatus(BuildContext context, InquiryQuestion question, String? updatedQuestionStatus) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    try {
      var params = {
        'selected_project_id': projectDetailsModel.getActiveProjectId,
        'question_id': question.questionId,
        'question_status': updatedQuestionStatus??question.questionStatus,
        'last_updated_by': userDetailsModel.getUserMachineId, 
      };

      var jsonResponse = await FlaskApiService().updateRecord('dbo.sproc_update_project_question_status', params);
      int updatedId = int.parse(jsonResponse['data'][0]['updated_id'].toString());

      if(updatedId>0){
        var index = questionsList.indexWhere((q) => q.questionId == question.questionId);
        if (index != -1) {
          questionsList[index].questionStatus = updatedQuestionStatus??question.questionStatus;
        }
        notifyListeners();
      }
      return updatedId;

    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to update the status.',
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
