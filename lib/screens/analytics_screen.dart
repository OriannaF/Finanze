import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/category_icon.dart';
import '../widgets/segmented_control.dart';
import '../models/transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 1;
  final List<String> _filters = ['Semana', 'Mes', 'Año'];
  final List<String> _periods = ['week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(period: 'month');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final expenses = provider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        final totalExpense = expenses.fold(0.0, (s, t) => s + t.amount);

        final byCategory = <TransactionCategory, double>{};
        for (final t in expenses) {
          byCategory.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
        }
        final sortedCategories = byCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Estadísticas',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                // Centered Segmented Control
                Center(
                  child: SegmentedControl(
                    options: _filters,
                    selectedIndex: _selectedFilter,
                    onChanged: (i) {
                      setState(() => _selectedFilter = i);
                      provider.loadTransactions(period: _periods[i]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Date range
                Text(
                  '${formatDayMonth(DateTime.now().subtract(const Duration(days: 7)))} – ${formatDayMonth(DateTime.now())}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 24),
                // Total
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(totalExpense),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                // Bar chart card
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: SizedBox(
                    height: 180,
                    child: _buildBarChart(expenses),
                  ),
                ),
                const SizedBox(height: 24),
                // Category filter
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Por categoría',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Todos',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category breakdown
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
                    children: sortedCategories.map((entry) {
                      final category = entry.key;
                      final amount = entry.value;
                      final isLast = entry == sortedCategories.last;

                      return InkWell(
                        onTap: () {},
                        borderRadius: isLast
                            ? const BorderRadius.vertical(bottom: Radius.circular(28))
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom: BorderSide(
                                      color: AppColors.surfaceVariant,
                                      width: 0.5,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              CategoryIcon(category: category, size: 44, iconSize: 18),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.label,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      '${_getCountForCategory(expenses, category)} Transacción${_getCountForCategory(expenses, category) != 1 ? 'es' : ''}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatCurrency(amount),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.outlineVariant,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<Transaction> expenses) {
    final dayTotals = <String, double>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat.E('es').format(day).substring(0, 1).toUpperCase() +
          DateFormat.E('es').format(day).substring(1, 3);
      dayTotals[key] = 0;
    }

    for (final t in expenses) {
      final diff = DateTime.now().difference(t.date).inDays;
      if (diff >= 0 && diff < 7) {
        final day = DateTime.now().subtract(Duration(days: diff));
        final key = DateFormat.E('es').format(day).substring(0, 1).toUpperCase() +
            DateFormat.E('es').format(day).substring(1, 3);
        dayTotals[key] = (dayTotals[key] ?? 0) + t.amount;
      }
    }

    final maxVal = dayTotals.values.fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal > 0 ? maxVal * 1.3 : 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= dayTotals.keys.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    dayTotals.keys.elementAt(i),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 2 : 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceVariant,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: dayTotals.entries.map((entry) {
          return BarChartGroupData(
            x: dayTotals.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value > 0 ? entry.value : 2,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color(0xFFbda7e0),
                    Color(0xFFad91d6),
                    Color(0xFFf3b5c9),
                  ],
                ),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  int _getCountForCategory(List<Transaction> expenses, TransactionCategory cat) {
    return expenses.where((t) => t.category == cat).length;
  }
}
