import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Símbolo por código de divisa
  static String symbol(String currency) {
    const symbols = {
      'COP': '\$', 'USD': '\$', 'EUR': '€', 'GBP': '£',
      'MXN': '\$', 'ARS': '\$', 'BRL': 'R\$', 'PEN': 'S/',
      'CLP': '\$', 'CAD': 'CA\$', 'JPY': '¥', 'CHF': 'Fr',
      'CNY': '¥', 'VES': 'Bs',
    };
    return symbols[currency] ?? '\$';
  }

  static int _decimals(String currency) {
    const noDecimals = {'COP', 'CLP', 'JPY', 'VES'};
    return noDecimals.contains(currency) ? 0 : 2;
  }

  static String _locale(String currency) {
    const locales = {
      'COP': 'es_CO', 'USD': 'en_US', 'EUR': 'de_DE',
      'GBP': 'en_GB', 'MXN': 'es_MX', 'ARS': 'es_AR',
      'BRL': 'pt_BR', 'PEN': 'es_PE', 'CLP': 'es_CL',
      'CAD': 'en_CA', 'JPY': 'ja_JP', 'CHF': 'de_CH',
      'CNY': 'zh_CN', 'VES': 'es_VE',
    };
    return locales[currency] ?? 'es_CO';
  }

  // Formato completo con símbolo: $ 1.250.000
  static String format(double amount, {String currency = 'COP'}) {
    final fmt = NumberFormat.currency(
      symbol: '${symbol(currency)} ',
      decimalDigits: _decimals(currency),
      locale: _locale(currency),
    );
    return fmt.format(amount);
  }

  // Solo número formateado sin símbolo
  static String formatNumber(double amount, {String currency = 'COP'}) {
    final dec = _decimals(currency);
    final pattern = '#,##0${dec > 0 ? '.${'0' * dec}' : ''}';
    return NumberFormat(pattern, _locale(currency)).format(amount);
  }

  // Compacto: $ 1.25M / $ 850K
  static String formatCompact(double amount, {String currency = 'COP'}) {
    final sym = symbol(currency);
    final abs = amount.abs();
    if (abs >= 1000000000) return '$sym ${(amount / 1000000000).toStringAsFixed(1)}B';
    if (abs >= 1000000)    return '$sym ${(amount / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000)       return '$sym ${(amount / 1000).toStringAsFixed(1)}K';
    return format(amount, currency: currency);
  }

  // Mini formato para cards: \$1.25M sin espacio
  static String formatShort(double amount, {String currency = 'COP'}) {
    final sym = symbol(currency);
    final abs = amount.abs();
    if (abs >= 1000000) return '$sym${(amount / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000)    return '$sym${(amount / 1000).toStringAsFixed(0)}K';
    return '$sym${amount.toStringAsFixed(_decimals(currency))}';
  }

  static double parse(String value) {
    final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}
