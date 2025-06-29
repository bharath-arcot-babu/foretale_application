import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:provider/provider.dart';

class FlaggedTransaction {
  final int projectId;
  final int testId;
  final String selectClause;
  final String result;

  FlaggedTransaction({
    required this.projectId,
    required this.testId,
    required this.selectClause,
    required this.result,
  });

  factory FlaggedTransaction.fromJson(Map<String, dynamic> json) {
    return FlaggedTransaction(
      projectId: json['project_id'],
      testId: json['test_id'],
      selectClause: json['select_clause'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'test_id': testId,
      'select_clause': selectClause,
      'result': result,
    };
  }
}

class FlaggedTransactionsModel extends ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<FlaggedTransaction> _flaggedTransactions = [];
  List<FlaggedTransaction> get flaggedTransactions => _flaggedTransactions;

  Future<void> fetchFlaggedTransactions(BuildContext context, int testId) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var testsModel = Provider.of<TestsModel>(context, listen: false);

    //Fetch the flagged transactions
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testsModel.getSelectedTestId
      };

    _flaggedTransactions = await _crudService.getJsonRecords<FlaggedTransaction>(
      context,
      'dbo.sproc_get_flagged_transactions',
      params,
      (json) => FlaggedTransaction.fromJson(json),
    );
    notifyListeners();
  }
  
}
