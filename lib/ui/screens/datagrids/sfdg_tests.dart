//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/grid_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//models
import 'package:foretale_application/models/tests_model.dart';
//themes
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
//widgets
import 'package:foretale_application/ui/widgets/message_helper.dart';

class TestsDataGrid extends StatefulWidget {
  const TestsDataGrid({super.key});

  @override
  _TestsDataGridState createState() => _TestsDataGridState();
}

class _TestsDataGridState extends State<TestsDataGrid> {

  late final TestsModel testssModel;

  @override
  void initState() {
    super.initState();
    testssModel = Provider.of<TestsModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<TestsModel>(builder: (context, model, child) {
        return Expanded(
          child: SfDataGrid(
            allowEditing: true,
            allowSorting: false,
            allowFiltering: false,
            isScrollbarAlwaysShown: true,
            columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
            selectionMode: SelectionMode.single,
            onCellTap: ((details) {
                          if (details.rowColumnIndex.rowIndex == 0) {
                            model.updateSortColumn(details.column.columnName);
                          }
                        }),
            onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) async {       
              if (addedRows.isNotEmpty) {
                model.updateTestIdSelection(addedRows.first.getCells()[5].value);
                //await inquiryResponseModel.fetchResponsesByQuestion(context);
              }
            },
            source: TestsDataSource(context, model, model.getTestsList),
            columns: <GridColumn>[
              GridColumn(
                width: 50,
                allowSorting: false,
                allowFiltering: false,
                columnName: 'isSelected',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('', style: TextStyles.gridHeaderText(context),),
                  ),
              ),
              GridColumn(
                columnName: 'testCategory',
                columnWidthMode: ColumnWidthMode.auto,
                label: buildHeader(context, model, "testCategory", "Category"),
              ),
              GridColumn(
                columnName: 'testName',
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                label: buildHeader(context, model, "testName", "Name"),
              ),
              GridColumn(
                columnName: 'testDescription',
                columnWidthMode: ColumnWidthMode.fill,
                label: buildHeader(context, model, "testDescription", "Description"),
              ),
              GridColumn(
                columnName: 'testCriticality',
                columnWidthMode: ColumnWidthMode.auto,
                label: buildHeader(context, model, "testCriticality", "Criticality"),
              ),
              GridColumn(
                columnName: 'testRunType',
                columnWidthMode: ColumnWidthMode.auto,
                label: buildHeader(context, model, "testRunType", "Run Type"),
              ),
              GridColumn(
                filterPopupMenuOptions: const FilterPopupMenuOptions(
                  filterMode: FilterMode.checkboxFilter,
                  showColumnName: false, 
                  canShowSortingOptions: false),
                visible: false,
                columnName: 'testId',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('test_id', style: TextStyles.gridHeaderText(context),),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TestsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  List<Test> testsList;
  TestsModel testsModel;

  TestsDataSource(
    this.context,
    this.testsModel, 
    this.testsList) {
    buildDataGridRows();
  }

  void buildDataGridRows() {
    dataGridRows = testsList.map<DataGridRow>((row) {
      return DataGridRow(cells: [
        
        if(row.isSelected)
        DataGridCell<Widget>(columnName: 'isSelected', value: IconButton(
          icon: const Icon(Icons.check_box, color: Colors.red),
          onPressed: () async {
            try{
              int resultId = await testsModel.removeTest(context, row);
              if(resultId>0){
                buildDataGridRows();
                notifyListeners();
              }
            }catch(e){
              SnackbarMessage.showErrorMessage(context, e.toString());
            }
          })),

        if(!row.isSelected)
        DataGridCell<Widget>(columnName: 'isSelected', value: IconButton(
        icon: const Icon(Icons.check_box_outline_blank, color: Colors.red),
        onPressed: () async {
          try{
              int resultId = await testsModel.selectTest(context, row);
              if(resultId>0){
                buildDataGridRows();
                notifyListeners();
              }
            }catch(e){
              SnackbarMessage.showErrorMessage(context, e.toString());
            }
        })),
        DataGridCell<String>(columnName: 'testCategory', value: row.testCategory),
        DataGridCell<String>(columnName: 'testName', value: row.testName),
        DataGridCell<String>(columnName: 'testDescription', value: row.testDescription),
        DataGridCell<String>(columnName: 'testCriticality', value: row.testCriticality),
        DataGridCell<String>(columnName: 'testRunType', value: row.testRunType),
        DataGridCell<int>(columnName: 'testId', value: row.testId),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        // For the widget column
        if (dataGridCell.value is Widget) {
          return Container(
            padding: const EdgeInsets.all(1.0),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }

        // Check if the column is "testDescription" and apply center-left alignment
        Alignment alignment = dataGridCell.columnName == "testDescription"
            ? Alignment.centerLeft
            : Alignment.center;

        // For "testDescription" column, display it with a max of 3 lines
        if (dataGridCell.columnName == "testDescription") {
          return Container(
            padding: const EdgeInsets.all(1.0),
            alignment: alignment,
            child: Flexible(
              child: Text(
                dataGridCell.value.toString(),
                maxLines: 3, // Limit the text to 3 lines
                overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                style: TextStyles.gridText(context),
              ),
            ),
          );
        }

        // For other columns, return the text value as usual
        return Container(
          padding: const EdgeInsets.all(1.0),
          alignment: alignment,
          child: Text(
            dataGridCell.value.toString(),
            style: TextStyles.gridText(context),
          ),
        );
      }).toList(),
    );
  }

}

