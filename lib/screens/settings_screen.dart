import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
                  icon: Icons.pie_chart_outline,
                  label: 'Límite de presupuesto mensual',
                  trailing: Text(settings.monthlyBudgetLimit > 0
                      ? '\$${settings.monthlyBudgetLimit.toStringAsFixed(0)}'
                      : 'Sin límite'),
                  onTap: () => _showBudgetLimitDialog(settings),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Cuenta por defecto',
                  trailing: Text(_defaultAccountName(settings)),
                  onTap: () => _showDefaultAccountPicker(settings),
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

  void _showBudgetLimitDialog(SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.monthlyBudgetLimit > 0
          ? settings.monthlyBudgetLimit.toStringAsFixed(0)
          : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Límite de presupuesto mensual'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Ingresa un monto',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              settings.setMonthlyBudgetLimit(0);
              Navigator.pop(ctx);
            },
            child: const Text('Sin límite'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                settings.setMonthlyBudgetLimit(value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
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

class _CategoriesScreen extends StatefulWidget {
  const _CategoriesScreen();

  @override
  State<_CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<_CategoriesScreen> {
  late TextEditingController _controller;
  TransactionCategory? _editing;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
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
          ...TransactionCategory.values.map((cat) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.tertiaryFixedDim.withValues(alpha: 0.3),
                child: Icon(
                  _iconForCategory(cat),
                  size: 20,
                  color: AppColors.onTertiaryContainer,
                ),
              ),
              title: Text(settings.getCategoryLabel(cat)),
              subtitle: Text(cat.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _startEditing(cat, settings),
                  ),
                  if (settings.customCategoryLabels.containsKey(cat.name))
                    IconButton(
                      icon: const Icon(Icons.restore_outlined, size: 20),
                      onPressed: () => settings.resetCustomCategoryLabel(cat),
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _startEditing(TransactionCategory cat, SettingsProvider settings) {
    _editing = cat;
    _controller.text = settings.getCategoryLabel(cat);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar categoría'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty && _editing != null) {
                settings.setCustomCategoryLabel(_editing!, _controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
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
      case TransactionCategory.income: return Icons.payments;
      case TransactionCategory.other: return Icons.more_horiz;
    }
  }
}
