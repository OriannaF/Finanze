import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_tile.dart';

const List<String> _budgetIcons = [
  'restaurant', 'directions_car', 'shopping_bag', 'bolt', 'local_activity',
  'local_hospital', 'school', 'payments', 'code', 'trending_up', 'home',
  'card_giftcard', 'more_horiz', 'flight_takeoff', 'savings', 'shopping_cart',
  'favorite', 'pets', 'devices', 'fitness_center', 'book', 'wallet', 'money',
];

IconData _budgetIconData(String name) {
  const map = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'bolt': Icons.bolt,
    'local_activity': Icons.local_activity,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'payments': Icons.payments,
    'code': Icons.code,
    'trending_up': Icons.trending_up,
    'home': Icons.home,
    'card_giftcard': Icons.card_giftcard,
    'more_horiz': Icons.more_horiz,
    'flight_takeoff': Icons.flight_takeoff,
    'savings': Icons.savings,
    'shopping_cart': Icons.shopping_cart,
    'favorite': Icons.favorite,
    'pets': Icons.pets,
    'devices': Icons.devices,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'wallet': Icons.wallet,
    'money': Icons.money,
  };
  return map[name] ?? Icons.more_horiz;
}

Color _colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

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

  void _showEditDialog() {
    final budget = _budget;
    if (budget == null) return;

    final nameCtrl = TextEditingController(text: budget.categoryName);
    final limitCtrl = TextEditingController(text: budget.limit.toInt().toString());
    String selectedIcon = budget.icon;
    String selectedColor = budget.color;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar presupuesto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del presupuesto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Límite mensual',
                    border: OutlineInputBorder(),
                    prefixText: r'$ ',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ícono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showIconPicker(ctx, selectedIcon, selectedColor, (newIcon) {
                    setDialogState(() => selectedIcon = newIcon);
                  }),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _colorFromHex(selectedColor).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _budgetIconData(selectedIcon),
                          color: _colorFromHex(selectedColor),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Tocar para elegir ícono',
                          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: accountColors.map((c) {
                    final hex = '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                    final isSel = selectedColor == hex;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(18),
                          border: isSel ? Border.all(color: AppColors.primary, width: 3) : null,
                        ),
                        child: isSel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newLimit = double.tryParse(limitCtrl.text);
                if (newName.isEmpty || newLimit == null || newLimit <= 0) return;
                context.read<GoalProvider>().updateBudget(budget.copyWith(
                  categoryName: newName,
                  limit: newLimit,
                  icon: selectedIcon,
                  color: selectedColor,
                ));
                Navigator.pop(ctx);
                _load();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext sheetContext, String currentIcon, String currentColor, void Function(String) onSelected) {
    showDialog(
      context: sheetContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Elegir ícono'),
        content: SizedBox(
          width: 320,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _budgetIcons.length,
            itemBuilder: (_, i) {
              final iconName = _budgetIcons[i];
              final isSelected = currentIcon == iconName;
              final iconColor = _colorFromHex(currentColor);
              return GestureDetector(
                onTap: () {
                  onSelected(iconName);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? iconColor : iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: iconColor, width: 2) : null,
                  ),
                  child: Icon(
                    _budgetIconData(iconName),
                    size: 24,
                    color: isSelected ? Colors.white : iconColor,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = _budget;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Center(
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
        ),
        title: Text(budget?.categoryName ?? widget.category.label),
        actions: [
          if (budget != null)
            GestureDetector(
              onTap: _showEditDialog,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
              ),
            ),
        ],
      ),
      body: budget == null
          ? const Center(child: Text('Presupuesto no encontrado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      formatCurrency(budget.spent),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'de ${formatCurrency(budget.limit)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Transacciones recientes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sin transacciones en esta categoría',
                            style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                    )
                  else
                    ..._transactions.map((tx) => Column(
                          children: [
                            TransactionTile(transaction: tx),
                            if (tx != _transactions.last)
                              const Divider(indent: 64, endIndent: 16),
                          ],
                        )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
