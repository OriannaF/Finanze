import 'transaction.dart';

class Budget {
  final int? id;
  final String categoryName;
  final TransactionCategory? category;
  final double limit;
  final double spent;
  final int month;
  final int year;

  Budget({
    this.id,
    this.categoryName = 'Otro',
    this.category,
    required this.limit,
    this.spent = 0,
    int? month,
    int? year,
  }) : month = month ?? DateTime.now().month,
       year = year ?? DateTime.now().year;

  double get remaining => limit - spent;
  bool get isOverBudget => spent > limit;
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'categoryName': categoryName,
    'category': category?.name,
    'budget_limit': limit,
    'spent': spent,
    'month': month,
    'year': year,
  };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    id: map['id'] as int?,
    categoryName: map['categoryName'] as String? ?? 'Otro',
    category: map['category'] != null
        ? TransactionCategory.values.firstWhere(
            (e) => e.name == map['category'],
            orElse: () => TransactionCategory.other,
          )
        : null,
    limit: (map['budget_limit'] as num?)?.toDouble() ?? (map['limit'] as num?)?.toDouble() ?? 0,
    spent: (map['spent'] as num).toDouble(),
    month: map['month'] as int? ?? DateTime.now().month,
    year: map['year'] as int? ?? DateTime.now().year,
  );

  Budget copyWith({
    int? id,
    String? categoryName,
    TransactionCategory? category,
    double? limit,
    double? spent,
    int? month,
    int? year,
  }) => Budget(
    id: id ?? this.id,
    categoryName: categoryName ?? this.categoryName,
    category: category ?? this.category,
    limit: limit ?? this.limit,
    spent: spent ?? this.spent,
    month: month ?? this.month,
    year: year ?? this.year,
  );
}
