import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _copFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _copFormatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return format(amount);
  }

  static double parse(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}
