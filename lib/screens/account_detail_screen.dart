import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
import '../widgets/transaction_tile.dart';

const List<String> _allCategoryIcons = [
  'account_balance_wallet', 'savings', 'credit_card', 'payments', 'wallet', 'money',
  'restaurant', 'directions_car', 'shopping_bag', 'bolt', 'local_activity',
  'local_hospital', 'school', 'code', 'trending_up', 'home',
  'card_giftcard', 'more_horiz', 'flight_takeoff', 'shopping_cart',
  'favorite', 'pets', 'devices', 'fitness_center', 'book',
  'work', 'celebration', 'construction', 'eco', 'flight',
  'grass', 'icecream', 'kitchen', 'landscape', 'light',
  'medical_services', 'nature', 'park', 'photo_camera', 'power', 'public',
  'recycling', 'restaurant_menu', 'security', 'self_improvement',
  'smartphone', 'solar_power', 'spa', 'sports_esports',
  'star', 'sunny', 'theater_comedy', 'timer',
  'toys', 'train', 'two_wheeler',
  'verified', 'water_drop', 'web', 'weekend',
  'yard',
];

IconData _iconDataFromString(String name) {
  const icons = {
    'account_balance_wallet': Icons.account_balance_wallet,
    'savings': Icons.savings,
    'credit_card': Icons.credit_card,
    'payments': Icons.payments,
    'wallet': Icons.wallet,
    'money': Icons.money,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'bolt': Icons.bolt,
    'local_activity': Icons.local_activity,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'code': Icons.code,
    'trending_up': Icons.trending_up,
    'home': Icons.home,
    'card_giftcard': Icons.card_giftcard,
    'more_horiz': Icons.more_horiz,
    'flight_takeoff': Icons.flight_takeoff,
    'shopping_cart': Icons.shopping_cart,
    'favorite': Icons.favorite,
    'pets': Icons.pets,
    'devices': Icons.devices,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'work': Icons.work,
    'celebration': Icons.celebration,
    'construction': Icons.construction,
    'eco': Icons.eco,
    'flight': Icons.flight,
    'grass': Icons.grass,
    'icecream': Icons.icecream,
    'kitchen': Icons.kitchen,
    'landscape': Icons.landscape,
    'medical_services': Icons.medical_services,
    'nature': Icons.nature,
    'park': Icons.park,
    'photo_camera': Icons.photo_camera,
    'power': Icons.power,
    'public': Icons.public,
    'recycling': Icons.recycling,
    'restaurant_menu': Icons.restaurant_menu,
    'security': Icons.security,
    'self_improvement': Icons.self_improvement,
    'smartphone': Icons.smartphone,
    'solar_power': Icons.solar_power,
    'spa': Icons.spa,
    'sports_esports': Icons.sports_esports,
    'star': Icons.star,
    'sunny': Icons.sunny,
    'theater_comedy': Icons.theater_comedy,
    'timer': Icons.timer,
    'toys': Icons.toys,
    'train': Icons.train,
    'two_wheeler': Icons.two_wheeler,
    'verified': Icons.verified,
    'water_drop': Icons.water_drop,
    'web': Icons.web,
    'weekend': Icons.weekend,
    'yard': Icons.yard,
  };
  return icons[name] ?? Icons.more_horiz;
}

Color _colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

class AccountDetailScreen extends StatefulWidget {
  final int accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  Account? _account;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await DatabaseHelper().getAccounts();
    final account = accounts.where((a) => a.id == widget.accountId).firstOrNull;
    final tx = await DatabaseHelper().getTransactionsByAccount(widget.accountId);
    if (!mounted) return;
    setState(() {
      _account = account;
      _transactions = tx;
    });
  }

  void _showEditDialog() {
    if (_account == null) return;
    final account = _account!;
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(
        text: account.balance.toStringAsFixed(2));
    String selectedIcon = account.icon;
    String selectedColor = account.color;
    bool countInTotal = account.isCountedInTotal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Editar cuenta',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 24),
                  Text('Nombre',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Efectivo, Débito',
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Icono',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showIconPicker(
                      ctx,
                      selectedIcon,
                      selectedColor,
                      (newIcon) => setDialogState(() => selectedIcon = newIcon),
                    ),
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
                            _iconDataFromString(selectedIcon),
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
                  Text('Color',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: accountColors.map((c) {
                      final hex = '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                      final isSelected = selectedColor == hex;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: c != accountColors.last ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setDialogState(() { selectedColor = hex; }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(18),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Saldo',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: countInTotal,
                        onChanged: (v) => setDialogState(() => countInTotal = v ?? true),
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Incluir en el total general',
                        style: TextStyle(fontSize: 14, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final newBalance = double.tryParse(balanceController.text) ??
                            account.balance;
                        final diff = newBalance - account.balance;
                        final updated = account.copyWith(
                          name: name,
                          balance: newBalance,
                          icon: selectedIcon,
                          color: selectedColor,
                          isCountedInTotal: countInTotal,
                        );

                        if (diff != 0) {
                          final oldBalance = account.balance;
                          if (!ctx.mounted) return;
                          final confirmed = await showDialog<bool>(
                            context: ctx,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Cambio de saldo'),
                              content: Text(
                                'El saldo cambió de ${formatCurrency(oldBalance)} a ${formatCurrency(newBalance)}.\n'
                                '¿Querés registrar la diferencia de ${formatCurrency(diff.abs())} como transacción?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                                  child: const Text('No, solo actualizar',
                                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                                  child: const Text('Sí, registrar'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await context.read<TransactionProvider>().addTransaction(
                              Transaction(
                                accountId: account.id,
                                title: 'Ajuste de saldo',
                                amount: diff.abs(),
                                category: TransactionCategory.other,
                                type: diff > 0 ? TransactionType.income : TransactionType.expense,
                              ),
                            );
                          }
                        }

                        await context.read<AccountProvider>().updateAccount(updated);
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        await _load();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Guardar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Eliminar cuenta'),
                            content: const Text(
                              'Esta acción es permanente. ¿Estás seguro de eliminar esta cuenta? Se eliminarán todas las transacciones asociadas.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(false),
                                child: const Text('Cancelar',
                                    style: TextStyle(color: AppColors.onSurfaceVariant)),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () => Navigator.of(dialogCtx).pop(true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await context.read<AccountProvider>().deleteAccount(account.id!);
                        }
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (confirmed == true) {
                          if (!context.mounted) return;
                          context.pop();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Eliminar cuenta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            itemCount: _allCategoryIcons.length,
            itemBuilder: (_, i) {
              final iconName = _allCategoryIcons[i];
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
                    _iconDataFromString(iconName),
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
    final account = _account;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-amount'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
        title: Text(account?.name ?? 'Cuenta'),
        actions: [
          if (account != null)
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
      body: account == null
          ? const Center(child: Text('Cuenta no encontrada'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      formatCurrency(account.balance),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _typeLabel(account.type),
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
                        child: Text('Sin transacciones',
                            style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                    )
                  else
                    ..._transactions.map((tx) => Column(
                      children: [
                        TransactionTile(
                          transaction: tx,
                          onTap: () => showEditTransactionSheet(context, tx),
                        ),
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

  String _typeLabel(AccountType type) {
    switch (type) {
      case AccountType.cash: return 'Efectivo';
      case AccountType.debit: return 'Débito';
      case AccountType.credit: return 'Crédito';
      case AccountType.savings: return 'Ahorros';
    }
  }
}




