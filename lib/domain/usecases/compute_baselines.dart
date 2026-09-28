import 'dart:math';

/// Computes rolling baselines from raw health records.
///
/// All functions are pure — they take lists of values and return
/// computed baselines without touching the database.
class ComputeBaselines {
  const ComputeBaselines();

  /// Compute the median of a list of values.
  /// More robust than mean against outlier readings.
  double? median(List<double> values) {
    if (values.isEmpty) return null;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Compute resting HR baseline from daily minimum RHR values.
  ///
  /// [dailyMinRhrs]: list of the minimum resting HR per day in the window.
  /// Returns the median of daily minimums (not a single instantaneous low).
  double? restingHrBaseline(List<double> dailyMinRhrs) {
    return median(dailyMinRhrs);
  }

  /// Compute sleep duration baseline from nightly durations (in minutes).
  /// Enforces a physiological baseline floor of 7.0 hours (420 min) and ceiling of 9.5 hours (570 min).
  double? sleepDurationBaseline(List<double> nightlyDurationsMinutes) {
    if (nightlyDurationsMinutes.isEmpty) return null;
    final avg = nightlyDurationsMinutes.reduce((a, b) => a + b) /
        nightlyDurationsMinutes.length;
    return avg.clamp(420.0, 570.0);
  }

  /// Compute SpO2 baseline from daily readings (percentage).
  double? spo2Baseline(List<double> dailySpo2Values) {
    if (dailySpo2Values.isEmpty) return null;
    return dailySpo2Values.reduce((a, b) => a + b) / dailySpo2Values.length;
  }

  /// Compute HRV baseline from historical HRV values (ms).
  double? hrvBaseline(List<double> dailyHrvValues) {
    return median(dailyHrvValues);
  }

  /// Compute respiratory rate baseline from historical readings (rpm).
  double? respiratoryRateBaseline(List<double> dailyRespValues) {
    if (dailyRespValues.isEmpty) return null;
    return dailyRespValues.reduce((a, b) => a + b) / dailyRespValues.length;
  }

  /// Group records by date and extract daily minimum values.
  List<double> extractDailyMinimums(
      List<({DateTime date, double value})> records) {
    final byDay = <String, List<double>>{};
    for (final r in records) {
      final key =
          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => []).add(r.value);
    }
    return byDay.values.map((vals) => vals.reduce(min)).toList();
  }

  /// Group records by date and extract daily resting HR values.
  ///
  /// - If [isExplicitRestingHr] is true (records are from RESTING_HEART_RATE):
  ///   uses the daily median value, reflecting the true daily resting state.
  /// - If false (fallback to raw HEART_RATE):
  ///   uses the 10th percentile of the day's readings to reject nocturnal sensor dropouts / motion artifacts.
  List<double> extractDailyRestingHrs(
    List<({DateTime date, double value})> records, {
    bool isExplicitRestingHr = true,
  }) {
    if (records.isEmpty) return [];
    final byDay = <String, List<double>>{};
    for (final r in records) {
      final key =
          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => []).add(r.value);
    }

    final List<double> result = [];
    for (final vals in byDay.values) {
      if (vals.isEmpty) continue;
      final sorted = List<double>.from(vals)..sort();
      if (isExplicitRestingHr) {
        // True resting HR reported by wearable: use median of the day
        final mid = sorted.length ~/ 2;
        final dailyVal = sorted.length.isOdd
            ? sorted[mid]
            : (sorted[mid - 1] + sorted[mid]) / 2;
        result.add(dailyVal);
      } else {
        // Raw heart rate: use 10th percentile to avoid single-sample sensor nadirs/glitches
        final p10Index =
            (sorted.length * 0.10).floor().clamp(0, sorted.length - 1);
        result.add(sorted[p10Index]);
      }
    }
    return result;
  }
}

