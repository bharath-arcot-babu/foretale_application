import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/empty_state.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_datasource.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomGrid extends StatefulWidget {
  List<CustomGridColumn> columns = []; //list of columns to be displayed in the grid
  List<Map<String, dynamic>> data = []; //list of data to be displayed in the grid
  bool gridAllowSorting = true; //whether the grid allows sorting
  bool gridAllowFiltering = true; //whether the grid allows filtering
  bool gridAllowPagination = true; //whether the grid allows pagination
  bool gridAllowSelection = true; //whether the grid allows selection
  bool gridAllowMultiSelection = true; //whether the grid allows multi-selection


  final void Function(Map<String, dynamic> rowData, int rowIndex)? gridOnRowTap; //callback for row tap

  bool enablePagination = false; //whether the grid allows pagination

  String? firstColumnName; //the name of the column that should be displayed first in the grid

  CustomGrid({
    super.key, 
    required this.columns, 
    required this.data,
    this.gridAllowSorting = true,
    this.gridAllowFiltering = true,
    this.gridAllowPagination = true,
    this.gridAllowSelection = true,
    this.gridAllowMultiSelection = true,
    this.gridOnRowTap,
    this.enablePagination = false,
    this.firstColumnName,
    });

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  final GlobalKey<SfDataGridState> _dataGridKey = GlobalKey<SfDataGridState>(); //key for the syncfusion datagrid. This will help in re-rendering the grid when the data changes.
  late CustomGridDataSource sfDataSource; //data source for the syncfusion datagrid.

  @override
  void initState() {
    super.initState();

    //a custom grid data source is created to be used by the syncfusion datagrid.
    sfDataSource = CustomGridDataSource(
      context: context,
      columns: getColumnsOrderedByFirstColumnName(widget.columns, widget.firstColumnName),
      data: widget.data,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sfDataSource.rows.isEmpty) {
      return _buildNoDataState(); //if there is no data, show the no data state
    }

    return _buildDataGrid(); //the data grid is built and displayed directly
  }

  Widget _buildNoDataState() {
    return const EmptyState(
      title: "No Data Available",
      subtitle: "Please ensure the test has been run and configured correctly.",
        icon: Icons.table_view_outlined,
    );
  }

  Widget _buildDataGrid() {
    return SfDataGrid(
      key: _dataGridKey,
      source: sfDataSource,
      columns: sfDataSource.columns.map((column) => column.toGridColumn(context)).toList(),
      allowSorting: widget.gridAllowSorting,
      allowFiltering: widget.gridAllowFiltering,
      gridLinesVisibility: GridLinesVisibility.horizontal,
      headerGridLinesVisibility: GridLinesVisibility.none,
      rowHeight: 48,
      headerRowHeight: 52,
      horizontalScrollPhysics: const BouncingScrollPhysics(),
      verticalScrollPhysics: const BouncingScrollPhysics(),
      allowColumnsResizing: true,
      columnWidthMode: ColumnWidthMode.fitByColumnName,
      columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
      isScrollbarAlwaysShown: true,
      onCellTap: (details) => _onCellTap(details),
    );
  } 

  void _onCellTap(DataGridCellTapDetails details) {
    // Only handle taps on data rows (not header row)
    if (details.rowColumnIndex.rowIndex > 0) {
      final rowIndex = details.rowColumnIndex.rowIndex - 1; // Adjust for header row
      if (rowIndex < widget.data.length) {        
        // Call the onRowTap callback if provided 
        if (widget.gridOnRowTap != null) {
          //get the row data
          final rowData = widget.data[rowIndex];
          //call the onRowTap callback with the row data and index
          widget.gridOnRowTap!(rowData, rowIndex);
        }
      }
    }
  }
}