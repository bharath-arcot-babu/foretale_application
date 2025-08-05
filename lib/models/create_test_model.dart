//core
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

class BusinessRisk {
  int riskId;
  String riskCategory;
  String riskStatement;
  String description;

  BusinessRisk({
    this.riskId = 0,
    this.riskCategory = '',
    this.riskStatement = '',
    this.description = '',
  });

  factory BusinessRisk.fromJson(Map<String, dynamic> map) {
    return BusinessRisk(
      riskId: map['risk_id'] ?? 0,
      riskCategory: map['risk_category'] ?? '',
      riskStatement: map['risk_statement'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'risk_id': riskId,
      'risk_category': riskCategory,
      'risk_statement': riskStatement,
      'description': description,
    };
  }
}

class BusinessAction {
  int actionId;
  String actionCategory;
  String businessAction;
  String description;

  BusinessAction({
    this.actionId = 0,
    this.actionCategory = '',
    this.businessAction = '',
    this.description = '',
  });

  factory BusinessAction.fromJson(Map<String, dynamic> map) {
    return BusinessAction(
      actionId: map['action_id'] ?? 0,
      actionCategory: map['action_category'] ?? '',
      businessAction: map['business_action'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_id': actionId,
      'action_category': actionCategory,
      'business_action': businessAction,
      'description': description,
    };
  }
}

class CreateTest {
  int testId;
  String testName;
  String testDescription;
  String technicalDescription;
  String potentialImpact;
  String industry;
  String projectType;
  String topic;
  String? runType;
  String? criticality;
  String? category;
  String? module;
  String? runProgram;
  String chosenMetricType;
  String impactSummary;
  Map<String, dynamic> metricDetails;
  String createdBy;
  String createdDate;
  String lastUpdatedBy;
  String lastUpdatedDate;
  List<BusinessRisk> businessRisks;
  List<BusinessAction> businessActions;

  CreateTest({
    this.testId = 0,
    this.testName = '',
    this.testDescription = '',
    this.technicalDescription = '',
    this.potentialImpact = '',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.runType,
    this.criticality,
    this.category,
    this.module,
    this.runProgram,
    this.chosenMetricType = '',
    this.impactSummary = '',
    this.metricDetails = const {},
    this.createdBy = '',
    this.createdDate = '',
    this.lastUpdatedBy = '',
    this.lastUpdatedDate = '',
    this.businessRisks = const [],
    this.businessActions = const [],
  });

  factory CreateTest.fromJson(Map<String, dynamic> map) {
    return CreateTest(
      testId: map['test_id'] ?? 0,
      testName: map['test_name'] ?? '',
      testDescription: map['test_description'] ?? '',
      technicalDescription: map['technical_description'] ?? '',
      potentialImpact: map['potential_impact'] ?? '',
      industry: map['industry'] ?? '',
      projectType: map['project_type'] ?? '',
      topic: map['topic'] ?? '',
      runType: map['run_type'],
      criticality: map['criticality'],
      category: map['category'],
      module: map['module'],
      runProgram: map['run_program'],
      chosenMetricType: map['chosen_metric_type'] ?? '',
      impactSummary: map['impact_summary'] ?? '',
      metricDetails: map['metric_details'] ?? {},
      createdBy: map['created_by'] ?? '',
      createdDate: map['created_date'] ?? '',
      lastUpdatedBy: map['last_updated_by'] ?? '',
      lastUpdatedDate: map['last_updated_date'] ?? '',
      businessRisks: map.containsKey('business_risks')
          ? List<BusinessRisk>.from((map['business_risks'] as List)
              .map((x) => BusinessRisk.fromJson(x)))
          : [],
      businessActions: map.containsKey('business_actions')
          ? List<BusinessAction>.from((map['business_actions'] as List)
              .map((x) => BusinessAction.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'test_name': testName,
      'test_description': testDescription,
      'technical_description': technicalDescription,
      'potential_impact': potentialImpact,
      'industry': industry,
      'project_type': projectType,
      'topic': topic,
      'run_type': runType,
      'criticality': criticality,
      'category': category,
      'module': module,
      'run_program': runProgram,
      'chosen_metric_type': chosenMetricType,
      'impact_summary': impactSummary,
      'metric_details': metricDetails,
      'created_by': createdBy,
      'created_date': createdDate,
      'last_updated_by': lastUpdatedBy,
      'last_updated_date': lastUpdatedDate,
      'business_risks': businessRisks.map((risk) => risk.toJson()).toList(),
      'business_actions': businessActions.map((action) => action.toJson()).toList()
    };
  }
}

class CreateTestModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  CreateTest currentTest = CreateTest();
  List<CreateTest> testList = [];
  List<CreateTest> get getTestList => testList;

  List<CreateTest> filteredTestList = [];
  List<CreateTest> get getFilteredTestList => filteredTestList;

  int _selectedTestId = 0;
  int get getSelectedTestId => _selectedTestId;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  bool _isAiMagicProcessing = false;
  bool get getIsAiMagicProcessing => _isAiMagicProcessing;

  // Getters for current test
  String get getTestName => currentTest.testName;
  String get getTestDescription => currentTest.testDescription;
  String get getTechnicalDescription => currentTest.technicalDescription;
  String get getPotentialImpact => currentTest.potentialImpact;
  String get getIndustry => currentTest.industry;
  String get getProjectType => currentTest.projectType;
  String get getTopic => currentTest.topic;
  String? get getRunType => currentTest.runType;
  String? get getCriticality => currentTest.criticality;
  String? get getCategory => currentTest.category;
  String? get getModule => currentTest.module;
  String? get getRunProgram => currentTest.runProgram;
  String get getChosenMetricType => currentTest.chosenMetricType;
  List<BusinessRisk> get getBusinessRisks => currentTest.businessRisks;
  List<BusinessAction> get getBusinessActions => currentTest.businessActions;

  // Setters for current test
  void setTestName(String value) {
    currentTest.testName = value;
    notifyListeners();
  }

  void setTestDescription(String value) {
    currentTest.testDescription = value;
    notifyListeners();
  }

  void setTechnicalDescription(String value) {
    currentTest.technicalDescription = value;
    notifyListeners();
  }

  void setPotentialImpact(String value) {
    currentTest.potentialImpact = value;
    notifyListeners();
  }

  void setIndustry(String value) {
    currentTest.industry = value;
    notifyListeners();
  }

  void setProjectType(String value) {
    currentTest.projectType = value;
    notifyListeners();
  }

  void setTopic(String value) {
    currentTest.topic = value;
    notifyListeners();
  }

  void setRunType(String? value) {
    currentTest.runType = value;
    notifyListeners();
  }

  void setCriticality(String? value) {
    currentTest.criticality = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    currentTest.category = value;
    notifyListeners();
  }

  void setModule(String? value) {
    currentTest.module = value;
    notifyListeners();
  }

  void setRunProgram(String? value) {
    currentTest.runProgram = value;
    notifyListeners();
  }

  void setChosenMetricType(String value) {
    currentTest.chosenMetricType = value;
    notifyListeners();
  }

  // Business Risks Management
  void addBusinessRisk(String description, {String category = '', String severityLevel = 'Medium'}) {
    final newRisk = BusinessRisk(
      riskId: DateTime.now().millisecondsSinceEpoch,
      riskCategory: category,
      riskStatement: description.trim(),
      description: description.trim(),
    );
    currentTest.businessRisks = List.from(currentTest.businessRisks)..add(newRisk);
    notifyListeners();
  }

  void removeBusinessRisk(int riskId) {
    currentTest.businessRisks = currentTest.businessRisks.where((risk) => risk.riskId != riskId).toList();
    notifyListeners();
  }

  void updateBusinessRisk(int riskId, String description, {String category = '', String severityLevel = 'Low'}) {
    final index = currentTest.businessRisks.indexWhere((risk) => risk.riskId == riskId);
    if (index != -1) {
      currentTest.businessRisks[index] = BusinessRisk(
        riskId: riskId,
        riskCategory: category,
        riskStatement: description.trim(),
        description: description.trim(),
      );
      notifyListeners();
    }
  }

  void clearBusinessRisks() {
    currentTest.businessRisks = [];
    notifyListeners();
  }

  // Business Actions Management
  void addBusinessAction(String description, {String category = '', String priorityLevel = 'Medium'}) {
    final newAction = BusinessAction(
      actionId: DateTime.now().millisecondsSinceEpoch,
      actionCategory: category,
      businessAction: description.trim(),
      description: description.trim(),
    );
    currentTest.businessActions = List.from(currentTest.businessActions)..add(newAction);
    notifyListeners();
  }

  void removeBusinessAction(int actionId) {
    currentTest.businessActions = currentTest.businessActions.where((action) => action.actionId != actionId).toList();
    notifyListeners();
  }

  void updateBusinessAction(int actionId, String description, {String category = '', String? priorityLevel = 'Low'}) {
    final index = currentTest.businessActions.indexWhere((action) => action.actionId == actionId);
    if (index != -1) {
      currentTest.businessActions[index] = BusinessAction(
        actionId: actionId,
        actionCategory: category,
        businessAction: description.trim(),
        description: description.trim(),
      );
      notifyListeners();
    }
  }

  void clearBusinessActions() {
    currentTest.businessActions = [];
    notifyListeners();
  }

  // Loading States Management
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setAiMagicProcessing(bool value) {
    _isAiMagicProcessing = value;
    notifyListeners();
  }

  // Selection Management
  void updateSelectedTestId(int testId) {
    _selectedTestId = testId;
    notifyListeners();
  }

  // Reset all data
  void reset() {
    currentTest = CreateTest();
    _selectedTestId = 0;
    _isLoading = false;
    _isAiMagicProcessing = false;
    notifyListeners();
  }

  // CRUD Operations
  Future<int> saveTest(BuildContext context) async {
    try {
      setLoading(true);
      
      var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      
      // Convert business risks to JSON string for TVP
      String risksJson = jsonEncode(currentTest.businessRisks.map((risk) => {
        'risk_category': risk.riskCategory,
        'risk_statement': risk.riskStatement,
        'description': risk.description,
      }).toList());
      
      // Convert business actions to JSON string for TVP
      String actionsJson = jsonEncode(currentTest.businessActions.map((action) => {
        'action_category': action.actionCategory,
        'business_action': action.businessAction,
        'description': action.description,
      }).toList());

      Map<String, dynamic> params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': currentTest.testId,
        'test_name': currentTest.testName,
        'test_description': currentTest.testDescription,
        'technical_description': currentTest.technicalDescription,
        'potential_impact': currentTest.potentialImpact,
        'industry': currentTest.industry,
        'project_type': currentTest.projectType,
        'topic': currentTest.topic,
        'run_type': currentTest.runType,
        'criticality': currentTest.criticality,
        'category': currentTest.category,
        'module': currentTest.module,
        'run_program': currentTest.runProgram,
        'chosen_metric_type': currentTest.chosenMetricType,
        'created_by': userDetailsModel.getUserMachineId,
        'business_risks': risksJson,
        'business_actions': actionsJson
      };

      int insertedId = await _crudService.addRecord(
        context,
        'dbo.sproc_insert_test',
        params,
      );

      if (insertedId > 0) {
        currentTest.testId = insertedId;
        notifyListeners();
      }

      return insertedId;
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}