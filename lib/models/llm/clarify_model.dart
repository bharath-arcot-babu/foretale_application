class ClarifyOutputModel {
  String question;
  String reason;
  String answerType;

  ClarifyOutputModel({
    this.question = '',
    this.reason = '',
    this.answerType = '',
  });

  factory ClarifyOutputModel.fromJson(Map<String, dynamic> json) {
    return ClarifyOutputModel(
      question: json['question'] ?? '',
      reason: json['reason'] ?? '',
      answerType: json['answerType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'reason': reason,
      'answerType': answerType,
    };
  }
}
