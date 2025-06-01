//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/inquiry_attachment_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';
import 'dart:async';

class InquiryResponse {
  int responseId;
  int projectId;
  int questionId;
  int testId;
  int isAiMagicResponse;
  String responseText;
  String responseBy;
  String responseDate;
  String responseByMachineId;
  List<InquiryAttachment> attachments; 
  bool isEmbeddingCompleted;

  InquiryResponse({
    this.responseId = 0,
    this.projectId = 0,
    this.questionId = 0,
    this.testId = 0,
    this.isAiMagicResponse = 0,
    this.responseText = '',
    this.responseBy = '',
    this.responseDate = '',
    this.responseByMachineId = '',
    this.attachments = const [], // Initialize with an empty list
    this.isEmbeddingCompleted = false,
  });

  factory InquiryResponse.fromJson(Map<String, dynamic> map) {
    return InquiryResponse(
      responseId: map['response_id'] ?? 0,
      projectId: map['project_id'] ?? 0,
      questionId: map['question_id'] ?? 0,
      testId: map['test_id'] ?? 0,
      isAiMagicResponse: map['is_ai_magic_response'] ?? 0,
      responseText: map['response_text'] ?? '',
      responseBy: map['response_by'] ?? '',
      responseDate: map['response_date'] ?? '',
      responseByMachineId: map['response_by_machine_id'] ?? '',
      attachments: map.containsKey('attachments')
          ? List<InquiryAttachment>.from((map['attachments'] as List)
              .map((x) => InquiryAttachment.fromJson(x)))
          : [],
      isEmbeddingCompleted: map['is_embedding_complete'] ?? false,
    );
  }

  @override
  String toString() {
    return 'InquiryResponse(responseId: $responseId, '
        'projectId: $projectId, '
        'questionId: $questionId, '
        'testId: $testId, '
        'isAiMagicResponse: $isAiMagicResponse, '
        'responseText: "$responseText", '
        'responseBy: "$responseBy", '
        'responseDate: "$responseDate", '
        'responseByMachineId: "$responseByMachineId", '
        'attachments: ${attachments.map((a) => a.toString()).toList()})';
  }
}

class InquiryResponseModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<InquiryResponse> responseList = [];
  List<InquiryResponse> get getResponseList => responseList;
 
  int _selectedInquiryResponseId = 0;
  int get getSelectedInquiryResponseId => _selectedInquiryResponseId;

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;

  Future<void> setIsPageLoading(bool value) async {
    _isPageLoading = value;
    notifyListeners();
  }

  List<String> get getSortedResponseTexts {
    return responseList.map((e) => e.responseText).toList()
      ..sort((a, b) => a.compareTo(b));
  }

  void updateResponseIdSelection(int responseId) {
    _selectedInquiryResponseId = responseId;
    notifyListeners();
  }

  Future<void> fetchResponsesByQuestion(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': questionModel.getSelectedInquiryQuestionId,
      'test_id': 0,
    };

    responseList = await _crudService.getJsonRecords<InquiryResponse>(
      context,
      'dbo.sproc_get_responses_with_attachments',
      params,
      (json) => InquiryResponse.fromJson(json),
    );

    notifyListeners();
  }

  Future<int> insertResponseByQuestion(
      BuildContext context, String? responseText) async {
    var userDetailsModel =  Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': questionModel.getSelectedInquiryQuestionId,
      'test_id': 0,
      'response_text': responseText ?? '',
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_response_by_question_or_test',
      params,
    );

    if (insertedId > 0) {
      await fetchResponsesByQuestion(context);
      notifyListeners();
    }
    return insertedId;
  }

  Future<void> fetchResponsesByTest(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': 0,
      'test_id': testModel.getSelectedTestId
    };


    responseList = await _crudService.getJsonRecords<InquiryResponse>(
      context,
      'dbo.sproc_get_responses_with_attachments',
      params,
      (json) => InquiryResponse.fromJson(json),
    );
    notifyListeners();
  }

  Future<int> insertResponseByTest(BuildContext context, String? responseText,
      {int? isAiMagicResponse = 0}) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);
    var testsModel = Provider.of<TestsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': 0,
      'test_id': testsModel.getSelectedTestId,
      'response_text': responseText ?? '',
      'last_updated_by': userDetailsModel.getUserMachineId,
      'is_ai_magic_response': isAiMagicResponse ?? 0,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_response_by_question_or_test',
      params,
    );

    if (insertedId > 0) {
      await fetchResponsesByTest(context);
      notifyListeners();
    }
    return insertedId;
  }

  Future<int> insertAttachmentByResponse(
      BuildContext context,
      String? s3FilePath,
      String fileName,
      String fileType,
      int fileSize) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'response_id': _selectedInquiryResponseId,
      'file_path': s3FilePath,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'created_by': userDetailsModel.getUserMachineId
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_attachments_by_response_id',
      params,
    );

    return insertedId;
  }

  Future<int> deleteResponse(BuildContext context, int responseId) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);

    var params = {
      'response_id': responseId,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_response',
      params,
    );

    return deletedId;
  }
}
