//core
import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/core/services/websocket_service.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/config_s3.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//model
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

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

  InquiryQuestion(
      {this.questionText = '',
      this.industry = '',
      this.projectType = '',
      this.topic = '',
      this.createdDate = '',
      this.createdBy = '',
      this.lastResponseBy = '',
      this.lastResponseDate = '',
      this.questionId = 0,
      this.questionStatus = 'Open'});

  factory InquiryQuestion.fromJson(Map<String, dynamic> map) {
    return InquiryQuestion(
        questionText: map['question_text'] ?? '',
        industry: map['industry'] ?? '',
        projectType: map['project_type'] ?? '',
        topic: map['topic'] ?? '',
        createdDate: map['created_date'] ?? '',
        createdBy: map['created_by'] ?? '',
        lastResponseBy: map['last_response_by'] ?? '',
        lastResponseDate: map['last_response_date'] ?? '',
        questionId: map['question_id'] ?? 0,
        questionStatus: map['question_status'] ?? 'Open');
  }
}

class InquiryQuestionModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();

  List<InquiryQuestion> questionsList = [];
  List<InquiryQuestion> get getQuestionsList => questionsList;

  List<InquiryQuestion> filteredQuestionsList = [];
  List<InquiryQuestion> get getFilteredQuestionsList => filteredQuestionsList;

  int _selectedInquiryQuestionId = 0;
  int get getSelectedInquiryQuestionId => _selectedInquiryQuestionId;

  String _currentSortColumn = 'lastResponseDate';
  String get getCurrentSortColumn => _currentSortColumn;
  DataGridSortDirection currentSortDirection = DataGridSortDirection.descending;
  DataGridSortDirection get getCurrentSortDirection => currentSortDirection;

  void updateQuestionIdSelection(int questionId) {
    _selectedInquiryQuestionId = questionId;
    notifyListeners();
  }

  void updateSortColumn(String sortColumnName) {
    if (_currentSortColumn == sortColumnName) {
      currentSortDirection =
          (currentSortDirection == DataGridSortDirection.descending)
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
        return inquiryQuestion.questionText
                .toLowerCase()
                .contains(lowerCaseQuery) ||
            inquiryQuestion.topic.toLowerCase().contains(lowerCaseQuery) ||
            inquiryQuestion.questionStatus
                .toLowerCase()
                .contains(lowerCaseQuery) ||
            inquiryQuestion.lastResponseBy
                .toLowerCase()
                .contains(lowerCaseQuery);
      }).toList();
    }

    notifyListeners();
  }

  Future<void> fetchQuestionsByProject(BuildContext context) async {
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {'project_id': projectDetailsModel.getActiveProjectId};

    questionsList = await _crudService.getRecords<InquiryQuestion>(
      context,
      'dbo.sproc_get_inquiry_questions_by_project_id',
      params,
      (json) => InquiryQuestion.fromJson(json),
    );

    if (filteredQuestionsList.isEmpty) {
      filteredQuestionsList = questionsList;
    }

    notifyListeners();
  }

  Future<int> updateQuestionStatus(BuildContext context,
      InquiryQuestion question, String? updatedQuestionStatus) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': question.questionId,
      'question_status': updatedQuestionStatus ?? question.questionStatus,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_project_question_status',
      params,
    );

    if (updatedId > 0) {
      var index =
          questionsList.indexWhere((q) => q.questionId == question.questionId);
      if (index != -1) {
        questionsList[index].questionStatus =
            updatedQuestionStatus ?? question.questionStatus;
      }

      notifyListeners();
    }

    return updatedId;
  }

  @override
  int get selectedId => getSelectedInquiryQuestionId;

  @override
  Future<void> fetchResponses(BuildContext context) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.fetchResponsesByReference(context, getSelectedInquiryQuestionId, 'question');
  }

  @override
  Future<int> insertResponse(BuildContext context, String responseText) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.insertResponseByReference(context, getSelectedInquiryQuestionId, 'question', responseText);
  }

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseQuestionAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  int getSelectedId(BuildContext context) => selectedId;

  @override
  Future<void> sendMessage(BuildContext context, String message, WebSocketService webSocketService) async {
    //placeholder for now
  }

  @override
  String getDrivingModelName(BuildContext context) => 'Question';

  @override
  String getWebSocketUrl(BuildContext context) => WebSocketECSForQueryGeneration.webSocket;

  @override
  Future<int> updateConfig(BuildContext context, String aiSummary, String keyTables, String keyColumns, String keyCriteria, String keyJoins, String keyAmbiguities, String fullState, String initialState, String config, String configExecStatus, String configExecMessage) {
    // TODO: implement updateConfig
    throw UnimplementedError();
  }
}
