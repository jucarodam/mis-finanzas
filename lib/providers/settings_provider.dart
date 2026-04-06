import 'package:flutter/material.dart';
import '../database/hive_service.dart';
import '../models/budget_model.dart';

class SettingsProvider extends ChangeNotifier {
  BudgetModel? _budget;

  BudgetModel? get budget => _budget;
  double get monthlyLimit       => _budget?.monthlyLimit ?? 0;
  double get warningPercentage  => _budget?.warningPercentage ?? 80.0;
  String get currency           => _budget?.currency ?? 'COP';

  SettingsProvider() {
    loadSettings();
  }

  void loadSettings() {
    final box = HiveService.getBudgetBox();
    if (box.isNotEmpty) {
      _budget = box.getAt(0);
      notifyListeners();
    }
  }

  Future<void> updateMonthlyLimit(double limit) async {
    if (_budget == null) return;
    _budget!.monthlyLimit = limit;
    await _budget!.save();
    notifyListeners();
  }

  Future<void> updateWarningPercentage(double pct) async {
    if (_budget == null) return;
    _budget!.warningPercentage = pct;
    await _budget!.save();
    notifyListeners();
  }

  Future<void> updateCurrency(String c) async {
    if (_budget == null) return;
    _budget!.currency = c;
    await _budget!.save();
    notifyListeners();
  }

  bool shouldShowWarning(double currentExpense) {
    if (_budget == null || _budget!.monthlyLimit <= 0) return false;
    return (currentExpense / _budget!.monthlyLimit * 100) >= _budget!.warningPercentage;
  }

  double getExpensePercentage(double currentExpense) {
    if (_budget == null || _budget!.monthlyLimit <= 0) return 0;
    return (currentExpense / _budget!.monthlyLimit * 100).clamp(0.0, 100.0);
  }
}
