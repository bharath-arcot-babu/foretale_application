import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/models/data_assessment_model.dart';

class NumericFieldsDataGrid extends StatelessWidget {
  final List<DataQualityProfile> profiles;

  const NumericFieldsDataGrid({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: SfDataGrid(
        allowSorting: true,
        allowFiltering: true,
        isScrollbarAlwaysShown: true,
        columnWidthMode: ColumnWidthMode.fill,
        selectionMode: SelectionMode.multiple,
        headerRowHeight: 30,
        source: NumericFieldsDataSource(context, profiles),
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
              child: Text('Min', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'max',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Max', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'average',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Average', style: TextStyles.gridHeaderText(context)),
            ),
          ),
          GridColumn(
            columnName: 'stddev',
            label: Container(
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text('Std Dev', style: TextStyles.gridHeaderText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class NumericFieldsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  NumericFieldsDataSource(this.context, List<DataQualityProfile> profiles) {
    dataGridRows = profiles.map<DataGridRow>((profile) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'columnName', value: profile.columnName),
        DataGridCell<String>(columnName: 'dataType', value: profile.dataType),
        DataGridCell<String>(columnName: 'min', value: profile.minValue),
        DataGridCell<String>(columnName: 'max', value: profile.maxValue),
        DataGridCell<num>(columnName: 'average', value: profile.avgValue),
        DataGridCell<num>(columnName: 'stddev', value: profile.stdDev),
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
          child: Text(
            dataGridCell.value.toString(),
            style: TextStyles.gridText(context),
            ),
        );
      }).toList(),
    );
  }
}
