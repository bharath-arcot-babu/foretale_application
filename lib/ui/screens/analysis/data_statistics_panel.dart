import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/analysis/data_statistics_service.dart';
import 'package:foretale_application/models/result_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

    _tableStats = DataStatisticsService.calculateTableStatistics(
      columns: widget.columns,
      data: widget.data,
    );

    _columnStats = DataStatisticsService.calculateColumnStatistics(
      columns: widget.columns,
      data: widget.data,
    );

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
        Text('Data Statistics', style: TextStyles.gridText(context).copyWith(
          fontWeight: FontWeight.w600,
        ),),
        const SizedBox(height: 12),
        _TableStatisticsWidget(statistics: _tableStats),
        const SizedBox(height: 12),
        Text('Column Statistics', style: TextStyles.gridText(context).copyWith(
          fontWeight: FontWeight.w600,
        ),),
        const SizedBox(height: 12),
        _ColumnStatisticsWidget(columnStats: _columnStats),
      ],
    );
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
        _StatCard(
          title: 'Text Columns',
          value: statistics['textColumns'].toString(),
          icon: Icons.text_fields,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Numeric Columns',
          value: statistics['numericColumns'].toString(),
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Categorical Columns',
          value: statistics['categoricalColumns'].toString(),
          icon: Icons.category,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Date Columns',
          value: statistics['dateColumns'].toString(),
          icon: Icons.calendar_month,
          color: Colors.red,
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
                /*const SizedBox(width: 50),
                _CompactMetric(
                  label: 'Non-Null',
                  value: '${stats.nonNullCount} (${stats.nonNullPercentage.toStringAsFixed(1)}%)',
                  color: Colors.green,
                ),*/
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