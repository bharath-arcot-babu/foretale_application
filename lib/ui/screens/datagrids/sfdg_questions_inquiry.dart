import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/utils/util_date.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class QuestionsInquiryGrid extends StatefulWidget {
  const QuestionsInquiryGrid({super.key});

  @override
  State<QuestionsInquiryGrid> createState() => _QuestionsInquiryGridState();
}

class _QuestionsInquiryGridState extends State<QuestionsInquiryGrid> {
  final DataGridController _dataGridController = DataGridController();
  late final InquiryQuestionModel questionModel;
  late final InquiryResponseModel inquiryResponseModel;
  late DataGridSource _dataGridSource;

  @override
  void initState() {
    super.initState();
    questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<InquiryQuestionModel>(builder: (context, model, child) {
        _dataGridSource = QuestionsDataSource(context, model.getFilteredQuestionsList);
        return SfDataGrid(
            controller: _dataGridController,
            allowEditing: false,
            allowSorting: false,
            allowFiltering: false,
            headerRowHeight: 25,
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            //rowHeight: MediaQuery.of(context).size.height * 0.10,
            columnWidthMode: ColumnWidthMode.auto, // Expands columns to fill the grid width
            selectionMode: SelectionMode.single,
            source: _dataGridSource,
            onCellTap: ((details) {
                          if (details.rowColumnIndex.rowIndex == 0) {
                            questionModel.updateSortColumn(details.column.columnName);
                          }
                        }),
            onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) async {       
              if (addedRows.isNotEmpty) {
                model.updateQuestionIdSelection(addedRows.first.getCells()[8].value);
                await inquiryResponseModel.fetchResponsesByQuestion(context);
              }
            },
            columns: <GridColumn>[
              GridColumn(
                columnName: 'topic',
                columnWidthMode: ColumnWidthMode.fill,
                label: _buildHeader("topic", "Topic"),
              ),
              GridColumn(
                columnWidthMode: ColumnWidthMode.fill,
                columnName: 'questionText',
                label: _buildHeader("questionText", "Question")
              ),
              GridColumn(
                visible: false,
                columnName: 'industry',
                label: _buildHeader("industry", "industry"),
              ),
              GridColumn(
                visible: false,
                columnName: 'projectType',
                label: _buildHeader("projectType", "Proj. Type"),
              ),          
              GridColumn(
                columnName: 'createdDate',
                visible: false,
                label: _buildHeader("createdDate", "Create Date"),
              ),
              GridColumn(
                columnName: 'createdBy',
                visible: false,
                label: _buildHeader("createdBy", "Creator"),
              ),
              GridColumn(
                columnName: 'lastResponseBy',
                columnWidthMode: ColumnWidthMode.fill,
                label: _buildHeader("lastResponseBy", "Response By"),
              ),
              GridColumn(
                columnName: 'lastResponseDate',
                columnWidthMode: ColumnWidthMode.fill,
                label: _buildHeader("lastResponseDate", "Response Date"),
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
              GridColumn(
                columnName: 'questionStatus',
                columnWidthMode: ColumnWidthMode.fill,
                label: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Text('Status', style: TextStyles.gridHeaderText(context),),
                ),
              ),
              
            ],
          );
      }),
    );
  }

  Widget _buildHeader(String columnName, String title) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.gridHeaderText(context),
            ),
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.009,
          ),
          getSortIcon(columnName),
        ],
      ),
    );
  }

  Widget getSortIcon(String title) {
    bool isCurrentColumn = questionModel.getCurrentSortColumn == title;
    double iconSize = MediaQuery.sizeOf(context).height * 0.014;
    return Transform.rotate(
      angle: isCurrentColumn
          ? (questionModel.getCurrentSortDirection == DataGridSortDirection.descending ? 0: 3.14159)
          : 0,
      child: Icon(
        Icons.sort_sharp,
        size: iconSize,
        color: Colors.red,
      ),
    );
  }
}

class QuestionsDataSource extends DataGridSource {
  final BuildContext context;
  List<InquiryQuestion> questionsList;
  List<DataGridRow> _dataGridRows = [];
  late InquiryQuestionModel inquiryQuestionsModel;

  
  QuestionsDataSource(
    this.context,
    this.questionsList,
  ) {
    inquiryQuestionsModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    buildDataGridRows();
  }

  // This method is used to build the DataGridRow for each client contact
  void buildDataGridRows() {
    _dataGridRows = questionsList.map<DataGridRow>((row) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'topic', value: row.topic),
        DataGridCell<String>(columnName: 'questionText', value: row.questionText),
        DataGridCell<String>(columnName: 'industry', value: row.industry),
        DataGridCell<String>(columnName: 'projectType', value: row.projectType),
        DataGridCell<String>(columnName: 'createdDate', value: convertToDateString(row.createdDate)),
        DataGridCell<String>(columnName: 'createdBy', value: row.createdBy),
        DataGridCell<String>(columnName: 'lastResponseBy', value: row.lastResponseBy),
        DataGridCell<String>(columnName: 'lastResponseDate', value: row.lastResponseDate),
        DataGridCell<int>(columnName: 'questionId', value: row.questionId), //There are references to the static id. Dont change the order.
        DataGridCell<Widget>(columnName: 'questionStatus', value: CustomDropdownSearch(
              items: const ['Open', 'Close', 'Defer'],
              hintText: 'Status',
              labelText: 'Status',
              isEnabled: true,
              selectedItem: row.questionStatus,
              onChanged: (value) async{
                try{
                  int resultId = await inquiryQuestionsModel.updateQuestionStatus(context, row, value);
                  if(resultId>0){
                    buildDataGridRows();
                    notifyListeners();
                  }
                }catch(e){
                  SnackbarMessage.showErrorMessage(context, e.toString());
                }
              },
            )),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  Future<void> performSorting(List<DataGridRow> rows) {
    // Use the current sort column and direction
    String columnName = inquiryQuestionsModel.getCurrentSortColumn;
    DataGridSortDirection direction = inquiryQuestionsModel.getCurrentSortDirection;

    rows.sort((a, b) {
      var aValue = a.getCells().firstWhere((cell) => cell.columnName == columnName).value;
      var bValue = b.getCells().firstWhere((cell) => cell.columnName == columnName).value;
      return direction == DataGridSortDirection.ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return super.performSorting(rows);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        //choose the background color
        Color? bgCellColor = Colors.transparent;
        if(row.getCells()[8].value == inquiryQuestionsModel.getSelectedInquiryQuestionId){
          bgCellColor = AppColors.primaryColor;
        }

        // For the widget column
        if (dataGridCell.value is Widget) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: dataGridCell.value as Widget,
          );
        }

        String value = dataGridCell.columnName == "lastResponseDate"
            ?convertToDateString(dataGridCell.value.toString())
            :dataGridCell.value.toString();

        // Check if the column is "questionText" and apply center-left alignment
        Alignment alignment = dataGridCell.columnName == "questionText"
            ? Alignment.centerLeft
            : Alignment.center;

        // For other columns, return the text value as usual
        return Container(
          color: bgCellColor,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          alignment: alignment,
          child: Text(
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            value,
            style: TextStyles.gridText(context),
          ),
        );
      }).toList(),
    );
  }
}

