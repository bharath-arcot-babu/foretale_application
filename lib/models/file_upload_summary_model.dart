//models
import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/file_upload_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:provider/provider.dart';

class UploadSummary {
  int tableId;
  String componentName;
  String tableName;
  String simpleText;
  String description;
  int rowCount;
  int columnCount;
  int overallUploadStatus;
  List<FileUpload> uploads;

  UploadSummary({
    this.tableId = 0,
    this.componentName = '',
    this.tableName = '',
    this.simpleText = '',
    this.description = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.overallUploadStatus = 0,
    this.uploads = const [],
  });

  factory UploadSummary.fromJson(Map<String, dynamic> map) {

    return UploadSummary(
      tableId: map['table_id'] ?? 0,
      componentName: map['component_name'] ?? '',
      tableName: map['table_name'] ?? '',
      simpleText: map['simple_text'] ?? '',
      description: map['description'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
      overallUploadStatus: map['overall_upload_status'] ?? 0,
      uploads: map.containsKey('uploads')
          ? List<FileUpload>.from(
              (map['uploads'] as List).map((x) => FileUpload.fromJson(x)))
          : [],
    );
  }

  @override
  String toString() {
    return 'UploadSummary('
           'tableId: $tableId, '
           'componentName: "$componentName", '
           'tableName: "$tableName", '
           'simpleText: "$simpleText", '
           'description: "$description", '
           'rowCount: $rowCount, '
           'columnCount: $columnCount, '
           'overallUploadStatus: "$overallUploadStatus", '
           'uploads: ${uploads.map((u) => u.toString()).toList()})';
  }
}

class UploadSummaryModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<UploadSummary> uploadSummaryList = [];
  List<UploadSummary> get getUploadSummaryList => uploadSummaryList;

  int activeTableSelectionId = 0;
  int get getActiveTableSelectionId => activeTableSelectionId;

  int activeFileUploadId = 0;
  int get getActiveFileUploadId => activeFileUploadId;

  String activeTableSelectionName = '';
  String get getActiveTableSelectionName => activeTableSelectionName;

  String activeFileUploadSelectionName = '';
  String get getActiveFileUploadSelectionName => activeFileUploadSelectionName;

  Future<void> fetchFileUploadsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      };

    uploadSummaryList = await _crudService.getJsonRecords<UploadSummary>(
      context,
      'dbo.sproc_get_project_upload_details',
      params,
      (json) => UploadSummary.fromJson(json),
    );

    notifyListeners();
  }

  Future<int> insertFileUpload(
      BuildContext context,
      String? s3FilePath,
      String fileName,
      String fileType,
      int fileSize,
      int rowCount,
      int columnCount,
      int tableId,
      String csvDetails,
      ) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'file_name': fileName,
      'file_path': s3FilePath,
      'file_type': fileType,
      'file_size_in_bytes': fileSize,
      'row_count': rowCount,
      'column_count': columnCount,
      'upload_status': 'Pending',
      'error_message': 'File has not been processed yet. Check back later.',
      'created_by': userDetailsModel.getUserMachineId,
      'table_id': tableId,
      'csv_details': csvDetails
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_file_upload',
      params,
    );

    return insertedId;
  }

  Future<void> updateFileUpload(
      BuildContext context,
      int fileUploadId,
      String uploadStatus,
      String errorMessage) async {
    var params = {
      'file_upload_id': fileUploadId,
      'upload_status': uploadStatus,
      'error_message': errorMessage,
    };

    await _crudService.updateRecord(
      context,
      'dbo.sproc_update_file_upload',
      params,
    );
  }

  Future<void> deleteFileUpload(BuildContext context, int fileUploadId) async {
    UserDetailsModel userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    var params = {
      'file_upload_id': fileUploadId,
      'deleted_by': userDetailsModel.getUserMachineId,
    };

    await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_file_upload',
      params,
    );
  }
}

