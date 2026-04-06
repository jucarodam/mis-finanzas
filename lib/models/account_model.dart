import 'dart:convert';

enum AccountType { cash, bank, credit, savings, investment }

class AccountModel {
  final String id;
  String name;
  AccountType type;
  double balance;
  final int colorValue;
  String icon;
  String currency;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    required this.colorValue,
    this.icon = '💵',
    this.currency = 'COP',
  });

  String get typeName {
    switch (type) {
      case AccountType.cash:       return 'Efectivo';
      case AccountType.bank:       return 'Cuenta Bancaria';
      case AccountType.credit:     return 'Tarjeta de Crédito';
      case AccountType.savings:    return 'Ahorros';
      case AccountType.investment: return 'Inversión';
    }
  }

  String get typeIcon {
    switch (type) {
      case AccountType.cash:       return '💵';
      case AccountType.bank:       return '🏦';
      case AccountType.credit:     return '💳';
      case AccountType.savings:    return '🏧';
      case AccountType.investment: return '📈';
    }
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    int? colorValue,
    String? icon,
    String? currency,
  }) {
    return AccountModel(
      id:         id         ?? this.id,
      name:       name       ?? this.name,
      type:       type       ?? this.type,
      balance:    balance    ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
      icon:       icon       ?? this.icon,
      currency:   currency   ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'type':       type.index,
    'balance':    balance,
    'colorValue': colorValue,
    'icon':       icon,
    'currency':   currency,
  };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    id:         json['id'] as String,
    name:       json['name'] as String,
    type:       AccountType.values[json['type'] as int? ?? 0],
    balance:    (json['balance'] as num?)?.toDouble() ?? 0.0,
    colorValue: json['colorValue'] as int? ?? 0xFF6366F1,
    icon:       json['icon'] as String? ?? '💵',
    currency:   json['currency'] as String? ?? 'COP',
  );

  String toJsonString() => jsonEncode(toJson());

  factory AccountModel.fromJsonString(String s) =>
      AccountModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
