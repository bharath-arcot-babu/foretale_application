import 'prompt_template.dart';

class CsvPrompts {
  final detectSeparators = PromptTemplate(
    role: 'You are a smart assistant that analyzes CSV data samples.',

    instructions: 
      '''
        You are given a CSV data sample in the form of a list of strings.
        Your task is to analyze the sample and identify:
        - The most likely column separator (e.g., comma, tab, semicolon, pipe).
        - The most likely row separator (e.g., \\n, \\r\\n).
        - Whether a text qualifier (e.g., double quotes or single quotes) is used to wrap fields.
      ''',

    goal: 'Identify column separator, row separator, and the presence and type of text qualifier.',

    outputFormat: '''STRICTLY RESPOND IN THE FOLLOWING JSON FORMAT:
                    {
                      "column_separator": "<detected_column_separator>",
                      "row_separator": "<detected_row_separator>",
                      "text_qualifier": "<detected_text_qualifier_or_null>"
                    }
                    Where "text_qualifier" is the character used to wrap text values (like '"' or "'"), or null if not used.
                  ''',

    examples: [],
  );
}
