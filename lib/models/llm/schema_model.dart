import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';

class Tables {
  String tables;
  String tableDescription;

  Tables({
    this.tables = '',
    this.tableDescription = '',
  });

  factory Tables.fromJson(Map<String, dynamic> json) {
    return Tables(
      tables: json['tables'] ?? '',
      tableDescription: json['tableDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tables': tables,
      'tableDescription': tableDescription,
    };
  }
}

class Columns {
  String tables;
  String columns;
  String colDescription;
  String sampleData;

  Columns({
    this.tables = '',
    this.columns = '',
    this.colDescription = '',
    this.sampleData = '',
  });

  factory Columns.fromJson(Map<String, dynamic> json) {
    return Columns(
      tables: json['tables'] ?? '',
      columns: json['columns'] ?? '',
      colDescription: json['colDescription'] ?? '',
      sampleData: json['sampleData'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tables': tables,
      'columns': columns,
      'colDescription': colDescription,
      'sampleData': sampleData,
    };
  }
}


class SchemaModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<Tables> tables = [];
  List<Tables> get getTables => tables;
  

  Future<void> fetchTables(BuildContext context, String tableList) async {

    final params = {
      'table_list': tableList
    };

    final result = await _crudService.getRecords<Tables>(
      context,
      'dbo.sproc_get_schema_tables',
      params,
      (json) => Tables.fromJson(json),
    );

    tables = result;

    notifyListeners();
  }
  
}