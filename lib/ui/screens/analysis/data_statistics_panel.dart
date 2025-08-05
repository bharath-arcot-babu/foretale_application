import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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

class DataStatisticsPanel extends StatefulWidget {
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> data;

  const DataStatisticsPanel({
    super.key,
    required this.columns,
    required this.data,
  });

  @override
  State<DataStatisticsPanel> createState() => _DataStatisticsPanelState();
}

class _DataStatisticsPanelState extends State<DataStatisticsPanel> {
  late Map<String, dynamic> _tableStats;
  late List<ColumnStats> _columnStats;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  @override
  void didUpdateWidget(DataStatisticsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate if data or columns have changed
    if (oldWidget.data != widget.data || oldWidget.columns != widget.columns) {
      _calculateStatistics();
    }
  }

  void _calculateStatistics() {
    if (widget.data.isEmpty || widget.columns.isEmpty) {
      _tableStats = {};
      _columnStats = [];
      _isCalculated = true;
      return;
    }

    _tableStats = _calculateTableStatistics();
    _columnStats = _calculateColumnStatistics();
    _isCalculated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCalculated || widget.data.isEmpty || widget.columns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _TableStatisticsWidget(statistics: _tableStats),
        const SizedBox(height: 12),
        _ColumnStatisticsWidget(columnStats: _columnStats),
      ],
    );
  }

  Map<String, dynamic> _calculateTableStatistics() {
    int totalRecords = widget.data.length;
    int totalColumns = widget.columns.length;
    int numericColumns = 0;
    int textColumns = 0;
    int badgeColumns = 0;
    int nullValues = 0;
    int nonNullValues = 0;

    // Single pass through columns to count types
    for (var column in widget.columns) {
      final cellType = _mapDataTypeToCellType(column.dataType);
      switch (cellType) {
        case CustomCellType.number:
          numericColumns++;
          break;
        case CustomCellType.badge:
          badgeColumns++;
          break;
        case CustomCellType.categorical:
          badgeColumns++; // Treat categorical as badge for counting purposes
          break;
        case CustomCellType.text:
        default:
          textColumns++;
          break;
      }
    }

    // Single pass through data to count null/non-null values
    for (var row in widget.data) {
      for (var column in widget.columns) {
        final value = row[column.columnName];
        if (value == null || value.toString().isEmpty) {
          nullValues++;
        } else {
          nonNullValues++;
        }
      }
    }

    return {
      'totalRecords': totalRecords,
      'totalColumns': totalColumns,
      'numericColumns': numericColumns,
      'textColumns': textColumns,
      'badgeColumns': badgeColumns,
      'nullValues': nullValues,
      'nonNullValues': nonNullValues,
    };
  }

  List<ColumnStats> _calculateColumnStatistics() {
    List<ColumnStats> columnStats = [];

    for (var column in widget.columns) {
      int nullCount = 0;
      int nonNullCount = 0;
      Set<String> uniqueValues = {};
      
      // Data type specific collections
      List<double> numericValues = [];
      List<DateTime> dateValues = [];
      List<int> stringLengths = [];

      final cellType = _mapDataTypeToCellType(column.dataType);

      // Single pass through data for this column
      for (var row in widget.data) {
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

      columnStats.add(ColumnStats(
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
      ));
    }

    return columnStats;
  }

  CustomCellType _mapDataTypeToCellType(String dataType) {
    final lowerDataType = dataType.toLowerCase();
    
    if (lowerDataType.contains('int') || 
        lowerDataType.contains('decimal') || 
        lowerDataType.contains('float') || 
        lowerDataType.contains('numeric') ||
        lowerDataType.contains('money')) {
      return CustomCellType.number;
    } else if (lowerDataType.contains('date') || 
               lowerDataType.contains('datetime') || 
               lowerDataType.contains('timestamp')) {
      return CustomCellType.date;
    } else if (lowerDataType.contains('bit') || 
               lowerDataType.contains('bool')) {
      return CustomCellType.badge;
    } else {
      return CustomCellType.text;
    }
  }

  void _collectDataTypeValues(
    dynamic value,
    CustomCellType cellType,
    List<double> numericValues,
    List<DateTime> dateValues,
    List<int> stringLengths,
  ) {
    final stringValue = value.toString();
    
    switch (cellType) {
      case CustomCellType.number:
        final numericValue = _parseNumericValue(stringValue);
        if (numericValue != null) {
          numericValues.add(numericValue);
        }
        break;
      case CustomCellType.text:
        // Check if it's a date
        final dateValue = _parseDateValue(stringValue);
        if (dateValue != null) {
          dateValues.add(dateValue);
        } else {
          // Treat as string
          stringLengths.add(stringValue.length);
        }
        break;
      case CustomCellType.categorical:
        // Treat categorical as string
        stringLengths.add(stringValue.length);
        break;
      default:
        // For other types, treat as string
        stringLengths.add(stringValue.length);
        break;
    }
  }

  double? _parseNumericValue(String value) {
    return double.tryParse(value.replaceAll(',', ''));
  }

  DateTime? _parseDateValue(String value) {
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

  Map<String, double?> _calculateNumericStats(List<double> values) {
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

  Map<String, dynamic> _calculateDateStats(List<DateTime> values) {
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

  Map<String, double?> _calculateStringStats(List<int> lengths) {
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
}

// Separate widget for table statistics to enable better optimization
class _TableStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const _TableStatisticsWidget({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _StatCard(
          title: 'Total Records',
          value: statistics['totalRecords'].toString(),
          icon: Icons.table_rows,
          color: AppColors.primaryColor,
        ),
        _StatCard(
          title: 'Total Columns',
          value: statistics['totalColumns'].toString(),
          icon: Icons.view_column,
          color: Colors.blue,
        ),
        if (statistics['numericColumns'] > 0)
          _StatCard(
            title: 'Numeric',
            value: statistics['numericColumns'].toString(),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        if (statistics['textColumns'] > 0)
          _StatCard(
            title: 'Text',
            value: statistics['textColumns'].toString(),
            icon: Icons.text_fields,
            color: Colors.orange,
          ),
        if (statistics['badgeColumns'] > 0)
          _StatCard(
            title: 'Badge',
            value: statistics['badgeColumns'].toString(),
            icon: Icons.label,
            color: Colors.purple,
          ),
      ],
    );
  }
}

// Optimized stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for column statistics to enable better optimization
class _ColumnStatisticsWidget extends StatelessWidget {
  final List<ColumnStats> columnStats;

  const _ColumnStatisticsWidget({required this.columnStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      child: SingleChildScrollView(
        child: Column(
          children: columnStats.map((stats) => _ColumnStatCard(stats: stats)).toList(),
        ),
      ),
    );
  }
}

// Optimized column stat card widget
class _ColumnStatCard extends StatelessWidget {
  final ColumnStats stats;

  const _ColumnStatCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Column name and type
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCellTypeIcon(stats.cellType),
                      color: _getCellTypeColor(stats.cellType),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stats.columnLabel,
                        style: TextStyles.gridText(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Cell type badge
                Container(
                  decoration: BoxDecoration(
                    color: _getCellTypeColor(stats.cellType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stats.cellType.name.toUpperCase(),
                    style: TextStyles.tinySupplementalInfo(context).copyWith(
                      color: _getCellTypeColor(stats.cellType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Basic metrics - always visible
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _CompactMetric(
                  label: 'Null',
                  value: '${stats.nullCount} (${stats.nullPercentage.toStringAsFixed(1)}%)',
                  color: Colors.red,
                ),
                const SizedBox(width: 50),
                _CompactMetric(
                  label: 'Non-Null',
                  value: '${stats.nonNullCount} (${stats.nonNullPercentage.toStringAsFixed(1)}%)',
                  color: Colors.green,
                ),
                const SizedBox(width: 50),
                _CompactMetric(
                  label: 'Unique',
                  value: stats.uniqueValues.toString(),
                  color: Colors.amber,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Data type specific metrics - conditionally visible
          Expanded(
              flex: 2,
              child: _CompactDataTypeStats(stats: stats),
            ) // Maintain layout consistency when no data type stats
        ],
      ),
    );
  }

  IconData _getCellTypeIcon(CustomCellType cellType) {
    switch (cellType) {
      case CustomCellType.number:
        return Icons.trending_up;
      case CustomCellType.badge:
        return Icons.label;
      case CustomCellType.categorical:
        return Icons.category;
      case CustomCellType.text:
      default:
        return Icons.text_fields;
    }
  }

  Color _getCellTypeColor(CustomCellType cellType) {
    switch (cellType) {
      case CustomCellType.number:
        return Colors.green;
      case CustomCellType.badge:
        return Colors.purple;
      case CustomCellType.categorical:
        return Colors.blue;
      case CustomCellType.text:
      default:
        return Colors.orange;
    }
  }

}

// Optimized compact metric widget
class _CompactMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyles.gridText(context).copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Optimized compact data type stats widget
class _CompactDataTypeStats extends StatelessWidget {
  final ColumnStats stats;

  const _CompactDataTypeStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    switch (stats.cellType) {
      case CustomCellType.number:
        return _buildNumericStats(context);
      case CustomCellType.text:
        if (stats.minDate != null) {
          return _buildDateStats(context);
        } else {
          return _buildStringStats(context);
        }
      case CustomCellType.categorical:
        return _buildStringStats(context);
      default:
        return _buildStringStats(context);
    }
  }

  Widget _buildNumericStats(BuildContext context) {
    if (stats.minValue == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min: ${stats.minValue!.toStringAsFixed(1)} | Max: ${stats.maxValue!.toStringAsFixed(1)}',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.green.shade700,
          ),
        ),
        Text(
          'Avg: ${stats.averageValue!.toStringAsFixed(1)} | Std: ${stats.standardDeviation!.toStringAsFixed(1)}',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDateStats(BuildContext context) {
    if (stats.minDate == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min: ${DateFormat('MMM dd').format(stats.minDate!)} | Max: ${DateFormat('MMM dd').format(stats.maxDate!)}',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          'Range: ${stats.dateRangeDays} days',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStringStats(BuildContext context) {
    if (stats.minLength == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min: ${stats.minLength} | Max: ${stats.maxLength}',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.orange.shade700,
          ),
        ),
        Text(
          'Avg: ${stats.averageLength!.toStringAsFixed(1)}',
          style: TextStyles.tinySupplementalInfo(context).copyWith(
            color: Colors.orange.shade700,
          ),
        ),
      ],
    );
  }
} 