import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double monthlyLimit;

  @HiveField(2)
  double warningPercentage; // Porcentaje para notificar (ej: 80%)

  @HiveField(3)
  String currency;

  @HiveField(4)
  bool isDarkMode;

  BudgetModel({
    required this.id,
    this.monthlyLimit = 0,
    this.warningPercentage = 80.0,
    this.currency = 'COP',
    this.isDarkMode = false,
  });

  BudgetModel copyWith({
    String? id,
    double? monthlyLimit,
    double? warningPercentage,
    String? currency,
    bool? isDarkMode,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      warningPercentage: warningPercentage ?? this.warningPercentage,
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthlyLimit': monthlyLimit,
      'warningPercentage': warningPercentage,
      'currency': currency,
      'isDarkMode': isDarkMode,
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      monthlyLimit: json['monthlyLimit'] ?? 0,
      warningPercentage: json['warningPercentage'] ?? 80.0,
      currency: json['currency'] ?? 'COP',
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }
}
