import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/icon_utils.dart';
import '../widgets/progress_bar.dart';
import '../widgets/segmented_control.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/transaction.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metas',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showCreateSheet(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar objetivo'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
              // FAB - Aportar
              Positioned(
                right: 4,
                bottom: 16,
                child: GestureDetector(
                  onTap: () => context.push('/aportar'),
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
                      inputFormatters: [ThousandsInputFormatter()],
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
                      inputFormatters: [ThousandsInputFormatter()],
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
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: goalColor.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Icon(
                        iconDataFromString(goal.icon),
                        size: 20,
                        color: goalColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            color: Color(0xFF191C1D),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          goal.deadline,
                          style: const TextStyle(
                            color: Color(0xFF4C4546),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrencyWhole(goal.savedAmount),
                  style: const TextStyle(
                    color: Color(0xFF4C4546),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatCurrencyWhole(goal.targetAmount),
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 6,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F4F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// But you held me down with those words, you held me down
// I'm not a girl who gives up like that
// No, I'm not that girl

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
        ? cat.color
        : AppColors.primary;
    final progress = budget.progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isLast
                  ? Colors.transparent
                  : const Color(0x19CFC4C5),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        color: isOver
                            ? const Color(0xFFFFDAD6)
                            : bgColor.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Icon(
                        iconData,
                        size: 22,
                        color: isOver ? AppColors.error : bgColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      budget.categoryName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF191C1D),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrencyWhole(budget.spent),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: isOver ? AppColors.error : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      'de ${formatCurrencyWhole(budget.limit)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF4C4546),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedProgressBar(
                progress: progress,
                color: isOver ? AppColors.error : bgColor,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOver
                        ? '${formatCurrencyWhole(budget.remaining.abs())} excedido'
                        : '${formatCurrencyWhole(budget.remaining)} restante',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      color: isOver ? AppColors.error : const Color(0xFF4C4546),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                ],
              ),
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
