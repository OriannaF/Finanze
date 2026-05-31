import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper().getAccounts();
    if (!mounted) return;
    setState(() => _accounts = accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final settings = context.watch<SettingsProvider>();
        final userName = settings.userName.isNotEmpty ? settings.userName : 'usuario';
        final recentTx = provider.transactions.take(5).toList();

        return SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  children: [
                    Image.asset(
                      'assets/images/zoe_sentada.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hola, $userName',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Balance
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(provider.totalBalance),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                // Accounts horizontal scroll
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._accounts.map((a) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AccountCard(account: a),
                      )),
                      const AddAccountCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos registros',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Transactions list
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (recentTx.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No hay transacciones aún',
                              style: TextStyle(color: AppColors.onSurfaceVariant)),
                        )
                      else
                        ...recentTx.map((tx) => Column(
                          children: [
                            TransactionTile(transaction: tx),
                            if (tx != recentTx.last)
                              const Divider(indent: 64, endIndent: 16),
                          ],
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
              // FAB
              Positioned(
                right: 4,
                bottom: 16,
                child: GestureDetector(
                  onTap: () => context.push('/add-amount'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.onPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
