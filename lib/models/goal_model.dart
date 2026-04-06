import 'dart:convert';

class GoalModel {
  final String id;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime? deadline;
  final int colorValue;
  String icon;
  String currency;
  bool isCompleted;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.colorValue,
    this.icon = '🎯',
    this.currency = 'COP',
    this.isCompleted = false,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isOverdue =>
      deadline != null && !isCompleted && deadline!.isBefore(DateTime.now());

  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  GoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    int? colorValue,
    String? icon,
    String? currency,
    bool? isCompleted,
  }) {
    return GoalModel(
      id:            id            ?? this.id,
      name:          name          ?? this.name,
      targetAmount:  targetAmount  ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline:      deadline      ?? this.deadline,
      colorValue:    colorValue    ?? this.colorValue,
      icon:          icon          ?? this.icon,
      currency:      currency      ?? this.currency,
      isCompleted:   isCompleted   ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
    'targetAmount':  targetAmount,
    'currentAmount': currentAmount,
    'deadline':      deadline?.toIso8601String(),
    'colorValue':    colorValue,
    'icon':          icon,
    'currency':      currency,
    'isCompleted':   isCompleted,
  };

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id:            json['id'] as String,
    name:          json['name'] as String,
    targetAmount:  (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
    deadline:      json['deadline'] != null
        ? DateTime.tryParse(json['deadline'] as String)
        : null,
    colorValue:    json['colorValue'] as int? ?? 0xFF8B5CF6,
    icon:          json['icon'] as String? ?? '🎯',
    currency:      json['currency'] as String? ?? 'COP',
    isCompleted:   json['isCompleted'] as bool? ?? false,
  );

  String toJsonString() => jsonEncode(toJson());

  factory GoalModel.fromJsonString(String s) =>
      GoalModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
