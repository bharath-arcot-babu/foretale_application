//core
import 'package:flutter/material.dart';
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
  
  Future<void> updateTestConfigGenerationStatus(int testId, String testConfigGenerationStatus) async {
    var index = testsList.indexWhere((q) => q.testId == testId);
    if (index != -1) {
      testsList[index].testConfigGenerationStatus = testConfigGenerationStatus;
    }
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

  void filterData(String query) {
    String lowerCaseQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredTestsList = List.from(testsList);
    } else {
      filteredTestsList = filteredTestsList.where((test) {
        return test.testName.toLowerCase().contains(lowerCaseQuery) ||
            test.testDescription.toLowerCase().contains(lowerCaseQuery) ||
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
      'status': 'Started',
      'message': 'Test execution started',
      'created_by': userDetailsModel.getUserMachineId,
    };


    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_test_execution_log',
      params,
    );

    return insertedId;
  }

  Future<int> executeTest(BuildContext context, int executionLogId) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    final params = {
      'execution_id': executionLogId,
      'executed_by': userDetailsModel.getUserMachineId
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_execute_config_sql',
      params,
    );

    return updatedId;
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

  Future<int> createNewTest(
      BuildContext context, 
      String testName,
      String testDescription,
      String testTechnicalDescription,
      String industryName,
      String topicName,
      String subtopicName,
      String testRunType,
      String testRunProgram,
      String testCategory,
      String testModule,
      String testCriticality) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'name': testName,
      'description': testDescription,
      'technical_description': testTechnicalDescription,
      'industry_name': industryName,
      'topic_name': topicName,
      'sub_topic_name': subtopicName,
      'created_by': userDetailsModel.getUserMachineId,
      'run_type': testRunType,
      'run_program': testRunProgram,
      'category': testCategory,
      'module': testModule,
      'criticality': testCriticality,
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_test',
      params,
    );

    return insertedId;
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
}
