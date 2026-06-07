import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/icon_utils.dart';
import '../widgets/progress_bar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/goal_customizer_sheet.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/transaction.dart';

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 44),
                    Text(
                      'Metas',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
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
                        onTap: () => context.push('/goal-detail?id=${goal.id}'),
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
                    if (provider.budgets.isEmpty)
                      Container(
                        width: double.infinity,
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
                          children: [
                            Image.asset(
                              'assets/images/zoe_anteojos.png',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Controlá tus gastos como un pro:\ncon un presupuesto mensual, limitá tus gastos\ny ahorrá para las cosas importantes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
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
                              onTap: () => context.push('/budget-transactions?category=${budget.category!.name}&budgetId=${budget.id}'),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Objetivos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // FAB
              Positioned(
                right: 4,
                bottom: 16,
                child: GestureDetector(
                  onTap: () => _showCreateSheet(context),
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

  void _showCreateSheet(BuildContext context) {
    int selectedType = 0;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedIcon = 'flight_takeoff';
    String selectedColor = '#1E88E5';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    TransactionCategory selectedBudgetCat = TransactionCategory.food;
    String selectedBudgetIcon = 'shopping_cart';
    String selectedBudgetColor = '#43A047';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Toggle
              SegmentedControl(
                options: const ['Meta', 'Presupuesto'],
                selectedIndex: selectedType,
                onChanged: (i) => setSheetState(() => selectedType = i),
              ),
              const SizedBox(height: 24),
              if (selectedType == 0) ...[
                _buildGoalForm(
                  ctx, setSheetState, titleCtrl, amountCtrl,
                  selectedIcon, selectedColor, selectedDate,
                  onIconChanged: (name) { selectedIcon = name; },
                  onDateChanged: (date) { selectedDate = date; },
                ),
              ] else ...[
                _buildBudgetForm(ctx, setSheetState, titleCtrl, amountCtrl, selectedBudgetCat, selectedBudgetIcon, selectedBudgetColor, (cat) { selectedBudgetCat = cat; }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalForm(
    BuildContext ctx,
    StateSetter setSheetState,
    TextEditingController titleCtrl,
    TextEditingController amountCtrl,
    String selectedIcon,
    String selectedColor,
    DateTime selectedDate, {
    ValueChanged<String>? onIconChanged,
    ValueChanged<DateTime>? onDateChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target Amount
        Center(
          child: Column(
            children: [
              Text('Monto objetivo',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\$',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsInputFormatter()],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Goal Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la meta',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Goal Icon selector
        Text('Ícono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: _goalIcons.asMap().entries.map((entry) {
              final i = entry.key;
              final icon = entry.value;
              final isSelected = _iconName(icon) == selectedIcon;
              final catColor = TransactionCategory.values[i % TransactionCategory.values.length].color;
              return GestureDetector(
                onTap: () {
                  final name = _iconName(icon);
                  setSheetState(() => selectedIcon = name);
                  onIconChanged?.call(name);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? catColor
                        : catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(icon, size: 22,
                    color: isSelected ? AppColors.onPrimary : catColor),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Target Date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fecha límite: ${_capMonth(DateFormat.yMMMd('es').format(selectedDate))}',
                  style: TextStyle(fontSize: 15, color: AppColors.onSurface),
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
                  if (date != null) {
                    setSheetState(() => selectedDate = date);
                    onDateChanged?.call(date);
                  }
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Create button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final amountText = amountCtrl.text
                  .replaceAll('.', '').replaceAll(',', '.');
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) return;
               await ctx.read<GoalProvider>().addGoal(Goal(
                 title: title,
                 targetAmount: amount,
                 deadline: _capMonth(DateFormat.yMMMd('es').format(selectedDate)),
                 icon: selectedIcon,
               ));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Crear meta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              side: BorderSide.none,
            ),
            child: const Text('Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetForm(
    BuildContext ctx,
    StateSetter setSheetState,
    TextEditingController nameCtrl,
    TextEditingController limitCtrl,
    TransactionCategory selectedCat,
    String selectedBudgetIcon,
    String selectedBudgetColor,
    ValueChanged<TransactionCategory> onCatChanged,
  ) {
    final expenseCategories = TransactionCategory.values
        .where((c) => c.isExpenseCategory)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Limit Amount
        Center(
          child: Column(
            children: [
              Text('Límite mensual',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\$',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: limitCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsInputFormatter()],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Budget Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del presupuesto',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Category selector
        Text('Categoría',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: expenseCategories.map((cat) {
              final isSelected = cat == selectedCat;
              return GestureDetector(
                onTap: () {
                  setSheetState(() => selectedCat = cat);
                  onCatChanged(cat);
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color : cat.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          _iconForCategory(cat),
                          size: 22,
                          color: isSelected ? AppColors.onPrimary : cat.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? cat.color : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 92),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final limitText = limitCtrl.text
                  .replaceAll('.', '').replaceAll(',', '.');
              final limit = double.tryParse(limitText);
              if (limit == null || limit <= 0) return;
              await ctx.read<GoalProvider>().addBudget(Budget(
                categoryName: name,
                category: selectedCat,
                limit: limit,
              ));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Crear presupuesto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              side: BorderSide.none,
            ),
            child: const Text('Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
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

  void _showGoalDetail(BuildContext context, Goal goal) {
    final provider = context.read<GoalProvider>();
    provider.loadContributions(goal.id!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
          builder: (ctx) => Consumer<GoalProvider>(
            builder: (context, provider, _) {
              final currentGoal = provider.goals.firstWhere(
                (g) => g.id == goal.id, orElse: () => goal,
              );
              final goalColor = colorFromHex(currentGoal.colorHex);
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
                              color: goalColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              iconDataFromString(currentGoal.icon),
                              size: 22, color: goalColor,
                            ),
                          ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentGoal.title, style: Theme.of(context).textTheme.titleLarge),
                            Text(currentGoal.deadline, style: Theme.of(context).textTheme.labelSmall),
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
                      Text('${formatCurrency(currentGoal.savedAmount)} ahorrados', style: Theme.of(context).textTheme.labelSmall),
                      Text('${(currentGoal.progress * 100).toInt()}%', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SimpleProgressBar(progress: currentGoal.progress),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Meta: ${formatCurrency(currentGoal.targetAmount)}', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const SizedBox(height: 16),
                  // Add contribution
                  Row(
                    children: [
                      Expanded(
                        child: Text('Historial', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddContribution(ctx, currentGoal),
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
                          onPressed: () => _editGoalName(ctx, currentGoal, setSheetState),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar nombre'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await GoalCustomizerSheet.show(
                              ctx,
                              currentIcon: currentGoal.icon,
                              currentColor: currentGoal.colorHex,
                            );
                            if (result != null && ctx.mounted) {
                              context.read<GoalProvider>().updateGoal(currentGoal.copyWith(
                                icon: result.$1,
                                colorHex: result.$2,
                              ));
                            }
                          },
                          icon: const Icon(Icons.emoji_symbols_outlined, size: 18),
                          label: const Text('Personalizar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _deleteGoal(ctx, currentGoal),
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

  String _capMonth(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final goalColor = colorFromHex(goal.colorHex);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: goalColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    iconDataFromString(goal.icon),
                    color: goalColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                ),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              formatCurrency(goal.savedAmount),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'de ${formatCurrency(goal.targetAmount)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            SimpleProgressBar(progress: goal.progress),
          ],
        ),
      ),
    );
  }

}

class _BudgetItem extends StatelessWidget {
  final Budget budget;
  final bool isLast;
  final VoidCallback? onTap;
  const _BudgetItem({required this.budget, required this.isLast, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.isOverBudget;
    final cat = budget.category;
    final iconData = cat != null
        ? _iconForCategory(cat)
        : Icons.more_horiz;
    final bgColor = cat != null
        ? cat.color.withValues(alpha: 0.2)
        : AppColors.surfaceContainer;
    final fgColor = cat != null
        ? cat.color
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOver
                      ? AppColors.errorContainer
                      : bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  iconData,
                  size: 18,
                  color: isOver
                      ? AppColors.error
                      : fgColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(budget.spent),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedProgressBar(
                  progress: budget.progress,
                  color: isOver ? AppColors.error : fgColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isOver
                    ? '${formatCurrency(budget.remaining.abs())} excedido'
                    : '${formatCurrency(budget.remaining)} restante',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOver ? AppColors.error : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
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
}

class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return TextEditingValue.empty;
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
