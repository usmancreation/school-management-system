import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String _academicYear = '2025-2026';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get academicYear => _academicYear;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('/auth/login', {
        'username': username,
        'password': password,
      });

      if (res is Map<String, dynamic>) {
        final token = res['accessToken'];
        ApiClient.token = token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        _currentUser = UserModel.fromJson(res['user']);
        if (res.containsKey('academicYear') && res['academicYear'] != null) {
          _academicYear = res['academicYear']['name'] ?? '2025-2026';
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Invalid server response format');
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    ApiClient.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
