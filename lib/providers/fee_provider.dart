import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/invoice_model.dart';

class FeeProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/fees/invoices');
      if (res is List) {
        _invoices = res.map((item) => InvoiceModel.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> collectFee({
    required String invoiceId,
    required double amount,
    required String paymentMode,
    String? referenceNumber,
  }) async {
    try {
      await ApiClient.post('/fees/collect', {
        'invoiceId': invoiceId,
        'amount': amount,
        'paymentMode': paymentMode,
        'referenceNumber': referenceNumber ?? '',
      });
      await fetchInvoices();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
