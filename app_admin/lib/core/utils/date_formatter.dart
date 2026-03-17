import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatWithTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
  }

  static String formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
