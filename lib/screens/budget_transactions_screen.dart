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
  late TextEditingController _titleCtrl;
  late TextEditingController _limitCtrl;
  bool _editingTitle = false;
  bool _editingLimit = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _limitCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final budget = await DatabaseHelper().getBudgetById(widget.budgetId);
    final tx = await DatabaseHelper().getTransactionsByCategory(widget.category.name);
    if (!mounted) return;
    setState(() {
      _budget = budget;
      _transactions = tx;
      if (budget != null) {
        _titleCtrl.text = budget.categoryName;
        _limitCtrl.text = budget.limit.toInt().toString();
      }
    });
  }

  Future<void> _saveTitle(String newTitle) async {
    final budget = _budget;
    if (budget == null || newTitle.trim().isEmpty) return;
    await context.read<GoalProvider>().updateBudget(budget.copyWith(categoryName: newTitle.trim()));
    _load();
  }

  Future<void> _saveLimit(String text) async {
    final budget = _budget;
    final amount = double.tryParse(text.replaceAll('.', '').replaceAll(',', '.'));
    if (budget == null || amount == null || amount <= 0) return;
    await context.read<GoalProvider>().updateBudget(budget.copyWith(limit: amount));
    _load();
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

  Color _categoryColor(TransactionCategory? cat) {
    if (cat == null) return AppColors.primary;
    switch (cat) {
      case TransactionCategory.food: return const Color(0xFFE53935);
      case TransactionCategory.transport: return const Color(0xFF1E88E5);
      case TransactionCategory.shopping: return const Color(0xFFEC407A);
      case TransactionCategory.services: return const Color(0xFFFFA726);
      case TransactionCategory.entertainment: return const Color(0xFFAB47BC);
      case TransactionCategory.health: return const Color(0xFF43A047);
      case TransactionCategory.education: return const Color(0xFF26A69A);
      default: return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = _budget;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
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
                            SizedBox(
                              width: 40,
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _editingTitle
                                      ? TextField(
                                          controller: _titleCtrl,
                                          autofocus: true,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.onSurface,
                                            fontSize: 20,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          onSubmitted: (v) {
                                            _editingTitle = false;
                                            _saveTitle(v);
                                          },
                                          onTapOutside: (_) {
                                            _editingTitle = false;
                                            _saveTitle(_titleCtrl.text);
                                          },
                                        )
                                      : GestureDetector(
                                          onTap: () => setState(() => _editingTitle = true),
                                          child: Text(
                                            'Detalles de Presupuesto',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.onSurface,
                                              fontSize: 20,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: PopupMenuButton<String>(
                                offset: const Offset(0, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.more_horiz, color: AppColors.onSurface, size: 20),
                                ),
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
                              const SizedBox(height: 8),
                              _buildProgressSection(budget),
                              const SizedBox(height: 24),
                              _buildZoeSection(budget),
                              const SizedBox(height: 32),
                              _buildActivitySection(budget),
                              const SizedBox(height: 24),
                              _buildPredictionCard(budget),
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

  Widget _buildProgressSection(Budget budget) {
    final catColor = _categoryColor(budget.category);
    final progress = budget.progress;

    return Center(
      child: SizedBox(
        width: 288,
        height: 288,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 288,
              height: 288,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: progress,
                  color: catColor,
                  backgroundColor: const Color(0xFFF3F4F6),
                  strokeWidth: 24,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCurrencyWhole(budget.spent),
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 48,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _editingLimit = !_editingLimit),
                  child: _editingLimit
                      ? SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _limitCtrl,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            inputFormatters: [ThousandsInputFormatter()],
                            onSubmitted: (v) {
                              _editingLimit = false;
                              _saveLimit(v);
                            },
                            onTapOutside: (_) {
                              _editingLimit = false;
                              _saveLimit(_limitCtrl.text);
                            },
                          ),
                        )
                      : Text(
                          'gastados de ${formatCurrency(budget.limit)}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}% consumido',
                    style: TextStyle(
                      color: catColor,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoeSection(Budget budget) {
    final remainingPct = ((1 - budget.progress) * 100).toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 96,
          height: 128,
          child: Image.asset(
            'assets/images/zoe_sentada.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE9E7ED)),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: '¡Cuidado! Te queda el ',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: '$remainingPct%',
                    style: TextStyle(
                      color: _categoryColor(budget.category),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' para el resto del mes. ¡Tú puedes!',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(Budget budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.onSurface,
              ),
            ),
            if (_transactions.length > 3)
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? 'Ver menos' : 'Ver todo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: _categoryColor(budget.category),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: const Text(
              'Sin transacciones en esta categoría',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'Inter'),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Column(children: _buildTransactionTiles()),
          ),
      ],
    );
  }

  Widget _buildPredictionCard(Budget budget) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFE879F9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'En una semana se terminaría tu presupuesto a este ritmo',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ZoeIA',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.surfaceContainer, width: 1)),
              ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _iconForCategory(tx.category),
                size: 20,
                color: _categoryColor(tx.category),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.yMd('es').add_Hm().format(tx.date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${formatCurrency(tx.amount)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = backgroundColor;
    canvas.drawCircle(center, radius, paint);

    paint.color = color;
    const fullAngle = 2 * 3.141592653589793;
    final sweepAngle = fullAngle * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -fullAngle / 4,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
