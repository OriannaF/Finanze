import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/segmented_control.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semana', 'Mes', 'Año'];
  final List<String> _periods = ['week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(period: 'week');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Actividad',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                SegmentedControl(
                  options: _filters,
                  selectedIndex: _selectedFilter,
                  onChanged: (i) {
                    setState(() => _selectedFilter = i);
                    provider.loadTransactions(period: _periods[i]);
                  },
                ),
                const SizedBox(height: 24),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Text(
                      'No hay transacciones en este período',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  )
                else
                  _buildTransactionList(provider),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    final grouped = <String, List<_TxGroup>>{};

    for (final tx in provider.transactions) {
      final key = formatDate(tx.date);
      grouped.putIfAbsent(key, () => []);
      final existing = grouped[key]!.indexWhere((g) => g.dateKey == key);
      if (existing >= 0) {
        grouped[key]![existing].transactions.add(tx);
      } else {
        grouped[key]!.add(_TxGroup(dateKey: key, transactions: [tx]));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        entry.value
            .expand((g) => g.transactions)
            .fold<dynamic>(0.0, (sum, t) => sum + (t.type == TransactionType.expense ? t.amount : 0));

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: entry.value
                      .expand((g) => g.transactions)
                      .map((tx) => Column(
                        children: [
                          TransactionTile(transaction: tx),
                          if (tx != entry.value.expand((g) => g.transactions).last)
                            const Divider(indent: 64, endIndent: 16),
                        ],
                      ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TxGroup {
  final String dateKey;
  final List transactions;
  _TxGroup({required this.dateKey, required this.transactions});
}
