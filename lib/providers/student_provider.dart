import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchStudents([String query = '']) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = query.isEmpty ? '/students' : '/students?search=${Uri.encodeComponent(query)}';
      final res = await ApiClient.get(endpoint);
      if (res is List) {
        _students = res.map((item) => StudentModel.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> admitStudent({
    required String firstName,
    required String lastName,
    required String gender,
    required String email,
    required String phone,
    required String address,
    required String bloodGroup,
  }) async {
    try {
      await ApiClient.post('/students', {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'email': email,
        'phone': phone,
        'address': address,
        'bloodGroup': bloodGroup,
      });
      await fetchStudents(_searchQuery);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
