import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) return _displayDateFormat.format(date);
    try {
      final parsed = DateTime.parse(date.toString());
      return _displayDateFormat.format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final numVal = num.tryParse(amount.toString()) ?? 0;
    return _currencyFormat.format(numVal);
  }
}
