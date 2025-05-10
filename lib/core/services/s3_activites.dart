import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class S3Service {
  Future<void> uploadFile(PlatformFile file, String storagePath) async {
    try {
      print("1. Starting upload for file: ${file.name} to $storagePath");

      // Validate file
      if (file.size == 0) {
        throw Exception("File ${file.name} is empty");
      }

      // Validate storage path
      if (storagePath.isEmpty) {
        throw Exception("Storage path cannot be empty");
      }

      // Create AWS file object
      AWSFile? awsFile;
      try {
        awsFile = kIsWeb
            ? AWSFile.fromData(
                file.bytes!,
                name: file.name,
              )
            : AWSFile.fromStream(
                file.readStream!,
                size: file.size,
              );
        print("2. Created AWS file object for: ${file.name}");
      } catch (e) {
        print("Error creating AWS file object: $e");
        throw Exception("Failed to create AWS file object: $e");
      }

      // Upload file
      try {
        print("3. Starting S3 upload for: ${file.name}");
        await Amplify.Storage.uploadFile(
          localFile: awsFile,
          path: StoragePath.fromString('$storagePath/${file.name}'),
        ).result;
        print("4. Successfully uploaded file: ${file.name}");
      } catch (e) {
        print("Error during S3 upload: $e");
        throw Exception("Failed to upload file to S3: $e");
      }
    } catch (e) {
      print("Error in uploadFile: $e");
      throw Exception("Failed to upload file ${file.name}: $e");
    }
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
