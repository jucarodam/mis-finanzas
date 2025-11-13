import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.isExpense).toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => !c.isExpense).toList();

  CategoryProvider() {
    loadCategories();
  }

  void loadCategories() {
    final box = HiveService.getCategoriesBox();
    _categories = box.values.toList();
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory({
    required String name,
    required String icon,
    required int colorValue,
    required bool isExpense,
  }) async {
    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      colorValue: colorValue,
      isExpense: isExpense,
    );

    final box = HiveService.getCategoriesBox();
    await box.add(category);
    loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await category.save();
    loadCategories();
  }

  Future<void> deleteCategory(CategoryModel category) async {
    await category.delete();
    loadCategories();
  }
}
