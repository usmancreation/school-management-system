class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['username'] ?? '',
      role: json['role'] ?? 'ROLE_ADMIN',
    );
  }
}
