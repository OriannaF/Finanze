import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

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

  Color get backgroundColor {
    switch (category) {
      case TransactionCategory.food: return AppColors.secondaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.transport: return AppColors.errorContainer;
      case TransactionCategory.shopping: return const Color(0xFFFD9D06).withValues(alpha: 0.2);
      case TransactionCategory.services: return AppColors.tertiaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.income: return AppColors.greenBg;
      case TransactionCategory.entertainment: return AppColors.tertiaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.health: return AppColors.errorContainer;
      case TransactionCategory.education: return AppColors.tertiaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.salary: return AppColors.greenBg;
      case TransactionCategory.freelance: return AppColors.tertiaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.investment: return const Color(0xFFFD9D06).withValues(alpha: 0.2);
      case TransactionCategory.rental: return AppColors.secondaryFixedDim.withValues(alpha: 0.3);
      case TransactionCategory.gift: return AppColors.errorContainer;
      case TransactionCategory.other: return AppColors.surfaceVariant;
    }
  }

  Color get iconColor {
    switch (category) {
      case TransactionCategory.food: return AppColors.secondary;
      case TransactionCategory.transport: return AppColors.error;
      case TransactionCategory.shopping: return AppColors.secondaryContainer;
      case TransactionCategory.services: return AppColors.tertiaryContainer;
      case TransactionCategory.income: return AppColors.green;
      case TransactionCategory.entertainment: return AppColors.tertiaryContainer;
      case TransactionCategory.health: return AppColors.error;
      case TransactionCategory.education: return AppColors.tertiaryContainer;
      case TransactionCategory.salary: return AppColors.green;
      case TransactionCategory.freelance: return AppColors.tertiaryContainer;
      case TransactionCategory.investment: return AppColors.secondaryContainer;
      case TransactionCategory.rental: return AppColors.secondary;
      case TransactionCategory.gift: return AppColors.error;
      case TransactionCategory.other: return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        _iconFromCategory(category),
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}
