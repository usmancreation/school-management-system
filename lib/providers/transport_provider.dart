import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/route_model.dart';

class TransportProvider extends ChangeNotifier {
  List<TransportRouteModel> _routes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransportRouteModel> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/transport/routes');
      if (res is List) {
        _routes = res.map((r) => TransportRouteModel.fromJson(r)).toList();
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

