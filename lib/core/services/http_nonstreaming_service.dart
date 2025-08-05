import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class HttpNonStreamingService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  HttpNonStreamingService(
    this.baseUrl, {
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.timeout = const Duration(seconds: 30),
  });

  /// Make a GET request
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Make a POST request
  Future<HttpResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'POST',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Make a PUT request
  Future<HttpResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'PUT',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Make a DELETE request
  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'DELETE',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Make a PATCH request
  Future<HttpResponse> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'PATCH',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Internal method to make HTTP requests
  Future<HttpResponse> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // Build the full URL
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // Merge headers
      final requestHeaders = Map<String, String>.from(defaultHeaders);
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Prepare request body
      String? requestBody;
      if (body != null) {
        requestBody = jsonEncode(body);
      }

      // Make the request
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        case 'PATCH':
          response = await http
              .patch(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Parse response
      return _parseResponse(response);
    } on TimeoutException {
      return HttpResponse.error(
        'Request timed out after ${timeout.inSeconds} seconds',
        statusCode: 408,
      );
    } on http.ClientException catch (e) {
      return HttpResponse.error(
        'Network error: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return HttpResponse.error(
        'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Parse HTTP response
  HttpResponse _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // Check if response is successful
    if (statusCode >= 200 && statusCode < 300) {
      try {
        // Try to parse as JSON
        final data = jsonDecode(body);
        return HttpResponse.success(data, statusCode: statusCode);
      } catch (e) {
        // Return as plain text if JSON parsing fails
        return HttpResponse.success(body, statusCode: statusCode);
      }
    } else {
      // Handle error response
      String errorMessage;
      try {
        final errorData = jsonDecode(body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? body;
      } catch (e) {
        errorMessage = body.isNotEmpty ? body : 'HTTP $statusCode';
      }
      
      return HttpResponse.error(
        errorMessage,
        statusCode: statusCode,
      );
    }
  }
}

/// Represents an HTTP response
class HttpResponse {
  final bool isSuccess;
  final dynamic data;
  final String? error;
  final int statusCode;
  final Map<String, String>? headers;

  HttpResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    required this.statusCode,
    this.headers,
  });

  /// Create a successful response
  factory HttpResponse.success(
    dynamic data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return HttpResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
      headers: headers,
    );
  }

  /// Create an error response
  factory HttpResponse.error(
    String error, {
    int statusCode = 0,
    Map<String, String>? headers,
  }) {
    return HttpResponse._(
      isSuccess: false,
      error: error,
      statusCode: statusCode,
      headers: headers,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'HttpResponse.success(statusCode: $statusCode, data: $data)';
    } else {
      return 'HttpResponse.error(statusCode: $statusCode, error: $error)';
    }
  }

  /// Parses AI response that contains markdown-wrapped JSON
  Map<String, dynamic>? parseAiResponse() {
    if (!isSuccess || data == null) {
      return null;
    }

    final responseData = data as Map<String, dynamic>;
    final messageString = responseData['message'] as String?;
    
    if (messageString == null) {
      return null;
    }

    // Remove markdown code block markers
    String cleanMessage = messageString;
    if (cleanMessage.startsWith('```json')) {
      cleanMessage = cleanMessage.substring(7); // Remove '```json'
    }
    if (cleanMessage.endsWith('```')) {
      cleanMessage = cleanMessage.substring(0, cleanMessage.length - 3); // Remove '```'
    }
    
    // Parse the JSON string
    final parsedData = jsonDecode(cleanMessage.trim());
    return parsedData as Map<String, dynamic>;

  }
} 