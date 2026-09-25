import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/dashboard_metrics.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardMetrics? _metrics;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/dashboard/metrics');
      if (res is Map<String, dynamic>) {
        _metrics = DashboardMetrics.fromJson(res);
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
