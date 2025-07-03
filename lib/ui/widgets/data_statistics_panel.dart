import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class ColumnStats {
  final String columnName;
  final String columnLabel;
  final GenericGridCellType cellType;
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

  ColumnStats({
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
}

class DataStatisticsPanel extends StatelessWidget {
  final List<GenericGridColumn> columns;
  final List<Map<String, dynamic>> data;

  const DataStatisticsPanel({
    super.key,
    required this.columns,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || columns.isEmpty) {
      return const SizedBox.shrink();
    }

    final tableStats = _calculateTableStatistics();
    final columnStats = _calculateColumnStatistics();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildTableStatistics(context, tableStats),
        const SizedBox(height: 12),
        _buildColumnStatistics(context, columnStats),
      ],
    );
  }

  Widget _buildTableStatistics(BuildContext context, Map<String, dynamic> statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildStatCard(
              context,
              'Total Records',
              statistics['totalRecords'].toString(),
              Icons.table_rows,
              AppColors.primaryColor,
            ),
            _buildStatCard(
              context,
              'Total Columns',
              statistics['totalColumns'].toString(),
              Icons.view_column,
              Colors.blue,
            ),
            if (statistics['numericColumns'] > 0)
              _buildStatCard(
                context,
                'Numeric',
                statistics['numericColumns'].toString(),
                Icons.trending_up,
                Colors.green,
              ),
            if (statistics['textColumns'] > 0)
              _buildStatCard(
                context,
                'Text',
                statistics['textColumns'].toString(),
                Icons.text_fields,
                Colors.orange,
              ),
            if (statistics['badgeColumns'] > 0)
              _buildStatCard(
                context,
                'Badge',
                statistics['badgeColumns'].toString(),
                Icons.label,
                Colors.purple,
              ),
            if (statistics['nullValues'] > 0)
              _buildStatCard(
                context,
                'Null Values',
                statistics['nullValues'].toString(),
                Icons.block,
                Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnStatistics(BuildContext context, List<ColumnStats> columnStats) {
    return Container(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      child: SingleChildScrollView(
        child: Column(
          children: columnStats.map((stats) => _buildColumnStatCard(context, stats)).toList(),
        ),
      ),
    );
  }

  Widget _buildColumnStatCard(BuildContext context, ColumnStats stats) {
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
            child: 
            Column(
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
        ]),
          ),

          // Basic metrics
          Expanded(
            flex: 3,
                          child: Row(
                children: [
                  _buildCompactMetric(context, 'Null', '${stats.nullCount} (${stats.nullPercentage.toStringAsFixed(1)}%)', Colors.red),
                  const SizedBox(width: 50),
                  _buildCompactMetric(context, 'Non-Null', '${stats.nonNullCount} (${stats.nonNullPercentage.toStringAsFixed(1)}%)', Colors.green),
                  const SizedBox(width: 50),
                  _buildCompactMetric(context, 'Unique', stats.uniqueValues.toString(), Colors.amber),
                ],
              ),
          ),
          // Data type specific metrics
          if (_hasDataTypeSpecificStats(stats))
            Expanded(
              flex: 2,
              child: _buildCompactDataTypeStats(context, stats),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(BuildContext context, String label, String value, Color color) {
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

  Widget _buildCompactDataTypeStats(BuildContext context, ColumnStats stats) {
    switch (stats.cellType) {
      case GenericGridCellType.number:
        return _buildCompactNumericStats(context, stats);
      case GenericGridCellType.text:
        if (stats.minDate != null) {
          return _buildCompactDateStats(context, stats);
        } else {
          return _buildCompactStringStats(context, stats);
        }
      default:
        return _buildCompactStringStats(context, stats);
    }
  }

  Widget _buildCompactNumericStats(BuildContext context, ColumnStats stats) {
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

  Widget _buildCompactDateStats(BuildContext context, ColumnStats stats) {
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

  Widget _buildCompactStringStats(BuildContext context, ColumnStats stats) {
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

  Widget _buildColumnMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCellTypeIcon(GenericGridCellType cellType) {
    switch (cellType) {
      case GenericGridCellType.number:
        return Icons.trending_up;
      case GenericGridCellType.badge:
        return Icons.label;
      case GenericGridCellType.text:
      default:
        return Icons.text_fields;
    }
  }

  Color _getCellTypeColor(GenericGridCellType cellType) {
    switch (cellType) {
      case GenericGridCellType.number:
        return Colors.green;
      case GenericGridCellType.badge:
        return Colors.purple;
      case GenericGridCellType.text:
      default:
        return Colors.orange;
    }
  }

  bool _hasDataTypeSpecificStats(ColumnStats stats) {
    return stats.minValue != null || 
           stats.minDate != null || 
           stats.minLength != null;
  }

  Widget _buildDataTypeSpecificStats(BuildContext context, ColumnStats stats) {
    switch (stats.cellType) {
      case GenericGridCellType.number:
        return _buildNumericStats(context, stats);
      case GenericGridCellType.text:
        if (stats.minDate != null) {
          return _buildDateStats(context, stats);
        } else {
          return _buildStringStats(context, stats);
        }
      default:
        return _buildStringStats(context, stats);
    }
  }

  Widget _buildNumericStats(BuildContext context, ColumnStats stats) {
    if (stats.minValue == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Numeric Statistics',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Min',
                  stats.minValue!.toStringAsFixed(2),
                  Icons.trending_down,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Max',
                  stats.maxValue!.toStringAsFixed(2),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Avg',
                  stats.averageValue!.toStringAsFixed(2),
                  Icons.show_chart,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Std Dev',
                  stats.standardDeviation!.toStringAsFixed(2),
                  Icons.science,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateStats(BuildContext context, ColumnStats stats) {
    if (stats.minDate == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Statistics',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Min Date',
                  DateFormat('MMM dd, yyyy').format(stats.minDate!),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Max Date',
                  DateFormat('MMM dd, yyyy').format(stats.maxDate!),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Range',
                  '${stats.dateRangeDays} days',
                  Icons.date_range,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStringStats(BuildContext context, ColumnStats stats) {
    if (stats.minLength == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'String Statistics',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Min Length',
                  stats.minLength.toString(),
                  Icons.text_fields,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Max Length',
                  stats.maxLength.toString(),
                  Icons.text_fields,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumnMetric(
                  context,
                  'Avg Length',
                  stats.averageLength!.toStringAsFixed(1),
                  Icons.text_fields,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
              Icon(
                icon,
                color: color,
                size: 16,
              ),
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

  Map<String, dynamic> _calculateTableStatistics() {
    int totalRecords = data.length;
    int totalColumns = columns.length;
    int numericColumns = 0;
    int textColumns = 0;
    int badgeColumns = 0;
    int nullValues = 0;
    int nonNullValues = 0;

    // Count column types based on cell types
    for (var column in columns) {
      switch (column.cellType) {
        case GenericGridCellType.number:
          numericColumns++;
          break;
        case GenericGridCellType.badge:
          badgeColumns++;
          break;
        case GenericGridCellType.text:
        default:
          textColumns++;
          break;
      }
    }

    // Analyze data for null and non-null values
    for (var row in data) {
      for (var column in columns) {
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

    for (var column in columns) {
      int nullCount = 0;
      int nonNullCount = 0;
      Set<String> uniqueValues = {};
      
      // Data type specific collections
      List<double> numericValues = [];
      List<DateTime> dateValues = [];
      List<int> stringLengths = [];

      // Analyze data for this column
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
            column.cellType,
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
        columnLabel: column.label,
        cellType: column.cellType,
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

  void _collectDataTypeValues(
    dynamic value,
    GenericGridCellType cellType,
    List<double> numericValues,
    List<DateTime> dateValues,
    List<int> stringLengths,
  ) {
    final stringValue = value.toString();
    
    switch (cellType) {
      case GenericGridCellType.number:
        final numericValue = _parseNumericValue(stringValue);
        if (numericValue != null) {
          numericValues.add(numericValue);
        }
        break;
      case GenericGridCellType.text:
        // Check if it's a date
        final dateValue = _parseDateValue(stringValue);
        if (dateValue != null) {
          dateValues.add(dateValue);
        } else {
          // Treat as string
          stringLengths.add(stringValue.length);
        }
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
    // Common date formats
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