import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class QuestionsDataGrid extends StatelessWidget {
  const QuestionsDataGrid({super.key});
 
  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<QuestionsModel>(builder: (context, model, child) {
        return Expanded(
          child: SfDataGrid(
            allowEditing: true,
            allowSorting: true,
            allowFiltering: true,
            isScrollbarAlwaysShown: true,
            columnWidthMode: ColumnWidthMode.fill, // Expands columns to fill the grid width
            selectionMode: SelectionMode.single,
            source: QuestionsDataSource(context, model, model.getQuestionsList),
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
                width: MediaQuery.of(context).size.width * 0.25,
                columnName: 'questionText',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Question', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.auto,
                visible: false,
                columnName: 'industry',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Industry', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.auto,
                visible: false,
                columnName: 'projectType',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Project Type', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                columnName: 'topic',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Topic', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.fitByColumnName,
                columnName: 'createdDate',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Created Date', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                columnName: 'createdBy',
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Created By', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              GridColumn(
                visible: false,
                columnName: 'questionId',
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text('question_id', style: TextStyles.gridHeaderText(context),),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class QuestionsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  List<Question> questionsList;
  QuestionsModel questionsModel;

  QuestionsDataSource(
    this.context,
    this.questionsModel, 
    this.questionsList) {
    buildDataGridRows();
  }

  // This method is used to build the DataGridRow for each client contact
  void buildDataGridRows() {
    dataGridRows = questionsList.map<DataGridRow>((row) {
      return DataGridRow(cells: [
        
        if(row.isSelected)
        DataGridCell<Widget>(columnName: 'isSelected', value: IconButton(
          icon: const Icon(Icons.check_box, color: Colors.red),
          onPressed: () async {
            try{
              int resultId = await questionsModel.removeQuestion(context, row);
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
              int resultId = await questionsModel.selectQuestion(context, row);
              if(resultId>0){
                buildDataGridRows();
                notifyListeners();
              }
            }catch(e){
              SnackbarMessage.showErrorMessage(context, e.toString());
            }
        })),
        DataGridCell<String>(columnName: 'questionText', value: row.questionText),
        DataGridCell<String>(columnName: 'industry', value: row.industry),
        DataGridCell<String>(columnName: 'projectType', value: row.projectType),
        DataGridCell<String>(columnName: 'topic', value: row.topic),
        DataGridCell<String>(columnName: 'createdDate', value: convertToDateString(row.createdDate)),
        DataGridCell<String>(columnName: 'createdBy', value: row.createdBy),
        DataGridCell<int>(columnName: 'questionId', value: row.questionId),
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

        // Check if the column is "questionText" and apply center-left alignment
        Alignment alignment = dataGridCell.columnName == "questionText"
            ? Alignment.centerLeft
            : Alignment.center;

        // For "questionText" column, display it with a max of 3 lines
        if (dataGridCell.columnName == "questionText") {
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

