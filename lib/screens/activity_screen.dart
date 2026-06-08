import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../utils/icon_utils.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
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
  TransactionCategory? _filterCategory;
  DateTime? _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category = GoRouterState.of(context).extra as TransactionCategory?;
      setState(() => _filterCategory = category);
      context.read<TransactionProvider>().loadTransactions(period: 'week');
    });
  }

  List<Transaction> get _filteredTransactions {
    final tx = context.read<TransactionProvider>().transactions;
    var result = tx;
    if (_filterCategory != null) {
      result = result.where((t) => t.category == _filterCategory).toList();
    }
    if (_rangeStart != null && _rangeEnd != null) {
      result = result.where((t) =>
        t.date.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
        t.date.isBefore(_rangeEnd!.add(const Duration(days: 1)))
      ).toList();
    }
    return result;
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
                    setState(() {
                      _selectedFilter = i;
                      _selectedDate = null;
                      _rangeStart = null;
                      _rangeEnd = null;
                    });
                    provider.loadTransactions(period: _periods[i]);
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('es'),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _selectedFilter = -1;
                        _rangeStart = picked.subtract(const Duration(days: 3));
                        _rangeEnd = picked.add(const Duration(days: 3));
                      });
                      provider.loadTransactions();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedDate != null
                              ? AppColors.lilac.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: _selectedDate != null
                                  ? AppColors.lilac
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate != null
                                  ? '${_rangeStart!.day} ${_monthName(_rangeStart!.month)} - ${_rangeEnd!.day} ${_monthName(_rangeEnd!.month)} ${_rangeEnd!.year}'
                                  : _rangeText,
                              style: TextStyle(
                                fontSize: 13,
                                color: _selectedDate != null || _selectedFilter >= 0
                                    ? AppColors.lilac
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                            if (_selectedDate != null) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = null;
                                    _rangeStart = null;
                                    _rangeEnd = null;
                                  });
                                  provider.loadTransactions(period: _periods[_selectedFilter >= 0 ? _selectedFilter : 0]);
                                },
                                child: const Icon(Icons.close, size: 16, color: AppColors.lilac),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category filter
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: TransactionCategory.values.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final selected = _filterCategory == null;
                        return GestureDetector(
                          onTap: () => setState(() => _filterCategory = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: selected ? Colors.black : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Todas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final cat = TransactionCategory.values[index - 1];
                      final selected = _filterCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _filterCategory = selected ? null : cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected ? cat.color : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconDataFromString(cat.icon),
                                size: 16,
                                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_filteredTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text(
                      _filterCategory != null
                          ? 'No hay transacciones de ${_filterCategory!.label} en este período'
                          : 'No hay transacciones en este período',
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
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

  String get _rangeText {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 0:
        final weekAgo = now.subtract(const Duration(days: 7));
        return '${weekAgo.day} ${_monthName(weekAgo.month)} - ${now.day} ${_monthName(now.month)} ${now.year}';
      case 1:
        return '${_monthName(now.month)} ${now.year}';
      case 2:
        return '${now.year}';
      default:
        return 'Todo';
    }
  }

  String _monthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return months[month - 1];
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    final grouped = <String, List<_TxGroup>>{};

    for (final tx in _filteredTransactions) {
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
                          TransactionTile(
                            transaction: tx,
                            onTap: () => showEditTransactionSheet(context, tx),
                          ),
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
