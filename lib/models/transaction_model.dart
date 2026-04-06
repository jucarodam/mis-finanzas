import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? description;

  @HiveField(7)
  bool isRecurring;

  // Campos nuevos (compatibles con datos existentes — null para registros viejos)
  @HiveField(8)
  String? accountId;

  @HiveField(9)
  String? notes;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.description,
    this.isRecurring = false,
    this.accountId,
    this.notes,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? description,
    bool? isRecurring,
    String? accountId,
    String? notes,
  }) {
    return TransactionModel(
      id:          id          ?? this.id,
      title:       title       ?? this.title,
      amount:      amount      ?? this.amount,
      type:        type        ?? this.type,
      categoryId:  categoryId  ?? this.categoryId,
      date:        date        ?? this.date,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      accountId:   accountId   ?? this.accountId,
      notes:       notes       ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'amount':      amount,
    'type':        type.name,
    'categoryId':  categoryId,
    'date':        date.toIso8601String(),
    'description': description,
    'isRecurring': isRecurring,
    'accountId':   accountId,
    'notes':       notes,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id:          json['id'] as String,
      title:       json['title'] as String,
      amount:      (json['amount'] as num).toDouble(),
      type:        json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId:  json['categoryId'] as String,
      date:        DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      accountId:   json['accountId'] as String?,
      notes:       json['notes'] as String?,
    );
  }
}
