import 'dart:convert';
import 'package:foretale_application/config_llm_model_selection.dart';
import 'package:foretale_application/config_llm_api.dart';
import 'package:http/http.dart' as http;

class LLMService {
  final LlmModelPicker modelPicker;
  final LLMModel model;

  LLMService()
      : modelPicker = LlmModelPicker(),
        model = LlmModelPicker().generalPurposeLLM;

  Future<dynamic> callLLMGeneralPurpose({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.5,
    double topP = 0.9,
    int topK = 50,
  }) async {
    final selectedModel = modelPicker.generalPurposeLLM;
    switch (selectedModel) {
      case LLMModel.mistral:
        return _callMistral(prompt, maxTokens, temperature, topP, topK);
      case LLMModel.llama3:
        return _callLlama3(prompt, maxTokens, temperature, topP);
      case LLMModel.claude3:
        return _callClaude3(prompt, maxTokens, temperature, topP, topK);
    }
  }

  Future<dynamic> callLLMForCodeGeneration({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.5,
    double topP = 0.9,
    int topK = 50,
  }) async {
    final selectedModel = modelPicker.codeGenerationLLM;
    switch (selectedModel) {
      case LLMModel.mistral:
        return _callMistral(prompt, maxTokens, temperature, topP, topK);
      case LLMModel.llama3:
        return _callLlama3(prompt, maxTokens, temperature, topP);
      case LLMModel.claude3:
        return _callClaude3(prompt, maxTokens, temperature, topP, topK);
    }
  }

  static Future<dynamic> _callMistral(String prompt, int maxTokens,
      double temperature, double topP, int topK) async {
    const String url = LLMApiConfig.baseMistralUrl;

    final body = jsonEncode({
      "prompt": prompt,
      "max_tokens": maxTokens,
      "temperature": temperature,
      "top_p": topP,
      "top_k": topK,
      "system_instruction": ""
    });

    final response = await http.post(
      Uri.parse(url), 
      headers: _headers(), 
      body: body);
      
    final outer = jsonDecode(response.body);
    final innerJsonBody = jsonDecode(outer['body']);

    return jsonDecode(innerJsonBody['model_response']);
  }

  static Future<dynamic> _callLlama3(
      String prompt, int maxGenLen, double temperature, double topP) async {
    const String url = LLMApiConfig.baseLlama70BUrl;

    final body = jsonEncode({
      "prompt": prompt,
      "max_gen_len": maxGenLen,
      "temperature": temperature,
      "top_p": topP
    });

    final response = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "LLaMA 3 Error: ${response.statusCode}, ${response.body}");
    }
  }

  static Future<dynamic> _callClaude3(String userMessage, int maxTokens,
      double temperature, double topP, int topK) async {
    const String url = LLMApiConfig.baseClaude35Url;

    final body = jsonEncode({
      "modelId": "anthropic.claude-3-5-sonnet-20241022-v2:0",
      "contentType": "application/json",
      "accept": "application/json",
      "body": {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": maxTokens,
        "top_k": topK,
        "stop_sequences": [],
        "temperature": temperature,
        "top_p": topP,
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": userMessage}
            ]
          }
        ]
      }
    });

    final response = await http.post(
      Uri.parse(url), 
      headers: _headers(), 
      body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Claude 3 Error: ${response.statusCode}, ${response.body}");
    }
  }

  static Map<String, String> _headers() => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
}
