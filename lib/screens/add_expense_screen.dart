import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/segmented_control.dart';

const List<String> _allCategoryIcons = [
  'restaurant', 'directions_car', 'shopping_bag', 'bolt', 'local_activity',
  'local_hospital', 'school', 'payments', 'code', 'trending_up', 'home',
  'card_giftcard', 'more_horiz', 'flight_takeoff', 'savings', 'shopping_cart',
  'favorite', 'pets', 'devices', 'fitness_center', 'book', 'wallet', 'money',
];

Color _colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

IconData _iconFromName(String name) {
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

class TransactionDetailScreen extends StatefulWidget {
  final double amount;

  const TransactionDetailScreen({super.key, required this.amount});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionType _transactionType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  String _selectedCustomCategory = '';
  Account? _selectedAccount;
  final TextEditingController _noteController = TextEditingController();
  late DateTime _selectedDate;
  RecurringInterval _recurringInterval = RecurringInterval.none;
  bool _isSaving = false;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper().getAccounts();
    if (mounted) {
      setState(() => _accounts = accounts);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onTypeChanged(int index) {
    setState(() {
      _transactionType = index == 0 ? TransactionType.expense : TransactionType.income;
      _selectedCategory = _transactionType == TransactionType.expense
          ? TransactionCategory.food
          : TransactionCategory.salary;
      _selectedCustomCategory = '';
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final tx = Transaction(
      accountId: _selectedAccount?.id,
      title: _getDefaultTitle(),
      amount: widget.amount,
      category: _selectedCategory,
      type: _transactionType,
      date: _selectedDate,
      note: _noteController.text,
      customCategoryName: _selectedCustomCategory,
      recurringInterval: _recurringInterval,
    );

    await context.read<TransactionProvider>().addTransaction(tx);

    if (mounted) {
      final msg = _transactionType == TransactionType.expense
          ? 'Gasto guardado' : 'Ingreso guardado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
      context.pop();
    }
  }

  String _getDefaultTitle() {
    if (_transactionType == TransactionType.income) {
      switch (_selectedCategory) {
        case TransactionCategory.salary: return 'Salario';
        case TransactionCategory.freelance: return 'Freelance';
        case TransactionCategory.investment: return 'Inversión';
        case TransactionCategory.rental: return 'Renta';
        case TransactionCategory.gift: return 'Regalo';
        default: return 'Ingreso';
      }
    }
    switch (_selectedCategory) {
      case TransactionCategory.food: return 'Comida';
      case TransactionCategory.transport: return 'Transporte';
      case TransactionCategory.shopping: return 'Compra';
      case TransactionCategory.services: return 'Servicio';
      case TransactionCategory.entertainment: return 'Entretenimiento';
      case TransactionCategory.health: return 'Salud';
      case TransactionCategory.education: return 'Educación';
      default: return 'Gasto';
    }
  }

  List<TransactionCategory> get _availableCategories {
    if (_transactionType == TransactionType.income) {
      return [
        TransactionCategory.salary,
        TransactionCategory.freelance,
        TransactionCategory.investment,
        TransactionCategory.rental,
        TransactionCategory.gift,
        TransactionCategory.other,
      ];
    }
    return [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.shopping,
      TransactionCategory.services,
      TransactionCategory.entertainment,
      TransactionCategory.health,
      TransactionCategory.education,
      TransactionCategory.other,
    ];
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '\$${amount.toInt()}';
    }
    return '\$${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _showCreateCustomCategory(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedIcon = 'more_horiz';
    String selectedColor = '#757575';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ícono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _allCategoryIcons.map((iconName) {
                      final isSel = selectedIcon == iconName;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = iconName),
                        child: Container(
                          width: 52, height: 52,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSel ? _colorFromHex(selectedColor) : _colorFromHex(selectedColor).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Icon(
                            _iconFromName(iconName),
                            size: 22,
                            color: isSel ? Colors.white : _colorFromHex(selectedColor),
                          ),
                        ),
                      );
                    }).toList(),
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
                      onTap: () => setDialogState(() { selectedColor = hex; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36, height: 36,
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                context.read<SettingsProvider>().addCustomCategory(name, selectedIcon, selectedColor);
                Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final buttonText = _transactionType == TransactionType.expense
        ? 'Guardar Gasto' : 'Guardar Ingreso';

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 22),
          ),
        ),
        title: GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            _formatAmount(widget.amount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SegmentedControl(
                    options: const ['Gasto', 'Ingreso'],
                    selectedIndex: _transactionType == TransactionType.expense ? 0 : 1,
                    onChanged: _onTypeChanged,
                  ),
                  const SizedBox(height: 24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoría',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                            ..._availableCategories.map((cat) => _CategoryButton(
                              category: cat,
                              isSelected: _selectedCustomCategory.isEmpty && cat == _selectedCategory,
                              onTap: () => setState(() {
                                _selectedCategory = cat;
                                _selectedCustomCategory = '';
                              }),
                            )),
                            ...context.watch<SettingsProvider>().customCategories.entries.map((entry) {
                              final catColor = _colorFromHex(entry.value['color'] ?? '#757575');
                              final isSelected = _selectedCustomCategory == entry.key;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedCategory = TransactionCategory.other;
                                  _selectedCustomCategory = entry.key;
                                }),
                                child: Container(
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 56, height: 56,
                                        decoration: BoxDecoration(
                                          color: isSelected ? catColor : catColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                        child: Icon(
                                          _iconFromName(entry.value['icon'] ?? 'more_horiz'),
                                          size: 24,
                                          color: isSelected ? Colors.white : catColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected ? catColor : AppColors.onSurfaceVariant,
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
                            }),
                            GestureDetector(
                              onTap: () => _showCreateCustomCategory(context),
                              child: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56, height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(color: AppColors.outlineVariant, width: 2),
                                      ),
                                      child: const Icon(Icons.add, color: AppColors.onSurfaceVariant, size: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Nueva',
                                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          ),
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 20,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedAccount?.id,
                                  hint: Text(
                                    'Seleccionar cuenta',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(Icons.expand_more, size: 20),
                                  items: _accounts.map((a) {
                                    return DropdownMenuItem(
                                      value: a.id,
                                      child: Text(
                                        a.name,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (id) {
                                    setState(() {
                                      _selectedAccount = _accounts.firstWhere(
                                        (a) => a.id == id,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hoy',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        ),
                        const Divider(height: 28),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                              ),
                              builder: (ctx) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Text('Repetir', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                      ),
                                      ...RecurringInterval.values.map((ri) {
                                        final label = switch (ri) {
                                          RecurringInterval.none => 'No repetir',
                                          RecurringInterval.daily => 'Cada d\u00eda',
                                          RecurringInterval.weekly => 'Cada semana',
                                          RecurringInterval.monthly => 'Cada mes',
                                          RecurringInterval.yearly => 'Cada a\u00f1o',
                                        };
                                        return Column(
                                          children: [
                                            const Divider(height: 1),
                                            ListTile(
                                              leading: Icon(
                                                _recurringInterval == ri ? Icons.radio_button_checked : Icons.radio_button_off,
                                                color: AppColors.primary,
                                              ),
                                              title: Text(label, style: TextStyle(fontWeight: _recurringInterval == ri ? FontWeight.w600 : FontWeight.w400)),
                                              onTap: () {
                                                setState(() => _recurringInterval = ri);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.repeat, size: 20, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _recurringInterval == RecurringInterval.none ? 'No repetir' : switch (_recurringInterval) {
                                RecurringInterval.daily => 'Cada d\u00eda',
                                RecurringInterval.weekly => 'Cada semana',
                                RecurringInterval.monthly => 'Cada mes',
                                RecurringInterval.yearly => 'Cada a\u00f1o',
                                RecurringInterval.none => 'No repetir',
                              },
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 20, color: AppColors.outlineVariant),
                          ],
                        ),
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit_note,
                                size: 20,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                decoration: const InputDecoration(
                                  hintText: 'Añadir nota...',
                                ),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.lilac.withValues(alpha: 0.5),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            buttonText,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return months[month - 1];
  }
}

class _CategoryButton extends StatelessWidget {
  final TransactionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lilac : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                _iconForCategory(category),
                size: 24,
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
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
      case TransactionCategory.salary: return Icons.payments;
      case TransactionCategory.freelance: return Icons.code;
      case TransactionCategory.investment: return Icons.trending_up;
      case TransactionCategory.rental: return Icons.home;
      case TransactionCategory.gift: return Icons.card_giftcard;
      default: return Icons.more_horiz;
    }
  }
}
