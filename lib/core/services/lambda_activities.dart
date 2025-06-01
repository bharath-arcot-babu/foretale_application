import 'dart:convert';
import 'package:http/http.dart' as http;

class LambdaHelper {
  final String apiGatewayUrl;

  LambdaHelper({required this.apiGatewayUrl});

  Future<Map<String, dynamic>> invokeLambda({required Map<String, dynamic> payload}) async {

    final uri = Uri.parse(apiGatewayUrl);

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lambda failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calling Lambda: $e');
    }
  }
}
