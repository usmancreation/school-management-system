import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/exam_model.dart';

class ExamProvider extends ChangeNotifier {
  List<ExamModel> _exams = [];
  List<ExamMarkModel> _marks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExamModel> get exams => _exams;
  List<ExamMarkModel> get marks => _marks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExamsAndMarks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final examsRes = await ApiClient.get('/exams');
      if (examsRes is List) {
        _exams = examsRes.map((e) => ExamModel.fromJson(e)).toList();
      }

      final marksRes = await ApiClient.get('/exams/marks');
      if (marksRes is List) {
        _marks = marksRes.map((m) => ExamMarkModel.fromJson(m)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}
