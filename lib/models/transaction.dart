import 'package:flutter/material.dart';

enum TransactionType { expense, income }

enum TransactionCategory {
  // Expense
  food,
  transport,
  shopping,
  services,
  entertainment,
  health,
  education,
  // Income
  salary,
  freelance,
  investment,
  rental,
  gift,
  income,
  other;

  bool get isExpenseCategory => index < 7;

  String get label {
    switch (this) {
      case TransactionCategory.food: return 'Comida';
      case TransactionCategory.transport: return 'Transporte';
      case TransactionCategory.shopping: return 'Compras';
      case TransactionCategory.services: return 'Servicios';
      case TransactionCategory.entertainment: return 'Entretenimiento';
      case TransactionCategory.health: return 'Salud';
      case TransactionCategory.education: return 'Educación';
      case TransactionCategory.salary: return 'Salario';
      case TransactionCategory.freelance: return 'Freelance';
      case TransactionCategory.investment: return 'Inversión';
      case TransactionCategory.rental: return 'Renta';
      case TransactionCategory.gift: return 'Regalo';
      case TransactionCategory.income: return 'Ingreso';
      case TransactionCategory.other: return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.food: return 'restaurant';
      case TransactionCategory.transport: return 'directions_car';
      case TransactionCategory.shopping: return 'shopping_bag';
      case TransactionCategory.services: return 'bolt';
      case TransactionCategory.entertainment: return 'local_activity';
      case TransactionCategory.health: return 'local_hospital';
      case TransactionCategory.education: return 'school';
      case TransactionCategory.salary: return 'payments';
      case TransactionCategory.freelance: return 'code';
      case TransactionCategory.investment: return 'trending_up';
      case TransactionCategory.rental: return 'home';
      case TransactionCategory.gift: return 'card_giftcard';
      case TransactionCategory.income: return 'payments';
      case TransactionCategory.other: return 'more_horiz';
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food: return const Color(0xFFE53935);
      case TransactionCategory.transport: return const Color(0xFF1E88E5);
      case TransactionCategory.shopping: return const Color(0xFFEC407A);
      case TransactionCategory.services: return const Color(0xFFFFA726);
      case TransactionCategory.entertainment: return const Color(0xFFAB47BC);
      case TransactionCategory.health: return const Color(0xFF43A047);
      case TransactionCategory.education: return const Color(0xFF26A69A);
      case TransactionCategory.salary: return const Color(0xFF2E7D32);
      case TransactionCategory.freelance: return const Color(0xFF00ACC1);
      case TransactionCategory.investment: return const Color(0xFF1565C0);
      case TransactionCategory.rental: return const Color(0xFFEF6C00);
      case TransactionCategory.gift: return const Color(0xFFD81B60);
      case TransactionCategory.income: return const Color(0xFF00897B);
      case TransactionCategory.other: return const Color(0xFF757575);
    }
  }
}

class Transaction {
  final int? id;
  final int? accountId;
  final String title;
  final double amount;
  final TransactionCategory category;
  final TransactionType type;
  final DateTime date;
  final String note;

  Transaction({
    this.id,
    this.accountId,
    required this.title,
    required this.amount,
    required this.category,
    this.type = TransactionType.expense,
    DateTime? date,
    this.note = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'category': category.name,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
    };
    if (id != null) map['id'] = id;
    if (accountId != null) map['accountId'] = accountId;
    return map;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'expense';
    return Transaction(
      id: map['id'] as int?,
      accountId: map['accountId'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      type: typeStr == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    String? title,
    double? amount,
    TransactionCategory? category,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) => Transaction(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    type: type ?? this.type,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}
