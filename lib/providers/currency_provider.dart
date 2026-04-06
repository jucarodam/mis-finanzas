import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/hive_service.dart';

class CurrencyProvider extends ChangeNotifier {
  // Tasas relativas a USD (1 USD = X moneda)
  Map<String, double> _rates = _fallbackRates;
  String _displayCurrency = 'COP';
  bool _isLoading = false;
  bool _lastFetchFailed = false;
  DateTime? _lastFetched;

  // Tasas de reserva actualizadas (Abril 2026, aproximadas)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'COP': 4200.0,
    'MXN': 17.2,
    'ARS': 890.0,
    'BRL': 5.05,
    'PEN': 3.75,
    'CLP': 950.0,
    'CAD': 1.36,
    'JPY': 149.0,
    'CHF': 0.89,
    'CNY': 7.24,
    'VES': 36.5,
  };

  String get displayCurrency => _displayCurrency;
  bool get isLoading => _isLoading;
  bool get lastFetchFailed => _lastFetchFailed;
  DateTime? get lastFetched => _lastFetched;
  Map<String, double> get rates => Map.unmodifiable(_rates);

  CurrencyProvider() {
    _loadCached();
    fetchRates();
  }

  // ── Carga desde Hive ───────────────────────────────────────────────────────
  void _loadCached() {
    try {
      final box = HiveService.getExchangeRatesBox();
      final currency = box.get('displayCurrency');
      if (currency != null) _displayCurrency = currency;

      final ratesJson = box.get('rates');
      if (ratesJson != null) {
        final decoded = jsonDecode(ratesJson) as Map<String, dynamic>;
        _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }

      final ts = box.get('lastFetched');
      if (ts != null) _lastFetched = DateTime.tryParse(ts);
    } catch (_) {}
  }

  Future<void> _saveToCache() async {
    try {
      final box = HiveService.getExchangeRatesBox();
      await box.put('displayCurrency', _displayCurrency);
      await box.put('rates', jsonEncode(_rates));
      await box.put('lastFetched', DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // ── Fetch de tasas desde API ───────────────────────────────────────────────
  Future<void> fetchRates() async {
    // Si ya hay datos de hoy, no volver a hacer fetch
    if (_lastFetched != null) {
      final diff = DateTime.now().difference(_lastFetched!);
      if (diff.inHours < 6 && !_lastFetchFailed) return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final apiRates = data['rates'] as Map<String, dynamic>;
          _rates = {};
          for (final entry in apiRates.entries) {
            _rates[entry.key] = (entry.value as num).toDouble();
          }
          _lastFetchFailed = false;
          _lastFetched = DateTime.now();
          await _saveToCache();
        }
      } else {
        _lastFetchFailed = true;
      }
    } catch (_) {
      _lastFetchFailed = true;
      // Mantener tasas de reserva si no hay cache
      if (_rates.isEmpty) _rates = Map.of(_fallbackRates);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Conversión ─────────────────────────────────────────────────────────────

  /// Convierte [amount] desde [fromCurrency] hacia [toCurrency]
  double convert(double amount, {required String from, required String to}) {
    if (from == to) return amount;
    final fromRate = _rates[from] ?? 1.0;
    final toRate   = _rates[to]   ?? 1.0;
    // from → USD → to
    return amount / fromRate * toRate;
  }

  /// Convierte [amount] desde la moneda base al display currency
  double toDisplay(double amount, {String baseCurrency = 'COP'}) {
    return convert(amount, from: baseCurrency, to: _displayCurrency);
  }

  // ── Cambiar moneda de visualización ───────────────────────────────────────
  Future<void> setDisplayCurrency(String currency) async {
    if (_displayCurrency == currency) return;
    _displayCurrency = currency;
    await _saveToCache();
    notifyListeners();
  }

  // ── Info de divisa ─────────────────────────────────────────────────────────
  String getSymbol(String currency) {
    const symbols = {
      'COP': '\$', 'USD': '\$', 'EUR': '€', 'GBP': '£',
      'MXN': '\$', 'ARS': '\$', 'BRL': 'R\$', 'PEN': 'S/',
      'CLP': '\$', 'CAD': 'CA\$', 'JPY': '¥', 'CHF': 'Fr',
      'CNY': '¥', 'VES': 'Bs',
    };
    return symbols[currency] ?? '\$';
  }

  String getName(String currency) {
    const names = {
      'COP': 'Peso Colombiano', 'USD': 'Dólar Americano',
      'EUR': 'Euro', 'GBP': 'Libra Esterlina',
      'MXN': 'Peso Mexicano', 'ARS': 'Peso Argentino',
      'BRL': 'Real Brasileño', 'PEN': 'Sol Peruano',
      'CLP': 'Peso Chileno', 'CAD': 'Dólar Canadiense',
      'JPY': 'Yen Japonés', 'CHF': 'Franco Suizo',
      'CNY': 'Yuan Chino', 'VES': 'Bolívar Venezolano',
    };
    return names[currency] ?? currency;
  }

  String getFlag(String currency) {
    const flags = {
      'COP': '🇨🇴', 'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧',
      'MXN': '🇲🇽', 'ARS': '🇦🇷', 'BRL': '🇧🇷', 'PEN': '🇵🇪',
      'CLP': '🇨🇱', 'CAD': '🇨🇦', 'JPY': '🇯🇵', 'CHF': '🇨🇭',
      'CNY': '🇨🇳', 'VES': '🇻🇪',
    };
    return flags[currency] ?? '🌐';
  }

  /// Tasa de cambio: 1 unidad de [from] en términos de [to]
  double getRate(String from, String to) {
    if (from == to) return 1.0;
    final fromRate = _rates[from] ?? 1.0;
    final toRate   = _rates[to]   ?? 1.0;
    return toRate / fromRate;
  }
}
