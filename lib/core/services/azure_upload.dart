import 'package:http/http.dart' as http;

Future<bool> uploadFileToAzure({
  required List<int> fileBytes,
  required String storageAccount,
  required String containerName,
  required String blobName,
  required String sasToken,  // Shared Access Signature token for secure access
}) async {
  try{
    final uri = Uri.parse(
        'https://$storageAccount.blob.core.windows.net/$containerName/$blobName?$sasToken');
    
      final request = http.Request("PUT", uri)
        ..headers.addAll({
          'x-ms-blob-type': 'BlockBlob',  // Required header for Azure
          'Content-Type': 'application/octet-stream',
        })
        ..bodyBytes = fileBytes;

      final response = await request.send();
      
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
  } catch(e){
    return false;
  }
}
