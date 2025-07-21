import 'dart:convert';

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class S3Service {
  Future<void> uploadFile(PlatformFile file, String storagePath) async {
    try {
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
      } catch (e) {
        throw Exception("Failed to create AWS file object: $e");
      }

      // Upload file
      try {
        await Amplify.Storage.uploadFile(
          localFile: awsFile,
          path: StoragePath.fromString('$storagePath/${file.name}'),
        ).result;
      } catch (e) {
        throw Exception("Failed to upload file to S3: $e");
      }
    } catch (e) {
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

  Future<void> uploadCsvStringToS3(String csvContent, String filename, String storagePath) async {
    final bytes = utf8.encode(csvContent);
    final awsFile = AWSFile.fromData(Uint8List.fromList(bytes), name: filename);

    await Amplify.Storage.uploadFile(
      localFile: awsFile,
      path: StoragePath.fromString('$storagePath/$filename'),
    ).result;

  }

}
