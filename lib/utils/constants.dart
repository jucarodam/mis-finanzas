import 'package:flutter/material.dart';

class AppConstants {
  // Colores
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  static const Color accentColor = Color(0xFF00D2D3);
  static const Color successColor = Color(0xFF00B894);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFECA57);

  // Iconos disponibles para categorías
  static const List<String> categoryIcons = [
    '🍔', '🏠', '💡', '🚗', '🎮', '💪', '⚕️', '📚',
    '🛍️', '💸', '💰', '🏪', '💼', '📈', '💵', '🎯',
    '🎨', '🎵', '✈️', '🍕', '☕', '🎬', '📱', '💻',
    '👕', '👟', '🎁', '🐕', '🐱', '🌟', '🔧', '🏋️',
  ];

  // Meses en español
  static const List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  // Padding y espaciado
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
}
