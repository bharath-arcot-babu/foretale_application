import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/models/client_contacts_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ClientContactsDataGrid extends StatelessWidget {
  const ClientContactsDataGrid({super.key});

  
  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<ClientContactsModel>(builder: (context, model, child) {
        return Expanded(
          child: SfDataGrid(
            allowSorting: true,
            isScrollbarAlwaysShown: true,
            columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
            selectionMode: SelectionMode.single,
            headerRowHeight: 30,
            source: ClientContactDataSource(context, model, model.getClientContacts),
            columns: <GridColumn>[
              GridColumn(
                width: 200,
                columnName: 'name',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Name', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                width: 200,
                columnName: 'position',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Position', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                width: 200,
                columnName: 'function',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Function', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                width: 350,
                columnName: 'email',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('Email', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              // New delete column
            GridColumn(
              allowSorting: false,
              columnName: 'delete',
              label: Container(
                padding: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text('', style: TextStyles.gridHeaderText(context),),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ClientContactDataSource extends DataGridSource {
  final BuildContext _context;
  List<DataGridRow> dataGridRows = [];
  List<ClientContact> clientContacts;
  ClientContactsModel clientContactsModel;

  ClientContactDataSource(
    this._context,
    this.clientContactsModel, 
    this.clientContacts) {
    buildDataGridRows();
  }

  // This method is used to build the DataGridRow for each client contact
  void buildDataGridRows() {
    dataGridRows = clientContacts.map<DataGridRow>((clientContact) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: clientContact.name),
        DataGridCell<String>(columnName: 'position', value: clientContact.position),
        DataGridCell<String>(columnName: 'function', value: clientContact.function),
        DataGridCell<String>(columnName: 'email', value: clientContact.email),
        // Add delete icon to each row
        DataGridCell<Widget>(columnName: 'delete', value: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.primaryColor),
          onPressed: () {
            // Remove the contact from the list
            clientContactsModel.removeContact(_context, clientContact);
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

