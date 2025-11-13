import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  List<TransactionModel> get incomes =>
      _transactions.where((t) => t.type == TransactionType.income).toList();

  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  TransactionProvider() {
    loadTransactions();
  }

  void loadTransactions() {
    final box = HiveService.getTransactionsBox();
    _transactions = box.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Obtener transacciones del mes actual
  List<TransactionModel> getTransactionsByMonth(DateTime month) {
    return _transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();
  }

  // Obtener ingresos del mes
  List<TransactionModel> getIncomesByMonth(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.income)
        .toList();
  }

  // Obtener gastos del mes
  List<TransactionModel> getExpensesByMonth(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.expense)
        .toList();
  }

  // Calcular total de ingresos
  double getTotalIncome([DateTime? month]) {
    final relevantIncomes = month != null
        ? getIncomesByMonth(month)
        : incomes;
    return relevantIncomes.fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calcular total de gastos
  double getTotalExpense([DateTime? month]) {
    final relevantExpenses = month != null
        ? getExpensesByMonth(month)
        : expenses;
    return relevantExpenses.fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calcular balance disponible
  double getBalance([DateTime? month]) {
    return getTotalIncome(month) - getTotalExpense(month);
  }

  // Obtener gastos por categoría
  Map<String, double> getExpensesByCategory([DateTime? month]) {
    final relevantExpenses = month != null
        ? getExpensesByMonth(month)
        : expenses;

    final Map<String, double> expensesByCategory = {};
    for (var transaction in relevantExpenses) {
      expensesByCategory.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return expensesByCategory;
  }

  // Obtener ingresos por categoría
  Map<String, double> getIncomesByCategory([DateTime? month]) {
    final relevantIncomes = month != null
        ? getIncomesByMonth(month)
        : incomes;

    final Map<String, double> incomesByCategory = {};
    for (var transaction in relevantIncomes) {
      incomesByCategory.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return incomesByCategory;
  }

  // Obtener transacciones por rango de fechas
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Obtener transacciones por categoría
  List<TransactionModel> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // CRUD Operations
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? description,
    bool isRecurring = false,
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      description: description,
      isRecurring: isRecurring,
    );

    final box = HiveService.getTransactionsBox();
    await box.add(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await transaction.save();
    loadTransactions();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await transaction.delete();
    loadTransactions();
  }

  // Obtener gastos recurrentes
  List<TransactionModel> getRecurringExpenses() {
    return expenses.where((t) => t.isRecurring).toList();
  }

  // Obtener evolución mensual (últimos 6 meses)
  List<Map<String, dynamic>> getMonthlyEvolution() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> evolution = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final income = getTotalIncome(month);
      final expense = getTotalExpense(month);

      evolution.add({
        'month': month,
        'income': income,
        'expense': expense,
        'balance': income - expense,
      });
    }

    return evolution;
  }
}
