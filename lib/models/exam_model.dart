class ExamModel {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isPublished;
  final int totalPapers;

  ExamModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isPublished,
    required this.totalPapers,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      isPublished: json['is_published'] ?? false,
      totalPapers: json['total_papers'] ?? 0,
    );
  }
}

class ExamMarkModel {
  final String id;
  final String studentId;
  final String admissionNumber;
  final String firstName;
  final String lastName;
  final String subjectName;
  final double theoryMarks;
  final double practicalMarks;
  final double totalObtained;
  final double maxMarks;

  ExamMarkModel({
    required this.id,
    required this.studentId,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.subjectName,
    required this.theoryMarks,
    required this.practicalMarks,
    required this.totalObtained,
    required this.maxMarks,
  });

  String get studentName => '$firstName $lastName'.trim();
  double get percentage => maxMarks > 0 ? (totalObtained / maxMarks) * 100 : 0.0;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }

  factory ExamMarkModel.fromJson(Map<String, dynamic> json) {
    return ExamMarkModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      theoryMarks: (json['theory_marks_obtained'] as num?)?.toDouble() ?? 0.0,
      practicalMarks: (json['practical_marks_obtained'] as num?)?.toDouble() ?? 0.0,
      totalObtained: (json['total_obtained'] as num?)?.toDouble() ?? 0.0,
      maxMarks: (json['max_marks'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
