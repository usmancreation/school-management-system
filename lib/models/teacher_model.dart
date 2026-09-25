class TeacherModel {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String gender;
  final String designation;
  final double basicSalary;
  final String status;
  final String? email;
  final String? phone;

  TeacherModel({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.designation,
    required this.basicSalary,
    required this.status,
    this.email,
    this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? 'MALE',
      designation: json['designation'] ?? 'Teacher',
      basicSalary: (json['basic_salary'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
      email: json['email'],
      phone: json['phone'],
    );
  }
}
