import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late TextEditingController _amountCtrl;
  late String _selectedPeriod;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.budget.limit.toInt().toString());
    _selectedPeriod = 'Mensual';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    await context.read<GoalProvider>().updateBudget(widget.budget.copyWith(
      limit: amount,
    ));
    if (mounted) context.pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: Text('¿Eliminar el presupuesto "${widget.budget.categoryName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<GoalProvider>().deleteBudget(widget.budget.id!);
      if (mounted) context.pop(true);
    }
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

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final cat = budget.category;
    final catColor = cat?.color ?? AppColors.primary;
    final catIcon = cat != null ? _iconForCategory(cat) : Icons.more_horiz;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.0, 0.0),
            radius: 1.41,
            colors: [
              const Color(0xFFF1D6FF),
              const Color(0x00F1D6FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
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
                    const Spacer(),
                    Text(
                      'Editar Presupuesto',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Budget amount
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'PRESUPUESTO MENSUAL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF4C4546),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.65,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 34,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 192,
                                      child: TextField(
                                        controller: _amountCtrl,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 34,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        inputFormatters: [ThousandsInputFormatter()],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: 200,
                                  height: 2,
                                  decoration: ShapeDecoration(
                                    color: const Color(0x7FCFC4C5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(9999),
                                        topRight: Radius.circular(9999),
                                        bottomLeft: Radius.circular(9999),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Form card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category field
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Categoría',
                                    style: TextStyle(
                                      color: const Color(0xFF4C4546),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4F3F8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: catColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Icon(catIcon, size: 18, color: catColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        budget.categoryName,
                                        style: TextStyle(
                                          color: const Color(0xFF1A1B1F),
                                          fontSize: 17,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Period toggle
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  padding: const EdgeInsets.all(4),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4F3F8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(() => _selectedPeriod = 'Mensual'),
                                        child: Container(
                                          width: 147,
                                          height: 48,
                                          decoration: ShapeDecoration(
                                            color: _selectedPeriod == 'Mensual'
                                                ? Colors.white
                                                : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            shadows: _selectedPeriod == 'Mensual'
                                                ? const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))]
                                                : null,
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Mensual',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => _selectedPeriod = 'Semanal'),
                                        child: Container(
                                          width: 147,
                                          height: 48,
                                          child: Center(
                                            child: Text(
                                              'Semanal',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _selectedPeriod == 'Semanal'
                                                    ? Colors.black
                                                    : const Color(0xFF4C4546),
                                                fontSize: 17,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Notifications toggle
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4F3F8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Notificaciones de límite',
                                              style: TextStyle(
                                                color: const Color(0xFF1A1B1F),
                                                fontSize: 17,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Avisar al llegar al 80% del límite',
                                              style: TextStyle(
                                                color: const Color(0xFF4C4546),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
                                        child: Container(
                                          width: 48,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _notificationsEnabled
                                                ? const Color(0xFFE8B3FF)
                                                : const Color(0xFFCFC4C5),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: AnimatedAlign(
                                            duration: const Duration(milliseconds: 200),
                                            alignment: _notificationsEnabled
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 180),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom actions
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFAF9FE).withValues(alpha: 0),
                      const Color(0xFFFAF9FE),
                      const Color(0xFFFAF9FE),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFB75AE6), Color(0xFF7201A2)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x4CB75AE6),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Guardar Cambios',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _delete,
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            'Eliminar Presupuesto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFBA1A1A),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
