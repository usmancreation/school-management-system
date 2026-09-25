class StudentModel {
  final String id;
  final String admissionNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? email;
  final String? phone;
  final String status;
  final String? className;
  final String? sectionName;
  final String? rollNumber;

  StudentModel({
    required this.id,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.email,
    this.phone,
    required this.status,
    this.className,
    this.sectionName,
    this.rollNumber,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? 'MALE',
      dateOfBirth: json['date_of_birth'],
      bloodGroup: json['blood_group'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'] ?? 'ENROLLED',
      className: json['class_name'] ?? 'Grade 10',
      sectionName: json['section_name'] ?? 'A',
      rollNumber: json['roll_number'] ?? '-',
    );
  }
}
