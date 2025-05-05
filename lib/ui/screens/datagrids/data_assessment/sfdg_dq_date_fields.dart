import 'package:flutter/material.dart';
import 'package:foretale_application/models/data_assessment_model.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class DateFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;

  const DateFieldsDataGrid({super.key, required this.profiles});

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
        source: DateFieldsDataSource(context, profiles),
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
            columnName: 'min',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Min Date', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'max',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Max Date', style: TextStyles.gridHeaderText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class DateFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  DateFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<String>(columnName: 'min', value: profile.minValue.toString()),
        DataGridCell<String>(columnName: 'max', value: profile.maxValue.toString()),
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
          child: Text(dataGridCell.value.toString(), style: TextStyles.gridText(context),),
        );
      }).toList(),
    );
  }
}