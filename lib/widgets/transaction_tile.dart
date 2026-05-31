import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDeclined = transaction.title == 'Prudential';
    final amountColor = transaction.type == TransactionType.income
        ? AppColors.green
        : AppColors.onBackground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CategoryIcon(category: transaction.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      decoration: isDeclined ? TextDecoration.lineThrough : null,
                      color: isDeclined ? AppColors.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDeclined
                        ? 'Rechazado – Tarjeta vencida'
                        : '${transaction.category.label} • ${formatDate(transaction.date)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDeclined ? AppColors.error : null,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.type == TransactionType.income ? '+' : '-'}${formatCurrency(transaction.amount)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: amountColor,
                    decoration: isDeclined ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (showDate && transaction.note.isNotEmpty)
                  Text(
                    transaction.note,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
