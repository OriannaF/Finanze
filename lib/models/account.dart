import 'package:flutter/material.dart';

enum AccountType { cash, debit, credit, savings }

class Account {
  final int? id;
  final String name;
  final double balance;
  final AccountType type;
  final String icon;
  final String color;
  final bool isCountedInTotal;

  Account({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.icon = 'account_balance_wallet',
    this.color = '#1E88E5',
    this.isCountedInTotal = true,
  });

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    AccountType? type,
    String? icon,
    String? color,
    bool? isCountedInTotal,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCountedInTotal: isCountedInTotal ?? this.isCountedInTotal,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'type': type.name,
    'icon': icon,
    'color': color,
    'is_counted_in_total': isCountedInTotal ? 1 : 0,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    id: map['id'] as int?,
    name: map['name'] as String,
    balance: (map['balance'] as num).toDouble(),
    type: AccountType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => AccountType.cash,
    ),
    icon: map['icon'] as String? ?? 'account_balance_wallet',
    color: map['color'] as String? ?? '#1E88E5',
    isCountedInTotal: (map['is_counted_in_total'] as int?) == 1,
  );
}

List<Color> accountColors = [
  const Color(0xFF1E88E5),
  const Color(0xFFE53935),
  const Color(0xFFEC407A),
  const Color(0xFF43A047),
  const Color(0xFFFFA726),
  const Color(0xFFAB47BC),
  const Color(0xFF26A69A),
  const Color(0xFFD81B60),
  const Color(0xFFEF6C00),
  const Color(0xFF00897B),
];
