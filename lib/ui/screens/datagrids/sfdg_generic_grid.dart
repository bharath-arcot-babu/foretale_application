import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GenericDataGrid extends StatelessWidget {
  final List<GridColumn> columns;
  final DataGridSource dataSource;
  final bool allowEditing;
  final bool allowSorting;
  final bool allowFiltering;
  final SelectionMode selectionMode;
  final ColumnWidthMode columnWidthMode;
  final bool isScrollbarAlwaysShown;

  const GenericDataGrid({
    super.key,
    required this.columns,
    required this.dataSource,
    this.allowEditing = false,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.selectionMode = SelectionMode.single,
    this.columnWidthMode = ColumnWidthMode.fill,
    this.isScrollbarAlwaysShown = true,
  });

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Expanded(
        child: SfDataGrid(
          allowEditing: allowEditing,
          allowSorting: allowSorting,
          allowFiltering: allowFiltering,
          isScrollbarAlwaysShown: isScrollbarAlwaysShown,
          columnWidthMode: columnWidthMode,
          selectionMode: selectionMode,
          source: dataSource,
          columns: columns,
        ),
      ),
    );
  }
}

class GenericDataSource<T> extends DataGridSource {
  final List<T> data;
  final List<DataGridColumn> columnDefinitions;
  final Map<String, dynamic> Function(T item) itemToMap;
  final BuildContext context;

  GenericDataSource({
    required this.data,
    required this.columnDefinitions,
    required this.itemToMap,
    required this.context,
  }) {
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = data.map<DataGridRow>((item) {
      final Map<String, dynamic> itemMap = itemToMap(item);
      return DataGridRow(
        cells: columnDefinitions.map<DataGridCell>((column) {
          return DataGridCell(
            columnName: column.columnName,
            value: itemMap[column.columnName],
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.value is Widget) {
          return Container(
            padding: const EdgeInsets.all(1.0),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }

        return Container(
          padding: const EdgeInsets.all(1.0),
          alignment: Alignment.center,
          child: Text(
            dataGridCell.value.toString(),
            style: TextStyles.gridText(context),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

class DataGridColumn {
  final String columnName;
  final String label;
  final double width;
  final bool allowSorting;
  final bool allowFiltering;
  final bool visible;
  final ColumnWidthMode columnWidthMode;
  final FilterPopupMenuOptions? filterPopupMenuOptions;

  const DataGridColumn({
    required this.columnName,
    required this.label,
    this.width = 0.0,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.columnWidthMode = ColumnWidthMode.fill,
    this.filterPopupMenuOptions,
  });

  GridColumn toGridColumn(BuildContext context) {
    return GridColumn(
      columnName: columnName,
      width: width,
      allowSorting: allowSorting,
      allowFiltering: allowFiltering,
      visible: visible,
      columnWidthMode: columnWidthMode,
      filterPopupMenuOptions: filterPopupMenuOptions,
      label: Container(
        padding: const EdgeInsets.all(2.0),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyles.gridHeaderText(context),
        ),
      ),
    );
  }
}
