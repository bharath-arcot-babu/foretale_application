import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickFileForChat() async {
  try {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'png',
        'svg',
        'pdf',
        'csv',
        'msg',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
      allowMultiple: true,
      withReadStream: true,
      withData: false,
    );

    return filePickerResult; // could be null if user cancels
  } catch (e) {
    // Log or handle the error as needed
    print("Error picking file: $e");
    return null;
  }
}
