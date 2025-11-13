import 'package:flutter/material.dart';
import '../database/hive_service.dart';
import '../models/budget_model.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final budgetBox = HiveService.getBudgetBox();
    if (budgetBox.isNotEmpty) {
      final budget = budgetBox.getAt(0);
      _isDarkMode = budget?.isDarkMode ?? false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final budgetBox = HiveService.getBudgetBox();
    if (budgetBox.isNotEmpty) {
      final budget = budgetBox.getAt(0);
      if (budget != null) {
        budget.isDarkMode = _isDarkMode;
        await budget.save();
      }
    }

    notifyListeners();
  }
}
