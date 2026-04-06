import 'package:flutter/material.dart';

class AppConstants {
  // ── Paleta principal ──────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark    = Color(0xFF4F46E5); // Indigo-600
  static const Color secondaryColor = Color(0xFFA855F7); // Purple-500
  static const Color accentColor    = Color(0xFF06B6D4); // Cyan-500

  // ── Semánticos ────────────────────────────────────────────────────────────
  static const Color incomeColor  = Color(0xFF10B981); // Emerald-500
  static const Color expenseColor = Color(0xFFEF4444); // Red-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor   = Color(0xFFEF4444);
  static const Color savingsColor = Color(0xFF8B5CF6); // Violet-500

  // Alias compatibilidad
  static const Color incomColor = incomeColor;

  // ── Fondos tema claro ─────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF1F5F9); // Slate-100
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);

  // ── Fondos tema oscuro ────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A14);
  static const Color darkSurface    = Color(0xFF12121F);
  static const Color darkCard       = Color(0xFF1C1C2E);
  static const Color darkBorder     = Color(0x14FFFFFF); // white 8%

  // ── Colores de cuentas ────────────────────────────────────────────────────
  static const List<int> accountColors = [
    0xFF6366F1, // Indigo
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFF8B5CF6, // Violet
    0xFF06B6D4, // Cyan
    0xFFF97316, // Orange
    0xFF14B8A6, // Teal
    0xFFEC4899, // Pink
    0xFF64748B, // Slate
  ];

  // ── Íconos de categorías ──────────────────────────────────────────────────
  static const List<String> categoryIcons = [
    '🍔', '🍕', '☕', '🛒', '🍻', '🍷', '🍰', '🍎',
    '🏠', '💡', '💧', '⚡', '🌐', '📞', '🛠️', '🛏️',
    '🚗', '⛽', '🚕', '🚌', '🚲', '✈️', '🔧', '🅿️',
    '💈', '💇', '💅', '🧴', '💪', '⚕️', '💊', '🧘',
    '🎮', '🎬', '🍿', '🎟️', '🎳', '🎨', '🎵', '📚',
    '🛍️', '👕', '👟', '👗', '👠', '👓', '💍', '🎁',
    '💸', '💰', '🏦', '💳', '💼', '📈', '💵', '🪙',
    '🐕', '🐱', '🐾', '🦴',
    '🎓', '👶', '🌟', '🎯', '💻', '📱', '🏖️', '🗺️',
    '🏋️', '🚴', '🏊', '⚽', '🎾', '🎸', '🏔️', '🌿',
  ];

  // ── Íconos de cuentas ─────────────────────────────────────────────────────
  static const List<String> accountIcons = [
    '💵', '🏦', '💳', '💰', '🪙', '🏧', '📊', '💎',
    '🏠', '🚗', '📱', '💼',
  ];

  // ── Divisas soportadas ────────────────────────────────────────────────────
  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'COP', 'name': 'Peso Colombiano',   'symbol': '\$',  'flag': '🇨🇴'},
    {'code': 'USD', 'name': 'Dólar Americano',   'symbol': '\$',  'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro',              'symbol': '€',   'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'Libra Esterlina',   'symbol': '£',   'flag': '🇬🇧'},
    {'code': 'MXN', 'name': 'Peso Mexicano',     'symbol': '\$',  'flag': '🇲🇽'},
    {'code': 'ARS', 'name': 'Peso Argentino',    'symbol': '\$',  'flag': '🇦🇷'},
    {'code': 'BRL', 'name': 'Real Brasileño',    'symbol': 'R\$', 'flag': '🇧🇷'},
    {'code': 'PEN', 'name': 'Sol Peruano',       'symbol': 'S/',  'flag': '🇵🇪'},
    {'code': 'CLP', 'name': 'Peso Chileno',      'symbol': '\$',  'flag': '🇨🇱'},
    {'code': 'CAD', 'name': 'Dólar Canadiense',  'symbol': 'CA\$','flag': '🇨🇦'},
    {'code': 'JPY', 'name': 'Yen Japonés',       'symbol': '¥',   'flag': '🇯🇵'},
    {'code': 'CHF', 'name': 'Franco Suizo',      'symbol': 'Fr',  'flag': '🇨🇭'},
    {'code': 'CNY', 'name': 'Yuan Chino',        'symbol': '¥',   'flag': '🇨🇳'},
    {'code': 'VES', 'name': 'Bolívar Venezolano','symbol': 'Bs',  'flag': '🇻🇪'},
  ];

  // ── Meses ─────────────────────────────────────────────────────────────────
  static const List<String> months = [
    'Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre',
  ];

  static const List<String> monthsShort = [
    'Ene','Feb','Mar','Abr','May','Jun',
    'Jul','Ago','Sep','Oct','Nov','Dic',
  ];

  // ── Espaciado ─────────────────────────────────────────────────────────────
  static const double paddingXS     = 4.0;
  static const double paddingSmall  = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge  = 24.0;
  static const double paddingXL     = 32.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXL     = 24.0;
  static const double radiusXXL    = 32.0;

  // ── Alias legacy ─────────────────────────────────────────────────────────
  static const double borderRadiusSmall  = radiusSmall;
  static const double borderRadiusMedium = radiusMedium;
  static const double borderRadiusLarge  = radiusLarge;
}
