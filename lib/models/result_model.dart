import 'package:flutter/material.dart';
import 'package:foretale_application/config_s3.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:provider/provider.dart';

class TableColumn{
  final String tableName;
  final String columnName;
  final String columnLabel;
  final String columnDescription;
  final String dataType;
  final String cellType;

  TableColumn({
    this.tableName = '',
    this.columnName = '',
    this.columnLabel = '',
    this.columnDescription = '',
    this.dataType = '',
    this.cellType = '',
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      tableName: json['table_name'] ?? '',
      columnName: json['column_name'] ?? '',
      columnLabel: json['column_alias'] ?? '',
      columnDescription: json['column_description'] ?? '',
      dataType: json['data_type'] ?? '',
      cellType: json['cell_type'] ?? '',
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
    };
  }
}

class ResultModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();
  List<TableColumn> tableColumnsList = [];
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredTableData = [];
  List<Map<String, dynamic>> feedbackData = [];
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
        cellType: GenericGridCellType.values.byName(element.cellType)
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

    feedbackData = await _crudService.getRecords<Map<String, dynamic>>(
      context,
      'dbo.sproc_get_active_feedback',
      params,
      (json) => json,
    );
    
  }

  void mergeFeedbackData() {
   for(var transaction in tableData){
    final feedback = feedbackData.firstWhere(
      (feedback) => feedback['hash_key'] == transaction['hash_key'],
      orElse: () => {},
    );
    if(feedback.isNotEmpty){
      //transaction.addAll(feedback);
      transaction['is_selected'] = true;
      transaction['feedback_id'] = feedback['feedback_id'];

    } else {
      transaction['is_selected'] = false;
      transaction['feedback_id'] = null;
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
}