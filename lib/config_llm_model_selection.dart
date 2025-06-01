enum LLMModel {
  mistral,
  llama3,
  claude3,
}

class LlmModelPicker {
  final LLMModel generalPurposeLLM = LLMModel.mistral;
  final LLMModel codeGenerationLLM = LLMModel.mistral;
}
