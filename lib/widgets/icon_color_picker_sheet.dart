import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/icon_utils.dart';

class IconColorPickerSheet extends StatefulWidget {
  final String currentIcon;
  final String currentColor;

  const IconColorPickerSheet({
    super.key,
    required this.currentIcon,
    required this.currentColor,
  });

  static Future<(String icon, String color)?> show(
    BuildContext context, {
    required String currentIcon,
    required String currentColor,
  }) {
    return showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (_) => IconColorPickerSheet(
        currentIcon: currentIcon,
        currentColor: currentColor,
      ),
    );
  }

  @override
  State<IconColorPickerSheet> createState() => _IconColorPickerSheetState();
}

class _IconColorPickerSheetState extends State<IconColorPickerSheet> {
  late String _selectedIcon;
  late String _selectedColor;

  static const List<String> _goalIconNames = [
    'flight_takeoff', 'savings', 'shopping_cart', 'restaurant',
    'directions_car', 'home', 'school', 'favorite',
    'card_giftcard', 'trending_up', 'pets', 'devices',
    'fitness_center', 'book',
  ];

  static const List<String> _colorPalette = [
    '#B75AE6',
    '#007AFF',
    '#34C759',
    '#FF9500',
    '#FF2D55',
    '#32ADE6',
    '#FFD60A',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.currentIcon;
    _selectedColor = _normalizeColor(widget.currentColor);
  }

  String _normalizeColor(String hex) {
    final h = hex.replaceFirst('0xFF', '#').replaceFirst('0x', '#');
    if (h == '#000000' && widget.currentColor == '0xFF000000') {
      return _colorPalette[0];
    }
    if (h.startsWith('#') && h.length == 7) return h;
    return _colorPalette[0];
  }

  Color _parseColor(String hex) {
    return colorFromHex(hex);
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = _parseColor(_selectedColor);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        'Personalizar',
                        style: TextStyle(
                          color: const Color(0xFF1A1B1F),
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.close, size: 18, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: previewColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Icon(
                          iconDataFromString(_selectedIcon),
                          size: 32,
                          color: previewColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Icon section
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'ÍCONO',
                        style: TextStyle(
                          color: const Color(0xFF4C4546),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 13,
                        children: _goalIconNames.map((name) {
                          final isSelected = _selectedIcon == name;
                          final iconColor = _parseColor(_selectedColor);
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = name),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? iconColor
                                    : iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(48),
                                border: isSelected
                                    ? Border.all(color: iconColor, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                iconDataFromString(name),
                                size: 22,
                                color: isSelected ? Colors.white : iconColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Color section
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'COLOR',
                        style: TextStyle(
                          color: const Color(0xFF4C4546),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: _colorPalette.map((hex) {
                          final c = _parseColor(hex);
                          final isSelected = _selectedColor == hex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = hex),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(9999),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 4)
                                    : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: c, blurRadius: 0, spreadRadius: 6)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFE3E2E7)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE9E7ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1A1B1F),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final colorHex =
                            '0xFF${_selectedColor.replaceFirst('#', '')}';
                        Navigator.pop(context, (_selectedIcon, colorHex));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFB75AE6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Aplicar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}
