import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final format = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
    locale: 'en_US',
  );
  return format.format(amount);
}

String formatCompactCurrency(double amount) {
  if (amount >= 1000000) {
    return '\$${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(0)}k';
  }
  return formatCurrency(amount);
}
