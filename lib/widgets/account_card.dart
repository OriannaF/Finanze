import 'package:flutter/material.dart';
import '../models/account.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _iconData,
              color: _iconColor,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            account.name,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            formatCompactCurrency(account.balance),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Color get _iconBgColor {
    switch (account.type) {
      case AccountType.cash: return AppColors.secondaryContainer.withValues(alpha: 0.2);
      case AccountType.debit: return AppColors.tertiaryFixedDim.withValues(alpha: 0.3);
      case AccountType.credit: return AppColors.errorContainer;
      case AccountType.savings: return AppColors.greenBg;
    }
  }

  Color get _iconColor {
    switch (account.type) {
      case AccountType.cash: return AppColors.secondaryContainer;
      case AccountType.debit: return AppColors.tertiaryContainer;
      case AccountType.credit: return AppColors.error;
      case AccountType.savings: return AppColors.green;
    }
  }

  IconData get _iconData {
    switch (account.type) {
      case AccountType.cash: return Icons.account_balance_wallet;
      case AccountType.debit: return Icons.credit_card;
      case AccountType.credit: return Icons.credit_card;
      case AccountType.savings: return Icons.savings;
    }
  }
}

class AddAccountCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AddAccountCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.onSurfaceVariant, size: 24),
            const SizedBox(height: 8),
            Text(
              'Añadir cuenta',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
