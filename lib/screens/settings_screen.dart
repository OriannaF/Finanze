import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper().getAccounts();
    if (mounted) setState(() => _accounts = accounts);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 22),
          ),
        ),
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _SettingsGroup(
              title: 'Finanzas',
              children: [
                _SettingsItem(
                  icon: Icons.attach_money,
                  label: 'Moneda predeterminada',
                  trailing: Text(settings.currency),
                  onTap: () => _showCurrencyPicker(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.numbers,
                  label: 'Formato',
                  trailing: Text(settings.numberLocale == 'es_AR' ? '10.000,00' : '10,000.00'),
                  onTap: () => _showNumberFormatPicker(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Cuenta por defecto',
                  trailing: Text(_defaultAccountName(settings)),
                  onTap: () => _showDefaultAccountPicker(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.manage_accounts,
                  label: 'Administrar cuentas',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                  onTap: () => context.push('/account-settings'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Datos',
              children: [
                _SettingsItem(
                  icon: Icons.file_download_outlined,
                  label: 'Exportar transacciones',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                  onTap: () => _exportTransactions(context),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.backup_outlined,
                  label: 'Respaldo y restauración',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                  onTap: () => _showBackupOptions(context),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.delete_forever,
                  label: 'Borrar todos los datos',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                  onTap: () => _confirmDeleteAll(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Personalización',
              children: [
                _SettingsItem(
                  icon: Icons.calendar_today,
                  label: 'Formato de fecha',
                  trailing: Text(settings.dateFormat),
                  onTap: () => _toggleDateFormat(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.view_week_outlined,
                  label: 'Inicio de semana',
                  trailing: Text(settings.weekStartDay),
                  onTap: () => _toggleWeekStart(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.category_outlined,
                  label: 'Categorías personalizadas',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _CategoriesScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Información',
              children: [
                _SettingsItem(
                  icon: Icons.info_outline,
                  label: 'Acerca de',
                  trailing: const Text('v1.0.0'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _defaultAccountName(SettingsProvider settings) {
    final id = settings.defaultAccountId;
    if (id == null) return 'Ninguna';
    final account = _accounts.where((a) => a.id == id).firstOrNull;
    return account?.name ?? 'Ninguna';
  }

  void _showCurrencyPicker(SettingsProvider settings) {
    const currencies = ['ARS', 'USD', 'EUR'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Moneda predeterminada',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            ...currencies.map((c) => ListTile(
              leading: Icon(
                c == settings.currency ? Icons.radio_button_checked : Icons.radio_button_off,
                color: AppColors.primary,
              ),
              title: Text(c),
              onTap: () {
                settings.setCurrency(c);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showNumberFormatPicker(SettingsProvider settings) {
    const options = [
      {'locale': 'es_AR', 'label': '10.000,00'},
      {'locale': 'en_US', 'label': '10,000.00'},
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Formato',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            ...options.map((opt) => ListTile(
              leading: Icon(
                opt['locale'] == settings.numberLocale ? Icons.radio_button_checked : Icons.radio_button_off,
                color: AppColors.primary,
              ),
              title: Text(opt['label']!),
              onTap: () {
                settings.updateNumberLocale(opt['locale']!);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDefaultAccountPicker(SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Cuenta por defecto',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                settings.defaultAccountId == null
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppColors.primary,
              ),
              title: const Text('Ninguna'),
              onTap: () {
                settings.setDefaultAccountId(null);
                Navigator.pop(ctx);
              },
            ),
            ..._accounts.map((a) => ListTile(
              leading: Icon(
                a.id == settings.defaultAccountId
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppColors.primary,
              ),
              title: Text(a.name),
              subtitle: Text('\$${a.balance.toStringAsFixed(2)}'),
              onTap: () {
                settings.setDefaultAccountId(a.id);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactions(BuildContext ctx) async {
    final db = DatabaseHelper();
    final data = await db.exportAllData();
    final csv = StringBuffer();
    csv.writeln('Título,Monto,Categoría,Tipo,Fecha,Nota');
    for (final t in data['transactions'] ?? []) {
      csv.writeln(
          '"${t['title']}",${t['amount']},"${t['category']}","${t['type']}","${t['date']}","${t['note']}"');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finanze_export.csv');
    await file.writeAsString(csv.toString());
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Exportado a ${file.path}')),
    );
  }

  Future<void> _showBackupOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Respaldo y restauración',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Crear respaldo'),
              onTap: () async {
                Navigator.pop(ctx);
                await _createBackup(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Restaurar respaldo'),
              onTap: () async {
                Navigator.pop(ctx);
                await _restoreBackup(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup(BuildContext ctx) async {
    final db = DatabaseHelper();
    final data = await db.exportAllData();
    final jsonStr = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finanze_backup.json');
    await file.writeAsString(jsonStr);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Respaldo creado en ${file.path}')),
    );
  }

  Future<void> _restoreBackup(BuildContext ctx) async {
    final txProvider = ctx.read<TransactionProvider>();
    final goalProvider = ctx.read<GoalProvider>();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finanze_backup.json');
    if (!await file.exists()) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No hay archivo de respaldo')),
      );
      return;
    }
    if (!ctx.mounted) return;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Restaurar respaldo'),
        content: const Text('Se reemplazarán todos los datos actuales. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (confirmed != true) return;
    final json = await file.readAsString();
    final data = Map<String, List<Map<String, dynamic>>>.from(
      (jsonDecode(json) as Map).map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))),
    );
    final db = DatabaseHelper();
    await db.importAllData(data);
    if (!ctx.mounted) return;
    txProvider.loadTransactions();
    goalProvider.loadData();
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Datos restaurados correctamente')),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext ctx) async {
    final txProvider = ctx.read<TransactionProvider>();
    final goalProvider = ctx.read<GoalProvider>();
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text('Esta acción no se puede deshacer. Se eliminarán todas las transacciones, cuentas, metas y presupuestos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = DatabaseHelper();
    await db.deleteAllData();
    if (!ctx.mounted) return;
    txProvider.loadTransactions();
    goalProvider.loadData();
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Todos los datos fueron eliminados')),
    );
  }

  void _toggleDateFormat(SettingsProvider settings) {
    final newFormat = settings.dateFormat == 'DD/MM' ? 'MM/DD' : 'DD/MM';
    settings.setDateFormat(newFormat);
  }

  void _toggleWeekStart(SettingsProvider settings) {
    final newDay = settings.weekStartDay == 'Lunes' ? 'Domingo' : 'Lunes';
    settings.setWeekStartDay(newDay);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finanze'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión: 1.0.0'),
            SizedBox(height: 8),
            Text('App de finanzas personales'),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleLarge),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 58, endIndent: 20, height: 1);
  }
}

const List<String> _allCategoryIcons = [
  'restaurant', 'directions_car', 'shopping_bag', 'bolt', 'local_activity',
  'local_hospital', 'school', 'payments', 'code', 'trending_up', 'home',
  'card_giftcard', 'more_horiz', 'flight_takeoff', 'savings', 'shopping_cart',
  'favorite', 'pets', 'devices', 'fitness_center', 'book', 'wallet', 'money',
];

IconData _iconDataFromName(String name) {
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

class _CategoriesScreen extends StatefulWidget {
  const _CategoriesScreen();

  @override
  State<_CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<_CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Categorías personalizadas'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 22),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (settings.customCategories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Tuyas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
            ),
            ...settings.customCategories.entries.map((entry) => _CategoryListTile(
              name: entry.key,
              iconName: entry.value['icon'] ?? 'more_horiz',
              colorHex: entry.value['color'] ?? '#757575',
              onEdit: () => _showEditDialog(entry.key, settings, isCustom: true),
              onDelete: () => _confirmDelete(entry.key, settings),
            )),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Predeterminadas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
          ),
          ...TransactionCategory.values.map((cat) {
            final hex = '#${cat.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
            return _CategoryListTile(
              name: settings.getCategoryLabel(cat),
              iconName: cat.icon,
              colorHex: hex,
              hasCustomLabel: settings.customCategoryLabels.containsKey(cat.name),
              onEdit: () => _showEditDialog(cat.name, settings, isCustom: false, cat: cat),
              onReset: settings.customCategoryLabels.containsKey(cat.name)
                  ? () => settings.resetCustomCategoryLabel(cat)
                  : null,
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditDialog(null, settings),
              icon: const Icon(Icons.add),
              label: const Text('Añadir categoría personalizada'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String? name, SettingsProvider settings,
      {bool isCustom = false, TransactionCategory? cat}) {
    final nameCtrl = TextEditingController(text: name ?? '');
    String selectedIcon = isCustom
        ? (settings.customCategories[name]?['icon'] ?? 'more_horiz')
        : (cat?.icon ?? 'more_horiz');
    String selectedColor = isCustom
        ? (settings.customCategories[name]?['color'] ?? '#757575')
        : (cat != null
            ? '#${cat.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}'
            : '#757575');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(name == null ? 'Nueva categoría' : 'Editar categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: name == null,
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
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSel ? _colorFromHex(selectedColor) : _colorFromHex(selectedColor).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Icon(
                            _iconDataFromName(iconName),
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
                      onTap: () => setDialogState(() {
                        selectedColor = hex;
                      }),
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
            if (name != null && !isCustom)
              TextButton(
                onPressed: () {
                  settings.resetCustomCategoryLabel(cat!);
                  Navigator.pop(ctx);
                },
                child: const Text('Restaurar', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newName = nameCtrl.text.trim();
                if (newName.isEmpty) return;
                if (name == null) {
                  settings.addCustomCategory(newName, selectedIcon, selectedColor);
                } else if (isCustom) {
                  settings.editCustomCategory(name, newName, selectedIcon, selectedColor);
                } else if (cat != null) {
                  settings.setCustomCategoryLabel(cat, newName);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String name, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              settings.deleteCustomCategory(name);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final String name;
  final String iconName;
  final String colorHex;
  final bool hasCustomLabel;
  final VoidCallback onEdit;
  final VoidCallback? onReset;
  final VoidCallback? onDelete;

  const _CategoryListTile({
    required this.name,
    required this.iconName,
    required this.colorHex,
    this.hasCustomLabel = false,
    required this.onEdit,
    this.onReset,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(colorHex);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            _iconDataFromName(iconName),
            size: 20,
            color: color,
          ),
        ),
        title: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            if (onReset != null)
              IconButton(
                icon: const Icon(Icons.restore_outlined, size: 20),
                onPressed: onReset,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
