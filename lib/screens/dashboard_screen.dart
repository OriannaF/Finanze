import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/account_card.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
import '../widgets/transaction_tile.dart';

const List<String> _allCategoryIcons = [
  'account_balance_wallet', 'savings', 'credit_card', 'payments', 'wallet', 'money',
  'restaurant', 'directions_car', 'shopping_bag', 'bolt', 'local_activity',
  'local_hospital', 'school', 'code', 'trending_up', 'home',
  'card_giftcard', 'more_horiz', 'flight_takeoff', 'shopping_cart',
  'favorite', 'pets', 'devices', 'fitness_center', 'book',
  'work', 'celebration', 'construction', 'eco', 'flight',
  'grass', 'icecream', 'kitchen', 'landscape', 'medical_services',
  'nature', 'park', 'photo_camera', 'power', 'public',
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
  return icons[name] ?? Icons.account_balance_wallet;
}

Color _colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  Future<void> _showCreateAccountDialog() async {
    final nameCtrl = TextEditingController();
    String selectedIcon = 'account_balance_wallet';
    String selectedColor = '#1E88E5';
    bool isCountedInTotal = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la cuenta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ícono',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showIconPicker(
                    ctx, selectedIcon, selectedColor, (icon) {
                    setDialogState(() => selectedIcon = icon);
                  }),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _colorFromHex(selectedColor),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _iconDataFromString(selectedIcon),
                          color: Colors.white, size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Tocar para elegir ícono',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant)),
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
                Wrap(
                  spacing: 8,
                  children: accountColors.map((c) {
                    final hex =
                        '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
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
                          border: isSel
                              ? Border.all(
                                  color: AppColors.primary, width: 3)
                              : null,
                        ),
                        child: isSel
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isCountedInTotal,
                      onChanged: (v) =>
                          setDialogState(() => isCountedInTotal = v ?? true),
                    ),
                    const Text('Incluir en el total'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                        context.read<AccountProvider>().insertAccount(
                  Account(
                    name: name,
                    balance: 0,
                    type: AccountType.cash,
                    icon: selectedIcon,
                    color: selectedColor,
                    isCountedInTotal: isCountedInTotal,
                  ),
                );
                Navigator.pop(ctx, true);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cuenta creada'),
            duration: Duration(seconds: 2)),
      );
    }
  }

  void _showFilterSheet(BuildContext context) {
    final txProvider = context.read<TransactionProvider>();
    final currentPeriod = txProvider.selectedPeriod;

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
                child: Text('Filtrar por período',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              ..._buildFilterOption(ctx, txProvider, currentPeriod, 'all', 'Todo'),
              ..._buildFilterOption(ctx, txProvider, currentPeriod, 'week', 'Semana'),
              ..._buildFilterOption(ctx, txProvider, currentPeriod, 'month', 'Mes'),
              ..._buildFilterOption(ctx, txProvider, currentPeriod, 'year', 'Año'),
            ],
          ),
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

  List<Widget> _buildFilterOption(
    BuildContext ctx,
    TransactionProvider txProvider,
    String current,
    String value,
    String label,
  ) {
    return [
      const Divider(height: 1),
      ListTile(
        leading: Icon(
          current == value
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: AppColors.primary,
        ),
        title: Text(label,
            style: TextStyle(
                fontWeight: current == value ? FontWeight.w600 : FontWeight.w400)),
        onTap: () {
          txProvider.loadTransactions(period: value == 'all' ? null : value);
          Navigator.pop(ctx);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final userName = settings.userName.isNotEmpty ? settings.userName : 'usuario';
    final recentTx = txProvider.transactions.take(5).toList();

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/zoe_sentada.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hola, $userName',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(accountProvider.totalBalance),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward, size: 14, color: AppColors.green),
                          const SizedBox(width: 4),
                          Text(
                            formatCurrency(txProvider.totalIncome),
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_downward, size: 14, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            formatCurrency(txProvider.totalExpense),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...accountProvider.accounts.map((a) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AccountCard(
                          account: a,
                          onTap: () => context.push('/account-detail?id=${a.id}'),
                        ),
                      )),
                      AddAccountCard(onTap: _showCreateAccountDialog),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos registros',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (recentTx.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No hay transacciones aún',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.onSurfaceVariant)),
                        )
                      else
                        ...recentTx.map((tx) => Column(
                          children: [
                            TransactionTile(
                              transaction: tx,
                              onTap: () => showEditTransactionSheet(context, tx),
                            ),
                            if (tx != recentTx.last)
                              const Divider(indent: 64, endIndent: 16),
                          ],
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Positioned(
            right: 4,
            bottom: 16,
            child: GestureDetector(
              onTap: () => context.push('/add-amount'),
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
  }
}
