import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class LambdaHelper {
  final String apiGatewayUrl;

  LambdaHelper({required this.apiGatewayUrl});

  Future<Map<String, dynamic>> invokeLambda({required Map<String, dynamic> payload}) async {   
    try {
      final uri = Uri.parse(apiGatewayUrl);

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final jsonBody = jsonEncode(payload);

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        throw Exception('Lambda failed: ${response.statusCode} ${response.body}');
      }
    } on TimeoutException catch (e) {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: Please check your internet connection and try again.');
    } catch (e) {
      throw Exception('Error calling Lambda: $e');
    }
  }
}
