import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limpiar el texto de cualquier caracter que no sea número
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si después de limpiar no queda nada, retornar vacío
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Convertir a número
    double value = double.parse(newText);

    // Formatear el número
    String formatted = _formatter.format(value).trim();

    // Calcular la nueva posición del cursor
    // Esto es necesario porque al agregar puntos, la longitud cambia
    int selectionIndex = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
