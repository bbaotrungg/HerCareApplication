import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Strips time components and returns midnight UTC/Local normalized date
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculates difference in days between two dates regardless of time/DST
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = dateOnly(from);
    final toDate = dateOnly(to);
    return toDate.difference(fromDate).inDays;
  }

  /// Checks if two dates fall on the exact same calendar day
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a date falls within an inclusive [start, end] range
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final d = dateOnly(date);
    final s = dateOnly(start);
    final e = dateOnly(end);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Formats date nicely: "Thursday, Oct 22"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  /// Formats date: "Oct 22, 2026"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats month & year: "October 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Formats month abbreviation: "Oct"
  static String formatMonthAbbr(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  /// Formats time: "8:30 AM"
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Returns total days in the given year/month, correctly accounting for leap years
  static int getDaysInMonth(int year, int month) {
    if (month == 12) {
      final nextYearFirst = DateTime(year + 1, 1, 1);
      final currentMonthFirst = DateTime(year, 12, 1);
      return nextYearFirst.difference(currentMonthFirst).inDays;
    }
    final nextMonthFirst = DateTime(year, month + 1, 1);
    final currentMonthFirst = DateTime(year, month, 1);
    return nextMonthFirst.difference(currentMonthFirst).inDays;
  }

  /// Parses an ISO 8601 string safely into a normalized date
  static DateTime? parseIsoDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      final parsed = DateTime.parse(isoString);
      return dateOnly(parsed);
    } catch (_) {
      return null;
    }
  }

  /// Converts a date to ISO-8601 YYYY-MM-DD
  static String toIsoDateString(DateTime date) {
    final d = dateOnly(date);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

