//models
import 'package:foretale_application/models/file_upload_model.dart';

class UploadSummary {
  String componentName;
  String tableName;
  int rowCount;
  int columnCount;
  String overallUploadStatus;
  List<FileUpload> uploads;

  UploadSummary({
    this.componentName = '',
    this.tableName = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.overallUploadStatus = '',
    this.uploads = const [],
  });

  factory UploadSummary.fromJson(Map<String, dynamic> map) {
    return UploadSummary(
      componentName: map['component_name'] ?? '',
      tableName: map['table_name'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
      overallUploadStatus: map['overall_upload_status'] ?? '',
      uploads: map.containsKey('uploads')
          ? List<FileUpload>.from(
              (map['uploads'] as List).map((x) => FileUpload.fromJson(x)))
          : [],
    );
  }

  @override
  String toString() {
    return 'UploadComponent('
           'componentName: "$componentName", '
           'tableName: "$tableName", '
           'rowCount: $rowCount, '
           'columnCount: $columnCount, '
           'overallUploadStatus: "$overallUploadStatus", '
           'uploads: ${uploads.map((u) => u.toString()).toList()})';
  }
}

