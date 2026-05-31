import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/progress_bar.dart';
import '../models/goal.dart';
import '../models/budget.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Stack(
                  children: [
                    Center(
                      child: Text(
                        'Metas activas',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showCreateGoalSheet(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Goals list
                if (provider.goals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: const Center(
                      child: Text(
                        'No hay metas aún. ¡Crea una!',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...provider.goals.map((goal) => _GoalCard(
                    goal: goal,
                    onTap: () => _showGoalDetail(context, goal),
                  )),
                const SizedBox(height: 32),
                // Monthly Budget
                Text(
                  'Presupuesto mensual',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                // Budget list
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
                    children: provider.budgets.map((budget) {
                      final isLast = budget == provider.budgets.last;
                      return _BudgetItem(
                        budget: budget,
                        isLast: isLast,
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

  static const List<IconData> _goalIcons = [
    Icons.flight_takeoff,
    Icons.savings,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.directions_car,
    Icons.home,
    Icons.school,
    Icons.favorite,
    Icons.card_giftcard,
    Icons.trending_up,
    Icons.pets,
    Icons.devices,
    Icons.fitness_center,
    Icons.book,
  ];

  static const Map<String, IconData> _goalIconMap = {
    'flight_takeoff': Icons.flight_takeoff,
    'savings': Icons.savings,
    'shopping_cart': Icons.shopping_cart,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'school': Icons.school,
    'favorite': Icons.favorite,
    'card_giftcard': Icons.card_giftcard,
    'trending_up': Icons.trending_up,
    'pets': Icons.pets,
    'devices': Icons.devices,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
  };

  static String _iconName(IconData icon) {
    return _goalIconMap.entries.firstWhere((e) => e.value == icon, orElse: () => _goalIconMap.entries.first).key;
  }

  void _showCreateGoalSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    IconData selectedIcon = Icons.flight_takeoff;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('Nueva meta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha límite: ${DateFormat.yMMMd('es').format(selectedDate)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) setSheetState(() => selectedDate = date);
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Ícono', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: GridView.count(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _goalIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedIcon = icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.tertiaryFixedDim.withValues(alpha: 0.3) : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 22, color: isSelected ? AppColors.onTertiaryContainer : AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    final amountText = amountCtrl.text
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) return;
                    await ctx.read<GoalProvider>().addGoal(Goal(
                      title: title,
                      targetAmount: amount,
                      deadline: DateFormat.yMMMd('es').format(selectedDate),
                      icon: _iconName(selectedIcon),
                    ));
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Crear meta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetail(BuildContext context, Goal goal) {
    final provider = context.read<GoalProvider>();
    provider.loadContributions(goal.id!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Consumer<GoalProvider>(
        builder: (context, provider, _) {
          final contributions = provider.getContributions(goal.id!);
          return StatefulBuilder(
            builder: (ctx, setSheetState) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon, name, and close
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _goalIconMap[goal.icon] ?? Icons.flag,
                          size: 22, color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.title, style: Theme.of(context).textTheme.titleLarge),
                            Text(goal.deadline, style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.close, size: 18, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${formatCurrency(goal.savedAmount)} ahorrados', style: Theme.of(context).textTheme.labelSmall),
                      Text('${(goal.progress * 100).toInt()}%', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SimpleProgressBar(progress: goal.progress),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Meta: ${formatCurrency(goal.targetAmount)}', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const SizedBox(height: 16),
                  // Add contribution
                  Row(
                    children: [
                      Expanded(
                        child: Text('Historial', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddContribution(ctx, goal),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Aportar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.lilac,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Contributions list
                  if (contributions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('Sin aportes aún', style: TextStyle(color: AppColors.onSurfaceVariant))),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        itemCount: contributions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = contributions[i];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.greenBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.arrow_upward, size: 16, color: AppColors.green),
                            ),
                            title: Text('+${formatCurrency(c.amount)}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
                            trailing: Text(DateFormat.yMd('es').add_Hm().format(c.date), style: Theme.of(context).textTheme.labelSmall),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editGoalName(ctx, goal, setSheetState),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar nombre'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editGoalIcon(ctx, goal, setSheetState),
                          icon: const Icon(Icons.emoji_symbols_outlined, size: 18),
                          label: const Text('Cambiar ícono'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _deleteGoal(ctx, goal),
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      label: const Text('Eliminar meta', style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddContribution(BuildContext ctx, Goal goal) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Aportar a meta'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Monto',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) {
                context.read<GoalProvider>().addContribution(goal.id!, amount);
              }
              Navigator.pop(c);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _editGoalName(BuildContext ctx, Goal goal, void Function(void Function()) setSheetState) {
    final ctrl = TextEditingController(text: goal.title);
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<GoalProvider>().updateGoal(goal.copyWith(title: ctrl.text.trim()));
              }
              Navigator.pop(c);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editGoalIcon(BuildContext ctx, Goal goal, void Function(void Function()) setSheetState) {
    IconData selectedIcon = _goalIconMap[goal.icon] ?? Icons.flag;
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Cambiar ícono'),
        content: SizedBox(
          width: 280,
          child: GridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            children: _goalIcons.map((icon) {
              final isSelected = icon == selectedIcon;
              return GestureDetector(
                onTap: () {
                  context.read<GoalProvider>().updateGoal(goal.copyWith(icon: _iconName(icon)));
                  Navigator.pop(c);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tertiaryFixedDim.withValues(alpha: 0.3) : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: AppColors.primary) : null,
                  ),
                  child: Icon(icon, size: 24, color: isSelected ? AppColors.onTertiaryContainer : AppColors.primary),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void _deleteGoal(BuildContext ctx, Goal goal) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Eliminar "${goal.title}"? Se borrará todo el historial de aportes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goal.id!);
              Navigator.pop(c);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _iconData(goal.icon),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          goal.deadline,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCurrency(goal.savedAmount)} ahorrados',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  'Meta: ${formatCurrency(goal.targetAmount)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SimpleProgressBar(progress: goal.progress),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'flight_takeoff': return Icons.flight_takeoff;
      case 'savings': return Icons.savings;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'school': return Icons.school;
      case 'favorite': return Icons.favorite;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'trending_up': return Icons.trending_up;
      case 'pets': return Icons.pets;
      case 'devices': return Icons.devices;
      case 'fitness_center': return Icons.fitness_center;
      case 'book': return Icons.book;
      default: return Icons.flag;
    }
  }
}

class _BudgetItem extends StatelessWidget {
  final Budget budget;
  final bool isLast;
  const _BudgetItem({required this.budget, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.isOverBudget;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.surfaceContainer, width: 1),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isOver
                          ? AppColors.errorContainer
                          : AppColors.secondaryFixedDim.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForCategory(budget.categoryName),
                      size: 18,
                      color: isOver
                          ? AppColors.error
                          : AppColors.secondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    budget.categoryName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOver
                        ? '${formatCurrency(budget.remaining.abs())} excedido'
                        : '${formatCurrency(budget.remaining)} restante',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isOver ? AppColors.error : null,
                    ),
                  ),
                  Text(
                    'de ${formatCurrency(budget.limit)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedProgressBar(
            progress: budget.progress,
            color: isOver ? AppColors.error : AppColors.secondaryContainer,
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'comestibles': return Icons.shopping_cart;
      case 'restaurantes': return Icons.restaurant;
      case 'transporte': return Icons.directions_car;
      case 'compras': return Icons.shopping_bag;
      default: return Icons.more_horiz;
    }
  }
}
