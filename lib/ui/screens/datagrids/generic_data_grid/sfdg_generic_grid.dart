import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_checkbox_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/multi_dropdown_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/generic_grid_cell_builder.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/column_width_calculator.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/row_highlight_manager.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/pagination_manager.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/models/result_model.dart';

class GenericDataGrid extends StatefulWidget {
  //grid properties
  final List<GenericGridColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool allowSorting;
  final bool allowFiltering;

  final bool showSearchBar;
  final String? searchHint;
  final double? height;
  final ColumnWidthMode? columnWidthMode;

  // Callback for row tap
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowTap;

  // Checkbox properties
  final Map<String, String>? checkboxInitializationColumns;
  final Map<String, bool>? checkboxHeaderSettings;

  // Dropdown properties
  final Map<String, List<String>>? dropdownOptions;
  final Map<String, String>? dropdownInitializationColumns;

  // Save callback for individual rows
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowSave;

  // Column name to be displayed as the first column
  final String? firstColumnName;

  // Pagination properties
  final bool enablePagination;
  final int pageSize;
  final int? maxPageSize;
  final bool showPageInfo;
  final bool showPageSizeSelector;
  final List<int> pageSizes;

  // Feedback column styling
  final Map<String, bool>? feedbackColumns;

  const GenericDataGrid({
    //grid properties
    super.key,
    required this.columns,
    required this.data,
    this.allowSorting = true,
    this.allowFiltering = true,

    this.showSearchBar = false,
    this.searchHint,
    this.height,
    this.columnWidthMode,
    this.onRowTap,
    this.firstColumnName,
    //checkbox properties
    this.checkboxInitializationColumns,
    this.checkboxHeaderSettings,
    //dropdown properties
    this.dropdownOptions,
    this.dropdownInitializationColumns,
    //save callback
    this.onRowSave,
    
    //pagination properties
    this.enablePagination = false,
    this.pageSize = 10,
    this.maxPageSize,
    this.showPageInfo = true,
    this.showPageSizeSelector = true,
    this.pageSizes = const [5, 10, 20, 50, 100],
    //feedback column properties
    this.feedbackColumns,
  });

  @override
  State<GenericDataGrid> createState() => GenericDataGridState();
}

class GenericDataGridState extends State<GenericDataGrid> {
  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>();
  late GenericDataSource<Map<String, dynamic>> dataSource;
  late RowHighlightManager _rowHighlightManager;

  int get currentPage => dataSource.currentPageNumber;
  int get totalPages => dataSource.totalPages;
  bool get hasNextPage => dataSource.hasNextPage;
  bool get hasPreviousPage => dataSource.hasPreviousPage;

  @override
  void initState() {
    super.initState();
    _rowHighlightManager = RowHighlightManager();

    dataSource = GenericDataSource<Map<String, dynamic>>(
          data: widget.data,
          columnDefinitions: _getOrderedColumns(),
          context: context,
          itemToMap: (item) => item,
          onRowTap: widget.onRowTap,
          rowHighlightManager: _rowHighlightManager,
          //checkbox properties
          checkboxInitializationColumns: widget.checkboxInitializationColumns,
          checkboxHeaderSettings: widget.checkboxHeaderSettings,
          //dropdown properties
          dropdownOptions: widget.dropdownOptions,
          dropdownInitializationColumns: widget.dropdownInitializationColumns,
          //save callback
          onRowSave: widget.onRowSave,
          //pagination properties
          enablePagination: widget.enablePagination,
          pageSize: widget.pageSize,
        );
    
    // Initialize managers after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCheckboxes();
      _initializeDropdowns();
    });
  }

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

  void _updateManagers() {
    // Add a small delay to prevent concurrent modification during rapid updates
    Future.microtask(() {
      _updateCheckboxManager();
      _updateDropdownManager();
    });
  }

  void _initializeCheckboxes() {
    final checkboxColumns = widget.checkboxInitializationColumns;
    if (checkboxColumns?.isNotEmpty == true) {
      dataSource.initializeCheckboxesFromColumns(checkboxColumns!);
    }
  }

  void _initializeDropdowns() {
    final dropdownColumns = widget.dropdownInitializationColumns;
    if (dropdownColumns?.isNotEmpty == true) {
      dataSource.initializeDropdownsFromColumns(dropdownColumns!);
    }
  }

  void _updateCheckboxManager() {
    final checkboxColumns = widget.checkboxInitializationColumns;
    if (checkboxColumns?.isNotEmpty == true) {
      dataSource.updateCheckboxData(widget.data, checkboxColumns!);
    } else {
      dataSource.updateCheckboxData(widget.data);
    }
  }

  void _updateDropdownManager() {
    final dropdownColumns = widget.dropdownInitializationColumns;
    if (dropdownColumns?.isNotEmpty == true) {
      dataSource.updateDropdownData(widget.data, dropdownColumns!);
    } else {
      dataSource.updateDropdownData(widget.data);
    }
  }

  @override
  void didUpdateWidget(GenericDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if data has changed or firstColumnName has changed
    if ( (widget.data != oldWidget.data) || widget.firstColumnName != oldWidget.firstColumnName) {
      setState(() {
        dataSource.data = widget.data;
        dataSource.updateColumnDefinitions(_getOrderedColumns());
        _updateManagers();
        dataSource.buildDataGridRows();
      });
    }
  }

  @override
  void dispose() {
    dataSource.dispose();
    super.dispose();
  }

  /**************************CHECKBOX METHODS************************** */
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

  /**************************DROPDOWN METHODS************************** */
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

  /**************************ROW HIGHLIGHTING METHODS************************** */
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

  Widget _buildDataGrid() {
    // Determine if we should use feedback theme
    final hasFeedbackColumns = widget.feedbackColumns?.values.any((isFeedback) => isFeedback) ?? false;
    final themeData = hasFeedbackColumns 
        ? SFDataGridTheme.sfFeedbackDataGridTheme 
        : SFDataGridTheme.sfCustomDataGridTheme;
    
    return SfDataGridTheme(
      data: themeData,
      child: SfDataGrid(
        key: _dataGridKey,
        allowSorting: widget.allowSorting,
        allowFiltering: widget.allowFiltering,
        source: dataSource,
        columns: _buildColumnsWithOptimalWidths(),
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.none,
        rowHeight: 48,
        headerRowHeight: 52,
        horizontalScrollPhysics: const BouncingScrollPhysics(),
        verticalScrollPhysics: const BouncingScrollPhysics(),
        allowColumnsResizing: true,
        columnWidthMode: widget.columnWidthMode ?? ColumnWidthMode.fill,
        columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
        onCellTap: (details) => _onCellTap(details),
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
      if (col.cellType == CustomCellType.checkbox) {
        return _buildCheckboxColumn(col);
      }
      final isFeedbackColumn = widget.feedbackColumns?.containsKey(col.columnName) == true &&
          widget.feedbackColumns![col.columnName] == true;
      return col.toGridColumn(isFeedbackColumn: isFeedbackColumn, context: context);
    }).toList();
  }

  GridColumn _buildCheckboxColumn(GenericGridColumn col) {
    final showHeaderCheckbox = widget.checkboxHeaderSettings?[col.columnName] ?? true;
    final isFeedbackColumn = widget.feedbackColumns?.containsKey(col.columnName) == true &&
        widget.feedbackColumns![col.columnName] == true;
    
    if (showHeaderCheckbox) {
      return col.toGridColumn(
        isFeedbackColumn: isFeedbackColumn,
        headerWidget: AnimatedBuilder(
          animation: dataSource.multiCheckboxManager!,
          builder: (context, child) {
            return dataSource.multiCheckboxManager!.buildHeaderCheckbox(col.columnName, isFeedbackColumn: isFeedbackColumn);
          },
        ),
      );
    }
    
    return col.toGridColumn(isFeedbackColumn: isFeedbackColumn, context: context);
  }

  void updateData(List<Map<String, dynamic>> newData) {
    setState(() {
      if (widget.enablePagination) {
        dataSource.updateAllData(newData);
      } else {
        _updateNonPaginatedData(newData);
      }
      dataSource.updateColumnDefinitions(_getOrderedColumns());
    });
  }

  void _updateNonPaginatedData(List<Map<String, dynamic>> newData) {
    dataSource.data = newData;
    // Use microtask to prevent concurrent modification during rapid updates
    Future.microtask(() {
      _updateManagers();
      dataSource.buildDataGridRows();
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
          _buildPageInfo(),
          _buildPaginationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageInfo() {
    return Text(
      dataSource.paginationManager?.getPageNavigationString() ?? 'Page ${dataSource.currentPageNumber} of ${dataSource.totalPages}',
      style: TextStyles.subtitleText(context).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildPaginationButtons() {
    return Row(
      children: [
        _buildPreviousButton(),
        if (widget.showPageSizeSelector) ...[
          _buildPageSizeSelector(),
          const SizedBox(width: 16),
        ],
        _buildNextButton(),
      ],
    );
  }

  Widget _buildPreviousButton() {
    return IconButton(
      onPressed: dataSource.hasPreviousPage ? () {
        setState(() {
          dataSource.previousPage();
        });
      } : null,
      icon: Icon(
        Icons.chevron_left,
        color: dataSource.hasPreviousPage ? AppColors.primaryColor : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      onPressed: dataSource.hasNextPage ? () {
        setState(() {
          dataSource.nextPage();
        });
      } : null,
      icon: Icon(
        Icons.chevron_right,
        color: dataSource.hasNextPage ? AppColors.primaryColor : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildPageSizeSelector() {
    return Row(
      children: [
        Text(
          'Show: ',
          style: TextStyles.subtitleText(context).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        DropdownButton<int>(
          value: dataSource.paginationManager?.pageSize ?? widget.pageSize,
          items: _buildPageSizeItems(),
          onChanged: _onPageSizeChanged,
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _buildPageSizeItems() {
    return widget.pageSizes.map((size) {
      return DropdownMenuItem<int>(
        value: size,
        child: Text(
          '$size',
          style: TextStyles.subtitleText(context).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }).toList();
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null) {
      setState(() {
        dataSource.updatePageSize(newSize);
      });
    }
  }
}

class GenericGridColumn {
  final String columnName;
  final String label;
  final double? width;
  final bool allowSorting;
  final bool allowFiltering;
  final bool visible;
  final CustomCellType cellType;
  final TextAlign textAlign;

  GenericGridColumn({
    required this.columnName,
    required this.label,
    this.width,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.cellType = CustomCellType.text,
    this.textAlign = TextAlign.start,
  });

  GridColumn toGridColumn({Widget? headerWidget, bool isFeedbackColumn = false, BuildContext? context}) {
    // Calculate appropriate width using the ColumnWidthCalculator
    double calculatedWidth = ColumnWidthCalculator.calculateOptimalWidth(
      label: label,
      cellType: cellType,
      customWidth: width,
    );
    
    Widget finalHeaderWidget;
    if (headerWidget != null) {
      finalHeaderWidget = headerWidget;
    } else if (isFeedbackColumn) {
      finalHeaderWidget = _buildFeedbackHeader(label, context!);
    } else {
      finalHeaderWidget = _buildConsistentHeader(label, context!);
    }
    
    return GridColumn(
      columnName: columnName,
      width: calculatedWidth,
      allowSorting: cellType == CustomCellType.checkbox ? false : allowSorting,
      allowFiltering: cellType == CustomCellType.checkbox ? false : allowFiltering,
      visible: visible,
      columnWidthMode: ColumnWidthMode.fitByCellValue,
      label: finalHeaderWidget,
    );
  }

  Widget _buildConsistentHeader(String label, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Center(
        child: Text(
          label,
          style: TextStyles.gridHeaderText(context).copyWith(
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFeedbackHeader(String label, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Center(
        child: Text(
          label,
          style: TextStyles.gridHeaderText(context).copyWith(
            color: AppColors.primaryColor,
            height: 1.2,
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
  final void Function(Map<String, dynamic> rowData, int rowIndex)? onRowSave;
  late final MultiCheckboxManager<T>? multiCheckboxManager;
  late final MultiDropdownManager<T>? multiDropdownManager;
  late final GenericGridCellBuilder cellBuilder;
  late final RowHighlightManager? rowHighlightManager;
  VoidCallback? _rowHighlightListener;
  List<DataGridRow> dataGridRows = [];
  
  // Pagination manager
  late final PaginationManager<T>? paginationManager;

  GenericDataSource({
    required this.data,
    required this.columnDefinitions,
    required this.itemToMap,
    required this.context,
    this.onRowTap,
    Map<String, String>? checkboxInitializationColumns,
    Map<String, bool>? checkboxHeaderSettings,
    Map<String, List<String>>? dropdownOptions,
    Map<String, String>? dropdownInitializationColumns,
    RowHighlightManager? rowHighlightManager,
    this.onRowSave,
    bool enablePagination = false,
    int pageSize = 10,
  }) {
    _initializePaginationManager(enablePagination, pageSize);
    _initializeManagers(checkboxInitializationColumns, dropdownInitializationColumns, dropdownOptions);
    _initializeCellBuilder();
    _initializeRowHighlightManager(rowHighlightManager);
    buildDataGridRows();
  }

  void _initializePaginationManager(bool enablePagination, int pageSize) {
    if (enablePagination) {
      paginationManager = PaginationManager<T>(
        enablePagination: enablePagination,
        pageSize: pageSize,
        initialData: data,
        onDataChanged: () {
          _updateDataFromPagination();
        },
      );
    } else {
      paginationManager = null;
    }
  }

  void _initializeManagers(
    Map<String, String>? checkboxInitializationColumns,
    Map<String, String>? dropdownInitializationColumns,
    Map<String, List<String>>? dropdownOptions,
  ) {
    _initializeCheckboxManager(checkboxInitializationColumns);
    _initializeDropdownManager(dropdownInitializationColumns, dropdownOptions);
  }

  void _initializeCheckboxManager(Map<String, String>? checkboxInitializationColumns) {
    if (checkboxInitializationColumns?.isNotEmpty == true) {
      multiCheckboxManager = MultiCheckboxManager<T>(
        data: _getCurrentData(),
      );
      // Initialize the checkbox columns
      multiCheckboxManager!.initializeColumns(checkboxInitializationColumns!.keys.toSet());
    } else {
      multiCheckboxManager = null;
    }
  }

  void _initializeDropdownManager(
    Map<String, String>? dropdownInitializationColumns,
    Map<String, List<String>>? dropdownOptions,
  ) {
    if (dropdownInitializationColumns?.isNotEmpty == true) {
      multiDropdownManager = MultiDropdownManager<T>(
        data: _getCurrentData(),
        dropdownOptions: dropdownOptions,
      );
      // Initialize the dropdown columns
      multiDropdownManager!.initializeColumns(dropdownInitializationColumns!.keys.toSet());
    } else {
      multiDropdownManager = null;
    }
  }

  List<T> _getCurrentData() {
    return paginationManager?.data ?? data;
  }

  void _updateDataFromPagination() {
    if (paginationManager != null) {
      data = paginationManager!.data;
      // Update managers with new data using microtask to prevent concurrent modification
      Future.microtask(() {
        // Update checkbox manager with new data
        if (multiCheckboxManager != null) {
          multiCheckboxManager!.updateData(data);
        }
        
        // Update dropdown manager with new data
        if (multiDropdownManager != null) {
          multiDropdownManager!.updateData(data);
        }
        
        buildDataGridRows();
      });
    }
  }

  void _initializeCellBuilder() {
    cellBuilder = GenericGridCellBuilder(
      context: context,
      multiCheckboxManager: multiCheckboxManager,
      multiDropdownManager: multiDropdownManager,
      onRowSave: onRowSave,
    );
  }

  void _initializeRowHighlightManager(RowHighlightManager? rowHighlightManager) {
    this.rowHighlightManager = rowHighlightManager;
    
    if (rowHighlightManager != null) {
      _rowHighlightListener = () {
        notifyListeners();
      };
      rowHighlightManager.addListener(_rowHighlightListener!);
    }
  }

  /// Initialize checkboxes based on multiple columns
  void initializeCheckboxesFromColumns(Map<String, String> columns) {
    columns.forEach((columnName, _) {
        if (multiCheckboxManager != null) {
          multiCheckboxManager!.initializeSelections(columnName, (item) {
          final itemMap = itemToMap(item);
          final value = itemMap[columnName];
          return _convertToBoolean(value);
        });
      }
    });
  }

  /// Initialize dropdowns based on multiple columns
  void initializeDropdownsFromColumns(Map<String, String> columns) {
    columns.forEach((columnName, _) {
      if (multiDropdownManager != null) {
          multiDropdownManager!.initializeSelections(columnName, (item) {
          final itemMap = itemToMap(item);
          final value = itemMap[columnName];
          return value?.toString();
        });
      }
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
    if (value is bool) {
      return value;
    } else if (value ==  null) {
      return false;
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
    final currentData = _getCurrentData();
    
    // Create a copy of data to avoid concurrent modification during iteration
    final dataCopy = List<T>.from(currentData);
    
    dataGridRows = dataCopy.asMap().entries.map<DataGridRow>((entry) {
      final item = entry.value;
      final itemMap = itemToMap(item);
      
      final cells = columnDefinitions.map<DataGridCell>((col) {
        return _createDataGridCell(col, entry.key, itemMap);
      }).toList();
      
      return DataGridRow(cells: cells);
    }).toList();
    
    notifyListeners();
  }

  DataGridCell _createDataGridCell(GenericGridColumn col, int rowIndex, Map<String, dynamic> itemMap) {
    if (col.cellType == CustomCellType.checkbox && multiCheckboxManager != null) {
      return DataGridCell(
        columnName: col.columnName,
        value: multiCheckboxManager!.getCheckboxValue(col.columnName, rowIndex),
      );
    }
    
    if (col.cellType == CustomCellType.dropdown && multiDropdownManager != null) {
      return DataGridCell(
        columnName: col.columnName,
        value: multiDropdownManager!.getDropdownValue(col.columnName, rowIndex),
      );
    }
    
    if (col.cellType == CustomCellType.save) {
      return DataGridCell(
        columnName: col.columnName,
        value: 'save', // Use a placeholder value for save cells
      );
    }
    
    return DataGridCell(
      columnName: col.columnName,
      value: itemMap[col.columnName],
    );
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = dataGridRows.indexOf(row);
    final backgroundColor = rowHighlightManager?.getRowBackgroundColor(rowIndex) ?? 
                           (rowIndex % 2 == 0 ? Colors.white : Colors.grey.shade50);
    
    // Get the row data for this row
    final rowData = rowIndex < data.length ? itemToMap(data[rowIndex]) : <String, dynamic>{};
        
    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((cell) {
        final columnDef = columnDefinitions.firstWhere(
          (col) => col.columnName == cell.columnName
        );
        final value = cell.value;

        return cellBuilder.buildCell(value, columnDef, rowIndex, rowData);
      }).toList(),
    );
  }

  /// Dispose the data source and clean up listeners
  @override
  void dispose() {
    if (_rowHighlightListener != null && rowHighlightManager != null) {
      rowHighlightManager!.removeListener(_rowHighlightListener!);
    }
    paginationManager?.dispose();
    super.dispose();
  }
  
  // Pagination methods - delegate to pagination manager
  int get totalPages => paginationManager?.totalPages ?? 1;
  
  int get currentPageNumber => paginationManager?.currentPageNumber ?? 1;
  
  bool get hasNextPage => paginationManager?.hasNextPage ?? false;
  
  bool get hasPreviousPage => paginationManager?.hasPreviousPage ?? false;
  
  void nextPage() {
    paginationManager?.nextPage();
  }
  
  void previousPage() {
    paginationManager?.previousPage();
  }
  
  void goToPage(int page) {
    paginationManager?.goToPage(page);
  }
  
  void updateAllData(List<T> newAllData) {
    paginationManager?.updateAllData(newAllData);
  }
  
  void updatePageSize(int newPageSize) {
    paginationManager?.updatePageSize(newPageSize);
  }
}
