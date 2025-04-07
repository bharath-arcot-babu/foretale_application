//core
import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

Widget _getSortIcon(BuildContext context, var model, String title) {
    bool isCurrentColumn = model.getCurrentSortColumn == title;
    double iconSize = MediaQuery.sizeOf(context).height * 0.014;
    return Transform.rotate(
      angle: isCurrentColumn
          ? (model.getCurrentSortDirection == DataGridSortDirection.descending ? 0: 3.14159)
          : 0,
      child: Icon(
        Icons.sort_sharp,
        size: iconSize,
        color: Colors.red,
      ),
    );
  }

  void performColumnSorting(var model, List<DataGridRow> rows) {
    // Use the current sort column and direction
    String columnName = model.getCurrentSortColumn;
    DataGridSortDirection direction = model.getCurrentSortDirection;

    rows.sort((a, b) {
      var aValue = a.getCells().firstWhere((cell) => cell.columnName == columnName).value;
      var bValue = b.getCells().firstWhere((cell) => cell.columnName == columnName).value;
      return direction == DataGridSortDirection.ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  Widget buildHeader(BuildContext context, var model, String columnName, String title) {
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
          _getSortIcon(context, model, columnName),
        ],
      ),
    );
  }