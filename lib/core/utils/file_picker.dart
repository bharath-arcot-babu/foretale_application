import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<FilePickerResult?> pickFileForChat() async {
  try {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
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
      withReadStream: !kIsWeb,
      withData: kIsWeb,
    );

    return filePickerResult; // could be null if user cancels
  } catch (e) {
    // Log or handle the error as needed
    return null;
  }
}
