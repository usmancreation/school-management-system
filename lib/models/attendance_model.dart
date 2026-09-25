class AttendanceModel {
  final String studentId;
  final String admissionNumber;
  final String firstName;
  final String lastName;
  final String rollNumber;
  String attendanceStatus; // PRESENT, ABSENT, LATE, UNMARKED
  String? remarks;

  AttendanceModel({
    required this.studentId,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.rollNumber,
    required this.attendanceStatus,
    this.remarks,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentId: json['student_id'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      rollNumber: json['roll_number'] ?? '',
      attendanceStatus: json['attendance_status'] ?? 'UNMARKED',
      remarks: json['remarks'],
    );
  }
}
