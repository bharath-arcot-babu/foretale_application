import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_dropdown_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/generic_grid_cell_builder.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/column_width_calculator.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/row_highlight_manager.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';

enum GenericGridCellType {
  text,
  number,
  badge,
  avatar,
  action,
  checkbox,
  dropdown,
  date,
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
  // Updated to support multiple checkbox columns
  final Map<String, void Function(Set<int> selectedRows)>? checkboxCallbacks;
  final Map<String, String>? checkboxInitializationColumns;
  // Map of checkbox column names to boolean - true shows checkbox in header, false shows header name
  final Map<String, bool>? checkboxHeaderSettings;
  // Updated to support multiple dropdown columns
  final Map<String, void Function(Map<int, String> selectedValues)>? dropdownCallbacks;
  final Map<String, List<String>>? dropdownOptions;
  final Map<String, String>? dropdownInitializationColumns;
  // Callback for row tap
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowTap;
  // Column name to be displayed as the first column
  final String? firstColumnName;
  // Pagination properties
  final bool enablePagination;
  final int pageSize;
  final int? maxPageSize;
  final bool showPageInfo;
  final bool showPageSizeSelector;
  final List<int> pageSizes;

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
    this.checkboxCallbacks,
    this.checkboxInitializationColumns,
    this.checkboxHeaderSettings,
    this.dropdownCallbacks,
    this.dropdownOptions,
    this.dropdownInitializationColumns,
    this.onRowTap,
    this.firstColumnName,
    this.enablePagination = false,
    this.pageSize = 10,
    this.maxPageSize,
    this.showPageInfo = true,
    this.showPageSizeSelector = true,
    this.pageSizes = const [5, 10, 20, 50, 100],
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
          columnDefinitions: _getOrderedColumns(),
          context: context,
          itemToMap: (item) => item,
          checkboxCallbacks: widget.checkboxCallbacks,
          checkboxInitializationColumns: widget.checkboxInitializationColumns,
          dropdownCallbacks: widget.dropdownCallbacks,
          dropdownOptions: widget.dropdownOptions,
          dropdownInitializationColumns: widget.dropdownInitializationColumns,
          onRowTap: widget.onRowTap,
          rowHighlightManager: _rowHighlightManager,
          enablePagination: widget.enablePagination,
          pageSize: widget.pageSize,
        );
    
    // Initialize checkboxes after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.checkboxInitializationColumns != null && widget.checkboxInitializationColumns!.isNotEmpty) {
        dataSource.initializeCheckboxesFromColumns(widget.checkboxInitializationColumns!);
      }
      if (widget.dropdownInitializationColumns != null && widget.dropdownInitializationColumns!.isNotEmpty) {
        dataSource.initializeDropdownsFromColumns(widget.dropdownInitializationColumns!);
      }
    });
  }

  @override
  void didUpdateWidget(GenericDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if data has changed or firstColumnName has changed
    if (widget.data != oldWidget.data || widget.firstColumnName != oldWidget.firstColumnName) {
      dataSource.data = widget.data;
      // Update column definitions with new order
      dataSource.updateColumnDefinitions(_getOrderedColumns());
      // Update the checkbox manager with new data and reinitialize selections
      if (widget.checkboxInitializationColumns != null && widget.checkboxInitializationColumns!.isNotEmpty) {
        dataSource.updateCheckboxData(widget.data, widget.checkboxInitializationColumns!);
      } else {
        dataSource.updateCheckboxData(widget.data);
      }
      
      // Update the dropdown manager with new data and reinitialize selections
      if (widget.dropdownInitializationColumns != null && widget.dropdownInitializationColumns!.isNotEmpty) {
        dataSource.updateDropdownData(widget.data, widget.dropdownInitializationColumns!);
      } else {
        dataSource.updateDropdownData(widget.data);
      }
      dataSource.buildDataGridRows();
    }
  }

  @override
  void dispose() {
    dataSource.dispose();
    super.dispose();
  }

  /// Get selected row indices for a specific checkbox column
  Set<int> getSelectedRowIndices(String columnName) {
    return dataSource.getSelectedRowIndices(columnName);
  }

  /// Get selected data items for a specific checkbox column
  List<Map<String, dynamic>> getSelectedData(String columnName) {
    return dataSource.getSelectedData(columnName);
  }

  /// Check if any rows are selected for a specific checkbox column
  bool hasSelectedRows(String columnName) {
    return dataSource.hasSelectedRows(columnName);
  }

  /// Clear all selections for a specific checkbox column
  void clearSelection(String columnName) {
    dataSource.clearSelection(columnName);
  }

  /// Get selected values for a specific dropdown column
  Map<int, String> getSelectedDropdownValues(String columnName) {
    return dataSource.getSelectedDropdownValues(columnName);
  }

  /// Get selected value for a specific row in a specific dropdown column
  String? getSelectedDropdownValue(String columnName, int rowIndex) {
    return dataSource.getSelectedDropdownValue(columnName, rowIndex);
  }

  /// Clear all selections for a specific dropdown column
  void clearDropdownSelection(String columnName) {
    dataSource.clearDropdownSelection(columnName);
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

  // Pagination control methods
  void nextPage() {
    if (widget.enablePagination && dataSource.hasNextPage) {
      setState(() {
        dataSource.nextPage();
      });
    }
  }

  void previousPage() {
    if (widget.enablePagination && dataSource.hasPreviousPage) {
      setState(() {
        dataSource.previousPage();
      });
    }
  }

  void goToPage(int page) {
    if (widget.enablePagination) {
      setState(() {
        dataSource.goToPage(page);
      });
    }
  }

  void setPageSize(int pageSize) {
    if (widget.enablePagination) {
      setState(() {
        dataSource.updatePageSize(pageSize);
      });
    }
  }

  int get currentPage => dataSource.currentPageNumber;
  int get totalPages => dataSource.totalPages;
  bool get hasNextPage => dataSource.hasNextPage;
  bool get hasPreviousPage => dataSource.hasPreviousPage;

  @override
  Widget build(BuildContext context) {
    if (dataSource.rows.isEmpty) {
      return const Expanded(
        child: EmptyState(
          title: "No Data Available",
          subtitle: "Please ensure the test has been run and configured correctly.",
          icon: Icons.table_view_outlined,
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Expanded(child: _buildDataGrid()),
          if (widget.enablePagination) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildDataGrid() {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: SfDataGrid(
        key: _dataGridKey,
        allowSorting: widget.allowSorting,
        allowFiltering: widget.allowFiltering,
        source: dataSource,
        columns: _buildColumnsWithOptimalWidths(),
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.none,
        rowHeight: 85,
        headerRowHeight: 54,
        horizontalScrollPhysics: const BouncingScrollPhysics(),
        verticalScrollPhysics: const BouncingScrollPhysics(),
        allowColumnsResizing: true,
        columnWidthMode: widget.columnWidthMode ?? ColumnWidthMode.fill,
        columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
        onCellTap: (details) => _onCellTap(details),
        // Make scrollbars always visible
        isScrollbarAlwaysShown: true,

      ),
    );
  }

  void _onCellTap(DataGridCellTapDetails details) {
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
  }

  List<GenericGridColumn> _getOrderedColumns() {
    // Reorder columns if firstColumnName is specified
    List<GenericGridColumn> orderedColumns = List.from(widget.columns);
    
    if (widget.firstColumnName != null) {
      // Find the column that should be first
      final firstColumnIndex = orderedColumns.indexWhere(
        (col) => col.columnName == widget.firstColumnName
      );
      
      if (firstColumnIndex != -1) {
        // Move the specified column to the first position
        final firstColumn = orderedColumns.removeAt(firstColumnIndex);
        orderedColumns.insert(0, firstColumn);
      }
    }
    
    return orderedColumns;
  }

  List<GridColumn> _buildColumnsWithOptimalWidths() {
    final orderedColumns = _getOrderedColumns();
    
    return orderedColumns.map((col) {
      // Handle checkbox column header
      if (col.cellType == GenericGridCellType.checkbox) {
        // Check if this checkbox column should show checkbox in header
        final showHeaderCheckbox = widget.checkboxHeaderSettings?[col.columnName] ?? true;
        
        if (showHeaderCheckbox) {
          // Show checkbox in header
          return col.toGridColumn(
            headerWidget: AnimatedBuilder(
              animation: dataSource.multiCheckboxManager!,
              builder: (context, child) {
                return dataSource.multiCheckboxManager!.buildHeaderCheckbox(col.columnName);
              },
            ),
          );
        } else {
          // Show header name instead of checkbox
          return col.toGridColumn();
        }
      }
      
      // For other columns, use default behavior
      return col.toGridColumn();
    }).toList();
  }

  void updateData(List<Map<String, dynamic>> newData) {
    setState(() {
      if (widget.enablePagination) {
        dataSource.updateAllData(newData);
      } else {
        dataSource.data = newData;
        // Update the checkbox manager with new data and reinitialize selections
        if (widget.checkboxInitializationColumns != null && widget.checkboxInitializationColumns!.isNotEmpty) {
          dataSource.updateCheckboxData(newData, widget.checkboxInitializationColumns!);
        } else {
          dataSource.updateCheckboxData(newData);
        }
        
        // Update the dropdown manager with new data and reinitialize selections
        if (widget.dropdownInitializationColumns != null && widget.dropdownInitializationColumns!.isNotEmpty) {
          dataSource.updateDropdownData(newData, widget.dropdownInitializationColumns!);
        } else {
          dataSource.updateDropdownData(newData);
        }
        dataSource.buildDataGridRows();
      }
      // Update column definitions with current order
      dataSource.updateColumnDefinitions(_getOrderedColumns());
    });
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Text(
            'Page ${dataSource.currentPageNumber} of ${dataSource.totalPages}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          
          // Pagination controls
          Row(
            children: [
              // Previous page button
              IconButton(
                onPressed: dataSource.hasPreviousPage ? () {
                  setState(() {
                    dataSource.previousPage();
                  });
                } : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: dataSource.hasPreviousPage ? AppColors.primaryColor : Colors.grey.shade400,
                ),
              ),
              
              // Page size selector
              if (widget.showPageSizeSelector) ...[
                Text(
                  'Show: ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                DropdownButton<int>(
                  value: widget.pageSize,
                  items: widget.pageSizes.map((size) {
                    return DropdownMenuItem<int>(
                      value: size,
                      child: Text(
                        '$size',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newSize) {
                    if (newSize != null) {
                      setState(() {
                        // Update page size in data source
                        dataSource.updatePageSize(newSize);
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
              ],
              
              // Next page button
              IconButton(
                onPressed: dataSource.hasNextPage ? () {
                  setState(() {
                    dataSource.nextPage();
                  });
                } : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: dataSource.hasNextPage ? AppColors.primaryColor : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      columnWidthMode: ColumnWidthMode.fitByCellValue,
      label: headerWidget ?? Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
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
  late final MultiCheckboxManager<T>? multiCheckboxManager;
  late final MultiDropdownManager<T>? multiDropdownManager;
  late final GenericGridCellBuilder cellBuilder;
  late final RowHighlightManager? rowHighlightManager;
  VoidCallback? _rowHighlightListener;
  List<DataGridRow> dataGridRows = [];
  
  // Pagination properties
  final bool enablePagination;
  int pageSize;
  int currentPage = 0;
  List<T> allData = [];

  GenericDataSource({
    required this.data,
    required this.columnDefinitions,
    required this.itemToMap,
    required this.context,
    this.onRowTap,
    Map<String, void Function(Set<int> selectedRows)>? checkboxCallbacks,
    Map<String, String>? checkboxInitializationColumns,
    Map<String, void Function(Map<int, String> selectedValues)>? dropdownCallbacks,
    Map<String, List<String>>? dropdownOptions,
    Map<String, String>? dropdownInitializationColumns,
    RowHighlightManager? rowHighlightManager,
    this.enablePagination = false,
    this.pageSize = 10,
  }) {
    // Initialize pagination data
    allData = List.from(data);
    
    // Initialize checkbox manager if callbacks are provided
    if (checkboxCallbacks != null && checkboxCallbacks.isNotEmpty) {
      multiCheckboxManager = MultiCheckboxManager<T>(
        data: enablePagination ? _getCurrentPageData() : data,
        callbacks: checkboxCallbacks,
      );
    } else {
      multiCheckboxManager = null;
    }
    
    // Initialize dropdown manager if callbacks are provided
    if (dropdownCallbacks != null && dropdownCallbacks.isNotEmpty) {
      multiDropdownManager = MultiDropdownManager<T>(
        data: enablePagination ? _getCurrentPageData() : data,
        dropdownOptions: dropdownOptions,
        callbacks: dropdownCallbacks,
      );
    } else {
      multiDropdownManager = null;
    }
    
    cellBuilder = GenericGridCellBuilder(
      context: context,
      multiCheckboxManager: multiCheckboxManager,
      multiDropdownManager: multiDropdownManager,
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
    if (multiCheckboxManager != null) {
      multiCheckboxManager!.initializeSelections(columnName, (item) {
        final itemMap = itemToMap(item);
        final value = itemMap[columnName];
        return _convertToBoolean(value);
      });
    }
  }

  /// Initialize checkboxes based on multiple columns
  void initializeCheckboxesFromColumns(Map<String, String> columns) {
    columns.forEach((columnName, _) {
      initializeCheckboxesFromColumn(columnName);
    });
  }

  /// Initialize dropdowns based on a column's value
  void initializeDropdownsFromColumn(String columnName) {
    if (multiDropdownManager != null) {
      multiDropdownManager!.initializeSelections(columnName, (item) {
        final itemMap = itemToMap(item);
        final value = itemMap[columnName];
        return value?.toString();
      });
    }
  }

  /// Initialize dropdowns based on multiple columns
  void initializeDropdownsFromColumns(Map<String, String> columns) {
    columns.forEach((columnName, _) {
      initializeDropdownsFromColumn(columnName);
    });
  }

  /// Update checkbox data with initialization columns
  void updateCheckboxData(List<T> newData, [Map<String, String>? initializationColumns]) {
    if (multiCheckboxManager != null) {
      Map<String, bool Function(T item)>? shouldSelectMap;
      
      if (initializationColumns != null) {
        shouldSelectMap = <String, bool Function(T item)>{};
        initializationColumns.forEach((columnName, _) {
          shouldSelectMap![columnName] = (item) {
            final itemMap = itemToMap(item);
            final value = itemMap[columnName];
            return _convertToBoolean(value);
          };
        });
      }
      
      multiCheckboxManager!.updateData(newData, shouldSelectMap: shouldSelectMap);
    }
  }

  /// Update dropdown data with initialization columns
  void updateDropdownData(List<T> newData, [Map<String, String>? initializationColumns]) {
    if (multiDropdownManager != null) {
      Map<String, String? Function(T item)>? getValueMap;
      
      if (initializationColumns != null) {
        getValueMap = <String, String? Function(T item)>{};
        initializationColumns.forEach((columnName, _) {
          getValueMap![columnName] = (item) {
            final itemMap = itemToMap(item);
            final value = itemMap[columnName];
            return value?.toString();
          };
        });
      }
      
      multiDropdownManager!.updateData(newData, getValueMap: getValueMap);
    }
  }

  /// Convert value to boolean for checkbox initialization
  bool _convertToBoolean(dynamic value) {
    if (value == null) {
      return false;
    } else if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true' || value.toLowerCase() == '1' || value.toLowerCase() == 'yes';
    } else if (value is int) {
      return value == 1;
    } else if (value is double) {
      return value == 1.0;
    }
    return false;
  }

  /// Get selected row indices for a specific checkbox column
  Set<int> getSelectedRowIndices(String columnName) {
    if (multiCheckboxManager != null) {
      return multiCheckboxManager!.getSelectedRowIndices(columnName);
    }
    return <int>{};
  }

  /// Get selected data items for a specific checkbox column
  List<Map<String, dynamic>> getSelectedData(String columnName) {
    if (multiCheckboxManager != null) {
      final items = multiCheckboxManager!.getSelectedItems(columnName);
      return items.map((item) => itemToMap(item)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Check if any rows are selected for a specific checkbox column
  bool hasSelectedRows(String columnName) {
    if (multiCheckboxManager != null) {
      return multiCheckboxManager!.getSelectedRowIndices(columnName).isNotEmpty;
    }
    return false;
  }

  /// Clear all selections for a specific checkbox column
  void clearSelection(String columnName) {
    multiCheckboxManager?.clearSelection(columnName);
  }

  /// Get selected values for a specific dropdown column
  Map<int, String> getSelectedDropdownValues(String columnName) {
    if (multiDropdownManager != null) {
      return multiDropdownManager!.getSelectedValues(columnName);
    }
    return <int, String>{};
  }

  /// Get selected value for a specific row in a specific dropdown column
  String? getSelectedDropdownValue(String columnName, int rowIndex) {
    if (multiDropdownManager != null) {
      return multiDropdownManager!.getSelectedValue(columnName, rowIndex);
    }
    return null;
  }

  /// Clear all selections for a specific dropdown column
  void clearDropdownSelection(String columnName) {
    multiDropdownManager?.clearSelection(columnName);
  }

  /// Update column definitions with new order
  void updateColumnDefinitions(List<GenericGridColumn> newColumnDefinitions) {
    columnDefinitions.clear();
    columnDefinitions.addAll(newColumnDefinitions);
  }

  void buildDataGridRows() {
    final currentData = enablePagination ? _getCurrentPageData() : data;
    
    dataGridRows = currentData.asMap().entries.map<DataGridRow>((entry) {
      final item = entry.value;
      final itemMap = itemToMap(item);
      
      final cells = columnDefinitions.map<DataGridCell>((col) {
        if (col.cellType == GenericGridCellType.checkbox) {
          if (multiCheckboxManager != null) {
            return DataGridCell(
              columnName: col.columnName,
              value: multiCheckboxManager!.getCheckboxValue(col.columnName, entry.key),
            );
          }
        } else if (col.cellType == GenericGridCellType.dropdown) {
          if (multiDropdownManager != null) {
            return DataGridCell(
              columnName: col.columnName,
              value: multiDropdownManager!.getDropdownValue(col.columnName, entry.key),
            );
          }
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
  
  // Pagination methods
  List<T> _getCurrentPageData() {
    if (!enablePagination) return allData;
    
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allData.length);
    return allData.sublist(startIndex, endIndex);
  }
  
  int get totalPages => (allData.length / pageSize).ceil();
  
  int get currentPageNumber => currentPage + 1;
  
  bool get hasNextPage => currentPage < totalPages - 1;
  
  bool get hasPreviousPage => currentPage > 0;
  
  void nextPage() {
    if (hasNextPage) {
      currentPage++;
      _updateDataForPagination();
    }
  }
  
  void previousPage() {
    if (hasPreviousPage) {
      currentPage--;
      _updateDataForPagination();
    }
  }
  
  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage = page;
      _updateDataForPagination();
    }
  }
  
  void _updateDataForPagination() {
    data = _getCurrentPageData();
    
    // Update checkbox manager with new data
    if (multiCheckboxManager != null) {
      multiCheckboxManager!.updateData(data);
    }
    
    // Update dropdown manager with new data
    if (multiDropdownManager != null) {
      multiDropdownManager!.updateData(data);
    }
    
    buildDataGridRows();
  }
  
  void updateAllData(List<T> newAllData) {
    allData = List.from(newAllData);
    currentPage = 0; // Reset to first page
    _updateDataForPagination();
  }
  
  void updatePageSize(int newPageSize) {
    pageSize = newPageSize;
    currentPage = 0; // Reset to first page
    _updateDataForPagination();
  }
}
