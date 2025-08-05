import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/core/services/http_nonstreaming_service.dart';
import 'dart:developer' as developer;

/// Utility class for handling Question & Answer operations with LLM
/// 
/// This class provides methods to send questions with context to an LLM
/// and receive structured responses.
class QaUtils {
  /// The question to be answered by the LLM
  final String question;
  
  /// The context information to help answer the question
  final String context;

  /// Creates a QaUtils instance with the provided question and context
  /// 
  /// Throws [ArgumentError] if question or context is empty
  QaUtils({
    required String question, 
    required String context
  }) : question = question.trim(),
       context = context.trim() {
    if (question.isEmpty) {
      throw ArgumentError('Question cannot be empty');
    }
    if (context.isEmpty) {
      throw ArgumentError('Context cannot be empty');
    }
    if (question.length > 1000) {
      throw ArgumentError('Question too long (max 1000 characters)');
    }
  }

  /// Builds the prompt payload for the LLM API
  /// Returns a map containing the question and context
  Map<String, dynamic> buildPrompt() {
    return {
      'question': question,
      'context': context,
    };
  }

  /// Sends the question and context to the LLM and returns the response
  /// Returns a map containing the LLM's response or error information
  /// Throws [ArgumentError] if inputs are invalid
  Future<Map<String, dynamic>> getLLMAnswerToQuestion() async {
    try {
      final nonStreamingService = HttpNonStreamingService(HttpNonStreamingForQa.nonStreamingQa,timeout: const Duration(seconds: 60));

      final response = await nonStreamingService.post('', body: buildPrompt());

      if (response.isSuccess) {
        final messageJson = response.parseAiResponse();
        return messageJson ?? {};
      } else {
        // Log the error for debugging
        print('Q&A API Error: ${response.error} (Status: ${response.statusCode})');
        return {'error': response.error, 'statusCode': response.statusCode};
      }
    } catch (e) {
      developer.log('Q&A Exception: $e', name: 'QaUtils');
      return {'error': 'Network or processing error: $e', 'statusCode': 500};
    }
  }
}