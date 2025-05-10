//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/s3_config.dart';
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
  String defaultConfig;

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
    this.defaultConfig = '',
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
      defaultConfig: map['default_config'] ?? '',
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

  Future<void> fetchTestsByProject(BuildContext context) async {
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

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

  Future<int> selectTest(BuildContext context, Test test) async {
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

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
    var userDetailsModel =
        Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
      'config': test.config,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int deletedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_project_test_config',
      params,
    );

    if (deletedId > 0) {
      _updateTestList(test.testId, false);
    }

    return deletedId;
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

  @override
  Future<void> fetchResponses(BuildContext context) {
    return Provider.of<InquiryResponseModel>(context, listen: false)
        .fetchResponsesByTest(context);
  }

  @override
  Future<int> insertResponse(BuildContext context, String responseText) {
    return Provider.of<InquiryResponseModel>(context, listen: false)
        .insertResponseByTest(context, responseText);
  }

  @override
  String buildStoragePath({
    required String projectId,
    required String responseId,
  }) {
    return '${S3Config.baseResponseTestAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel =
        Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(
      projectId: projectDetailsModel.getActiveProjectId.toString(),
      responseId: responseId.toString(),
    );
  }

  @override
  int getSelectedId(BuildContext context) => selectedId;
}
