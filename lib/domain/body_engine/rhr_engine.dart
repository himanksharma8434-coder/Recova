import 'dart:math' as math;
import '../../core/config/engine_config.dart';

/// Autonomic cardiovascular resting heart rate status.
enum RhrStatus {
  /// Baseline is still calibrating.
  calibrating,

  /// Resting heart rate is at or below baseline (optimal cardiovascular rest).
  optimal,

  /// Resting heart rate sits comfortably inside personal normal band.
  normal,

  /// Resting heart rate is acutely elevated above personal normal range.
  acuteElevation,

  /// 7-day baseline resting heart rate is elevated. Common indicator of chronic fatigue, illness, or overreaching.
  sustainedElevation,
}

/// Result of resting heart rate analysis.
class RhrAnalysisResult {
  /// Today's overnight lowest sustained resting heart rate in beats per minute (bpm).
  final double todayBpm;

  /// 7-day rolling average resting heart rate (bpm).
  final double? baseline7d;

  /// 60-day personal baseline mean (bpm).
  final double? normalRangeMean60d;

  /// 60-day personal standard deviation (bpm).
  final double? normalRangeSd60d;

  /// Lower normal range boundary: mean - 0.75 * SD.
  final double? normalRangeLowerBound;

  /// Upper normal range boundary: mean + 0.75 * SD.
  final double? normalRangeUpperBound;

  /// Inverted standardized Z-Score: - (todayBpm - mean60) / sd60.
  /// Positive = better recovery (lower heart rate); Negative = worse recovery (elevated heart rate).
  final double invertedZScore;

  /// Delta vs 7-day baseline (bpm). Negative = below baseline (good); Positive = elevated.
  final double? deltaVsBaseline;

  /// Current RHR status tier.
  final RhrStatus status;

  /// Human-readable explanation.
  final String explanation;

  const RhrAnalysisResult({
    required this.todayBpm,
    this.baseline7d,
    this.normalRangeMean60d,
    this.normalRangeSd60d,
    this.normalRangeLowerBound,
    this.normalRangeUpperBound,
    required this.invertedZScore,
    this.deltaVsBaseline,
    required this.status,
    required this.explanation,
  });
}

/// Pure Dart science engine for Resting Heart Rate (RHR) analysis.
class RhrEngine {
  const RhrEngine();

  /// Extract the lowest sustained 5-minute average heart rate from nocturnal samples.
  /// Rejects single instantaneous sensor glitches by requiring sustained low readings.
  static double? extractLowestSustainedNadir(
      List<({DateTime timestamp, double bpm})> nocturnalSamples) {
    if (nocturnalSamples.isEmpty) return null;

    final sorted = List.of(nocturnalSamples)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Filter non-physiological readings
    final valid = sorted.where((s) => s.bpm >= 35.0 && s.bpm <= 150.0).toList();
    if (valid.isEmpty) return null;

    if (valid.length < 5) {
      // Fallback: 10th percentile
      final bpms = valid.map((s) => s.bpm).toList()..sort();
      final idx = (bpms.length * 0.10).floor().clamp(0, bpms.length - 1);
      return bpms[idx];
    }

    // Sliding 5-minute window
    double lowestWindowAvg = double.infinity;
    for (int i = 0; i < valid.length; i++) {
      final windowStart = valid[i].timestamp;
      final windowEnd = windowStart.add(const Duration(minutes: 5));
      final inWindow = valid
          .where((s) =>
              !s.timestamp.isBefore(windowStart) &&
              s.timestamp.isBefore(windowEnd))
          .toList();

      if (inWindow.length >= 3) {
        final avg =
            inWindow.fold<double>(0.0, (sum, s) => sum + s.bpm) / inWindow.length;
        if (avg < lowestWindowAvg) {
          lowestWindowAvg = avg;
        }
      }
    }

    if (lowestWindowAvg == double.infinity) {
      final bpms = valid.map((s) => s.bpm).toList()..sort();
      final idx = (bpms.length * 0.10).floor().clamp(0, bpms.length - 1);
      return bpms[idx];
    }

    return lowestWindowAvg;
  }

  /// Alias for [extractLowestSustainedNadir].
  static double? extractNadir(
          List<({DateTime timestamp, double bpm})> nocturnalSamples) =>
      extractLowestSustainedNadir(nocturnalSamples);

  /// Analyze today's resting heart rate against historical 7-day and 60-day baselines.
  RhrAnalysisResult analyze({
    required double todayBpm,
    List<double>? historicalNightlyRhr7d,
    List<double>? historicalNightlyRhr60d,
  }) {
    // 1. Compute 7-day rolling baseline
    double? baseline7d;
    if (historicalNightlyRhr7d != null && historicalNightlyRhr7d.isNotEmpty) {
      baseline7d = historicalNightlyRhr7d.reduce((a, b) => a + b) /
          historicalNightlyRhr7d.length;
    }

    // 2. Compute 60-day personal baseline & normal range
    double? mean60;
    double? sd60;
    double? lowerBound;
    double? upperBound;
    final total60dNights = historicalNightlyRhr60d?.length ?? 0;

    if (historicalNightlyRhr60d != null &&
        total60dNights >= EngineConfig.minDaysForStableNormalRange) {
      mean60 = historicalNightlyRhr60d.reduce((a, b) => a + b) /
          historicalNightlyRhr60d.length;

      double variance60 = 0.0;
      for (final val in historicalNightlyRhr60d) {
        variance60 += (val - mean60) * (val - mean60);
      }
      sd60 = math.sqrt(variance60 / historicalNightlyRhr60d.length);
      if (sd60 < 1.0) sd60 = 2.0; // Minimum plausible standard deviation (bpm)

      lowerBound = mean60 - EngineConfig.hrvNormalRangeSdMultiplier * sd60;
      upperBound = mean60 + EngineConfig.hrvNormalRangeSdMultiplier * sd60;
    }

    // 3. Compute Inverted Z-Score:
    // Higher RHR = lower recovery, so inverted: - (today - mean) / sd
    double invertedZ;
    if (mean60 != null && sd60 != null && sd60 > 0) {
      invertedZ = -(todayBpm - mean60) / sd60;
    } else if (baseline7d != null) {
      // Standard deviation estimate for adult RHR (3.0 bpm)
      // ASSUMPTION: needs calibration
      invertedZ = -(todayBpm - baseline7d) / 3.0;
    } else {
      invertedZ = -(todayBpm - EngineConfig.rhrAdaptiveFallbackBpm) / 4.0;
    }
    invertedZ = invertedZ.clamp(
        -EngineConfig.rhrZScoreClamp, EngineConfig.rhrZScoreClamp);

    // 4. Delta vs baseline
    double? deltaVsBaseline;
    if (baseline7d != null) {
      deltaVsBaseline = todayBpm - baseline7d;
    }

    // 5. Determine RHR Status & Explanation
    RhrStatus status;
    String explanation;

    if (total60dNights < EngineConfig.minDaysForProvisionalScore) {
      status = RhrStatus.calibrating;
      explanation = 'Collecting resting HR baseline.';
    } else if (mean60 != null && lowerBound != null && upperBound != null) {
      final isDailyHigh = todayBpm > upperBound;
      final isDailyLow = todayBpm < lowerBound;
      final isBaselineHigh = baseline7d != null && baseline7d > upperBound;

      if (isBaselineHigh) {
        status = RhrStatus.sustainedElevation;
        explanation =
            '7-day resting HR baseline is elevated above your normal band. Indicates accumulated fatigue or systemic stress.';
      } else if (isDailyHigh) {
        status = RhrStatus.acuteElevation;
        final diff = (todayBpm - mean60).round();
        explanation =
            'Resting HR is elevated (+$diff bpm vs baseline). Reflects exertion fatigue, alcohol, or poor sleep.';
      } else if (isDailyLow) {
        status = RhrStatus.optimal;
        final diff = (mean60 - todayBpm).round();
        explanation =
            'Resting HR is low ($diff bpm below baseline). Excellent cardiovascular efficiency.';
      } else {
        status = RhrStatus.normal;
        explanation = 'Resting HR is on target within your personal normal band.';
      }
    } else {
      if (deltaVsBaseline != null && deltaVsBaseline > 3.0) {
        status = RhrStatus.acuteElevation;
        explanation =
            'Resting HR is elevated (+${deltaVsBaseline.round()} bpm above baseline).';
      } else if (deltaVsBaseline != null && deltaVsBaseline < -1.0) {
        status = RhrStatus.optimal;
        explanation = 'Resting HR is below baseline (optimal).';
      } else {
        status = RhrStatus.normal;
        explanation = 'Resting HR is normal.';
      }
    }

    return RhrAnalysisResult(
      todayBpm: todayBpm,
      baseline7d: baseline7d,
      normalRangeMean60d: mean60,
      normalRangeSd60d: sd60,
      normalRangeLowerBound: lowerBound,
      normalRangeUpperBound: upperBound,
      invertedZScore: invertedZ,
      deltaVsBaseline: deltaVsBaseline,
      status: status,
      explanation: explanation,
    );
  }
}
