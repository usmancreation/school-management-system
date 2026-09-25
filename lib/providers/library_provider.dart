import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/book_model.dart';

class LibraryProvider extends ChangeNotifier {
  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/library/books');
      if (res is List) {
        _books = res.map((b) => BookModel.fromJson(b)).toList();
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
