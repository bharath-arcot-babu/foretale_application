import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/datagrid_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/generic_grid_cell_builder.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/column_width_calculator.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/row_highlight_manager.dart';

enum GenericGridCellType {
  text,
  number,
  badge,
  avatar,
  action,
  checkbox,
}

class GenericDataGrid extends StatefulWidget {
  final List<GenericGridColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool allowSorting;
  final bool allowFiltering;
  final String? title;
  final List<Widget>? actions;
  final bool showSearchBar;
  final String? searchHint;
  final double? height;
  final ColumnWidthMode? columnWidthMode;
  final void Function(Set<int> selectedRows)? onSelectionChanged;
  final String? checkboxInitializationColumn;
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowTap;

  const GenericDataGrid({
    super.key,
    required this.columns,
    required this.data,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.title,
    this.actions,
    this.showSearchBar = false,
    this.searchHint,
    this.height,
    this.columnWidthMode,
    this.onSelectionChanged,
    required this.checkboxInitializationColumn,
    this.onRowTap,
  });

  @override
  State<GenericDataGrid> createState() => GenericDataGridState();
}

class GenericDataGridState extends State<GenericDataGrid> {
  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>();
  late GenericDataSource<Map<String, dynamic>> dataSource;
  late RowHighlightManager _rowHighlightManager;

  @override
  void initState() {
    super.initState();
    _rowHighlightManager = RowHighlightManager();
    
    dataSource = GenericDataSource<Map<String, dynamic>>(
          data: widget.data,
          columnDefinitions: widget.columns,
          context: context,
          itemToMap: (item) => item,
          onSelectionChanged: widget.onSelectionChanged,
          checkboxInitializationColumn: widget.checkboxInitializationColumn,
          onRowTap: widget.onRowTap,
          rowHighlightManager: _rowHighlightManager,
        );
    
    // Initialize checkboxes after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.checkboxInitializationColumn != null && widget.checkboxInitializationColumn!.isNotEmpty) {
        dataSource.initializeCheckboxesFromColumn(widget.checkboxInitializationColumn!);
      }
    });
  }

  @override
  void didUpdateWidget(GenericDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if data has changed
    if (widget.data != oldWidget.data) {
      dataSource.data = widget.data;
      // Update the checkbox manager with new data and reinitialize selections
      if (widget.checkboxInitializationColumn != null && widget.checkboxInitializationColumn!.isNotEmpty) {
        dataSource.checkboxManager.updateData(widget.data, shouldSelect: (item) {
          final itemMap = item as Map<String, dynamic>;
          final value = itemMap[widget.checkboxInitializationColumn!];
          // Handle different data types for boolean conversion
          if (value == null) {
            return false; // Handle null values
          } else if (value is bool) {
            return value;
          } else if (value is String) {
            return value.toLowerCase() == 'true' || value.toLowerCase() == '1' || value.toLowerCase() == 'yes';
          } else if (value is int) {
            return value == 1;
          } else if (value is double) {
            return value == 1.0;
          }
          return false; // Default to false for null or unrecognized values
        });
      } else {
        dataSource.checkboxManager.updateData(widget.data);
      }
      dataSource.buildDataGridRows();
    }
  }

  @override
  void dispose() {
    dataSource.dispose();
    super.dispose();
  }

  /// Get selected row indices
  Set<int> getSelectedRowIndices() {
    return dataSource.checkboxManager.selectedRowIndices;
  }

  /// Get selected data items
  List<Map<String, dynamic>> getSelectedData() {
    return dataSource.checkboxManager.selectedItems;
  }

  /// Check if any rows are selected
  bool hasSelectedRows() {
    return dataSource.checkboxManager.selectedRowIndices.isNotEmpty;
  }

  /// Clear all selections
  void clearSelection() {
    dataSource.checkboxManager.clearSelection();
  }

  /// Get the currently highlighted row index
  int? getHighlightedRowIndex() {
    return _rowHighlightManager.highlightedRowIndex;
  }

  /// Highlight a specific row
  void highlightRow(int rowIndex) {
    _rowHighlightManager.highlightRow(rowIndex);
  }

  /// Clear row highlighting
  void clearRowHighlight() {
    _rowHighlightManager.clearHighlight();
  }

  /// Check if a specific row is highlighted
  bool isRowHighlighted(int rowIndex) {
    return _rowHighlightManager.isRowHighlighted(rowIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (dataSource.rows.isEmpty) {
      return const EmptyState(
        title: "No Data Available",
        subtitle: "Please ensure the test has been run and configured correctly.",
        icon: Icons.table_view_outlined,
      );
    }

    return _buildDataGrid();
  }

  Widget _buildDataGrid() {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: Colors.grey.shade50,
        headerHoverColor: Colors.grey.shade100,
        rowHoverColor: AppColors.primaryColor.withOpacity(0.05),
        selectionColor: AppColors.primaryColor.withOpacity(0.1),
        gridLineColor: Colors.grey.shade200,
        gridLineStrokeWidth: 0.5,
      ),
      child: SfDataGrid(
        key: _dataGridKey,
        allowSorting: widget.allowSorting,
        allowFiltering: widget.allowFiltering,
        source: dataSource,
        columns: _buildColumnsWithOptimalWidths(),
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.none,
        rowHeight: 52,
        headerRowHeight: 44,
        horizontalScrollPhysics: const BouncingScrollPhysics(),
        verticalScrollPhysics: const BouncingScrollPhysics(),
        allowColumnsResizing: true,
        columnWidthMode: widget.columnWidthMode ?? ColumnWidthMode.fill,
        columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
                    onCellTap: (DataGridCellTapDetails details) {
              // Only handle taps on data rows (not header row)
              if (details.rowColumnIndex.rowIndex > 0) {
                final rowIndex = details.rowColumnIndex.rowIndex - 1; // Adjust for header row
                if (rowIndex < widget.data.length) {
                  // Highlight the tapped row
                  _rowHighlightManager.highlightRow(rowIndex);
                  
                  // Call the onRowTap callback if provided
                  if (widget.onRowTap != null) {
                    final rowData = widget.data[rowIndex];
                    widget.onRowTap!(rowData, rowIndex);
                  }
                }
              }
            },
      ),
    );
  }

  List<GridColumn> _buildColumnsWithOptimalWidths() {
    return widget.columns.map((col) {
      // Handle checkbox column header
      if (col.cellType == GenericGridCellType.checkbox) {
        return col.toGridColumn(
          headerWidget: AnimatedBuilder(
            animation: dataSource.checkboxManager,
            builder: (context, child) {
              return dataSource.checkboxManager.buildHeaderCheckbox();
            },
          ),
        );
      }
      
      // For other columns, use default behavior
      return col.toGridColumn();
    }).toList();
  }

  void updateData(List<Map<String, dynamic>> newData) {
    setState(() {
      dataSource.data = newData;
      // Update the checkbox manager with new data and reinitialize selections
      if (widget.checkboxInitializationColumn != null && widget.checkboxInitializationColumn!.isNotEmpty) {
        dataSource.checkboxManager.updateData(newData, shouldSelect: (item) {
          final itemMap = item as Map<String, dynamic>;
          final value = itemMap[widget.checkboxInitializationColumn!];
          // Handle different data types for boolean conversion
          if (value == null) {
            return false; // Handle null values
          } else if (value is bool) {
            return value;
          } else if (value is String) {
            return value.toLowerCase() == 'true' || value.toLowerCase() == '1' || value.toLowerCase() == 'yes';
          } else if (value is int) {
            return value == 1;
          } else if (value is double) {
            return value == 1.0;
          }
          return false; // Default to false for null or unrecognized values
        });
      } else {
        dataSource.checkboxManager.updateData(newData);
      }
      dataSource.buildDataGridRows();
    });
  }

}

class GenericGridColumn {
  final String columnName;
  final String label;
  final double? width;
  final bool allowSorting;
  final bool allowFiltering;
  final bool visible;
  final GenericGridCellType cellType;
  final TextAlign textAlign;

  const GenericGridColumn({
    required this.columnName,
    required this.label,
    this.width,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.cellType = GenericGridCellType.text,
    this.textAlign = TextAlign.start,
  });

  GridColumn toGridColumn({Widget? headerWidget}) {
    // Calculate appropriate width using the ColumnWidthCalculator
    double calculatedWidth = ColumnWidthCalculator.calculateOptimalWidth(
      label: label,
      cellType: cellType,
      customWidth: width,
    );
    
    return GridColumn(
      columnName: columnName,
      width: calculatedWidth,
      allowSorting: cellType == GenericGridCellType.checkbox ? false : allowSorting,
      allowFiltering: cellType == GenericGridCellType.checkbox ? false : allowFiltering,
      visible: visible,
      columnWidthMode: ColumnWidthMode.fitByColumnName,
      label: headerWidget ?? Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class GenericDataSource<T> extends DataGridSource {
  List<T> data;
  final List<GenericGridColumn> columnDefinitions;
  final Map<String, dynamic> Function(T item) itemToMap;
  final BuildContext context;
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowTap;
  late final DatagridCheckboxManager<T> checkboxManager;
  late final GenericGridCellBuilder cellBuilder;
  late final RowHighlightManager? rowHighlightManager;
  VoidCallback? _rowHighlightListener;
  List<DataGridRow> dataGridRows = [];

  GenericDataSource({
    required this.data,
    required this.columnDefinitions,
    required this.itemToMap,
    required this.context,
    this.onRowTap,
    void Function(Set<int> selectedRows)? onSelectionChanged,
    required String? checkboxInitializationColumn,
    RowHighlightManager? rowHighlightManager,
  }) {
    checkboxManager = DatagridCheckboxManager<T>(
      data: data,
      onSelectionChanged: onSelectionChanged,
    );
    
    cellBuilder = GenericGridCellBuilder(
      context: context,
      checkboxManager: checkboxManager,
    );
    
    this.rowHighlightManager = rowHighlightManager;
    
    // Listen to row highlight changes to rebuild rows
    if (rowHighlightManager != null) {
      _rowHighlightListener = () {
        notifyListeners();
      };
      rowHighlightManager.addListener(_rowHighlightListener!);
    }
    
    buildDataGridRows();
  }
  
  /// Initialize checkboxes based on a column's value
  void initializeCheckboxesFromColumn(String columnName) {
    checkboxManager.initializeSelections((item) {
      final itemMap = itemToMap(item);
      final value = itemMap[columnName];
      // Handle different data types for boolean conversion
      if (value == null) {
        return false; // Handle null values
      } else if (value is bool) {
        return value;
      } else if (value is String) {
        return value.toLowerCase() == 'true' || value.toLowerCase() == '1' || value.toLowerCase() == 'yes';
      } else if (value is int) {
        return value == 1;
      } else if (value is double) {
        return value == 1.0;
      }
      return false; // Default to false for null or unrecognized values
    });
  } 

  void buildDataGridRows() {
    dataGridRows = data.asMap().entries.map<DataGridRow>((entry) {
      final item = entry.value;
      final itemMap = itemToMap(item);
      
      final cells = columnDefinitions.map<DataGridCell>((col) {
        if (col.cellType == GenericGridCellType.checkbox) {
          return DataGridCell(
            columnName: col.columnName,
            value: checkboxManager.getCheckboxValue(entry.key),
          );
        }
        return DataGridCell(
          columnName: col.columnName,
          value: itemMap[col.columnName],
        );
      }).toList();
      
      return DataGridRow(cells: cells);
    }).toList();
    
    // Notify the DataGrid that the data has changed
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = dataGridRows.indexOf(row);
    final backgroundColor = rowHighlightManager?.getRowBackgroundColor(rowIndex) ?? 
                           (rowIndex % 2 == 0 ? Colors.white : Colors.grey.shade50);
        
    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((cell) {
        final columnDef = columnDefinitions.firstWhere(
          (col) => col.columnName == cell.columnName
        );
        final value = cell.value;

        return cellBuilder.buildCell(value, columnDef, rowIndex);
      }).toList(),
    );
  }

  /// Dispose the data source and clean up listeners
  void dispose() {
    if (_rowHighlightListener != null && rowHighlightManager != null) {
      rowHighlightManager!.removeListener(_rowHighlightListener!);
    }
  }
}
