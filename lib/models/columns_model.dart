import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/file_upload_model.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:provider/provider.dart';

class TableColumns {
  final int columnId;
  final String category;
  final String columnName;
  final String simpleText;
  final String description;
  final String dataType;
  final String dataLength;
  final String primaryCompositeKey;

  TableColumns({
    required this.columnId,
    required this.category,
    required this.columnName,
    required this.simpleText,
    required this.description,
    required this.dataType,
    required this.dataLength,
    required this.primaryCompositeKey,
  });

  factory TableColumns.fromJson(Map<String, dynamic> json) {
    return TableColumns(
      columnId: json['column_id'] ?? 0,
      category: json['category'] ?? '',
      columnName: json['column_name'] ?? '',
      simpleText: json['simple_text'] ?? '',
      description: json['description'] ?? '',
      dataType: json['data_type'] ?? '',
      dataLength: json['data_length'] ?? '',
      primaryCompositeKey: json['primary_composite_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'column_id': columnId,
      'category': category,
      'column_name': columnName,
      'simple_text': simpleText,
      'description': description,
      'data_type': dataType,
      'data_length': dataLength,
      'primary_composite_key': primaryCompositeKey,
    };
  }
}

class ColumnsModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<TableColumns> _columnsList = [];
  List<TableColumns> get getColumnsList => _columnsList;

  List<FileUpload> _fileUploadSummary = [];
  List<FileUpload> get getFileUploadSummaryList => _fileUploadSummary;

  List<String> sourceFields = [];
  Map<String, String> destinationFieldMap = {};
  Map<String, String> technicalFieldMap = {};

  List<String> sourceFieldSampleValues = [];
  List<String> get getSourceFieldSampleValues => sourceFieldSampleValues;

  List<Map<String, dynamic>> sourceFieldInfo = [];
  Map<String, String> sourceFieldMap = {};

  Map<String, String?> columnMappings = {};
  Map<String, String?> get getColumnMappings => columnMappings;

  Map<String, String?> activeSelectedMappings = {};
  Map<String, String?> get getActiveSelectedMappings => activeSelectedMappings; 

  Future<void> fetchColumnsByTable(BuildContext context) async {
    var uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);


    final params = {
      'table_id': uploadSummaryModel.activeTableSelectionId,
      };

    _columnsList = await _crudService.getRecords<TableColumns>(
      context,
      'dbo.sproc_get_columns_by_table',
      params,
      (json) => TableColumns.fromJson(json),
    );

    destinationFieldMap = {
      for (var column in _columnsList) column.simpleText: column.description,
    };

    technicalFieldMap = {
      for(var column in _columnsList) column.simpleText: column.columnName,
    };

    notifyListeners();
  }

  Future<void> fetchColumnsCsvDetails(BuildContext context) async {
    var uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);

    final params = {
      'file_upload_id': uploadSummaryModel.activeFileUploadId,
    };


    _fileUploadSummary = await _crudService.getRecords<FileUpload>(
      context,
      'dbo.sproc_get_csv_details_by_file_upload',
      params,
      (json) => FileUpload.fromJson(json),
    );

    if (_fileUploadSummary.isNotEmpty &&  _fileUploadSummary.first.csvDetails.isNotEmpty) {
      final parsed = jsonDecode(_fileUploadSummary.first.csvDetails);

      final columnMetadata = parsed['column_metadata'] as List<dynamic>;
      
      // Build list of maps with name and metadata
      sourceFieldInfo = columnMetadata.map<Map<String, dynamic>>((column) {
        return {
          'name': column['name'].toString(),
          'metadata': {
            'type': column['metadata']['type'],
            'maxLength': column['metadata']['maxLength'],
            'sampleValues': (column['metadata']['sampleValues'] as List)
                .map((e) => e.toString())
                .toList(),
          }
        };
      }).toList();

      // Optional: extract just names if needed elsewhere
      sourceFields = sourceFieldInfo.map((e) => e['name'] as String).toList();

      if(_fileUploadSummary.first.columnMappings.isNotEmpty){
        Map<String, dynamic> parsedJson = jsonDecode(_fileUploadSummary.first.columnMappings);

        columnMappings = parsedJson.map(
          (key, value) => MapEntry(key, value as String?),
        );

      } else{
        columnMappings = {};
      }
    }

    notifyListeners();
  }

  Future<void> updateFileUpload(
      BuildContext context,
      String columnMappings,
  ) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);

    final params = {
      'file_upload_id': uploadSummaryModel.activeFileUploadId,
      'column_mapping': columnMappings,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    await _crudService.updateRecord(
      context,
      'dbo.sproc_update_file_upload',
      params,
    );

    notifyListeners();
  }
}
