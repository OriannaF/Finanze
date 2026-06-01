import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/progress_bar.dart';

IconData _goalIconData(String name) {
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

const Map<String, IconData> _goalIconMap = {
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

Color _colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

class GoalDetailScreen extends StatefulWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  Goal? _goal;
  List<GoalContribution> _contributions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals = await DatabaseHelper().getGoals();
    final goal = goals.where((g) => g.id == widget.goalId).firstOrNull;
    final contributions = await DatabaseHelper().getContributions(widget.goalId);
    if (!mounted) return;
    setState(() {
      _goal = goal;
      _contributions = contributions;
    });
  }

  void _showEditDialog() {
    final goal = _goal;
    if (goal == null) return;

    String selectedIcon = goal.icon;
    final raw = goal.colorHex.replaceFirst('0x', '');
    String selectedColor = '#${raw.substring(2)}';
    final nameCtrl = TextEditingController(text: goal.title);
    final amountCtrl = TextEditingController(text: goal.targetAmount.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar meta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la meta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Monto objetivo',
                    border: OutlineInputBorder(),
                    prefixText: r'$ ',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ícono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showGoalIconPicker(ctx, selectedIcon, selectedColor, (newIcon) {
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
                          _goalIconData(selectedIcon),
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
                final newAmount = double.tryParse(amountCtrl.text);
                if (newName.isEmpty || newAmount == null || newAmount <= 0) return;
                final colorHex = '0xFF${selectedColor.replaceFirst('#', '')}';
                context.read<GoalProvider>().updateGoal(goal.copyWith(
                  title: newName,
                  targetAmount: newAmount,
                  icon: selectedIcon,
                  colorHex: colorHex,
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

  void _showGoalIconPicker(BuildContext sheetContext, String currentIcon, String currentColor, void Function(String) onSelected) {
    final iconNames = _goalIconMap.keys.toList();
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
            itemCount: iconNames.length,
            itemBuilder: (_, i) {
              final iconName = iconNames[i];
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
                    _goalIconData(iconName),
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
    final goal = _goal;

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
        title: Text(goal?.title ?? 'Meta'),
        actions: [
          if (goal != null)
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
      body: goal == null
          ? const Center(child: Text('Meta no encontrada'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            _goalIconData(goal.icon),
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formatCurrency(goal.savedAmount),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'de ${formatCurrency(goal.targetAmount)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: SimpleProgressBar(progress: goal.progress),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(goal.progress * 100).toInt()}% · ${goal.deadline}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Historial de aportes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_contributions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sin aportes aún',
                            style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                    )
                  else
                    ..._contributions.map((c) => Column(
                          children: [
                            _ContributionTile(contribution: c),
                            if (c != _contributions.last)
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

class _ContributionTile extends StatelessWidget {
  final GoalContribution contribution;

  const _ContributionTile({required this.contribution});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_upward, size: 20, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aporte',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMd('es').add_Hm().format(contribution.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${formatCurrency(contribution.amount)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
