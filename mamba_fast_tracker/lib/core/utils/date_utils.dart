import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppDateUtils {
  static bool _localeInitialized = false;

  static Future<void> initLocale() async {
    if (!_localeInitialized) {
      await initializeDateFormatting('pt_BR', null);
      _localeInitialized = true;
    }
  }
  static String formatTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd/MM', 'pt_BR').format(date);
  }

  static String formatWeekday(DateTime date) {
    return DateFormat('EEE', 'pt_BR').format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static List<DateTime> lastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => startOfDay(now.subtract(Duration(days: n - 1 - i))));
  }
}
