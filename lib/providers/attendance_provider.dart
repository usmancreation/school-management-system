import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  List<AttendanceModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  Future<void> fetchAttendance([DateTime? date]) async {
    if (date != null) _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final res = await ApiClient.get('/attendance?date=$dateStr');
      if (res is List) {
        _records = res.map((item) => AttendanceModel.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void updateStatus(String studentId, String newStatus) {
    final idx = _records.indexWhere((r) => r.studentId == studentId);
    if (idx != -1) {
      _records[idx].attendanceStatus = newStatus;
      notifyListeners();
    }
  }

  Future<bool> saveAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final payload = {
        'date': dateStr,
        'records': _records.map((r) => {
          'studentId': r.studentId,
          'status': r.attendanceStatus == 'UNMARKED' ? 'PRESENT' : r.attendanceStatus,
          'remarks': r.remarks ?? '',
        }).toList()
      };

      await ApiClient.post('/attendance', payload);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
