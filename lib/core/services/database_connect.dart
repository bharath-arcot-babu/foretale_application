import 'dart:convert';
import 'package:foretale_application/db_api_config.dart';
import 'package:http/http.dart' as http;

class FlaskApiService {
  late String baseUrl;

  FlaskApiService(){
    baseUrl = DatabaseApiConfig.baseApIUrl;
  }

  Future<dynamic> insertRecord(String procedureName, Map<String, dynamic> params) async {
    final response = await _post('/insert_record', {
      "procedure_name": procedureName,
      "params": params,
    });
    return _handleResponse(response);
  }

  Future<dynamic> updateRecord(String procedureName, Map<String, dynamic> params) async {
    final response = await _put('/update_record', {
      "procedure_name": procedureName,
      "params": params,
    });
    return _handleResponse(response);
  }

  Future<dynamic> deleteRecord(String procedureName, Map<String, dynamic> params) async {
    final response = await _delete('/delete_record', {
      "procedure_name": procedureName,
      "params": params,
    });
    return _handleResponse(response);
  }

  Future<dynamic> readRecord(String procedureName, Map<String, dynamic> params) async {
    final uri = Uri.parse('$baseUrl/read_record').replace(queryParameters: {
      "procedure_name": procedureName,
      ...params.map((key, value) => MapEntry(key, value.toString())),
    });

    final response = await http.get(uri);
    return _handleResponse(response);
  }

  Future<dynamic> readJsonRecord(String procedureName, Map<String, dynamic> params) async {

    final uri = Uri.parse('$baseUrl/read_json_record').replace(queryParameters: {
      "procedure_name": procedureName,
      ...params.map((key, value) => MapEntry(key, value.toString())),
    });

    final response = await http.get(
      uri,
      headers: {"Accept": "application/json"});

    return _handleResponse(response);
  }

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    return http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),  // Send the params as part of the body
    );
  }

  Future<http.Response> _put(String endpoint, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> _delete(String endpoint, Map<String, dynamic> body) {
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      return jsonDecode(body);
    } else {
      throw Exception(
        'Request failed with status: $statusCode, body: $body',
      );
    }
  }
}
