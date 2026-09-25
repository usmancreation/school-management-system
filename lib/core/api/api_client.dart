import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:5050/api/v1';
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.get(uri, headers: _headers);
    return _handleResponse(res);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    return _handleResponse(res);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.put(uri, headers: _headers, body: jsonEncode(body));
    return _handleResponse(res);
  }

  static Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.delete(uri, headers: _headers);
    return _handleResponse(res);
  }

  static dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    } else {
      String msg = 'Server error (${res.statusCode})';
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
          msg = decoded['message'];
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
