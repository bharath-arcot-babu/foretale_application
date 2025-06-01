import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:foretale_application/core/services/llms/prompts/csv_analysis_prompt.dart';
import 'package:foretale_application/core/services/llms/api/llm_api.dart';

class CsvUtils {
  static Future<Map<String, dynamic>> readTopRowsFromCsv(PlatformFile file,
      {int rowLimit = 50}) async {
    if (file.bytes == null) {
      throw Exception(
          "File bytes are null. Make sure the file is loaded correctly.");
    }

    Uint8List fileBytes = file.bytes!;
    final rawContent = String.fromCharCodes(fileBytes);

    final normalizedContent = _normalizeRowSeparators(rawContent);

    final lines = normalizedContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final topLines = lines.take(rowLimit).toList();

    // Call the LLM to detect the column separator, row separator, and text qualifier
    String promptInput = topLines.join('\n');
    CsvPrompts prompts = CsvPrompts();
    String callingPrompt = prompts.detectSeparators.buildPrompt(promptInput);
    final modelOuput = await LLMService()
        .callLLMGeneralPurpose(prompt: callingPrompt, maxTokens: 200);

    final columnSeparator = modelOuput['column_separator'];
    final rowSeparator = modelOuput['row_separator'];
    final textQualifier = modelOuput['text_qualifier'];

    final parsedRows =
        topLines.map((line) => line.split(columnSeparator)).toList();
    final columnMetadata = extractColumnInfo(parsedRows);

    return {
      "column_separator": columnSeparator,
      "row_separator": rowSeparator,
      "text_qualifier": textQualifier,
      "column_metadata": columnMetadata
    };
  }

  /// Extracts column names with data types, max length, and 5 sample values from sample rows
  static List<Map<String, dynamic>> extractColumnInfo(
      List<List<String>> parsedRows) {
    if (parsedRows.isEmpty) {
      return [];
    }

    final headers = parsedRows.first;
    final dataRows = parsedRows.skip(1).toList();

    final columnInfo = List.generate(headers.length, (index) {
      final columnName = headers[index];
      final columnData =
          dataRows.map((row) => row.length > index ? row[index] : '').toList();

      final detectedType = _inferColumnType(columnData);
      final maxLength = columnData
          .map((val) => val.length)
          .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);

      // Extract up to 5 non-empty, unique sample values
      final sampleValues =
          columnData.where((val) => val.isNotEmpty).toSet().take(5).toList();

      return {
        'name': columnName,
        'metadata': {
          'type': detectedType,
          'maxLength': maxLength,
          'sampleValues': sampleValues,
        }
      };
    });

    return columnInfo;
  }

  /// Normalizes row separators to \n
  static String _normalizeRowSeparators(String content) {
    return content.replaceAll(RegExp(r'\r\n?|\n'), '\n');
  }

  /// Infer column data type from sample data
  static String _inferColumnType(List<String> values) {
    final trimmedValues =
        values.map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

    final isInt = trimmedValues.every((v) => int.tryParse(v) != null);
    if (isInt) return 'int';

    final isDouble = trimmedValues.every((v) => double.tryParse(v) != null);
    if (isDouble) return 'double';

    final isDate = trimmedValues.every((v) => DateTime.tryParse(v) != null);
    if (isDate) return 'DateTime';

    return 'String';
  }
}
