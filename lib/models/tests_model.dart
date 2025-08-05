//core
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/config_s3.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';
import 'package:foretale_application/core/services/websocket_service.dart';

class Test {
  int testId;
  String testName;
  String testDescription;
  String topicName;
  String subtopicName;
  String testCriticality;
  String testRunType;
  String testCategory;
  String config;
  bool isSelected;
  String relevantSchemaName;
  String testConfigGenerationStatus;
  String testConfigExecutionStatus;
  String testCode;
  int projectTestId;
  String selectClause;
  String technicalDescription;
  String analysisTableName;
  bool markAsCompleted;
  String testRunProgram;
  String aiSummary;
  String aiKeyTables;
  String aiKeyColumns;
  String aiKeyCriteria;
  String aiAmbiguities;
  String aiResolvedJoins;
  String aiFormattedSqlQuery;
  String module;
  String testConfigExecutionMessage;
  String testConfigGenerationMessage;

  Test({
    this.testId = 0,
    this.testName = '',
    this.testDescription = '',
    this.topicName = '',
    this.subtopicName = '',
    this.testCriticality = '',
    this.testRunType = '',
    this.testCategory = '',
    this.config = '',
    this.isSelected = false,
    this.relevantSchemaName = '',
    this.testConfigGenerationStatus = '',
    this.testConfigExecutionStatus = '',
    this.testCode = '',
    this.projectTestId = 0,
    this.selectClause = '',
    this.technicalDescription = '',
    this.analysisTableName = '',
    this.markAsCompleted = false,
    this.testRunProgram = '',
    this.aiSummary = '',
    this.aiKeyTables = '',
    this.aiKeyColumns = '',
    this.aiKeyCriteria = '',
    this.aiAmbiguities = '',
    this.aiResolvedJoins = '',
    this.aiFormattedSqlQuery = '',
    this.module = '',
    this.testConfigExecutionMessage = '',
    this.testConfigGenerationMessage = '',
  });

  factory Test.fromJson(Map<String, dynamic> map) {
 
    return Test(
      testId: map['test_id'] ?? 0,
      testName: map['test_name'] ?? '',
      testDescription: map['test_description'] ?? '',
      topicName: map['topic_name'] ?? '',
      subtopicName: map['sub_topic_name'] ?? '',
      testCriticality: map['test_criticality'] ?? '',
      testRunType: map['test_run_type'] ?? '',
      testCategory: map['test_category'] ?? '',
      config: map['config'] ?? '',
      isSelected: bool.tryParse(map['is_selected']) ?? false,
      relevantSchemaName: map['relevant_schema_name'] ?? '',
      testConfigGenerationStatus: map['config_generation_status'] ?? '',
      testConfigExecutionStatus: map['config_execution_status'] ?? '',
      testCode: map['test_code'] ?? '',
      projectTestId: map['project_test_id'] ?? 0,
      selectClause: map['select_clause'] ?? '',
      technicalDescription: map['technical_description'] ?? '',
      analysisTableName: map['analysis_table_name'] ?? '',
      markAsCompleted: bool.tryParse(map['mark_as_completed']) ?? false,
      testRunProgram: map['run_program'] ?? '',
      aiSummary: map['ai_summary'] ?? '',
      aiKeyTables: map['ai_key_tables'] ?? '',
      aiKeyColumns: map['ai_key_columns'] ?? '',
      aiKeyCriteria: map['ai_key_criteria'] ?? '',
      aiAmbiguities: map['ai_ambiguities'] ?? '',
      aiResolvedJoins: map['ai_join_hints'] ?? '',
      module: map['module'] ?? '',
      testConfigExecutionMessage: map['config_execution_message'] ?? '',
      testConfigGenerationMessage: map['config_generation_message'] ?? '',
    );
  }
}

class TestExecutionStatus {
  int testExecutionLogId;
  int projectId;
  int testId;
  int projectTestId;
  String status;
  String message;

  TestExecutionStatus({
    this.testExecutionLogId = 0,
    this.projectId = 0,
    this.testId = 0,
    this.projectTestId = 0,
    this.status = '',
    this.message = '',
  });

  factory TestExecutionStatus.fromJson(Map<String, dynamic> map) {
    return TestExecutionStatus(
      testExecutionLogId: map['execution_id'] ?? 0,
      projectId: map['project_id'] ?? 0,
      testId: map['test_id'] ?? 0,
      projectTestId: map['project_test_id'] ?? 0,
      status: map['config_execution_status'] ?? '',
      message: map['config_execution_message'] ?? '',
    );
  }
}

class TestsModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();
  List<Test> testsList = [];
  List<Test> get getTestsList => testsList;

  List<Test> filteredTestsList = [];
  List<Test> get getFilteredTestList => filteredTestsList;

  int _selectedTestId = 0;
  int get getSelectedTestId => _selectedTestId;

  String _currentSortColumn = 'testName';
  String get getCurrentSortColumn => _currentSortColumn;
  DataGridSortDirection currentSortDirection = DataGridSortDirection.descending;
  DataGridSortDirection get getCurrentSortDirection => currentSortDirection;

  Test get getSelectedTest => testsList.firstWhere((test) => test.testId == _selectedTestId);

  Future<void> updateTestIdSelection(int testId) async {
    _selectedTestId = testId;
    notifyListeners();
  }
  


  void updateSortColumn(String sortColumnName) {
    if (_currentSortColumn == sortColumnName) {
      currentSortDirection =
          (currentSortDirection == DataGridSortDirection.descending)
              ? DataGridSortDirection.ascending
              : DataGridSortDirection.descending;
    } else {
      _currentSortColumn = sortColumnName;
      currentSortDirection = DataGridSortDirection.descending;
    }

    notifyListeners();
  }

  Future<void> filterData(String query) async {
    String lowerCaseQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredTestsList = List.from(testsList);
    } else {
      filteredTestsList = testsList.where((test) {
        return test.testName.toLowerCase().contains(lowerCaseQuery) ||
            test.testDescription.toLowerCase().contains(lowerCaseQuery) ||
            test.testCategory.toLowerCase().contains(lowerCaseQuery) ||
            test.testRunType.toLowerCase().contains(lowerCaseQuery) ||
            test.testCriticality.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    notifyListeners();
  }

  void _updateTestList(int testId, bool isSelected) {
    var index = testsList.indexWhere((q) => q.testId == testId);
    if (index != -1) {
      testsList[index].isSelected = isSelected;
    }

    notifyListeners();
  }

  @override
  int get selectedId => getSelectedTestId;

  Future<void> fetchTestsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'project_type_id': projectDetailsModel.getProjectTypeId,
      'industry_id': projectDetailsModel.getIndustryId,
    };

    testsList = await _crudService.getRecords<Test>(
      context,
      'dbo.sproc_get_tests_by_project',
      params,
      (json) => Test.fromJson(json),
    );

    filteredTestsList = testsList;

    notifyListeners();
  }

  Future<int> insertTestExecutionLog(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'project_test_id': test.projectTestId,
      'test_code': test.testCode,
      'test_name': test.testName,
      'config': test.config,
      'status': 'Running',
      'message': 'Test execution running',
      'created_by': userDetailsModel.getUserMachineId,
    };


    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_test_execution_log',
      params,
    );

    return insertedId;
  }

  Future<void> updateTestConfigGenerationStatus(int testId, String testConfigGenerationStatus) async {
    var index = testsList.indexWhere((q) => q.testId == testId);
    if (index != -1) {
      testsList[index].testConfigGenerationStatus = testConfigGenerationStatus;
    }
    notifyListeners();
  }

  Future<void> updateTestExecutionStatusToRunning(BuildContext context, Test test) async {
    var index = testsList.indexWhere((q) => q.testId == test.testId);

    if (index != -1) {
      testsList[index].testConfigExecutionStatus = 'Running';
      testsList[index].testConfigExecutionMessage = 'Test execution running';

      test.testConfigExecutionStatus = testsList[index].testConfigExecutionStatus;
      test.testConfigExecutionMessage = testsList[index].testConfigExecutionMessage;
    }

    notifyListeners();
  }

  Future<void> executeTest(BuildContext context,Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'project_test_id': test.projectTestId,
      'test_code': test.testCode,
      'test_name': test.testName,
      'config': test.config,
      'status': 'Running',
      'message': 'Test execution running',
      'created_by': userDetailsModel.getUserMachineId,
    };

    unawaited(_crudService.updateRecord(
      context,
      'dbo.sproc_execute_config_sql',
      params,
    ).catchError((e){
      debugPrint("Error executing test: $e");
    }));
  }

  Future<int> updateTestExecutionLog(
      BuildContext context, 
      Test test, 
      String status, 
      String message, 
      String errorMessage, 
      String errorStackTrace,
      String errorSource,
      String severityLevel,
      String requestPath
    ) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'project_test_id': test.projectTestId,
      'status': status,
      'message': message,
      'error_message': errorMessage,
      'error_stack_trace': errorStackTrace,
      'error_source': errorSource,
      'severity_level': severityLevel,
      'request_path': requestPath,
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_insert_update_test_execution_log',
      params,
    );

    return updatedId;
  }


  Future<int> selectTest(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'config': test.config,
      'created_by': userDetailsModel.getUserMachineId,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_test_project',
      params,
    );

    if (insertedId > 0) {
      _updateTestList(test.testId, true);
    }

    return insertedId;
  }

  Future<int> removeTest(BuildContext context, Test test) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_assigned_test',
      params,
    );

    if (deletedId > 0) {
      _updateTestList(test.testId, false);
    }

    return deletedId;
  }

  Future<int> updateProjectTestConfig(BuildContext context, Test test) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'config': test.config,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_project_test_config',
      params,
    );

    return updatedId;
  }

  Future<int> updateTestCompletion(BuildContext context, Test test, bool status) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'status': status,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_mark_test_completion_status',
      params,
    );

    return updatedId;
  }

  void updatedTestCompletionOffline(Test test, bool status) {
    var index = testsList.indexWhere((q) => q.testId == test.testId);
    if (index != -1) {
      testsList[index].markAsCompleted = status;
    }
    notifyListeners();
  }

  Future<void> fetchTestExecutionStatus(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    String commaSeparatedRunningTestIds = 
      testsList
      .where((test) => test.testConfigExecutionStatus == 'Running')
      .map((test) => test.testId.toString())
      .join(',');

    if(commaSeparatedRunningTestIds.isEmpty){
      return;
    }
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id_list': commaSeparatedRunningTestIds,
    };

    List<TestExecutionStatus> executionStatusList = await _crudService.getRecords<TestExecutionStatus>(
      context,
      'dbo.sproc_get_test_status_by_project',
      params,
      (json) => TestExecutionStatus.fromJson(json),
    );

    for (var executionStatus in executionStatusList) {
      var index = testsList.indexWhere((q) => q.testId == executionStatus.testId);
      if (index != -1) {
        testsList[index].testConfigExecutionStatus = executionStatus.status;
        testsList[index].testConfigExecutionMessage = executionStatus.message;
      }
    }

    notifyListeners();
  }

  @override
  Future<void> fetchResponses(BuildContext context) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.fetchResponsesByReference(context, getSelectedTestId, 'test');
  }

  @override
  Future<int> insertResponse(BuildContext context, String responseText) {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.insertResponseByReference(context, getSelectedTestId, 'test', responseText);
  }

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseTestAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  int getSelectedId(BuildContext context) => selectedId;

  @override
  String getDrivingModelName(BuildContext context) => 'Test';

  @override
  String getWebSocketUrl(BuildContext context) => StreamingForQueryGeneration.streaming;

  @override
  Future<void> sendMessage(BuildContext context, String message, WebSocketService? webSocketService) async {
    if (webSocketService == null) return;
    
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    var projectModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userModel = Provider.of<UserDetailsModel>(context, listen: false);
    var test = getSelectedTest;

    await webSocketService.send({
            "test_case": test.testName,
            "test_description": test.technicalDescription,
            "past_user_responses": inquiryResponseModel.getSortedResponseTexts.join("\n"),
            "schema_name": test.relevantSchemaName,
            "project_id": projectModel.getActiveProjectId,
            "test_id": test.testId.toString(),
            "last_updated_by": userModel.getUserMachineId,
            "default_config": test.config,
            "select_clause": test.selectClause,
            "financial_impact_statement": "",
            "last_response": message
        });
  }

  @override
  Future<int> updateConfig(BuildContext context, Map<dynamic, dynamic> parsedData, {bool finalUpdate = false})async{
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    

    final finalState = parsedData['data'] is Map ? Map<String, dynamic>.from(parsedData['data']) : {};
    int updatedId = 0;

    var test = getSelectedTest;
    test.aiSummary = finalState['summary']?.toString() ?? '';
    test.aiKeyTables = finalState['key_tables'] is List 
        ? finalState['resolved_tables'].toString() 
        : finalState['resolved_tables']?.toString() ?? '';
    test.aiKeyColumns = finalState['key_columns'] is List 
        ? finalState['resolved_columns'].toString() 
        : finalState['resolved_columns']?.toString() ?? '';
    test.aiKeyCriteria = finalState['key_criteria'] is List
        ? finalState['key_criteria'].toString() 
        : finalState['key_criteria']?.toString() ?? '';
    test.aiAmbiguities = finalState['ambiguities'] is List 
        ? finalState['ambiguities'].toString() 
        : finalState['ambiguities']?.toString() ?? '';
    test.aiResolvedJoins = finalState['resolved_joins'] is List 
        ? finalState['key_join_hints'].toString() 
        : finalState['key_join_hints']?.toString() ?? '';
    test.aiFormattedSqlQuery = finalState['formatted_sql_query'] is Map 
        ? finalState['formatted_sql_query']['formatted_sql']?.toString() ?? ''
        : finalState['formatted_sql_query']?.toString() ?? '';

    if(finalState['type'] == 'error'){
      test.testConfigGenerationStatus = 'Failed';
      test.testConfigGenerationMessage = finalState['message']?.toString() ?? '';
    } else {
      test.testConfigGenerationStatus = 'Completed';
      test.testConfigGenerationMessage = 'Processing completed successfully.';
    }
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': getSelectedTestId,
      'ai_summary': test.aiSummary,
      'ai_key_tables': test.aiKeyTables,
      'ai_key_columns': test.aiKeyColumns,
      'ai_key_criteria': test.aiKeyCriteria,
      'ai_join_hints': test.aiResolvedJoins,
      'ai_ambiguities': test.aiAmbiguities,
      'ai_full_state': "",
      'config': test.aiFormattedSqlQuery,
      'initial_state': "",
      'config_generation_status': test.testConfigGenerationStatus,
      'config_generation_message': test.testConfigGenerationMessage,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_project_test_config',
      params,
    );

    if(updatedId > 0){
      var index = testsList.indexWhere((q) => q.testId == getSelectedTestId);
      if (index != -1) {
        testsList[index].config = test.aiFormattedSqlQuery;
        testsList[index].testConfigGenerationStatus = 'Completed';
      }

      notifyListeners();
    }

    return updatedId;
  }
}
