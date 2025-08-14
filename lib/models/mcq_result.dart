class MCQResult {
  final String name;
  final String roll;
  final String email;
  final int correctAnswers;
  final int totalQuestions;
  final int marksObtained;
  final double percentage;

  MCQResult({
    required this.name,
    required this.roll,
    required this.email,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.marksObtained,
    required this.percentage,
  });

  factory MCQResult.fromJson(Map<String, dynamic> json) {
    return MCQResult(
      name: json['name'] ?? 'Unknown',
      roll: json['roll'] ?? 'Unknown',
      email: json['email'] ?? 'No email provided',
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      marksObtained: json['marks_obtained'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'roll': roll,
      'email': email,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'marksObtained': marksObtained,
      'percentage': percentage,
    };
  }
}

class MCQResponse {
  final List<MCQResult> output;

  MCQResponse({required this.output});

  factory MCQResponse.fromJson(Map<String, dynamic> json) {
    if (json['output'] != null) {
      var outputList = json['output'] as List;
      List<MCQResult> results =
          outputList.map((item) => MCQResult.fromJson(item)).toList();
      return MCQResponse(output: results);
    }
    return MCQResponse(output: []);
  }
}
