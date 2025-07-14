import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ExecutionStats {
  final int totalTests;
  final int executedTests;
  final int pendingTests;
  final int reviewCompleted;
  final int reviewPending;
  final int withObservations;
  final int withoutObservations;
  final int acceptedFindings;
  final int otherFindings;

  ExecutionStats({
    this.totalTests = 0,
    this.executedTests = 0,
    this.pendingTests = 0,
    this.reviewCompleted = 0,
    this.reviewPending = 0,
    this.withObservations = 0,
    this.withoutObservations = 0,
    this.acceptedFindings = 0,
    this.otherFindings = 0,
  });

  factory ExecutionStats.fromJson(Map<String, dynamic> json) {
    return ExecutionStats(
      totalTests: json['total_tests_selected'] ?? 0,
      executedTests: json['tests_executed'] ?? 0,
      pendingTests: json['tests_pending'] ?? 0,
      reviewCompleted: json['tests_reviewed'] ?? 0,
      reviewPending: json['tests_pending_review'] ?? 0,
      withObservations: json['tests_with_observations'] ?? 0,
      withoutObservations: json['tests_without_observations'] ?? 0,
      acceptedFindings: json['tests_with_accepted_findings'] ?? 0,
      otherFindings: json['tests_with_other_findings'] ?? 0,
    );
  }
}

class ExecutionStatsModel {
  final CRUD _crudService = CRUD();
  ExecutionStats executionStats = ExecutionStats();

  Future<void> getExecutionStats(BuildContext context) async {

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    final result = await _crudService.getRecords<ExecutionStats>(
      context,
      'dbo.sproc_get_report_execution_statistics',
      params,
      (json) => ExecutionStats.fromJson(json),
    );

    if (result.isNotEmpty) {
      executionStats = result.first;
    }
  }
}