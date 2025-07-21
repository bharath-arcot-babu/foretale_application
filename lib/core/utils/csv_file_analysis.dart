import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:foretale_application/core/services/llms/prompts/csv_analysis_prompt.dart';
import 'package:foretale_application/core/services/llms/api/llm_api.dart';
import 'package:foretale_application/core/services/s3_activites.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CsvUtils {
  static Future<Map<String, dynamic>> readTopRowsFromCsv(PlatformFile file, String storagePath, {int rowLimit = 50, int chunkSize = 10000}) async {
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
    final modelOuput = await LLMService().callLLMGeneralPurpose(prompt: callingPrompt, maxTokens: 200);

    final columnSeparator = modelOuput['column_separator'];
    final rowSeparator = modelOuput['row_separator'];
    final textQualifier = modelOuput['text_qualifier'] ?? '"';

    final parsedRows = topLines.map((line) => line.split(columnSeparator)).toList();
    final columnMetadata = extractColumnInfo(parsedRows);

    final fileChunks = await splitFileIntoChunks(
      file,
      columnSeparator,
      rowSeparator,
      textQualifier,
      normalizedContent,
      storagePath,
      chunkSize: 10000);
    print("file chunks: $fileChunks");
    return {
      "column_separator": columnSeparator,
      "row_separator": rowSeparator,
      "text_qualifier": textQualifier,
      "column_metadata": columnMetadata,
      "file_chunks": fileChunks
    };
  }

  static Future<List<String>> splitFileIntoChunks(
    PlatformFile file,
    String columnSeparator,
    String rowSeparator,
    String textQualifier,
    String normalizedContent,
    String storagePath, {
    int chunkSize = 10000,
  }) async {
    // Step 1: Parse CSV
    final csvConverter = CsvToListConverter(
      fieldDelimiter: columnSeparator,
      textDelimiter: textQualifier,
      eol: rowSeparator,
    );

    final allRows = csvConverter.convert(normalizedContent);

    if (allRows.isEmpty || allRows.length == 1) {
      throw Exception("CSV file has no data rows.");
    }
 
    final header = allRows.first;
    final dataRows = allRows.sublist(1);
    final fileName = path.basenameWithoutExtension(file.name);
    final fileExtension = path.extension(file.name);
    final uniqueFolderName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';

    List<String> fileChunks = [];
    String? outputDirPath;


    if (!kIsWeb) {
      // Only on mobile/desktop
      final outputDir = Directory(path.join(Directory.systemTemp.path, uniqueFolderName));
      await outputDir.create(recursive: true);
      outputDirPath = outputDir.path;
    }

    // Step 2: Split and store chunks
    int chunkIndex = 1;
    for (int i = 0; i < dataRows.length; i += chunkSize) {
      final chunkRows = [
        header,
        ...dataRows.sublist(i, (i + chunkSize > dataRows.length) ? dataRows.length : i + chunkSize),
      ];

      final chunkCsv = ListToCsvConverter(
        fieldDelimiter: columnSeparator,
        textDelimiter: textQualifier,
        eol: rowSeparator,
      ).convert(chunkRows);

      String chunkName = '${fileName}_part_$chunkIndex$fileExtension';
      await S3Service().uploadCsvStringToS3(chunkCsv, chunkName, storagePath);
      fileChunks.add(chunkName);
      chunkIndex++;
    }

    return fileChunks;
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
      final sampleValues = columnData.where((val) => val.isNotEmpty).toSet().take(5).toList();

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
    final trimmedValues = values.map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

    final isInt = trimmedValues.every((v) => int.tryParse(v) != null);
    if (isInt) return 'int';

    final isDouble = trimmedValues.every((v) => double.tryParse(v) != null);
    if (isDouble) return 'double';

    final isDate = trimmedValues.every((v) => DateTime.tryParse(v) != null);
    if (isDate) return 'DateTime';

    return 'String';
  }
}
