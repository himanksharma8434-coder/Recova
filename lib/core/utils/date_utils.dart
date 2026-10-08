/// Date/time helpers for trailing-window computations.
class AppDateUtils {
  AppDateUtils._();

  /// Returns midnight (start of day) for the given [dateTime].
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Returns the start of day N days ago from [now].
  static DateTime daysAgo(int days, {DateTime? from}) {
    final ref = from ?? DateTime.now();
    return startOfDay(ref.subtract(Duration(days: days)));
  }

  /// Returns a list of dates from [start] to [end] inclusive.
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDay = startOfDay(end);
    while (!current.isAfter(endDay)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Returns the start of the week (Monday) for the given [dateTime].
  static DateTime startOfWeek(DateTime dateTime) {
    final start = startOfDay(dateTime);
    return start.subtract(Duration(days: start.weekday - 1));
  }

  /// Returns the end of the week (Sunday) for the given [dateTime], typically used as exclusive end.
  static DateTime endOfWeek(DateTime dateTime) {
    final start = startOfDay(dateTime);
    return start.add(Duration(days: 7 - start.weekday)).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  }
}
