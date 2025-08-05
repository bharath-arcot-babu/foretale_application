import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/core/utils/test_config_parser.dart';
import 'package:foretale_application/ui/screens/test_case/custom_code_formatter.dart';
import 'package:foretale_application/ui/screens/test_case/test_service.dart';

class SqlQueryDialogWidget extends StatefulWidget {
  final Test test;
  final Function() onMaximizeChanged;

  const SqlQueryDialogWidget({
    super.key,
    required this.test,
    required this.onMaximizeChanged,
  });

  @override
  State<SqlQueryDialogWidget> createState() => _SqlQueryDialogWidgetState();
}

class _SqlQueryDialogWidgetState extends State<SqlQueryDialogWidget> {
  late CodeController _codeController;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<TestsModel>(
          builder: (context, testsModel, child) {
            // Get the formatted query
            String formattedQuery = TestConfigParser.parseFormattedSql(widget.test.config);
            _codeController = CodeController(
              text: formattedQuery.isNotEmpty ? formattedQuery : '-- No SQL query available --',
              language: sql
            );

            // Get the updated test from the model
            final updatedTest = testsModel.testsList.firstWhere(
              (t) => t.testId == widget.test.testId,
              orElse: () => widget.test,
            );
            
            return Container(
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomCodeFormatter(
                key: ValueKey('${formattedQuery}_${updatedTest.testConfigExecutionStatus}'),
                selectedTest: updatedTest,
                initialCode: formattedQuery.isNotEmpty ? formattedQuery : '-- No SQL query available --',
                onCodeChanged: (code) {
                  _codeController.text = code;
                },
                width: constraints.maxWidth,
                showSaveRunButtons: true,
                onSaveQuery: () async {
                  await TestService.saveSqlQuery(context, updatedTest, _codeController);
                },
                onRunQuery: () async {
                  await TestService.saveAndRunSqlQuery(context, updatedTest, _codeController);
                },
                onMaximizeChanged: widget.onMaximizeChanged,
              ),
            );
          },
        );
      },
    );
  }
} 