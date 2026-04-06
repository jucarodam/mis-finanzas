import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  List<GoalModel> _goals = [];

  List<GoalModel> get goals => List.unmodifiable(_goals);
  List<GoalModel> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  GoalProvider() {
    loadGoals();
  }

  void loadGoals() {
    final box = HiveService.getGoalsBox();
    _goals = box.values
        .map((s) => GoalModel.fromJsonString(s))
        .toList();
    _goals.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.progress.compareTo(a.progress);
    });
    notifyListeners();
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0.0,
    DateTime? deadline,
    required int colorValue,
    String icon = '🎯',
    String currency = 'COP',
  }) async {
    final goal = GoalModel(
      id:            const Uuid().v4(),
      name:          name,
      targetAmount:  targetAmount,
      currentAmount: currentAmount,
      deadline:      deadline,
      colorValue:    colorValue,
      icon:          icon,
      currency:      currency,
    );
    final box = HiveService.getGoalsBox();
    await box.put(goal.id, goal.toJsonString());
    loadGoals();
  }

  Future<void> updateGoal(GoalModel goal) async {
    final box = HiveService.getGoalsBox();
    await box.put(goal.id, goal.toJsonString());
    loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    final box = HiveService.getGoalsBox();
    await box.delete(id);
    loadGoals();
  }

  Future<void> addAmount(String goalId, double amount) async {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return;
    final goal = _goals[idx];
    final newCurrent = (goal.currentAmount + amount)
        .clamp(0.0, goal.targetAmount);
    final updated = goal.copyWith(
      currentAmount: newCurrent,
      isCompleted: newCurrent >= goal.targetAmount,
    );
    await updateGoal(updated);
  }

  GoalModel? getById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  double get totalTargetAmount =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get totalCurrentAmount =>
      _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
}
