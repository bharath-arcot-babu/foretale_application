import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/datagrids/sfdg_generic_grid.dart';
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

class ResultModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<TableColumn> tableColumnsList = [];
  List<Map<String, dynamic>> tableData = [];

  List<GenericGridColumn> genericGridColumns = [];

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
        cellType: element.cellType == 'number' ? GenericGridCellType.number : GenericGridCellType.text,
      ));
    }
    
    notifyListeners();
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

    notifyListeners();
  }
}