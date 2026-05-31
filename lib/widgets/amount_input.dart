import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AmountInput extends StatefulWidget {
  final double amount;
  final ValueChanged<double> onChanged;
  final String currencySymbol;

  const AmountInput({
    super.key,
    this.amount = 0,
    required this.onChanged,
    this.currencySymbol = r'$',
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late String _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = _fromDouble(widget.amount);
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _displayValue = _fromDouble(widget.amount);
    }
  }

  String _fromDouble(double value) {
    final rounded = (value * 100).roundToDouble() / 100;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '⌫') {
        if (_displayValue.length > 1) {
          _displayValue = _displayValue.substring(0, _displayValue.length - 1);
        } else {
          _displayValue = '0';
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

      final parsed = double.tryParse(_displayValue.replaceAll(',', '.'));
      if (parsed != null) {
        widget.onChanged(parsed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${widget.currencySymbol}$_displayValue',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: AppColors.primary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 32),
        _buildKeypad(),
      ],
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return _KeypadButton(
              keyValue: key,
              onTap: () => _onKeyPress(key),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String keyValue;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.keyValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: keyValue == '⌫'
              ? const Icon(Icons.backspace_outlined, size: 24, color: AppColors.onSurface)
              : Text(
                  keyValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
