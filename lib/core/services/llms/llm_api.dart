//core
import 'dart:convert';
import 'package:http/http.dart' as http;
//config
import 'package:foretale_application/llm_api_config';


Future<dynamic> callMistral(String prompt, {int maxTokens = 128, double temperature = 0.5, double topP = 0.9, int topK = 50}) async {
  const String url = "https://pw4lylhb3g.execute-api.us-east-1.amazonaws.com/dev/bedrock_invoker_resource";

  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

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
    headers: headers, 
    body: body);

  final outer = jsonDecode(response.body);
  final innerJsonBody = jsonDecode(outer['body']);
  
  return jsonDecode(innerJsonBody['model_response']);
}


Future<void> callLlama3(String prompt, {int maxGenLen = 512, double temperature = 0.5, double topP = 0.9}) async {
  const String url = LLMApiConfig.baseLlama70BUrl;

  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  final body = jsonEncode({
    "prompt": prompt,
    "max_gen_len": maxGenLen,
    "temperature": temperature,
    "top_p": topP
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    print("Network Error: $e");
  }
}

Future<void> callClaude3(String userMessage, {int maxTokens = 200, double temperature = 1.0, double topP = 0.999, int topK = 250}) async {
  const String url = LLMApiConfig.baseClaude35Url;

  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

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
            {
              "type": "text",
              "text": userMessage
            }
          ]
        }
      ]
    }
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    print("Network Error: $e");
  }
}
