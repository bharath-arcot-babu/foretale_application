import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class S3Service {
  Future<void> uploadFile(PlatformFile file, String storagePath) async {
    final awsFile = kIsWeb
        ? AWSFile.fromData(
            file.bytes!,
            name: file.name,
          )
        : AWSFile.fromStream(
            file.readStream!,
            size: file.size,
          );

    await Amplify.Storage.uploadFile(
      localFile: awsFile,
      path: StoragePath.fromString('$storagePath/${file.name}'),
    ).result;
  }


  // Delete a file from S3
  Future<void> deleteFile(String path) async {
    await Amplify.Storage.remove(
      path: StoragePath.fromString(path),
    ).result;
  }

  // Download a file from S3
  Future<void> downloadFile(String path) async {
    await Amplify.Storage.downloadFile(
      path: StoragePath.fromString(path),
      localFile: AWSFile.fromPath(path),
    ).result;
  }

  // Get the URL of a file
  Future<String?> getFileUrl(String path) async {
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(path),
      options: const StorageGetUrlOptions(
        pluginOptions: S3GetUrlPluginOptions(
          validateObjectExistence: true,
          expiresIn: Duration(minutes: 1),
        ),
      ),
    ).result;
    return result.url.toString();
  }
}
