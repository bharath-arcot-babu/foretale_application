import '../template/prompt_template.dart';

class CsvPrompts {
  final detectSeparators = PromptTemplate(
    role: 'You are a smart assistant that analyzes CSV data samples.',
    instructions: '''
        You are given a CSV data sample in the form of a list of strings.
        Your task is to analyze the sample and identify:
        - The most likely column separator (e.g., comma, tab, semicolon, pipe).
        - The most likely row separator (e.g., \\n, \\r\\n).
        - Whether a text qualifier (e.g., double quotes or single quotes) is used to wrap fields.
      ''',
    goal:
        'Identify column separator, row separator, and the presence and type of text qualifier.',
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

  final matchSourceDestinationColumns = PromptTemplate(
    role: 'You are a smart assistant that maps CSV columns.',
    instructions: '''
      You are given two lists:
      - A list of source column names from an uploaded CSV file.
      - A list of destination field names from the target system schema.

      Your task is to match each source column to the most appropriate destination field based on semantic similarity, naming patterns, or commonly understood mappings.

      Return a one-to-one mapping where each source field is assigned the most relevant destination field.
    ''',
    goal: 'Map source columns to the most appropriate destination fields.',
    outputFormat: '''STRICTLY RESPOND IN THE FOLLOWING JSON FORMAT:
      {
        "mappings": {
          "source_column_1": "destination_field_x",
          "source_column_2": "destination_field_y",
          ...
        }
      }
      Only include destination fields with a CONFIDENCE SCORE > 95% that are the best semantic match for each source column. If no suitable match is found, DO NOT INCLUDE THE MAPPING. STRICTLY COLUMNS NAME MUST NOT BE CHANGED.
      NO EXPLANATION REQUIRED. IF THEY ARE NO MAPPINGS FOUND, THE OUTPUT MUST STRICTLY FOLLOW BELOW JSON FORMAT
      {
        "mappings":{}
      }
    ''',
    examples: [],
  );
}
