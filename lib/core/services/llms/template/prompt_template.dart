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

  /// Builds the full prompt with examples and input
  String buildPromptToClarifyTestConfig(
      String testName, String testDescription, String context) {
    String prompt = '''
      $role

      $goal

      $instructions

      $outputFormat

      Here is the test case name and description:
      Test Case Name: $testName
      Test Case Description: $testDescription

      ${context.isEmpty ? '' : 'Here is the list of past user responses in the descending order to the test case:\n$context'}

      ''';

    return prompt;
  }

  String buildPromptToFindTablesForTestConfig(
    String testName, String testDescription, String pastUserResponses) {
    String prompt = '''
      $role

      $goal

      $instructions

      $outputFormat

      Here is the test case name and description:
      Test Case Name: $testName
      Test Case Description: $testDescription

      ${pastUserResponses.isEmpty ? '' : 'Here is the list of past user responses in the descending order to the test case:\n$pastUserResponses'}

      $examples
      ''';

    return prompt;
  }
}
