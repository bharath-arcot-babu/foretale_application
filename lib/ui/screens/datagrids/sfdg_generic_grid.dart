import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

enum GenericGridCellType {
  text,
  number,
  badge,
  avatar,
  action,
  checkbox,
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
    // Calculate appropriate width based on label length and cell type
    double calculatedWidth = width ?? _calculateOptimalWidth();
    
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

  double _calculateOptimalWidth() {
    // More accurate width calculation based on label length and font characteristics
    double baseWidth = label.length * 9.5; // Better character width estimation for Inter font
    
    // Add padding for the container
    baseWidth += 64.0; // 16px padding on each side
    
    // Adjust based on cell type
    switch (cellType) {
      case GenericGridCellType.checkbox:
        baseWidth = 60.0; // Fixed width for checkbox column
        break;
      case GenericGridCellType.badge:
        baseWidth += 24.0; // Extra space for badge padding and border
        break;
      case GenericGridCellType.avatar:
        baseWidth = 64.0; // Fixed width for avatar with some margin
        break;
      case GenericGridCellType.action:
        baseWidth = 120.0; // Fixed width for action buttons (2 icons + spacing)
        break;
      case GenericGridCellType.number:
        baseWidth += 16.0; // Extra space for numbers and alignment
        break;
      case GenericGridCellType.text:
      default:
        // Add some buffer for text overflow
        baseWidth += 8.0;
        break;
    }
    
    // Ensure minimum and maximum width constraints
    return baseWidth.clamp(100.0, 400.0);
  }
}

class GenericDataSource<T> extends DataGridSource {
  List<T> data;
  final List<GenericGridColumn> columnDefinitions;
  final Map<String, dynamic> Function(T item) itemToMap;
  final BuildContext context;
  final void Function(T item)? onRowTap;
  final Set<int> selectedRows = <int>{};
  void Function(Set<int> selectedRows)? onSelectionChanged;

  GenericDataSource({
    required this.data,
    required this.columnDefinitions,
    required this.itemToMap,
    required this.context,
    this.onRowTap,
    this.onSelectionChanged,
  }) {
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = data.asMap().entries.map<DataGridRow>((entry) {
      final item = entry.value;
      final itemMap = itemToMap(item);
      
      final cells = columnDefinitions.map<DataGridCell>((col) {
        if (col.cellType == GenericGridCellType.checkbox) {
          return DataGridCell(
            columnName: col.columnName,
            value: selectedRows.contains(entry.key),
          );
        }
        return DataGridCell(
          columnName: col.columnName,
          value: itemMap[col.columnName],
        );
      }).toList();
      
      return DataGridRow(cells: cells);
    }).toList();
  }

  void updateData(List<T> newData) {
    data = newData;
    // Clear selection when data changes
    selectedRows.clear();
    buildDataGridRows();
    notifyListeners();
    onSelectionChanged?.call(selectedRows);
  }

  void toggleRowSelection(int rowIndex) {
    if (selectedRows.contains(rowIndex)) {
      selectedRows.remove(rowIndex);
    } else {
      selectedRows.add(rowIndex);
    }
    buildDataGridRows();
    notifyListeners();
    onSelectionChanged?.call(selectedRows);
  }

  void selectAll() {
    selectedRows.clear();
    for (int i = 0; i < data.length; i++) {
      selectedRows.add(i);
    }
    buildDataGridRows();
    notifyListeners();
    onSelectionChanged?.call(selectedRows);
  }

  void clearSelection() {
    selectedRows.clear();
    buildDataGridRows();
    notifyListeners();
    onSelectionChanged?.call(selectedRows);
  }

  bool get isAllSelected => selectedRows.length == data.length && data.isNotEmpty;
  bool get isPartiallySelected => selectedRows.isNotEmpty && selectedRows.length < data.length;

  List<T> get selectedItems {
    return selectedRows.map((index) => data[index]).toList();
  }

  Set<int> get selectedRowIndices => Set<int>.from(selectedRows);

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = dataGridRows.indexOf(row);
    final item = data[rowIndex];
    
    return DataGridRowAdapter(
      color: rowIndex % 2 == 0 ? Colors.white : Colors.grey.shade50,
      cells: row.getCells().map<Widget>((cell) {
        final columnDef = columnDefinitions.firstWhere(
          (col) => col.columnName == cell.columnName
        );
        final value = cell.value;

        Widget cellWidget;
        switch (columnDef.cellType) {
          case GenericGridCellType.checkbox:
            cellWidget = _buildCheckboxCell(value, rowIndex);
            break;
          case GenericGridCellType.number:
            cellWidget = _buildNumberCell(value);
            break;
          case GenericGridCellType.badge:
            cellWidget = _buildBadgeCell(value);
            break;
          case GenericGridCellType.avatar:
            cellWidget = _buildAvatarCell(value);
            break;
          case GenericGridCellType.action:
            cellWidget = _buildActionCell();
            break;
          case GenericGridCellType.text:
          default:
            cellWidget = _buildTextCell(value);
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          alignment: _getAlignment(columnDef.textAlign),
          child: cellWidget,
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxCell(dynamic value, int rowIndex) {
    return Center(
      child: Checkbox(
        value: value as bool? ?? false,
        onChanged: (bool? newValue) {
          toggleRowSelection(rowIndex);
        },
        activeColor: AppColors.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget buildHeaderCheckbox() {
    return Center(
      child: Checkbox(
        value: isAllSelected,
        tristate: true,
        onChanged: (bool? newValue) {
          if (newValue == true) {
            selectAll();
          } else {
            clearSelection();
          }
        },
        activeColor: AppColors.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildTextCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNumberCell(dynamic value) {
    return Text(
      '${value ?? ''}',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBadgeCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatarCell(dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value.toString().isNotEmpty 
              ? value.toString().substring(0, 1).toUpperCase()
              : '?',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_outlined, 
            size: 16,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            // Handle edit action
          },
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline, 
            size: 16,
            color: Colors.red.shade500,
          ),
          onPressed: () {
            // Handle delete action
          },
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.start:
      case TextAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }
}

class GenericDataGrid extends StatefulWidget {
  final List<GenericGridColumn> columns;
  final GenericDataSource dataSource;
  final bool allowSorting;
  final bool allowFiltering;
  final String? title;
  final List<Widget>? actions;
  final bool showSearchBar;
  final String? searchHint;
  final double? height;
  final ColumnWidthMode? columnWidthMode;
  final void Function(Set<int> selectedRows)? onSelectionChanged;

  const GenericDataGrid({
    super.key,
    required this.columns,
    required this.dataSource,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.title,
    this.actions,
    this.showSearchBar = false,
    this.searchHint,
    this.height,
    this.columnWidthMode,
    this.onSelectionChanged,
  });

  @override
  State<GenericDataGrid> createState() => _GenericDataGridState();
}

class _GenericDataGridState extends State<GenericDataGrid> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>();

  @override
  void initState() {
    super.initState();
    // Set up selection callback
    widget.dataSource.onSelectionChanged = widget.onSelectionChanged;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GridColumn> _buildColumnsWithOptimalWidths() {
    return widget.columns.map((col) {
      // Handle checkbox column header
      if (col.cellType == GenericGridCellType.checkbox) {
        return col.toGridColumn(
          headerWidget: widget.dataSource.buildHeaderCheckbox(),
        );
      }
      
      // For other columns, use default behavior
      return col.toGridColumn();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataSource.rows.isEmpty) {
      return const EmptyState(
        title: "No Data Available",
        subtitle: "Please ensure the test has been run and configured correctly.",
        icon: Icons.table_view_outlined,
      );
    }

    Widget dataGridWidget = _buildDataGrid();
    
    // Apply height constraint if specified
    if (widget.height != null) {
      dataGridWidget = SizedBox(
        height: widget.height,
        child: dataGridWidget,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null || widget.actions != null || widget.showSearchBar)
          _buildHeader(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: dataGridWidget,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (widget.title != null || widget.actions != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                      fontSize: 16,
                    ),
                  ),
                if (widget.actions != null)
                  Row(children: widget.actions!),
              ],
            ),
          if (widget.showSearchBar) ...[
            if (widget.title != null || widget.actions != null)
              const SizedBox(height: 12),
            _buildSearchBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: Colors.grey.shade500,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear, 
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade800,
        ),
        onChanged: (value) {
          // Implement search logic here
        },
      ),
    );
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
        source: widget.dataSource,
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
      ),
    );
  }
}