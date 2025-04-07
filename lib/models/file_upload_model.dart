class FileUpload {
  String fileName;
  String filePath;
  int fileSizeInBytes;
  String fileType;
  int rowCount;
  int columnCount;
  String uploadStatus;
  String errorMessage;

  FileUpload({
    this.fileName = '',
    this.filePath = '',
    this.fileSizeInBytes = 0,
    this.fileType = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.uploadStatus = '',
    this.errorMessage = '',
  });

  factory FileUpload.fromJson(Map<String, dynamic> map) {
    return FileUpload(
      fileName: map['file_name'] ?? '',
      filePath: map['file_path'] ?? '',
      fileSizeInBytes: map['file_size_in_bytes'] ?? 0,
      fileType: map['file_type'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
      uploadStatus: map['upload_status'] ?? '',
      errorMessage: map['error_message'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Upload('
           'fileName: "$fileName", '
           'filePath: "$filePath", '
           'fileSizeInBytes: $fileSizeInBytes, '
           'fileType: "$fileType", '
           'rowCount: $rowCount, '
           'columnCount: $columnCount, '
           'uploadStatus: "$uploadStatus", '
           'errorMessage: "$errorMessage")';
  }
}