import 'package:flutter/material.dart';
import 'package:foretale_application/config_s3.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/core/services/websocket_service.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:provider/provider.dart';

enum CustomCellType {
  text,
  number,
  badge,
  avatar,
  action,
  checkbox,
  dropdown,
  date,
  categorical,
}

class TableColumn{
  final String tableName;
  final String columnName;
  final String columnLabel;
  final String columnDescription;
  final String dataType;
  final String cellType;
  final bool isVisible;
  final bool isFeedbackColumn;

  TableColumn({
    this.tableName = '',
    this.columnName = '',
    this.columnLabel = '',
    this.columnDescription = '',
    this.dataType = '',
    this.cellType = '',
    this.isVisible = false,
    this.isFeedbackColumn = false,
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      tableName: json['table_name'] ?? '',
      columnName: json['column_name'] ?? '',
      columnLabel: json['column_alias'] ?? '',
      columnDescription: json['column_description'] ?? '',
      dataType: json['data_type'] ?? '',
      cellType: json['cell_type'] ?? '',
      isVisible: json['is_visible'] ?? false,
      isFeedbackColumn: json['is_feedback_column'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_name': tableName,
      'column_name': columnName,
      'column_label': columnLabel,
      'column_description': columnDescription,
      'data_type': dataType,
      'cell_type': cellType,
      'is_visible': isVisible,
      'is_feedback_column': isFeedbackColumn,
    };
  }
}

class FeedbackData{
  final int feedbackId;
  final int projectId;
  final int testId;
  final String tableReference;
  final String hashKey;
  final String feedbackStatus;
  final String feedbackCategory;
  final String severityRating;
  final bool isFinal;
  final String lastUpdatedBy;
  final String lastUpdatedOn;
  final bool isSelected;

  FeedbackData({
    this.feedbackId = 0,
    this.projectId = 0,
    this.testId = 0,
    this.tableReference = '',
    this.hashKey = '',
    this.feedbackStatus = '',
    this.feedbackCategory = '',
    this.severityRating = '',
    this.isFinal = false,
    this.lastUpdatedBy = '',
    this.lastUpdatedOn = '',
    this.isSelected = false,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      feedbackId: json['feedback_id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      testId: json['test_id'] ?? 0,
      tableReference: json['table_reference'] ?? '',
      hashKey: json['hash_key'] ?? '',
      feedbackStatus: json['feedback_status'] ?? '',
      feedbackCategory: json['feedback_category'] ?? '',
      severityRating: json['severity_rating'] ?? '',
      isFinal: json['is_final'] ?? false,
      lastUpdatedBy: json['last_updated_by'] ?? '',
      lastUpdatedOn: json['last_updated_on'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class ResultModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredTableData = [];
  List<FeedbackData> feedbackData = [];
  List<TableColumn> tableColumnsList = [];
  List<GenericGridColumn> genericGridColumns = [];
  int selectedFeedbackId = 0;

  Future<void> fetchResultMetadata(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
    };

    tableColumnsList = await _crudService.getRecords<TableColumn>(
      context,
      'dbo.sproc_get_result_metadata',
      params,
      (json) => TableColumn.fromJson(json),
    );

    // Clear existing columns before adding new ones
    genericGridColumns.clear();
    
    for (var element in tableColumnsList) {
      genericGridColumns.add(GenericGridColumn(
        columnName: element.columnName,
        label: element.columnLabel,
        cellType: CustomCellType.values.byName(element.cellType),
        visible: element.isVisible ,
        allowSorting: (element.cellType == 'dropdown' || element.cellType == 'checkbox') ? false : true,
        allowFiltering: (element.cellType == 'dropdown' || element.cellType == 'checkbox') ? false : true,
      ));
    }
  }

  Future<void> fetchResultData(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
    };

    tableData = await _crudService.getRecords<Map<String, dynamic>>(
      context,
      'dbo.sproc_get_result_data',
      params,
      (json) => json,
    );
  }

  Future<int> insertFlaggedTransaction(BuildContext context, Test test, List<Map<String, dynamic>> transactions) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.addRecord(
        context,
        'dbo.sproc_insert_update_feedback',
        params,
      );
    }

    return 1;
  }

  Future<int> updateFeedbackStatus(BuildContext context, Test test, List<Map<String, dynamic>> transactions, String selectedValue) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'feedback_status': selectedValue,
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.updateRecord(
        context,
        'dbo.sproc_update_feedback_status',
        params,
      );
    }

    return 1;
  }

  Future<int> updateFeedbackCategory(BuildContext context, Test test, List<Map<String, dynamic>> transactions, String selectedValue) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'feedback_category': selectedValue,
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.updateRecord(
        context,
        'dbo.sproc_update_feedback_category',
        params,
      );
    }

    return 1;
  }

  Future<int> updateSeverityRating(BuildContext context, Test test, List<Map<String, dynamic>> transactions, String selectedValue) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId, 
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'severity_rating': selectedValue,
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.updateRecord(
        context,
        'dbo.sproc_update_feedback_severity_rating',
        params,
      );
    }

    return 1;
  }

  Future<int> updateIsFinal(BuildContext context, Test test, List<Map<String, dynamic>> transactions, bool selectedValue) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'is_final': selectedValue,
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.updateRecord(
        context,
        'dbo.sproc_update_feedback_is_final',
        params,
      );
    }

    return 1;
  }

  Future<int> deleteFlaggedTransaction(BuildContext context, Test test, List<Map<String, dynamic>> transactions) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    for (var transaction in transactions) {
      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
        'hash_key': transaction['hash_key'],
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      await _crudService.deleteRecord(
        context,
        'dbo.sproc_delete_feedback',
        params,
      );
    }

    return 1;
  }

  Future<void> fetchFeedbackData(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
    };

    feedbackData = await _crudService.getRecords<FeedbackData>(
      context,
      'dbo.sproc_get_active_feedback',
      params,
      (json) => FeedbackData.fromJson(json),
    );
    
  }

  void mergeFeedbackData() {
   for(var transaction in tableData){
    final feedback = feedbackData.firstWhere(
      (feedback) => feedback.hashKey == transaction['hash_key'],
      orElse: () => FeedbackData(),
    );
    if(feedback.feedbackId != 0){
      //transaction.addAll(feedback);
      transaction['is_selected'] = feedback.isSelected;
      transaction['feedback_id'] = feedback.feedbackId;
      transaction['table_reference'] = feedback.tableReference;
      //transaction['hash_key'] = feedback.hashKey;
      transaction['feedback_status'] = feedback.feedbackStatus;
      transaction['feedback_category'] = feedback.feedbackCategory;
      transaction['severity_rating'] = feedback.severityRating;
      transaction['is_final'] = feedback.isFinal;
      transaction['last_updated_by'] = feedback.lastUpdatedBy;
      transaction['last_updated_on'] = feedback.lastUpdatedOn;

    } else {
      transaction['is_selected'] = false;
      transaction['feedback_id'] = null;
      transaction['table_reference'] = null;
      //transaction['hash_key'] = null;
      transaction['feedback_status'] = null;
      transaction['feedback_category'] = null;
      transaction['severity_rating'] = null;
      transaction['is_final'] = null;
      transaction['last_updated_by'] = null;
      transaction['last_updated_on'] = null;
    }
   }
   filteredTableData = tableData;
   
  }

  Future<void> updateDataGrid(BuildContext context, Test test) async{
    await fetchResultMetadata(context, test);
    await fetchResultData(context, test);
    await fetchFeedbackData(context, test);
    mergeFeedbackData();
    notifyListeners();
  }

  void updateSelectedTransactions(bool showFlaggedTransactions){

    if(showFlaggedTransactions){
      filteredTableData = tableData.where((item) => item['is_selected'] == true).toList();
    } else {
      filteredTableData = tableData;
    }

    notifyListeners();
  }

  void updateSelectedFeedback(int feedbackId){
    selectedFeedbackId = feedbackId;
    notifyListeners();
  }

  @override
  int get selectedId => selectedFeedbackId;

  @override
  int getSelectedId(BuildContext context) => selectedFeedbackId;

  @override
  Future<int> insertResponse(BuildContext context, String responseText) async {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.insertResponseByReference(context, selectedFeedbackId, 'feedback', responseText);
  }

  @override
  Future<void> fetchResponses(BuildContext context) async {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    await inquiryResponseModel.fetchResponsesByReference(context, selectedFeedbackId, 'feedback');
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseQuestionAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  Future<void> sendMessage(BuildContext context, String message, WebSocketService? webSocketService) async {
    // Not implemented for result model
    return;
  }

  @override
  String getDrivingModelName(BuildContext context) => 'Feedback';

  @override
  String getWebSocketUrl(BuildContext context) => 'ws://alb-fastapi-agent-423791108.us-east-1.elb.amazonaws.com/wsqg';

  @override
  Future<int> updateConfig(BuildContext context, Map<dynamic, dynamic> fullState, {bool finalUpdate = false}) async{
    return 0;
  }
}
