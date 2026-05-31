import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateDay = DateTime(date.year, date.month, date.day);

  if (dateDay == today) return 'Hoy';
  if (dateDay == today.subtract(const Duration(days: 1))) return 'Ayer';

  final diff = today.difference(dateDay).inDays;
  if (diff < 7) {
    final weekday = DateFormat('EEEE', 'es').format(date);
    return weekday[0].toUpperCase() + weekday.substring(1);
  }

  return DateFormat('d MMM yyyy', 'es').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy', 'es').format(date);
}

String formatDayMonth(DateTime date) {
  return DateFormat('d MMM', 'es').format(date);
}
