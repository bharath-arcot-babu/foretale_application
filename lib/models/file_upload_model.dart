class FileUpload {
  int fileUploadId;
  String fileName;
  String filePath;
  int fileSizeInBytes;
  String fileType;
  int rowCount;
  int columnCount;
  int uploadStatus;
  String errorMessage;
  String csvDetails;

  FileUpload({
    this.fileUploadId = 0,
    this.fileName = '',
    this.filePath = '',
    this.fileSizeInBytes = 0,
    this.fileType = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.uploadStatus = 0,
    this.errorMessage = '',
    this.csvDetails = '',
  });

  factory FileUpload.fromJson(Map<String, dynamic> map) {

    return FileUpload(
      fileUploadId: map['file_upload_id'] ?? 0,
      fileName: map['file_name'] ?? '',
      filePath: map['file_path'] ?? '',
      fileSizeInBytes: map['file_size_in_bytes'] ?? 0,
      fileType: map['file_type'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
      uploadStatus: map['upload_status'] ?? 0,
      errorMessage: map['error_message'] ?? '',
      csvDetails: map['csv_details'] ?? '',
    );
  }
}