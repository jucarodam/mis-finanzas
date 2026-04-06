import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/account_model.dart';

class AccountProvider extends ChangeNotifier {
  List<AccountModel> _accounts = [];

  List<AccountModel> get accounts => List.unmodifiable(_accounts);

  AccountProvider() {
    loadAccounts();
  }

  void loadAccounts() {
    final box = HiveService.getAccountsBox();
    _accounts = box.values
        .map((s) => AccountModel.fromJsonString(s))
        .toList();
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addAccount({
    required String name,
    required AccountType type,
    double balance = 0.0,
    required int colorValue,
    String icon = '💵',
    String currency = 'COP',
  }) async {
    final account = AccountModel(
      id:         const Uuid().v4(),
      name:       name,
      type:       type,
      balance:    balance,
      colorValue: colorValue,
      icon:       icon,
      currency:   currency,
    );
    final box = HiveService.getAccountsBox();
    await box.put(account.id, account.toJsonString());
    loadAccounts();
  }

  Future<void> updateAccount(AccountModel account) async {
    final box = HiveService.getAccountsBox();
    await box.put(account.id, account.toJsonString());
    loadAccounts();
  }

  Future<void> deleteAccount(String id) async {
    final box = HiveService.getAccountsBox();
    await box.delete(id);
    loadAccounts();
  }

  // ── Operaciones de balance ─────────────────────────────────────────────────

  Future<void> adjustBalance(String accountId, double delta) async {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx == -1) return;
    _accounts[idx].balance += delta;
    await updateAccount(_accounts[idx]);
  }

  Future<void> transferBetween({
    required String fromId,
    required String toId,
    required double amount,
  }) async {
    await adjustBalance(fromId, -amount);
    await adjustBalance(toId, amount);
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  AccountModel? getById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Saldo neto total (excluye tarjetas de crédito que sumarían negativo)
  double get totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + a.balance);

  /// Saldo neto excluyendo crédito
  double get netWorth => _accounts
      .where((a) => a.type != AccountType.credit)
      .fold(0.0, (sum, a) => sum + a.balance);
}
