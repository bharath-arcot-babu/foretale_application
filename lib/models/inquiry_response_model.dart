import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';

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
  List<InquiryResponse> responseList = [];
  List<InquiryResponse> get getResponseList => responseList;

  int _selectedInquiryResponseId = 0;
  int get getSelectedInquiryResponseId => _selectedInquiryResponseId;

  void updateResponseIdSelection(int responseId ){
    _selectedInquiryResponseId = responseId;
    notifyListeners();
  }

  Future<void> fetchResponsesByQuestion(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    
    try {
      // Ensuring user ID is available.
      if (userDetailsModel.getUserMachineId == null) {
        SnackbarMessage.showErrorMessage(context, "User has not logged in. Please login again.");
        responseList = [];
        return;
      }

      final params = {
        'selected_project_id': projectDetailsModel.getActiveProjectId,
        'question_id': questionModel.getSelectedInquiryQuestionId
        };

      var jsonResponse = await FlaskApiService().readJsonRecord('dbo.sproc_get_responses_with_attachments', params);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        responseList = data.map((json) {
              try {
                return InquiryResponse.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<InquiryResponse>()
            .toList()??[];   
      } else {
        responseList = [];
      }
    } catch (e, error_stack_trace) {
      String errMessage = SnackbarMessage.extractErrorMessage(e.toString());

      if (errMessage != 'NOT_FOUND') {
        SnackbarMessage.showErrorMessage(context, errMessage);
      } else {
        // Showing a more detailed error message with logging.
        SnackbarMessage.showErrorMessage(
          context,
          'Unable to get the response list.',
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: error_stack_trace.toString(),
          errorSource: 'inquiry_response_model.dart',
          severityLevel: 'Critical',
          requestPath: 'readRecord',
        );
      }
      responseList = [];
    } finally {
      notifyListeners();
    }
  }

  Future<int> insertResponseByQuestion(BuildContext context, String? responseText) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    try {
      var params = {
        'selected_project_id': projectDetailsModel.getActiveProjectId,
        'question_id': questionModel.getSelectedInquiryQuestionId,
        'response_text': responseText??'',
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_response_by_question', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      if(insertedId>0){
        await fetchResponsesByQuestion(context);
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
              'Unable to update the response.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'inquiry_response_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }

  Future<int> insertAttachmentByResponse(BuildContext context, String? s3FilePath, String fileName, String fileType, int fileSize) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);

    try {
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

      var jsonResponse = await FlaskApiService().insertRecord('dbo.sproc_insert_attachments_by_response_id', params);
      int insertedId = int.parse(jsonResponse['data'][0]['inserted_id'].toString());

      return insertedId;
    } catch (e, error_stack_trace) {
        String errMessage = SnackbarMessage.extractErrorMessage(e.toString());
        if (errMessage != 'NOT_FOUND') {
          SnackbarMessage.showErrorMessage(context, errMessage);
        } else {
            SnackbarMessage.showErrorMessage(
              context,
              'Unable to update the attachment.',
              logError: true,
              errorMessage: e.toString(),
              errorStackTrace: error_stack_trace.toString(),
              errorSource: 'inquiry_response_model.dart',
              severityLevel: 'Critical',
              requestPath: 'insertRecord',
            );
        }
        return 0;
    }
  }
}
