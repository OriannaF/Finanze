import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'edit_budget_screen.dart';

class BudgetTransactionsScreen extends StatefulWidget {
  final int budgetId;
  final TransactionCategory category;

  const BudgetTransactionsScreen({
    super.key,
    required this.budgetId,
    required this.category,
  });

  @override
  State<BudgetTransactionsScreen> createState() => _BudgetTransactionsScreenState();
}

class _BudgetTransactionsScreenState extends State<BudgetTransactionsScreen> {
  Budget? _budget;
  List<Transaction> _transactions = [];
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final budget = await DatabaseHelper().getBudgetById(widget.budgetId);
    final tx = await DatabaseHelper().getTransactionsByCategory(widget.category.name);
    if (!mounted) return;
    setState(() {
      _budget = budget;
      _transactions = tx;
    });
  }

  IconData _iconForCategory(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.food: return Icons.restaurant;
      case TransactionCategory.transport: return Icons.directions_car;
      case TransactionCategory.shopping: return Icons.shopping_bag;
      case TransactionCategory.services: return Icons.bolt;
      case TransactionCategory.entertainment: return Icons.local_activity;
      case TransactionCategory.health: return Icons.local_hospital;
      case TransactionCategory.education: return Icons.school;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = _budget;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.0, 0.0),
            radius: 1.41,
            colors: [
              const Color(0xFFF1D6FF),
              const Color(0x00F1D6FF),
            ],
          ),
        ),
        child: budget == null
            ? const Center(child: Text('Presupuesto no encontrado'))
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 22),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Detalles de Presupuesto',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (value) async {
                                final budget = _budget;
                                if (budget == null) return;
                                if (value == 'edit') {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditBudgetScreen(budget: budget),
                                    ),
                                  );
                                  if (result == true) _load();
                                } else if (value == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Eliminar presupuesto'),
                                      content: Text('¿Eliminar el presupuesto "${budget.categoryName}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                                          onPressed: () => Navigator.pop(c, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await context.read<GoalProvider>().deleteBudget(budget.id!);
                                    if (context.mounted) context.pop();
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurface),
                                      SizedBox(width: 12),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                      SizedBox(width: 12),
                                      Text('Eliminar', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(Icons.more_horiz, color: AppColors.onSurface, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              // Amount display
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      formatCurrency(budget.spent),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 34,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'gastados de ${formatCurrency(budget.limit)}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF4C4546),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Percentage badge
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: ShapeDecoration(
                                    color: budget.category!.color.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Text(
                                    '${(budget.progress * 100).toInt()}% consumido',
                                    style: TextStyle(
                                      color: budget.category!.color,
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Warning card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1, color: const Color(0xFFE9E7ED)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                      spreadRadius: -4,
                                    ),
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 15,
                                      offset: Offset(0, 10),
                                      spreadRadius: -3,
                                    ),
                                  ],
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '¡Cuidado! Te queda el\n',
                                        style: TextStyle(
                                          color: const Color(0xFF1A1B1F),
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${((1 - budget.progress) * 100).toInt()}%',
                                        style: TextStyle(
                                          color: budget.category!.color,
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' para el resto del\nmes. ¡Tú puedes!',
                                        style: TextStyle(
                                          color: const Color(0xFF1A1B1F),
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Activity section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Actividad',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_transactions.length > 3)
                                    GestureDetector(
                                      onTap: () => setState(() => _showAll = !_showAll),
                                      child: Text(
                                        _showAll ? 'Ver menos' : 'Ver todo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: budget.category!.color,
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Transactions list
                              if (_transactions.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Sin transacciones en esta categoría',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.onSurfaceVariant),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: _buildTransactionTiles(),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // ZoeIA insight
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.0, 0.0),
                                    radius: 1.41,
                                    colors: [
                                      const Color(0xFFF6D9FF),
                                      const Color(0x00F6D9FF),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'En una semana se terminaría tu presupuesto a este ritmo',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ZoeIA',
                                      style: TextStyle(
                                        color: const Color(0xFF4C4546),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildTransactionTiles() {
    final displayList = _showAll
        ? _transactions
        : _transactions.take(3).toList();

    return List.generate(displayList.length, (i) {
      final tx = displayList[i];
      final isLast = i == displayList.length - 1;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: isLast
            ? null
            : ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0xFFEEEDF3)),
                ),
              ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFEEEDF3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Icon(
                _iconForCategory(widget.category),
                size: 20,
                color: widget.category.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(
                      color: const Color(0xFF1A1B1F),
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat.yMd('es').add_Hm().format(tx.date),
                    style: TextStyle(
                      color: const Color(0xFF4C4546),
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${formatCurrency(tx.amount)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFFBA1A1A),
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
