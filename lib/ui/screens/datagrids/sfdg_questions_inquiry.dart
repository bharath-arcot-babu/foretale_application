//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//themes
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/datagrid_theme.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
//utils
import 'package:foretale_application/core/utils/grid_builder.dart';
import 'package:foretale_application/core/utils/util_date.dart';
//models
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_dropdown_search.dart';
import 'package:foretale_application/ui/widgets/message_helper.dart';

class QuestionsInquiryGrid extends StatefulWidget {
  const QuestionsInquiryGrid({super.key});

  @override
  State<QuestionsInquiryGrid> createState() => _QuestionsInquiryGridState();
}

class _QuestionsInquiryGridState extends State<QuestionsInquiryGrid> {
  final DataGridController _dataGridController = DataGridController();
  late DataGridSource _dataGridSource;
  late final InquiryQuestionModel questionModel;
  late final InquiryResponseModel inquiryResponseModel;

  @override
  void initState() {
    super.initState();
    questionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    inquiryResponseModel =
        Provider.of<InquiryResponseModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SFDataGridTheme.sfCustomDataGridTheme,
      child: Consumer<InquiryQuestionModel>(builder: (context, model, child) {
        _dataGridSource =
            QuestionsDataSource(context, model.getFilteredQuestionsList);
        return SfDataGrid(
          controller: _dataGridController,
          allowEditing: false,
          allowSorting: false,
          allowFiltering: false,
          headerRowHeight: 25,
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,
          //rowHeight: MediaQuery.of(context).size.height * 0.10,
          columnWidthMode:
              ColumnWidthMode.auto, // Expands columns to fill the grid width
          selectionMode: SelectionMode.single,
          source: _dataGridSource,
          onCellTap: ((details) {
            if (details.rowColumnIndex.rowIndex == 0) {
              questionModel.updateSortColumn(details.column.columnName);
            }
          }),
          onSelectionChanged: (List<DataGridRow> addedRows,
              List<DataGridRow> removedRows) async {
            if (addedRows.isNotEmpty) {
              model.updateQuestionIdSelection(
                  addedRows.first.getCells()[8].value);
              await inquiryResponseModel.fetchResponsesByQuestion(context);
            }
          },
          columns: <GridColumn>[
            GridColumn(
              columnName: 'topic',
              columnWidthMode: ColumnWidthMode.fill,
              label: buildHeader(context, model, "topic", "Topic"),
            ),
            GridColumn(
                columnWidthMode: ColumnWidthMode.fill,
                columnName: 'questionText',
                label: buildHeader(context, model, "questionText", "Question")),
            GridColumn(
              visible: false,
              columnName: 'industry',
              label: buildHeader(context, model, "industry", "industry"),
            ),
            GridColumn(
              visible: false,
              columnName: 'projectType',
              label: buildHeader(context, model, "projectType", "Proj. Type"),
            ),
            GridColumn(
              columnName: 'createdDate',
              visible: false,
              label: buildHeader(context, model, "createdDate", "Create Date"),
            ),
            GridColumn(
              columnName: 'createdBy',
              visible: false,
              label: buildHeader(context, model, "createdBy", "Creator"),
            ),
            GridColumn(
              columnName: 'lastResponseBy',
              columnWidthMode: ColumnWidthMode.fill,
              label:
                  buildHeader(context, model, "lastResponseBy", "Response By"),
            ),
            GridColumn(
              columnName: 'lastResponseDate',
              columnWidthMode: ColumnWidthMode.fill,
              label: buildHeader(
                  context, model, "lastResponseDate", "Response Date"),
            ),
            GridColumn(
              visible: false,
              columnName: 'questionId',
              label: Container(
                padding: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text(
                  'question_id',
                  style: TextStyles.gridHeaderText(context),
                ),
              ),
            ),
            GridColumn(
              columnName: 'questionStatus',
              columnWidthMode: ColumnWidthMode.fill,
              label: Container(
                padding: const EdgeInsets.all(2.0),
                alignment: Alignment.center,
                child: Text(
                  'Status',
                  style: TextStyles.gridHeaderText(context),
                ),
              ),
            ),
          ],
        );
      }),
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
    inquiryQuestionsModel =
        Provider.of<InquiryQuestionModel>(context, listen: false);
    buildDataGridRows();
  }

  // This method is used to build the DataGridRow for each client contact
  void buildDataGridRows() {
    _dataGridRows = questionsList.map<DataGridRow>((row) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'topic', value: row.topic),
        DataGridCell<String>(
            columnName: 'questionText', value: row.questionText),
        DataGridCell<String>(columnName: 'industry', value: row.industry),
        DataGridCell<String>(columnName: 'projectType', value: row.projectType),
        DataGridCell<String>(
            columnName: 'createdDate',
            value: convertToDateString(row.createdDate)),
        DataGridCell<String>(columnName: 'createdBy', value: row.createdBy),
        DataGridCell<String>(
            columnName: 'lastResponseBy', value: row.lastResponseBy),
        DataGridCell<String>(
            columnName: 'lastResponseDate', value: row.lastResponseDate),
        DataGridCell<int>(
            columnName: 'questionId',
            value: row
                .questionId), //There are references to the static id. Dont change the order.
        DataGridCell<Widget>(
            columnName: 'questionStatus',
            value: CustomDropdownSearch(
              items: const ['Open', 'Close', 'Defer'],
              hintText: 'Status',
              title: 'Status',
              isEnabled: true,
              selectedItem: row.questionStatus,
              onChanged: (value) async {
                try {
                  int resultId = await inquiryQuestionsModel
                      .updateQuestionStatus(context, row, value);
                  if (resultId > 0) {
                    buildDataGridRows();
                    notifyListeners();
                  }
                } catch (e) {
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
    performColumnSorting(inquiryQuestionsModel, rows);

    return super.performSorting(rows);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        //choose the background color
        Color? bgCellColor = Colors.transparent;
        if (row.getCells()[8].value ==
            inquiryQuestionsModel.getSelectedInquiryQuestionId) {
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
            ? convertToDateString(dataGridCell.value.toString())
            : dataGridCell.value.toString();

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
