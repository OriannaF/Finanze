import 'package:intl/intl.dart';

String _numberLocale = 'es_AR';

String get numberLocale => _numberLocale;

void setNumberLocale(String locale) {
  _numberLocale = locale;
}

String formatCurrency(double amount) {
  final abs = amount.abs();
  final formatted = NumberFormat('#,##0.00', _numberLocale).format(abs);
  final sign = amount < 0 ? '-' : '';
  return '$sign\$$formatted';
}

String formatCurrencyWhole(double amount) {
  final abs = amount.abs();
  final formatted = NumberFormat('#,##0', _numberLocale).format(abs);
  final sign = amount < 0 ? '-' : '';
  return '$sign\$$formatted';
}

String formatCompactCurrency(double amount) {
  final sign = amount < 0 ? '-' : '';
  final abs = amount.abs();
  if (abs >= 1000000) {
    final formatted = _compactNumber(abs / 1000000);
    return '$sign\$${formatted}M';
  } else if (abs >= 1000) {
    final formatted = _compactNumber(abs / 1000);
    return '$sign\$${formatted}k';
  }
  return formatCurrency(amount);
}

String _compactNumber(double value) {
  return NumberFormat('#,##0.#', _numberLocale).format(value);
}
