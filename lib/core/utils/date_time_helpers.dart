import 'package:intl/intl.dart';

abstract final class DateTimeHelpers {
  static const List<String> _indonesianMonths = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _shortMonths = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Returns full Indonesian month name (e.g. Oktober)
  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return _indonesianMonths[month];
    }
    return '';
  }

  /// Returns short Indonesian month name (e.g. Okt)
  static String getShortMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return _shortMonths[month];
    }
    return '';
  }

  /// Formats DateTime to Indonesian readable date (e.g. 3 Okt 2026)
  static String formatReadableDate(DateTime dateTime) {
    return '${dateTime.day} ${getShortMonthName(dateTime.month)} ${dateTime.year}';
  }

  /// Alias for Indonesian readable date formatting
  static String formatIndonesianDate(DateTime dateTime) {
    return formatReadableDate(dateTime);
  }

  /// Formats DateTime to HH:mm (e.g. 14:30)
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Calculates remaining days until the end of the current monthly cycle.
  /// If cycleStartDay is 1, cycle ends on the last day of the current month.
  /// Always returns at least 1 to prevent division-by-zero errors.
  static int getRemainingDaysInCycle({int cycleStartDay = 1, DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime nextCycleDate;
    if (cycleStartDay == 1) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      nextCycleDate = DateTime(nextYear, nextMonth, 1);
    } else {
      final daysInCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
      final safeCurrentCycleDay = cycleStartDay.clamp(1, daysInCurrentMonth);

      if (now.day < safeCurrentCycleDay) {
        nextCycleDate = DateTime(now.year, now.month, safeCurrentCycleDay);
      } else {
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final safeNextCycleDay = cycleStartDay.clamp(1, daysInNextMonth);
        nextCycleDate = DateTime(nextYear, nextMonth, safeNextCycleDay);
      }
    }

    final differenceInDays = nextCycleDate.difference(today).inDays;
    return differenceInDays <= 0 ? 1 : differenceInDays;
  }
}
