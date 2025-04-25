import 'dart:convert';
import 'package:http/http.dart' as http;

class LambdaHelper {
  final String apiGatewayUrl;
  final Map<String, String> defaultHeaders;

  LambdaHelper({
    required this.apiGatewayUrl,
    this.defaultHeaders = const {},
  });

  /// Calls the Lambda function via API Gateway with a JSON payload.
  Future<Map<String, dynamic>> invokeLambda({required Map<String, dynamic> payload, Map<String, String>? headers,}) async {

    final uri = Uri.parse(apiGatewayUrl);

    final mergedHeaders = {
      'Content-Type': 'application/json',
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    try {
      final response = await http.post(
        uri,
        headers: mergedHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lambda call failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error invoking Lambda: $e');
    }
  }
}
