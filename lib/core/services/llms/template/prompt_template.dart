class PromptTemplate {
  final String role;
  final String instructions;
  final String goal;
  final String outputFormat;
  final List<String> examples;

  PromptTemplate({
    this.role = 'assistant',
    required this.instructions,
    required this.goal,
    required this.outputFormat,
    this.examples = const [],
  });

  /// Builds the full prompt with examples and input
  String buildPrompt(String actualInput) {
    final exampleSection = examples.map((e) => 'Example:\n$e').join('\n\n');
    String prompt = '''
      $role

      $instructions

      $goal

      $exampleSection

      $outputFormat

      Here is the actual input for you to analyze:
      
      $actualInput
      ''';

    return prompt;
  }

  /// Builds the full prompt with examples and input
  String buildPromptForMatch(List<String> input1, List<String> input2) {
    final exampleSection = examples.map((e) => 'Example:\n$e').join('\n\n');
    String prompt = '''
      $role

      $instructions

      $goal

      $exampleSection

      $outputFormat

      Here is the actual inputs for you to analyze:
      Source fields list
      $input1

      Destination fields list
      $input2

      ''';

    return prompt;
  }

  String buildPromptForTestConfig(String projectType, String topic, String testName) {
    final exampleSection = examples.map((e) => 'Example:\n$e').join('\n\n');
    String prompt = '''
      $role

      $instructions

      $goal

      $exampleSection

      $outputFormat

      Here is the actual input for you to analyze:

      Project Type: $projectType
      Topic: $topic
      Test Name: $testName
      ''';

    return prompt;
  }
}
