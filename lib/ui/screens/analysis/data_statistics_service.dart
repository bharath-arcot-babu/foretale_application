import 'package:foretale_application/models/result_model.dart';
import 'package:intl/intl.dart';
import 'dart:math';


/// Data class for column statistics
class ColumnStats {
  final String columnName;
  final String columnLabel;
  final CustomCellType cellType;
  final int nullCount;
  final int nonNullCount;
  final int uniqueValues;
  final double nullPercentage;
  final double nonNullPercentage;
  
  // Numeric statistics
  final double? minValue;
  final double? maxValue;
  final double? averageValue;
  final double? standardDeviation;
  
  // Date statistics
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? dateRangeDays;
  
  // String statistics
  final int? minLength;
  final int? maxLength;
  final double? averageLength;

  const ColumnStats({
    required this.columnName,
    required this.columnLabel,
    required this.cellType,
    required this.nullCount,
    required this.nonNullCount,
    required this.uniqueValues,
    required this.nullPercentage,
    required this.nonNullPercentage,
    this.minValue,
    this.maxValue,
    this.averageValue,
    this.standardDeviation,
    this.minDate,
    this.maxDate,
    this.dateRangeDays,
    this.minLength,
    this.maxLength,
    this.averageLength,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnStats &&
          runtimeType == other.runtimeType &&
          columnName == other.columnName &&
          columnLabel == other.columnLabel &&
          cellType == other.cellType &&
          nullCount == other.nullCount &&
          nonNullCount == other.nonNullCount &&
          uniqueValues == other.uniqueValues;

  @override
  int get hashCode =>
      columnName.hashCode ^
      columnLabel.hashCode ^
      cellType.hashCode ^
      nullCount.hashCode ^
      nonNullCount.hashCode ^
      uniqueValues.hashCode;
} 

/// Service class responsible for calculating data statistics
class DataStatisticsService {
  /// Calculates comprehensive table-level statistics
  static Map<String, dynamic> calculateTableStatistics({
    required List<TableColumn> columns,
    required List<Map<String, dynamic>> data,
  }) {
    if (data.isEmpty || columns.isEmpty) {
      return _getEmptyTableStats();
    }

    int totalRecords = data.length;
    int totalColumns = columns.length;
    int numericColumns = 0;
    int textColumns = 0;
    int dateColumns = 0;
    int categoricalColumns = 0;

    // Single pass through columns to count types
    for (var column in columns) {
      final cellType = _mapDataTypeToCellType(column.cellType);
      switch (cellType) {
        case (CustomCellType.number || CustomCellType.currency):
          numericColumns++;
          break;
        case (CustomCellType.badge || CustomCellType.checkbox || CustomCellType.categorical):
          categoricalColumns++;
          break;
        case CustomCellType.date:
          dateColumns++;
          break;
        case (CustomCellType.text || CustomCellType.dropdown):
          textColumns++;
          break;
        default:
          textColumns++;
          break;
      }
    }

    return {
      'totalRecords': totalRecords,
      'totalColumns': totalColumns,
      'numericColumns': numericColumns,
      'textColumns': textColumns,
      'dateColumns': dateColumns,
      'categoricalColumns': categoricalColumns,
    };
  }

  /// Calculates comprehensive column-level statistics
  static List<ColumnStats> calculateColumnStatistics({
    required List<TableColumn> columns,
    required List<Map<String, dynamic>> data,
  }) {
    if (data.isEmpty || columns.isEmpty) {
      return [];
    }

    List<ColumnStats> columnStats = [];

    for (var column in columns) {
      final stats = _calculateSingleColumnStats(column, data);
      columnStats.add(stats);
    }

    return columnStats;
  }

  /// Calculates statistics for a single column
  static ColumnStats _calculateSingleColumnStats(
    TableColumn column,
    List<Map<String, dynamic>> data,
  ) {
    int nullCount = 0;
    int nonNullCount = 0;
    Set<String> uniqueValues = {};
    
    // Data type specific collections
    List<double> numericValues = [];
    List<DateTime> dateValues = [];
    List<int> stringLengths = [];

    final cellType = _mapDataTypeToCellType(column.cellType);

    // Single pass through data for this column
    for (var row in data) {
      final value = row[column.columnName];
      
      if (value == null || value.toString().isEmpty) {
        nullCount++;
      } else {
        nonNullCount++;
        uniqueValues.add(value.toString());
        
        // Collect data type specific values
        _collectDataTypeValues(
          value,
          cellType,
          numericValues,
          dateValues,
          stringLengths,
        );
      }
    }

    int totalValues = nullCount + nonNullCount;
    double nullPercentage = totalValues > 0 ? (nullCount / totalValues) * 100 : 0;
    double nonNullPercentage = totalValues > 0 ? (nonNullCount / totalValues) * 100 : 0;

    // Calculate data type specific statistics
    final numericStats = _calculateNumericStats(numericValues);
    final dateStats = _calculateDateStats(dateValues);
    final stringStats = _calculateStringStats(stringLengths);

    return ColumnStats(
      columnName: column.columnName,
      columnLabel: column.columnLabel,
      cellType: cellType,
      nullCount: nullCount,
      nonNullCount: nonNullCount,
      uniqueValues: uniqueValues.length,
      nullPercentage: nullPercentage,
      nonNullPercentage: nonNullPercentage,
      minValue: numericStats['min'],
      maxValue: numericStats['max'],
      averageValue: numericStats['average'],
      standardDeviation: numericStats['stdDev'],
      minDate: dateStats['minDate'],
      maxDate: dateStats['maxDate'],
      dateRangeDays: dateStats['rangeDays'],
      minLength: stringStats['minLength']?.toInt(),
      maxLength: stringStats['maxLength']?.toInt(),
      averageLength: stringStats['averageLength'],
    );
  }

  /// Maps database data types to custom cell types
  static CustomCellType _mapDataTypeToCellType(String cellType) {
    return CustomCellType.values.firstWhere(
      (e) => e.name.toLowerCase() == cellType.toLowerCase(),
      orElse: () => CustomCellType.text,
    );
  }

  /// Collects data type specific values for statistical analysis
  static void _collectDataTypeValues(
    dynamic value,
    CustomCellType cellType,
    List<double> numericValues,
    List<DateTime> dateValues,
    List<int> stringLengths,
  ) {
    final stringValue = value.toString();
    
    switch (cellType) {
      case (CustomCellType.number || CustomCellType.currency):
        final numericValue = _parseNumericValue(stringValue);
        if (numericValue != null) {
          numericValues.add(numericValue);
        }
        break;
      case (CustomCellType.text || CustomCellType.dropdown):
        stringLengths.add(stringValue.length);
        break;
      case (CustomCellType.date):
        final dateValue = _parseDateValue(stringValue);
        if (dateValue != null) {
          dateValues.add(dateValue);
        }
        break;  
      case (CustomCellType.badge || CustomCellType.checkbox || CustomCellType.categorical):
        stringLengths.add(stringValue.length);
        break;
      default:
        stringLengths.add(stringValue.length);
        break;
    }
  }

  /// Parses numeric values from strings
  static double? _parseNumericValue(String value) {
    return double.tryParse(value.replaceAll(',', ''));
  }

  /// Parses date values from strings using multiple formats
  static DateTime? _parseDateValue(String value) {
    // Common date formats - using a more efficient approach
    final dateFormats = [
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'yyyy/MM/dd',
      'MM-dd-yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd HH:mm:ss',
      'MM/dd/yyyy HH:mm:ss',
    ];
    
    for (final format in dateFormats) {
      try {
        return DateFormat(format).parse(value);
      } catch (e) {
        // Continue to next format
      }
    }
    
    return null;
  }

  /// Calculates numeric statistics (min, max, average, standard deviation)
  static Map<String, double?> _calculateNumericStats(List<double> values) {
    if (values.isEmpty) {
      return {'min': null, 'max': null, 'average': null, 'stdDev': null};
    }
    
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final average = values.reduce((a, b) => a + b) / values.length;
    
    // Calculate standard deviation
    final variance = values.map((x) => (x - average) * (x - average)).reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);
    
    return {
      'min': min,
      'max': max,
      'average': average,
      'stdDev': stdDev,
    };
  }

  /// Calculates date statistics (min date, max date, range in days)
  static Map<String, dynamic> _calculateDateStats(List<DateTime> values) {
    if (values.isEmpty) {
      return {'minDate': null, 'maxDate': null, 'rangeDays': null};
    }
    
    final minDate = values.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = values.reduce((a, b) => a.isAfter(b) ? a : b);
    final rangeDays = maxDate.difference(minDate).inDays;
    
    return {
      'minDate': minDate,
      'maxDate': maxDate,
      'rangeDays': rangeDays,
    };
  }

  /// Calculates string statistics (min length, max length, average length)
  static Map<String, double?> _calculateStringStats(List<int> lengths) {
    if (lengths.isEmpty) {
      return {'minLength': null, 'maxLength': null, 'averageLength': null};
    }
    
    final minLength = lengths.reduce((a, b) => a < b ? a : b).toDouble();
    final maxLength = lengths.reduce((a, b) => a > b ? a : b).toDouble();
    final averageLength = lengths.reduce((a, b) => a + b) / lengths.length;
    
    return {
      'minLength': minLength,
      'maxLength': maxLength,
      'averageLength': averageLength,
    };
  }

  /// Returns empty table statistics
  static Map<String, dynamic> _getEmptyTableStats() {
    return {
      'totalRecords': 0,
      'totalColumns': 0,
      'numericColumns': 0,
      'textColumns': 0,
      'badgeColumns': 0,
      'dateColumns': 0,
      'categoricalColumns': 0,
      'nullValues': 0,
      'nonNullValues': 0,
    };
  }
}
