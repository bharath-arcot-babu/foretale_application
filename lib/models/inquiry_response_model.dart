//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/utils/handling_crud.dart';

class InquiryResponse {
  int responseId;
  int projectId;
  int questionId;
  String responseText;
  String responseBy;
  String responseDate;
  String responseByMachineId;
  List<InquiryAttachment> attachments; // List of attachments

  InquiryResponse({
    this.responseId = 0,
    this.projectId = 0,
    this.questionId = 0,
    this.responseText = '',
    this.responseBy = '',
    this.responseDate = '',
    this.responseByMachineId = '',
    this.attachments = const [], // Initialize with an empty list
  });

  factory InquiryResponse.fromJson(Map<String, dynamic> map) {
    return InquiryResponse(
      responseId: map['response_id'] ?? 0,
      projectId: map['project_id'] ?? 0,
      questionId: map['question_id'] ?? 0,
      responseText: map['response_text'] ?? '',
      responseBy: map['response_by'] ?? '',
      responseDate: map['response_date'] ?? '',
      responseByMachineId: map['response_by_machine_id'] ?? '',
      attachments: map.containsKey('attachments') 
          ? List<InquiryAttachment>.from(
              (map['attachments'] as List).map((x) => InquiryAttachment.fromJson(x)))
          : [],
    );
  }

  @override
  String toString() {
    return 'InquiryResponse(responseId: $responseId, '
           'projectId: $projectId, '
           'questionId: $questionId, '
           'responseText: "$responseText", '
           'responseBy: "$responseBy", '
           'responseDate: "$responseDate", '
           'responseByMachineId: "$responseByMachineId", '
           'attachments: ${attachments.map((a) => a.toString()).toList()})';
  }
}


class InquiryAttachment {
  int attachmentId;
  String filePath;
  String fileName;
  int fileSize;
  String fileType;
  String uploadedBy;
  String uploadedDate;

  InquiryAttachment({
    this.attachmentId = 0,
    this.filePath = '',
    this.fileName = '',
    this.fileSize = 0,
    this.fileType = '',
    this.uploadedBy = '',
    this.uploadedDate = '',
  });

  factory InquiryAttachment.fromJson(Map<String, dynamic> map) {
    return InquiryAttachment(
      attachmentId: map['attachment_id'] ?? 0,
      filePath: map['file_path'] ?? '',
      fileName: map['file_name'] ?? '',
      fileSize: map['file_size'] ?? 0,
      fileType: map['file_type'] ?? '',
      uploadedBy: map['uploaded_by'] ?? '',
      uploadedDate: map['uploaded_date'] ?? '',
    );
  }
}


class InquiryResponseModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<InquiryResponse> responseList = [];
  List<InquiryResponse> get getResponseList => responseList;

  int _selectedInquiryResponseId = 0;
  int get getSelectedInquiryResponseId => _selectedInquiryResponseId;

  void updateResponseIdSelection(int responseId ){
    _selectedInquiryResponseId = responseId;
    notifyListeners();
  }

  Future<void> fetchResponsesByQuestion(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    final params = {
      'selected_project_id': projectDetailsModel.getActiveProjectId,
      'question_id': questionModel.getSelectedInquiryQuestionId
      };

    responseList = await _crudService.getJsonRecords<InquiryResponse>(
      context,
      'dbo.sproc_get_responses_with_attachments',
      params,
      (json) => InquiryResponse.fromJson(json),
    );

    notifyListeners();
  }

  Future<int> insertResponseByQuestion(BuildContext context, String? responseText) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    var params = {
      'selected_project_id': projectDetailsModel.getActiveProjectId,
      'question_id': questionModel.getSelectedInquiryQuestionId,
      'response_text': responseText??'',
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_response_by_question',
      params,
    );

    if(insertedId>0){
      await fetchResponsesByQuestion(context);
      notifyListeners();
    }
    return insertedId;
  }

  Future<int> insertAttachmentByResponse(BuildContext context, String? s3FilePath, String fileName, String fileType, int fileSize) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    var params = {
      'selected_project_id': projectDetailsModel.getActiveProjectId,
      'question_id': questionModel.getSelectedInquiryQuestionId,
      'response_id': _selectedInquiryResponseId,
      'file_path': s3FilePath,
      'file_name': fileName,
      'fiel_type': fileType,
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
}
