import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/account_provider.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/icon_utils.dart';

class AportarScreen extends StatefulWidget {
  const AportarScreen({super.key});

  @override
  State<AportarScreen> createState() => _AportarScreenState();
}

class _AportarScreenState extends State<AportarScreen> {
  Goal? _selectedGoal;
  String _displayValue = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  double get _parsedAmount {
    final raw = _displayValue.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '⌫') {
        if (_displayValue.length > 1) {
          _displayValue = _displayValue.substring(0, _displayValue.length - 1);
        } else {
          _displayValue = '';
        }
      } else if (key == ',') {
        if (!_displayValue.contains(',')) {
          _displayValue += ',';
        }
      } else {
        if (_displayValue.contains(',')) {
          final decimals = _displayValue.split(',')[1];
          if (decimals.length >= 2) return;
        }
        if (_displayValue == '0') {
          _displayValue = key;
        } else {
          _displayValue += key;
        }
      }
      _displayValue = _formatThousands(_displayValue);
    });
  }

  String _formatThousands(String value) {
    if (value.isEmpty) return '';
    if (value.contains(',')) {
      final parts = value.split(',');
      return '${_formatIntPart(parts[0])},${parts[1]}';
    }
    return _formatIntPart(value);
  }

  String _formatIntPart(String intPart) {
    final digits = intPart.replaceAll('.', '');
    if (digits.isEmpty) return '0';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  Future<void> _confirmAportar() async {
    final goal = _selectedGoal;
    final amount = _parsedAmount;
    if (goal == null || amount <= 0) return;

    await context.read<GoalProvider>().addContribution(goal.id!, amount);
    _confettiController.play();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<GoalProvider>(
            builder: (context, provider, _) {
              final goals = provider.goals;
              return SafeArea(
                child: Column(
                  children: [
                    // TopAppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 22),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Aportar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seleccionar Meta
                            Text(
                              'Seleccionar Meta',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 184,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(bottom: 8),
                                separatorBuilder: (_, _) => const SizedBox(width: 16),
                                itemCount: goals.length,
                                itemBuilder: (context, index) {
                                  final goal = goals[index];
                                  final isSelected = _selectedGoal?.id == goal.id;
                                  final goalColor = colorFromHex(goal.colorHex);
                                  final icon = iconDataFromString(goal.icon);
                                  final pct = goal.progress;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedGoal = goal),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 160,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? goalColor : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48, height: 48,
                                            decoration: BoxDecoration(
                                              color: goalColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: Icon(icon, color: goalColor, size: 24),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            goal.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter',
                                              color: AppColors.primary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(pct * 100).toInt()}% completado',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'Inter',
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceContainerHigh,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: pct.clamp(0.0, 1.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: goalColor,
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Monto a Aportar
                            Center(
                              child: Text(
                                _displayValue.isEmpty ? '\$0' : '\$$_displayValue',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Keypad
                            _buildKeypad(),
                            const SizedBox(height: 16),
                            // Todo el saldo
                            Consumer<AccountProvider>(
                              builder: (context, accProvider, _) {
                                final total = accProvider.totalBalance;
                                return SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        final whole = total.toInt();
                                        _displayValue = _formatThousands(whole.toString());
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.surfaceContainerLow,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      side: BorderSide.none,
                                    ),
                                    child: Text(
                                      'Todo el saldo',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Consumer<AccountProvider>(
                                builder: (context, accProvider, _) {
                                  return Text(
                                    'Saldo disponible: ${formatCurrencyWhole(accProvider.totalBalance)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Fixed bottom button
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Consumer<GoalProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedGoal != null && _parsedAmount > 0 ? _confirmAportar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.25),
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirmar Aporte',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: _selectedGoal != null && _parsedAmount > 0
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 22,
                          color: _selectedGoal != null && _parsedAmount > 0
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFC107),
                Color(0xFF4CAF50),
                Color(0xFF03A9F4),
                Color(0xFFE91E63),
                Color(0xFF9C27B0),
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return _KeypadBtn(
                keyValue: key,
                onTap: () => _onKeyPress(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadBtn extends StatelessWidget {
  final String keyValue;
  final VoidCallback onTap;

  const _KeypadBtn({required this.keyValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 88,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: keyValue == '⌫'
                ? const Icon(Icons.backspace_outlined, size: 24, color: AppColors.primary)
                : Text(
                    keyValue,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
