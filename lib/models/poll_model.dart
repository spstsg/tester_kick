import 'package:cloud_firestore/cloud_firestore.dart';

class PollModel {
  String pollId;
  String question;
  List answers;
  int totalVotes;
  Map pollResultPercentage;
  String pollEnd;
  String status;
  Timestamp createdAt;

  PollModel({
    this.pollId = '',
    this.question = '',
    this.pollEnd = '',
    this.answers = const [],
    this.pollResultPercentage = const {},
    totalVotes,
    createdAt,
    status,
  })  : this.createdAt = createdAt ?? Timestamp.now(),
        this.totalVotes = totalVotes ?? 0,
        this.status = status ?? 'live';

  factory PollModel.fromJson(Map<String, dynamic> parsedJson) {
    List _answers = parsedJson['answers'] ?? [];
    return new PollModel(
      pollId: parsedJson['pollId'] ?? '',
      question: parsedJson['question'] ?? '',
      pollEnd: parsedJson['pollEnd'] ?? '',
      status: parsedJson['status'] ?? 'live',
      answers: _answers,
      totalVotes: parsedJson['totalVotes'] ?? 0,
      pollResultPercentage: parsedJson['pollResultPercentage'] ?? {},
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollId': this.pollId,
      'question': this.question,
      'pollEnd': this.pollEnd,
      'answers': this.answers,
      'totalVotes': this.totalVotes,
      'pollResultPercentage': this.pollResultPercentage,
      'createdAt': this.createdAt,
      'status': this.status,
    };
  }
}
