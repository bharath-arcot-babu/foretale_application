import 'package:flutter/material.dart';
import 'package:foretale_application/models/team_contacts_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TeamContactsDataGrid extends StatelessWidget {
  const TeamContactsDataGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<TeamContactsModel>(builder: (context, model, child) {
        return Expanded(
          child: SfDataGrid(
            allowEditing: true,
            allowSorting: true,
            isScrollbarAlwaysShown: true,
            columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
            selectionMode: SelectionMode.multiple,
            headerRowHeight: 30,
            source: TeamContactDataSource(context, model, model.getTeamContacts),
            columns: <GridColumn>[
              GridColumn(
                width: 200,
                columnName: 'name',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Name', style: DatagridTheme.datagridHeaderText(),),
                ),
              ),
              GridColumn(
                width: 200,
                columnName: 'position',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Position', style: DatagridTheme.datagridHeaderText(),),
                ),
              ),
              GridColumn(
                width: 200,
                columnName: 'function',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Function', style: DatagridTheme.datagridHeaderText(),),
                ),
              ),
              GridColumn(
                width: 350,
                columnName: 'email',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Email', style: DatagridTheme.datagridHeaderText(),),
                ),
              ),
              // New delete column
            GridColumn(
              allowSorting: false,
              columnName: 'delete',
              label: Container(
                padding: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text('', style: DatagridTheme.datagridHeaderText(),),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TeamContactDataSource extends DataGridSource {
  final BuildContext _context;
  List<DataGridRow> dataGridRows = [];
  List<TeamContact> teamContacts;
  TeamContactsModel teamContactsModel;

  TeamContactDataSource(
    this._context,
    this.teamContactsModel, 
    this.teamContacts) {

    buildDataGridRows();

  }

  // This method is used to build the DataGridRow for each team contact
  void buildDataGridRows() {
    dataGridRows = teamContacts.map<DataGridRow>((teamContact) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: teamContact.name),
        DataGridCell<String>(columnName: 'position', value: teamContact.position),
        DataGridCell<String>(columnName: 'function', value: teamContact.function),
        DataGridCell<String>(columnName: 'email', value: teamContact.email),
        // Add delete icon to each row
        DataGridCell<Widget>(columnName: 'delete', value: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            // Remove the contact from the list
            teamContactsModel.removeContact(_context, teamContact);
            // Rebuild the rows
            buildDataGridRows();
            // Notify listeners so that the DataGrid gets rebuilt
            notifyListeners();
          },
        )),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.value is Widget) {
          // For the delete button, return the widget (the icon button)
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }
        // For other cells, return the text value as usual
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}

