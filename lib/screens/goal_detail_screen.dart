import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/icon_utils.dart';
import '../widgets/progress_bar.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  Goal? _goal;
  List<GoalContribution> _contributions = [];
  bool _showAllContributions = false;

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

  void _showAddContribution() {
    final goal = _goal;
    if (goal == null) return;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Aportar a meta'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Monto',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) {
                context.read<GoalProvider>().addContribution(goal.id!, amount);
              }
              Navigator.pop(c);
              _load();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;

    return Scaffold(
      body: Container(
        width: double.infinity,
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
        child: goal == null
            ? const Center(child: Text('Meta no encontrada'))
            : SafeArea(
                child: SingleChildScrollView(
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
                              'Detalles de Meta',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final goal = _goal;
                                  if (goal == null) return;
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditGoalScreen(goal: goal),
                                    ),
                                  );
                                  if (result == true) _load();
                                } else if (value == 'delete') {
                                  final goal = _goal;
                                  if (goal == null) return;
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Eliminar meta'),
                                      content: Text('¿Eliminar "${goal.title}"? Se borrará todo el historial de aportes.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                                          onPressed: () => Navigator.pop(c, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await context.read<GoalProvider>().deleteGoal(goal.id!);
                                    if (context.mounted) context.pop();
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurface),
                                      SizedBox(width: 12),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                      SizedBox(width: 12),
                                      Text('Eliminar', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(Icons.more_horiz, color: AppColors.onSurface, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Goal title
                              Center(
                                child: Text(
                                  goal.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 34,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Amount display
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      formatCurrency(goal.savedAmount),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 34,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'of ${formatCurrency(goal.targetAmount)}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF4C4546),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Progress bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: SimpleProgressBar(progress: goal.progress),
                              ),
                              const SizedBox(height: 8),
                              // Percentage badge
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: ShapeDecoration(
                                    color: colorFromHex(goal.colorHex).withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Text(
                                    '${(goal.progress * 100).toInt()}% consumido',
                                    style: TextStyle(
                                      color: colorFromHex(goal.colorHex),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Info cards row: remaining + deadline
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
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
                                          Text(
                                            'Falta',
                                            style: TextStyle(
                                              color: const Color(0xFF4C4546),
                                              fontSize: 13,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatCurrency((goal.targetAmount - goal.savedAmount).clamp(0, double.infinity)),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
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
                                          Text(
                                            'Fecha Límite',
                                            style: TextStyle(
                                              color: const Color(0xFF4C4546),
                                              fontSize: 13,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            goal.deadline,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Aportar button
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: _showAddContribution,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFB75AE6),
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Aportar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Activity section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Actividad',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_contributions.length > 3)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _showAllContributions = !_showAllContributions);
                                      },
                                      child: Text(
                                        _showAllContributions ? 'Ver menos' : 'Ver todo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFFB75AE6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Contributions list
                              if (_contributions.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Sin aportes aún',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.onSurfaceVariant),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
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
                                    children: _buildContributionTiles(),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // ZoeIA insight
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.0, 0.0),
                                    radius: 1.41,
                                    colors: [
                                      const Color(0xFFF6D9FF),
                                      const Color(0x00F6D9FF),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'En dos semanas llegarías a tu meta con este ritmo ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ZoeIA',
                                      style: TextStyle(
                                        color: const Color(0xFF4C4546),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildContributionTiles() {
    final displayList = _showAllContributions
        ? _contributions
        : _contributions.take(3).toList();

    return List.generate(displayList.length, (i) {
      final c = displayList[i];
      final isLast = i == displayList.length - 1;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: isLast
            ? null
            : ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0xFFEEEDF3)),
                ),
              ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFEEEDF3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Icon(Icons.arrow_upward, size: 20, color: AppColors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aporte',
                    style: TextStyle(
                      color: const Color(0xFF1A1B1F),
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat.yMd('es').add_Hm().format(c.date),
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
            Text(
              '+${formatCurrency(c.amount)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.green,
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
