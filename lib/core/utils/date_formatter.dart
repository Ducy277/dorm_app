import 'package:intl/intl.dart';

/// Tiện ích định dạng ngày tháng.
class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static String formatDate(DateTime date) => _dateFormat.format(date);
}