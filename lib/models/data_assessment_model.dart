import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:provider/provider.dart';

class DataQualityProfile {
  int dpqId;
  int tableId;
  int columnId;
  String dataType;
  String columnName;
  int nullCount;
  int distinctCount;
  String minValue;
  String maxValue;
  double avgValue;
  double stdDev;
  int length;
  int duplicateCount;
  String sampleValues;
  DateTime createdAt;
  int nonCompliantCount;
  String columnCategory;

  DataQualityProfile({
    this.dpqId = 0,
    this.tableId = 0,
    this.columnId = 0,
    this.dataType = '',
    this.columnName = '',
    this.nullCount = 0,
    this.distinctCount = 0,
    this.minValue = '',
    this.maxValue = '',
    this.avgValue = 0.0,
    this.stdDev = 0.0,
    this.length = 0,
    this.duplicateCount = 0,
    this.sampleValues = '',
    DateTime? createdAt,
    this.nonCompliantCount = 0,
    this.columnCategory = '',
  }) : createdAt = createdAt ?? DateTime.now();

  factory DataQualityProfile.fromJson(Map<String, dynamic> map) {
    return DataQualityProfile(
      dpqId: map['dpq_id'] ?? 0,
      tableId: map['table_id'] ?? 0,
      columnId: map['column_id'] ?? 0,
      dataType: map['data_type'] ?? '',
      columnName: map['column_name'] ?? '',
      nullCount: map['null_count'] ?? 0,
      distinctCount: map['distinct_count'] ?? 0,
      minValue: map['min_value']?.toString() ?? '',
      maxValue: map['max_value']?.toString() ?? '',
      avgValue: (map['avg_value'] ?? 0).toDouble(),
      stdDev: (map['std_dev'] ?? 0).toDouble(),
      length: map['length'] ?? 0,
      duplicateCount: map['duplicate_count'] ?? 0,
      sampleValues: map['sample_values'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      nonCompliantCount: map['non_compliant_count'] ?? 0,
      columnCategory: map['column_category'] ?? '',
    );
  }
}

class DataQualityProfileModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<DataQualityProfile> dataQualityProfileList = [];
  List<DataQualityProfile> get getDataQualityProfileList => dataQualityProfileList;

  Future<void> fetchDataQualityRepByTable(BuildContext context) async {
    var uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);

    final params = {
      'table_id': uploadSummaryModel.getActiveTableSelectionId,
      };

    dataQualityProfileList = await _crudService.getRecords<DataQualityProfile>(
      context,
      'dbo.sproc_get_data_quality_by_table_id',
      params,
      (json) => DataQualityProfile.fromJson(json),
    );

    notifyListeners();
  }
}