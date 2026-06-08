import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/icon_utils.dart';
import '../widgets/icon_color_picker_sheet.dart';

class EditGoalScreen extends StatefulWidget {
  final Goal goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late String _selectedIcon;
  late String _selectedColor;
  late DateTime _selectedDate;
  bool _isPriority = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.goal.title);
    _amountCtrl = TextEditingController(text: widget.goal.targetAmount.toString().replaceAll('.', ','));
    _selectedIcon = widget.goal.icon;
    _selectedColor = widget.goal.colorHex;
    final parsed = DateFormat.yMMMd('es').tryParse(widget.goal.deadline);
    _selectedDate = parsed ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _nameCtrl.text.trim();
    final amountText = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    if (title.isEmpty || amount == null || amount <= 0) return;

    final deadline = _capMonth(DateFormat.yMMMd('es').format(_selectedDate));
    await context.read<GoalProvider>().updateGoal(widget.goal.copyWith(
      title: title,
      targetAmount: amount,
      icon: _selectedIcon,
      colorHex: _selectedColor,
      deadline: deadline,
    ));
    if (mounted) context.pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Eliminar "${widget.goal.title}"? Se borrará todo el historial de aportes.'),
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
      await context.read<GoalProvider>().deleteGoal(widget.goal.id!);
      if (mounted) context.pop(true);
    }
  }

  String _capMonth(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> _openIconPicker() async {
    final result = await IconColorPickerSheet.show(
      context,
      currentIcon: _selectedIcon,
      currentColor: _selectedColor,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedIcon = result.$1;
        _selectedColor = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalColor = colorFromHex(_selectedColor);

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
                      'Editar Meta',
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
                          // Target Amount
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'MONTO OBJETIVO',
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
                                        onChanged: (_) => setState(() {}),
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
                                // Icon + edit button (centered)
                                Center(
                                  child: GestureDetector(
                                    onTap: _openIconPicker,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: goalColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Icon(
                                            iconDataFromString(_selectedIcon),
                                            size: 26,
                                            color: goalColor,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.edit, size: 13, color: Color(0xFF4C4546)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Name field
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Nombre de la Meta',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4F3F8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF4C4546)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _nameCtrl,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: TextStyle(
                                            color: const Color(0xFF1A1B1F),
                                            fontSize: 17,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Date field
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Fecha Objetivo',
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
                                GestureDetector(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                                    );
                                    if (date != null) setState(() => _selectedDate = date);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF4F3F8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 20, color: Color(0xFF4C4546)),
                                        const SizedBox(width: 12),
                                        Text(
                                          DateFormat('MM/dd/yyyy').format(_selectedDate),
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
                                ),
                                const SizedBox(height: 24),
                                // Priority toggle
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
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: goalColor.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Icon(Icons.flag, size: 20, color: goalColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Meta Prioritaria',
                                              style: TextStyle(
                                                color: const Color(0xFF1A1B1F),
                                                fontSize: 15,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Aparecerá en el inicio',
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
                                        onTap: () => setState(() => _isPriority = !_isPriority),
                                        child: Container(
                                          width: 48,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _isPriority
                                                ? const Color(0xFFE8B3FF)
                                                : const Color(0xFFCFC4C5),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: AnimatedAlign(
                                            duration: const Duration(milliseconds: 200),
                                            alignment: _isPriority
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
                          const SizedBox(height: 32),
                          // Save button
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
                          // Delete button
                          GestureDetector(
                            onTap: _delete,
                            child: SizedBox(
                              height: 48,
                              child: Center(
                                child: Text(
                                  'Eliminar Meta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFBA1A1A),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
