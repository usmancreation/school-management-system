import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/teacher_model.dart';

class TeacherProvider extends ChangeNotifier {
  List<TeacherModel> _teachers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TeacherModel> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTeachers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/teachers');
      if (res is List) {
        _teachers = res.map((item) => TeacherModel.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> addTeacher({
    required String firstName,
    required String lastName,
    required String designation,
    required String gender,
    required String email,
    required String phone,
    required double basicSalary,
  }) async {
    try {
      await ApiClient.post('/teachers', {
        'firstName': firstName,
        'lastName': lastName,
        'designation': designation,
        'gender': gender,
        'email': email,
        'phone': phone,
        'basicSalary': basicSalary,
      });
      await fetchTeachers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
