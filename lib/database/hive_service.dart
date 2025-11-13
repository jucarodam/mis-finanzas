import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class HiveService {
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetBox = 'budget';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());

    // Abrir boxes
    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<BudgetModel>(budgetBox);

    // Inicializar datos por defecto si es primera vez
    await _initDefaultData();
  }

  static Future<void> _initDefaultData() async {
    final categoriesDb = Hive.box<CategoryModel>(categoriesBox);
    final budgetDb = Hive.box<BudgetModel>(budgetBox);

    // Categorías por defecto si no existen
    if (categoriesDb.isEmpty) {
      final defaultCategories = [
        // Categorías de Gastos
        CategoryModel(
          id: '1',
          name: 'Alimentación',
          icon: '🍔',
          colorValue: 0xFFFF6B6B,
          isExpense: true,
        ),
        CategoryModel(
          id: '2',
          name: 'Vivienda',
          icon: '🏠',
          colorValue: 0xFF4ECDC4,
          isExpense: true,
        ),
        CategoryModel(
          id: '3',
          name: 'Servicios',
          icon: '💡',
          colorValue: 0xFF95E1D3,
          isExpense: true,
        ),
        CategoryModel(
          id: '4',
          name: 'Transporte',
          icon: '🚗',
          colorValue: 0xFFFECA57,
          isExpense: true,
        ),
        CategoryModel(
          id: '5',
          name: 'Entretenimiento',
          icon: '🎮',
          colorValue: 0xFFEE5A6F,
          isExpense: true,
        ),
        CategoryModel(
          id: '6',
          name: 'Gimnasio',
          icon: '💪',
          colorValue: 0xFF6C5CE7,
          isExpense: true,
        ),
        CategoryModel(
          id: '7',
          name: 'Salud',
          icon: '⚕️',
          colorValue: 0xFF00B894,
          isExpense: true,
        ),
        CategoryModel(
          id: '8',
          name: 'Educación',
          icon: '📚',
          colorValue: 0xFF0984E3,
          isExpense: true,
        ),
        CategoryModel(
          id: '9',
          name: 'Compras',
          icon: '🛍️',
          colorValue: 0xFFFD79A8,
          isExpense: true,
        ),
        CategoryModel(
          id: '10',
          name: 'Otros Gastos',
          icon: '💸',
          colorValue: 0xFFB2BEC3,
          isExpense: true,
        ),
        // Categorías de Ingresos
        CategoryModel(
          id: '11',
          name: 'Salario',
          icon: '💰',
          colorValue: 0xFF00D2D3,
          isExpense: false,
        ),
        CategoryModel(
          id: '12',
          name: 'Ventas',
          icon: '🏪',
          colorValue: 0xFF54A0FF,
          isExpense: false,
        ),
        CategoryModel(
          id: '13',
          name: 'Proyectos',
          icon: '💼',
          colorValue: 0xFF48DBFB,
          isExpense: false,
        ),
        CategoryModel(
          id: '14',
          name: 'Comisiones',
          icon: '📈',
          colorValue: 0xFF1DD1A1,
          isExpense: false,
        ),
        CategoryModel(
          id: '15',
          name: 'Otros Ingresos',
          icon: '💵',
          colorValue: 0xFF10AC84,
          isExpense: false,
        ),
      ];

      for (var category in defaultCategories) {
        await categoriesDb.add(category);
      }
    }

    // Budget por defecto si no existe
    if (budgetDb.isEmpty) {
      final defaultBudget = BudgetModel(
        id: 'main',
        monthlyLimit: 0,
        warningPercentage: 80.0,
        currency: 'COP',
        isDarkMode: false,
      );
      await budgetDb.add(defaultBudget);
    }
  }

  static Box<TransactionModel> getTransactionsBox() {
    return Hive.box<TransactionModel>(transactionsBox);
  }

  static Box<CategoryModel> getCategoriesBox() {
    return Hive.box<CategoryModel>(categoriesBox);
  }

  static Box<BudgetModel> getBudgetBox() {
    return Hive.box<BudgetModel>(budgetBox);
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}
