import 'package:flutter/material.dart';
import '../models/account.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

IconData _iconDataFromString(String name) {
  const icons = {
    'account_balance_wallet': Icons.account_balance_wallet,
    'savings': Icons.savings,
    'credit_card': Icons.credit_card,
    'payments': Icons.payments,
    'wallet': Icons.wallet,
    'money': Icons.money,
  };
  return icons[name] ?? Icons.account_balance_wallet;
}

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountCard({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Color _hexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color get _iconBgColor => _hexColor(account.color).withValues(alpha: 0.2);

  Color get _iconColor => _hexColor(account.color);

  IconData get _iconData => _iconDataFromString(account.icon);
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
