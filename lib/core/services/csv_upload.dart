//libraries
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:foretale_application/core/services/azure_upload.dart';
import 'dart:convert';
import 'dart:io';

class CsvFileDetails {
  String? fileName;
  double? fileSize;
  int? rowCount;
  int? columnCount;
  String? columnSeparator;
  String? rowSeparator;
  String? textQualifier;
  int? errorRows;
  int? rowsWithoutError;

  // Default constructor
  CsvFileDetails({
    this.fileName,
    this.fileSize,
    this.rowCount,
    this.columnCount,
    this.columnSeparator,
    this.rowSeparator,
    this.textQualifier,
    this.errorRows,
    this.rowsWithoutError,
  });

  // Named constructor for initializing all values at once
  CsvFileDetails.initial({
    this.fileName = '',
    this.fileSize = 0.0,
    this.rowCount = 0,
    this.columnCount = 0,
    this.columnSeparator = '',
    this.rowSeparator = '',
    this.textQualifier = '',
    this.errorRows = 0,
    this.rowsWithoutError = 0,
  });
}

class CsvUpload {
  //properties
  String? fileName;
  String? columnSeparator;
  double? fileSize;
  int rowCount = 0;
  int columnCount = 0;
  List<List<dynamic>> goodRows = [];
  List<List<dynamic>> errorRows = [];
  final int validationSampleSize = 10;
  List<List<dynamic>> duplicateRows = [];
  final ValueNotifier<List<String>> errorNotifier;
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<List<CsvFileDetails>> csvFilesNotifier;
  final BuildContext context;

  //constructor to accept and initialize the properties
  CsvUpload({
    required this.errorNotifier,
    required this.progressNotifier,
    required this.csvFilesNotifier,
    required this.context
  });
  
  //picking and reading the csv files
  Future<void> browseAndReadCsvMultiple() async {
    errorNotifier.value = [];
    //pick only csv files
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['csv'],
        readSequential: true);
    
    //progressNotifier - 10% of the work reading the file
    progressNotifier.value = 0.10;

    if(result != null && result.files.isNotEmpty){
      for(var file in result.files){
        if (file.bytes != null) {
          //get the file name
          fileName = file.name;
          //read data in integers/bytes
          Uint8List fileBytes = file.bytes!;
          //get the file size
          fileSize = _getFileSizeInKb(fileBytes);
          //convert to string from bytes
          String csvContent = String.fromCharCodes(fileBytes);
          //normamilze the new line characters
          csvContent = csvContent.replaceAll(RegExp(r'\r\n|\r'), '\n');
          List<String> csvRows = csvContent.split("\n").where((row) => row.trim().isNotEmpty).toList();
          //get the row count
          rowCount = csvRows.length;
          //get the column separator
          columnSeparator = _findColumnSeparator(csvRows);     
          //convert into list of lists
          final List<List<dynamic>> rows = const CsvToListConverter().convert(
              csvContent,
              textDelimiter: '"',
              shouldParseNumbers: false,
              //allowInvalid: false,
              fieldDelimiter: columnSeparator,
              eol: "\n");
          //get the column count
          columnCount = _findColumnCount(rows);
          //validate CSV
          _validateCsv(rows);
          //find duplicate rows in CSV
          findDuplicateLists(rows);

          csvFilesNotifier.value = List.from(csvFilesNotifier.value)..add(CsvFileDetails()
          ..fileName = fileName
          ..fileSize = double.parse((fileSize!/1024).toStringAsFixed(2))
          ..rowCount = rowCount
          ..columnCount = columnCount
          ..columnSeparator = columnSeparator
          ..rowSeparator = "\n"
          ..errorRows = errorRows.length + duplicateRows.length
          ..rowsWithoutError = rowCount - errorRows.length);
        }
      }
    } else {
      errorNotifier.value = List.from(errorNotifier.value)..add("The file is empty.");
    }
  }

  Future<bool> uploadDataToAzure({String? fileName, List<int>? fileBytes}) async{
    //upload the file to the blob storage
    bool fileUploadStatus = await uploadFileToAzure(
      fileBytes: fileBytes!,
      storageAccount: "foretalestorage",
      containerName: "db-data",
      blobName: fileName!,
      sasToken: "sp=racwdl&st=2025-01-20T04:14:43Z&se=2025-01-20T12:14:43Z&spr=https&sv=2022-11-02&sr=c&sig=%2F%2FglfDJ1zftVVAo6jxsA7beTqPOvOH9aS%2BUveo3Lvlw%3D"
    );

    return fileUploadStatus;
}
  
  //validate csv before loading
  void _validateCsv(List<List<dynamic>> rows){
      for(int i =0; i<rows.length; i++){
        if(rows[i].length != columnCount){
          //segregate the error rows
          errorRows.add(rows[i]);
          errorNotifier.value = List.from(errorNotifier.value)..add('Row $i has ${rows[i].length} columns (expected $columnCount).');
        }
        goodRows.add(rows[i]);
        //progressNotifier
        progressNotifier.value = progressNotifier.value + i/rows.length;
      }
  }

  //find the column separator
  String _findColumnSeparator(List<String> csvRows) {
    //starting with only five separators
    Map<String, double> separatorCounts = {
      ',': 0,
      ';': 0,
      ':': 0,
      '\t': 0,
      '|': 0
    };

    //analyze only the first few rows for performance and reliability to determine the separator
    int rowsToAnalyze = validationSampleSize < csvRows.length ? validationSampleSize : csvRows.length;
    for (int i = 0; i < rowsToAnalyze; i++) {
      for (var separator in separatorCounts.keys) {
        //count the occurrences of each separator in the row
        separatorCounts[separator] = separatorCounts[separator]! + csvRows[i].split(separator).length - 1;
      }
    }
    //find the separator with the highest count (mode)
    return separatorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  //find the column count
  int _findColumnCount(List<List<dynamic>> csvRows){
    //analyze only the first few rows for performance and reliability to determine the separator
    int rowsToAnalyze = validationSampleSize < csvRows.length ? validationSampleSize : csvRows.length;
    //get the column count
    Map<int, int> columnCountDetector = {};
    for (int i = 0; i < rowsToAnalyze; i++) {
      columnCountDetector[i] = csvRows[i].length;
    }
    //create the frequency map of values
    Map<int, int> frequencyMap = {};
    for (var value in columnCountDetector.values.toList()) {
      frequencyMap[value] = (frequencyMap[value] ?? 0) + 1;
    }
    //reduce the list to the maximum occurring number
    return frequencyMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  //get the file size in KB
  double _getFileSizeInKb(Uint8List fileBytes) {
    return fileBytes.length / 1024;
  }

  void findDuplicateLists(List<List<dynamic>> lists) {
    final Set<String> seen = {};

    for (var list in lists) {
      // Convert each list to a string representation for comparison
      String listString = list.toString();
      if (seen.contains(listString)) {
        duplicateRows.add(list); // Add to duplicates if already seen
      } 
      seen.add(listString); // Mark as seen
    }
  }

  Future<List<List<dynamic>>> readTopRowsFromCsv(File file, {int maxRows = 200}) async {
    final input = file.openRead();
    final rows = <List<dynamic>>[];

    // Stream the file and decode line-by-line
    await input
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .take(maxRows) // Only take the first `maxRows` lines
        .forEach((line) {
          final row = const CsvToListConverter().convert(line, eol: '\n');
          if (row.isNotEmpty) {
            rows.add(row.first);
          }
        });

    return rows;
  }
}


