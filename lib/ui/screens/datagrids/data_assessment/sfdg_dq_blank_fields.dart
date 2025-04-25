import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:foretale_application/models/data_assessment_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class NullFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;
  const NullFieldsDataGrid({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: SfDataGrid(
        allowFiltering: true,
        allowSorting: true,
        isScrollbarAlwaysShown: true,
        columnWidthMode: ColumnWidthMode.fill,
        selectionMode: SelectionMode.multiple,
        headerRowHeight: 30,
        source: NullFieldsDataSource(context, profiles),
        columns: <GridColumn>[
          GridColumn(
            columnName: 'columnName',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Column Name', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'dataType',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Data Type', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'nulls',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Nulls', style: TextStyles.gridHeaderText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class NullFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  NullFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<int>(columnName: 'nulls', value: profile.nullCount),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(dataGridCell.value.toString(),style: TextStyles.gridText(context),),
        );
      }).toList(),
    );
  }
}