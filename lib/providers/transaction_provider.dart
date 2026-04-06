import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String _searchQuery = '';
  TransactionType? _typeFilter;
  String? _categoryFilter;
  DateTimeRange? _dateFilter;

  List<TransactionModel> get transactions => _transactions;
  String get searchQuery => _searchQuery;
  TransactionType? get typeFilter => _typeFilter;
  String? get categoryFilter => _categoryFilter;
  DateTimeRange? get dateFilter => _dateFilter;

  List<TransactionModel> get incomes =>
      _transactions.where((t) => t.type == TransactionType.income).toList();

  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  // ── Filtros ────────────────────────────────────────────────────────────────

  List<TransactionModel> get filtered {
    var list = List.of(_transactions);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false) ||
            (t.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }
    if (_categoryFilter != null) {
      list = list.where((t) => t.categoryId == _categoryFilter).toList();
    }
    if (_dateFilter != null) {
      list = list.where((t) {
        return !t.date.isBefore(_dateFilter!.start) &&
            !t.date.isAfter(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }
    return list;
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setCategoryFilter(String? id) {
    _categoryFilter = id;
    notifyListeners();
  }

  void setDateFilter(DateTimeRange? range) {
    _dateFilter = range;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _typeFilter = null;
    _categoryFilter = null;
    _dateFilter = null;
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _typeFilter != null ||
      _categoryFilter != null ||
      _dateFilter != null;

  // ── Carga ──────────────────────────────────────────────────────────────────

  TransactionProvider() {
    loadTransactions();
  }

  void loadTransactions() {
    final box = HiveService.getTransactionsBox();
    _transactions = box.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // ── Consultas por mes ─────────────────────────────────────────────────────

  List<TransactionModel> getTransactionsByMonth(DateTime month) =>
      _transactions.where((t) =>
          t.date.year == month.year && t.date.month == month.month).toList();

  List<TransactionModel> getIncomesByMonth(DateTime month) =>
      getTransactionsByMonth(month)
          .where((t) => t.type == TransactionType.income)
          .toList();

  List<TransactionModel> getExpensesByMonth(DateTime month) =>
      getTransactionsByMonth(month)
          .where((t) => t.type == TransactionType.expense)
          .toList();

  double getTotalIncome([DateTime? month]) {
    final list = month != null ? getIncomesByMonth(month) : incomes;
    return list.fold(0.0, (s, t) => s + t.amount);
  }

  double getTotalExpense([DateTime? month]) {
    final list = month != null ? getExpensesByMonth(month) : expenses;
    return list.fold(0.0, (s, t) => s + t.amount);
  }

  double getBalance([DateTime? month]) =>
      getTotalIncome(month) - getTotalExpense(month);

  // ── Por categoría ─────────────────────────────────────────────────────────

  Map<String, double> getExpensesByCategory([DateTime? month]) {
    final list = month != null ? getExpensesByMonth(month) : expenses;
    final map = <String, double>{};
    for (final t in list) {
      map.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return map;
  }

  Map<String, double> getIncomesByCategory([DateTime? month]) {
    final list = month != null ? getIncomesByMonth(month) : incomes;
    final map = <String, double>{};
    for (final t in list) {
      map.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return map;
  }

  // ── Por rango de fechas ───────────────────────────────────────────────────

  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) =>
      _transactions.where((t) =>
          !t.date.isBefore(start) &&
          !t.date.isAfter(end.add(const Duration(days: 1)))).toList();

  List<TransactionModel> getTransactionsByCategory(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).toList();

  List<TransactionModel> getTransactionsByAccount(String accountId) =>
      _transactions.where((t) => t.accountId == accountId).toList();

  // ── Evolución mensual ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> getMonthlyEvolution({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final month = DateTime(now.year, now.month - (months - 1 - i), 1);
      final income  = getTotalIncome(month);
      final expense = getTotalExpense(month);
      return {
        'month':   month,
        'income':  income,
        'expense': expense,
        'balance': income - expense,
      };
    });
  }

  // ── Gastos recurrentes ─────────────────────────────────────────────────────

  List<TransactionModel> getRecurringExpenses() =>
      expenses.where((t) => t.isRecurring).toList();

  double getTotalRecurring() =>
      getRecurringExpenses().fold(0.0, (s, t) => s + t.amount);

  // ── Últimas N transacciones ───────────────────────────────────────────────

  List<TransactionModel> getRecent({int count = 5}) =>
      _transactions.take(count).toList();

  // ── Tasa de ahorro ────────────────────────────────────────────────────────

  double getSavingsRate([DateTime? month]) {
    final income = getTotalIncome(month);
    if (income <= 0) return 0;
    final expense = getTotalExpense(month);
    return ((income - expense) / income * 100).clamp(0.0, 100.0);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? description,
    bool isRecurring = false,
    String? accountId,
    String? notes,
  }) async {
    final t = TransactionModel(
      id:          const Uuid().v4(),
      title:       title,
      amount:      amount,
      type:        type,
      categoryId:  categoryId,
      date:        date,
      description: description,
      isRecurring: isRecurring,
      accountId:   accountId,
      notes:       notes,
    );
    final box = HiveService.getTransactionsBox();
    await box.add(t);
    loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await t.save();
    loadTransactions();
  }

  Future<void> deleteTransaction(TransactionModel t) async {
    await t.delete();
    loadTransactions();
  }
}
