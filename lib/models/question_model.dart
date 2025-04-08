//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/handling_crud.dart';

class Question {
  String questionText;  
  String industry;
  String projectType;
  String topic;
  String status;        
  String createdDate; 
  String createdBy;     
  String lastUpdatedBy;  
  String lastUpdatedDate; 
  int questionId;    
  bool isSelected;

  Question({
    this.questionText ='',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.status = 'A',
    this.createdDate = '',
    this.createdBy = '',
    this.lastUpdatedBy = '',
    this.lastUpdatedDate = '',
    this.questionId = 0,
    this.isSelected = false
  });

  // A method to convert a map back into a model object (e.g., when fetching data from Firestore).
  factory Question.fromJson(Map<String, dynamic> map) {
    return Question(
      questionText: map['question_text']??'',
      industry: map['industry']??'',
      projectType: map['project_type']??'',
      topic: map['topic']??'',
      status: map['status']?? 'A',
      createdDate: map['created_date']??'',
      createdBy: map['created_by']??'',
      lastUpdatedBy: map['last_updated_by']??'',
      lastUpdatedDate: map['last_updated_date']??'',
      questionId: map['question_id']??0,
      isSelected: bool.tryParse(map['is_selected'])??false,
    );
  }
}

class QuestionsModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<Question> questionsList = [];
  List<Question> get getQuestionsList => questionsList;

  Future<void> fetchQuestionsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId
      };

    questionsList = await _crudService.getRecords<Question>(
      context,
      'dbo.sproc_get_questions_by_project_id',
      params,
      (json) => Question.fromJson(json),
    );  

    notifyListeners();
  }

  Future<int> selectQuestion(BuildContext context, Question question) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': question.questionId,
      'created_by': userDetailsModel.getUserMachineId, 
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_question_project',
      params,
    );

    if(insertedId>0){
      _updateQuestionList(question.questionId, true);
    }

    return insertedId;
  }

  Future<int> addNewQuestionByProjectId(BuildContext context, String questionText, String topic) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_text': questionText,
      'created_by': userDetailsModel.getUserMachineId, 
      'industry': projectDetailsModel.getIndustry,
      'project_type': projectDetailsModel.getProjectType,
      'topic': topic
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_new_question_by_project',
      params,
    );

    return insertedId;
  }

  Future<int> removeQuestion(BuildContext context, Question question) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

      final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'question_id': question.questionId,
        'last_updated_by': userDetailsModel.getUserMachineId
      };

      int deletedId = await _crudService.deleteRecord(
        context,
        'dbo.sproc_delete_assigned_question',
        params,
      );

      if(deletedId>0){
        _updateQuestionList(question.questionId, false);
      }

      return deletedId;
  }

  void _updateQuestionList(int questionId, bool isSelected) {
    var index = questionsList.indexWhere((q) => q.questionId == questionId);
    if (index != -1) {
      questionsList[index].isSelected = isSelected;
    }

    notifyListeners();
  }

}
