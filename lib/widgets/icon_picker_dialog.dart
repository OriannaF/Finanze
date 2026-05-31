import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';
import '../theme/app_colors.dart';

class IconPickerDialog extends StatefulWidget {
  final String currentIcon;
  final String currentColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<String> onColorSelected;

  const IconPickerDialog({
    super.key,
    required this.currentIcon,
    required this.currentColor,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  late String _selectedIcon;
  late String _selectedColor;

  static const List<String> _palette = [
    '#1E88E5', '#E53935', '#43A047', '#FB8C00', '#8E24AA',
    '#00ACC1', '#F4511E', '#3949AB', '#C0CA33', '#D81B60',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.currentIcon;
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: colorFromHex(_selectedColor).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(
                iconDataFromString(_selectedIcon),
                size: 32,
                color: colorFromHex(_selectedColor),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette.map((c) {
                final isSelected = _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: colorFromHex(c),
                      borderRadius: BorderRadius.circular(18),
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: colorFromHex(c).withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ícono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: allCategoryIcons.length,
                itemBuilder: (_, i) {
                  final iconName = allCategoryIcons[i];
                  final isSelected = _selectedIcon == iconName;
                  final iconColor = colorFromHex(_selectedColor);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? iconColor : iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: iconColor, width: 2) : null,
                      ),
                      child: Icon(
                        iconDataFromString(iconName),
                        size: 24,
                        color: isSelected ? Colors.white : iconColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onIconSelected(_selectedIcon);
                  widget.onColorSelected(_selectedColor);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Confirmar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showIconPickerDialog(
  BuildContext context, {
  required String currentIcon,
  required String currentColor,
  required ValueChanged<String> onIconSelected,
  required ValueChanged<String> onColorSelected,
}) {
  return showDialog(
    context: context,
    builder: (_) => IconPickerDialog(
      currentIcon: currentIcon,
      currentColor: currentColor,
      onIconSelected: onIconSelected,
      onColorSelected: onColorSelected,
    ),
  );
}
