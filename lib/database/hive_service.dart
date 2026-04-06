import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class HiveService {
  static const String transactionsBox  = 'transactions';
  static const String categoriesBox    = 'categories';
  static const String budgetBox        = 'budget';
  static const String accountsBox      = 'accounts_v2';
  static const String goalsBox         = 'goals_v2';
  static const String exchangeRatesBox = 'exchange_rates';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());

    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<BudgetModel>(budgetBox);
    // Cajas JSON (String) para modelos nuevos
    await Hive.openBox<String>(accountsBox);
    await Hive.openBox<String>(goalsBox);
    await Hive.openBox<String>(exchangeRatesBox);

    await _initDefaultData();
  }

  static Future<void> _initDefaultData() async {
    final categoriesDb = Hive.box<CategoryModel>(categoriesBox);
    final budgetDb     = Hive.box<BudgetModel>(budgetBox);

    if (categoriesDb.isEmpty) {
      final defaults = [
        // Gastos
        CategoryModel(id: '1',  name: 'Alimentación',   icon: '🍔', colorValue: 0xFFEF4444, isExpense: true),
        CategoryModel(id: '2',  name: 'Vivienda',        icon: '🏠', colorValue: 0xFF06B6D4, isExpense: true),
        CategoryModel(id: '3',  name: 'Servicios',       icon: '💡', colorValue: 0xFF10B981, isExpense: true),
        CategoryModel(id: '4',  name: 'Transporte',      icon: '🚗', colorValue: 0xFFF59E0B, isExpense: true),
        CategoryModel(id: '5',  name: 'Entretenimiento', icon: '🎮', colorValue: 0xFFEC4899, isExpense: true),
        CategoryModel(id: '6',  name: 'Salud',           icon: '⚕️', colorValue: 0xFF8B5CF6, isExpense: true),
        CategoryModel(id: '7',  name: 'Educación',       icon: '📚', colorValue: 0xFF3B82F6, isExpense: true),
        CategoryModel(id: '8',  name: 'Compras',         icon: '🛍️', colorValue: 0xFFF97316, isExpense: true),
        CategoryModel(id: '9',  name: 'Restaurantes',    icon: '🍽️', colorValue: 0xFFDC2626, isExpense: true),
        CategoryModel(id: '10', name: 'Suscripciones',   icon: '📱', colorValue: 0xFF7C3AED, isExpense: true),
        CategoryModel(id: '11', name: 'Gimnasio',        icon: '💪', colorValue: 0xFF059669, isExpense: true),
        CategoryModel(id: '12', name: 'Otros Gastos',    icon: '💸', colorValue: 0xFF64748B, isExpense: true),
        // Ingresos
        CategoryModel(id: '13', name: 'Salario',         icon: '💰', colorValue: 0xFF10B981, isExpense: false),
        CategoryModel(id: '14', name: 'Freelance',       icon: '💻', colorValue: 0xFF6366F1, isExpense: false),
        CategoryModel(id: '15', name: 'Ventas',          icon: '🏪', colorValue: 0xFF0EA5E9, isExpense: false),
        CategoryModel(id: '16', name: 'Inversiones',     icon: '📈', colorValue: 0xFF14B8A6, isExpense: false),
        CategoryModel(id: '17', name: 'Arriendo',        icon: '🏘️', colorValue: 0xFF8B5CF6, isExpense: false),
        CategoryModel(id: '18', name: 'Otros Ingresos',  icon: '💵', colorValue: 0xFF22C55E, isExpense: false),
      ];
      for (final c in defaults) {
        await categoriesDb.add(c);
      }
    }

    if (budgetDb.isEmpty) {
      await budgetDb.add(BudgetModel(
        id: 'main',
        monthlyLimit: 0,
        warningPercentage: 80.0,
        currency: 'COP',
        isDarkMode: false,
      ));
    }
  }

  static Box<TransactionModel> getTransactionsBox() =>
      Hive.box<TransactionModel>(transactionsBox);

  static Box<CategoryModel> getCategoriesBox() =>
      Hive.box<CategoryModel>(categoriesBox);

  static Box<BudgetModel> getBudgetBox() =>
      Hive.box<BudgetModel>(budgetBox);

  static Box<String> getAccountsBox() =>
      Hive.box<String>(accountsBox);

  static Box<String> getGoalsBox() =>
      Hive.box<String>(goalsBox);

  static Box<String> getExchangeRatesBox() =>
      Hive.box<String>(exchangeRatesBox);

  static Future<void> dispose() async => Hive.close();
}
