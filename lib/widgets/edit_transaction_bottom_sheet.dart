import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import 'segmented_control.dart';

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

Future<void> showEditTransactionSheet(BuildContext context, Transaction transaction) async {
  final result = await showModalBottomSheet<Transaction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _EditTransactionSheet(transaction: transaction),
  );

  if (result != null && context.mounted) {
    await context.read<TransactionProvider>().updateTransaction(result);
  }
}

class _EditTransactionSheet extends StatefulWidget {
  final Transaction transaction;

  const _EditTransactionSheet({required this.transaction});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TransactionType _type;
  late TransactionCategory _category;
  late String _customCategoryName;
  late int? _accountId;
  late DateTime _date;
  late RecurringInterval _recurringInterval;
  bool _isSaving = false;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _titleController = TextEditingController(text: tx.title);
    _amountController = TextEditingController(
      text: tx.amount == tx.amount.roundToDouble()
          ? tx.amount.toInt().toString()
          : tx.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _noteController = TextEditingController(text: tx.note);
    _type = tx.type;
    _category = tx.category;
    _customCategoryName = tx.customCategoryName;
    _accountId = tx.accountId;
    _date = tx.date;
    _recurringInterval = tx.recurringInterval;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper().getAccounts();
    if (mounted) setState(() => _accounts = accounts);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _availableCategories {
    if (_type == TransactionType.income) {
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

  void _save() {
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = widget.transaction.copyWith(
      title: _titleController.text.trim().isEmpty
          ? widget.transaction.title
          : _titleController.text.trim(),
      amount: amount,
      category: _category,
      type: _type,
      accountId: _accountId,
      date: _date,
      note: _noteController.text,
      customCategoryName: _customCategoryName,
      recurringInterval: _recurringInterval,
    );

    Navigator.of(context).pop(updated);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _date.day == DateTime.now().day &&
        _date.month == DateTime.now().month &&
        _date.year == DateTime.now().year;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, size: 22, color: AppColors.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'Editar transacción',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              SegmentedControl(
                options: const ['Gasto', 'Ingreso'],
                selectedIndex: _type == TransactionType.expense ? 0 : 1,
                onChanged: (i) {
                  setState(() {
                    _type = i == 0 ? TransactionType.expense : TransactionType.income;
                    _category = _type == TransactionType.expense
                        ? TransactionCategory.food
                        : TransactionCategory.salary;
                    _customCategoryName = '';
                  });
                },
              ),
              const SizedBox(height: 20),
              Text('Categoría',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._availableCategories.map((cat) => _EditCategoryButton(
                      category: cat,
                      isSelected: _customCategoryName.isEmpty && cat == _category,
                      onTap: () => setState(() {
                        _category = cat;
                        _customCategoryName = '';
                      }),
                    )),
                    ...context.watch<SettingsProvider>().customCategories.entries.map((entry) {
                      final catColor = _colorFromHex(entry.value['color'] ?? '#757575');
                      final isSelected = _customCategoryName == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _category = TransactionCategory.other;
                          _customCategoryName = entry.key;
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_balance_wallet, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _accountId,
                        hint: Text('Cuenta', style: Theme.of(context).textTheme.bodyLarge),
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more, size: 20),
                        items: _accounts.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: Theme.of(context).textTheme.bodyLarge),
                        )).toList(),
                        onChanged: (id) => setState(() => _accountId = id),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.calendar_today, size: 20, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isToday ? 'Hoy' : '${_date.day} ${_getMonthName(_date.month)} ${_date.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${_date.day} ${_getMonthName(_date.month)} ${_date.year}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.edit_note, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(hintText: 'Nota...'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, size: 22),
                            SizedBox(width: 8),
                            Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar transacción'),
                        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      Navigator.of(context).pop();
                      await context.read<TransactionProvider>().deleteTransaction(widget.transaction.id!);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Eliminar transacción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditCategoryButton extends StatelessWidget {
  final TransactionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _EditCategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isSelected ? catColor : catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                _iconForCategory(category),
                size: 24,
                color: isSelected ? Colors.white : catColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
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
