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
import '../widgets/amount_input.dart';
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
  late TextEditingController _titleCtrl;
  late TextEditingController _targetCtrl;
  bool _editingTitle = false;
  bool _editingTarget = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _targetCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final goals = await DatabaseHelper().getGoals();
    final goal = goals.where((g) => g.id == widget.goalId).firstOrNull;
    final contributions = await DatabaseHelper().getContributions(widget.goalId);
    if (!mounted) return;
    setState(() {
      _goal = goal;
      _contributions = contributions;
      if (goal != null) {
        _titleCtrl.text = goal.title;
        _targetCtrl.text = goal.targetAmount.toInt().toString();
      }
    });
  }

  Future<void> _saveTitle(String newTitle) async {
    final goal = _goal;
    if (goal == null || newTitle.trim().isEmpty) return;
    await context.read<GoalProvider>().updateGoal(goal.copyWith(title: newTitle.trim()));
    _load();
  }

  Future<void> _saveTarget(String text) async {
    final goal = _goal;
    final amount = double.tryParse(text.replaceAll('.', '').replaceAll(',', '.'));
    if (goal == null || amount == null || amount <= 0) return;
    await context.read<GoalProvider>().updateGoal(goal.copyWith(targetAmount: amount));
    _load();
  }

  void _showAddContribution() {
    final goal = _goal;
    if (goal == null) return;
    double amount = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(c),
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.close, color: AppColors.primary, size: 22),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Aportar a meta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    AmountInput(
                      amount: amount,
                      onChanged: (v) => setSheetState(() => amount = v),
                    ),
                    const Spacer(flex: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: amount > 0
                              ? () {
                                  context.read<GoalProvider>().addContribution(goal.id!, amount);
                                  Navigator.pop(c);
                                  _load();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aportar',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.add_circle_outline, size: 22, color: AppColors.onPrimary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    if (goal == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: AppColors.background),
          child: const Center(child: Text('Meta no encontrada')),
        ),
      );
    }

    final goalColor = colorFromHex(goal.colorHex);
    final progress = goal.progress.clamp(0.0, 1.0);
    final remaining = (goal.targetAmount - goal.savedAmount).clamp(0.0, double.infinity);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Detalles de Meta',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: PopupMenuButton<String>(
                          offset: const Offset(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditGoalScreen(goal: goal),
                                ),
                              );
                              if (result == true) _load();
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Eliminar meta'),
                                  content: Text('¿Eliminar "${goal.title}"? Se borrará todo el historial de aportes.'),
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
                                await context.read<GoalProvider>().deleteGoal(goal.id!);
                                if (context.mounted) context.pop();
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurface), SizedBox(width: 12), Text('Editar')],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [Icon(Icons.delete_outline, size: 20, color: AppColors.error), SizedBox(width: 12), Text('Eliminar', style: TextStyle(color: AppColors.error))],
                              ),
                            ),
                          ],
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.more_horiz, color: AppColors.onSurface, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main content
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Editable Title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _editingTitle
                              ? TextField(
                                  controller: _titleCtrl,
                                  autofocus: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 30,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onSubmitted: (v) {
                                    _editingTitle = false;
                                    _saveTitle(v);
                                  },
                                  onTapOutside: (_) {
                                    _editingTitle = false;
                                    _saveTitle(_titleCtrl.text);
                                  },
                                )
                              : GestureDetector(
                                  onTap: () => setState(() => _editingTitle = true),
                                  child: Text(
                                    goal.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 30,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                        // Progress Ring + Zoe
                        _buildProgressSection(goal, goalColor, progress),
                        const SizedBox(height: 24),
                        // Info cards
                        _buildInfoCards(goal, goalColor, remaining),
                        const SizedBox(height: 24),
                        // Aportar button
                        _buildAportarButton(goalColor),
                        const SizedBox(height: 32),
                        // Activity
                        _buildActivitySection(goalColor),
                        const SizedBox(height: 24),
                        // Prediction card
                        _buildPredictionCard(),
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

  Widget _buildProgressSection(Goal goal, Color goalColor, double progress) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: SizedBox(
            width: 256,
            height: 256,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: progress,
                color: goalColor,
                backgroundColor: AppColors.surfaceContainer,
                strokeWidth: 24,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatCurrencyWhole(goal.savedAmount),
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() => _editingTarget = !_editingTarget),
                      child: _editingTarget
                          ? SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _targetCtrl,
                                autofocus: true,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onSubmitted: (v) {
                                  _editingTarget = false;
                                  _saveTarget(v);
                                },
                                onTapOutside: (_) {
                                  _editingTarget = false;
                                  _saveTarget(_targetCtrl.text);
                                },
                              ),
                            )
                          : Text(
                              'of ${formatCurrencyWhole(goal.targetAmount)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Speech bubble overlapping bottom of ring
        Positioned(
          left: 40,
          right: 40,
          bottom: -16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    '¡Vas por buen camino! 🌸',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Zoe character
        Positioned(
          left: -20,
          bottom: -10,
          child: Image.asset('assets/images/zoe_sentada.png', width: 112, height: 112),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Goal goal, Color goalColor, double remaining) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Falta', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(
                  formatCurrencyWhole(remaining),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha Límite', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontFamily: 'Inter')),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      final deadline = _capMonth(DateFormat.yMMMd('es').format(date));
                      await context.read<GoalProvider>().updateGoal(goal.copyWith(deadline: deadline));
                      _load();
                    }
                  },
                  child: Text(
                    goal.deadline,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAportarButton(Color goalColor) {
    return GestureDetector(
      onTap: _showAddContribution,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: goalColor,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(color: goalColor.withValues(alpha: 0.39), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Aportar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(Color goalColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.onSurface,
              ),
            ),
            if (_contributions.length > 3)
              GestureDetector(
                onTap: () => setState(() => _showAllContributions = !_showAllContributions),
                child: Text(
                  _showAllContributions ? 'Ver menos' : 'Ver todo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: const Color(0xFFAF52DE),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_contributions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Text(
              'Sin aportes aún',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'Inter'),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
            child: Column(children: _buildContributionTiles()),
          ),
      ],
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4D6), Color(0xFFD8B4FE)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En dos semanas llegarías a tu meta con este ritmo',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ZoeIA',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContributionTiles() {
    final displayList = _showAllContributions ? _contributions : _contributions.take(3).toList();
    return List.generate(displayList.length, (i) {
      final c = displayList[i];
      final isLast = i == displayList.length - 1;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isLast ? null : BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.surfaceContainer, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.trending_up, size: 18, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aporte',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.yMd('es').add_Hm().format(c.date),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${formatCurrencyWhole(c.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _capMonth(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background
    paint.color = backgroundColor;
    canvas.drawCircle(center, radius, paint);

    // Progress
    paint.color = color;
    const fullAngle = 2 * 3.141592653589793;
    final sweepAngle = fullAngle * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -fullAngle / 4,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
