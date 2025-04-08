import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/file_upload_model.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:provider/provider.dart';

class TableColumns {
  final int columnId;
  final String category;
  final String columnName;
  final String simpleText;
  final String description;
  final String dataType;
  final int dataLength;
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
      dataLength: json['data_length'] ?? 0,
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
  List<String> destinationFields = [];

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

    destinationFields = _columnsList.map((column) => column.simpleText).toList();

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

    if (_fileUploadSummary.isNotEmpty) {
      if(_fileUploadSummary.first.csvDetails.isNotEmpty){

        final parsed = jsonDecode(_fileUploadSummary.first.csvDetails);
        final columnMetadata = parsed['column_metadata'] as List<dynamic>;
        
        sourceFields = columnMetadata.map(
          (column) => column['name'].toString()
          ).toList();
      } 
    }

    notifyListeners();
  }
}
