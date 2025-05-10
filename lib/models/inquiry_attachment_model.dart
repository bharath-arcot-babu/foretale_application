class InquiryAttachment {
  int attachmentId;
  String filePath;
  String fileName;
  int fileSize;
  String fileType;
  String uploadedBy;
  String uploadedDate;

  InquiryAttachment({
    this.attachmentId = 0,
    this.filePath = '',
    this.fileName = '',
    this.fileSize = 0,
    this.fileType = '',
    this.uploadedBy = '',
    this.uploadedDate = '',
  });

  factory InquiryAttachment.fromJson(Map<String, dynamic> map) {
    return InquiryAttachment(
      attachmentId: map['attachment_id'] ?? 0,
      filePath: map['file_path'] ?? '',
      fileName: map['file_name'] ?? '',
      fileSize: map['file_size'] ?? 0,
      fileType: map['file_type'] ?? '',
      uploadedBy: map['uploaded_by'] ?? '',
      uploadedDate: map['uploaded_date'] ?? '',
    );
  }
}
