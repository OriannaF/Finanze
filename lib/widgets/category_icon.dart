import 'package:flutter/material.dart';
import '../models/transaction.dart';

IconData _iconFromCategory(TransactionCategory category) {
  switch (category) {
    case TransactionCategory.food: return Icons.restaurant;
    case TransactionCategory.transport: return Icons.directions_car;
    case TransactionCategory.shopping: return Icons.shopping_bag;
    case TransactionCategory.services: return Icons.bolt;
    case TransactionCategory.income: return Icons.payments;
    case TransactionCategory.entertainment: return Icons.local_activity;
    case TransactionCategory.health: return Icons.local_hospital;
    case TransactionCategory.education: return Icons.school;
    case TransactionCategory.salary: return Icons.payments;
    case TransactionCategory.freelance: return Icons.code;
    case TransactionCategory.investment: return Icons.trending_up;
    case TransactionCategory.rental: return Icons.home;
    case TransactionCategory.gift: return Icons.card_giftcard;
    case TransactionCategory.other: return Icons.more_horiz;
  }
}

class CategoryIcon extends StatelessWidget {
  final TransactionCategory category;
  final double size;
  final double iconSize;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 48,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        _iconFromCategory(category),
        size: iconSize,
        color: category.color,
      ),
    );
  }
}
