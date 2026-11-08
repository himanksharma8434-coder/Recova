import 'dart:math' as math;
import '../../core/config/engine_config.dart';

/// Provenance of the HRV metric.
enum HrvSource {
  /// Calculated from high-precision beat-to-beat RR intervals (ECG or chest strap).
  rrIntervals,

  /// Provided directly by wearable companion API (Health Connect / HealthKit RMSSD).
  vendor,

  /// Estimated from optical PPG nocturnal pulse streams and inter-sample telemetry.
  estimated,
}

/// Autonomic nervous system trend status based on personal 60-day baseline.
enum HrvTrendStatus {
  /// Insufficient days of wear to establish normal range band (< 14 days).
  calibrating,

  /// Today's value and 7-day baseline sit comfortably inside the 60-day normal band.
  stable,

  /// Acute single-night suppression below normal band; 7-day baseline remains intact.
  /// Typical of acute alcohol, intense late workout, or poor sleep.
  acuteSuppression,

  /// Acute single-night elevation above normal band.
  acuteElevation,

  /// 7-day baseline has dropped below normal band for multiple consecutive nights.
  /// Strong signal of overtraining, impending illness, or systemic stress. Prioritize rest.
  sustainedSuppression,

  /// 7-day baseline elevated above normal band. Often reflects parasympathetic tapering / supercompensation.
  sustainedElevation,
}

/// Result of nocturnal HRV analysis.
class HrvAnalysisResult {
  /// Raw overnight RMSSD value in milliseconds (ms).
  final double rmssdMs;

  /// Natural-log transformed RMSSD: x = ln(RMSSD).
  /// Normalizes the right-skewed raw RMSSD distribution for valid parametric statistics.
  final double lnRmssd;

  /// 7-day rolling mean of ln(RMSSD) (minimum 3 nights required).
  final double? baseline7d;

  /// 60-day personal baseline mean of ln(RMSSD).
  final double? normalRangeMean60d;

  /// 60-day personal standard deviation of ln(RMSSD).
  final double? normalRangeSd60d;

  /// Lower boundary of personal normal range: mean - 0.75 * SD.
  final double? normalRangeLowerBound;

  /// Upper boundary of personal normal range: mean + 0.75 * SD.
  final double? normalRangeUpperBound;

  /// 7-day coefficient of variation: CV = (SD_7 / Mean_7). Lower = higher autonomic stability.
  final double? cv7d;

  /// Standardized Z-Score: (lnRmssd - mean60) / sd60, clamped to [-3.0, +3.0].
  final double zScore;

  /// Autonomic nervous system trend classification.
  final HrvTrendStatus trendStatus;

  /// Source provenance of the HRV data point.
  final HrvSource source;

  /// Human-readable explanation of the HRV state.
  final String explanation;

  const HrvAnalysisResult({
    required this.rmssdMs,
    required this.lnRmssd,
    this.baseline7d,
    this.normalRangeMean60d,
    this.normalRangeSd60d,
    this.normalRangeLowerBound,
    this.normalRangeUpperBound,
    this.cv7d,
    required this.zScore,
    required this.trendStatus,
    required this.source,
    required this.explanation,
  });
}

/// Pure Dart science engine for Heart Rate Variability (HRV) analysis.
///
/// Follows established sports-cardiology methodology (e.g. Plews et al., 2013;
/// Buchheit, 2014; Shaffer & Ginsberg, 2017).
class HrvEngine {
  const HrvEngine();

  /// Clean raw RR intervals (in milliseconds) by filtering non-physiological
  /// intervals and ectopic beats / motion artifacts.
  ///
  /// Plausible human resting RR: 300 ms (200 bpm) to 2000 ms (30 bpm).
  /// Ectopic rejection: filter successive jumps > 20%.
  static List<double> cleanRrIntervals(List<double> rawIntervals) {
    if (rawIntervals.isEmpty) return [];

    // 1. Range filtering
    final rangeValid = rawIntervals
        .where((rr) => rr >= 300.0 && rr <= 2000.0)
        .toList();
    if (rangeValid.length < 3) return rangeValid;

    // 2. Successive percentage difference filtering (ectopic beats)
    final cleaned = <double>[rangeValid.first];
    for (int i = 1; i < rangeValid.length; i++) {
      final prev = cleaned.last;
      final curr = rangeValid[i];
      final deltaPct = (curr - prev).abs() / prev;

      // Reject intervals deviating by more than 20% from previous valid beat
      // ASSUMPTION: needs calibration
      if (deltaPct <= 0.20) {
        cleaned.add(curr);
      }
    }
    return cleaned;
  }

  /// Compute RMSSD (Root Mean Square of Successive Differences) from clean RR intervals.
  static double? computeRmssdFromRr(List<double> cleanIntervals) {
    if (cleanIntervals.length < 5) return null;

    double sumSquaredDiffs = 0.0;
    int count = 0;

    for (int i = 0; i < cleanIntervals.length - 1; i++) {
      final diff = cleanIntervals[i + 1] - cleanIntervals[i];
      sumSquaredDiffs += diff * diff;
      count++;
    }

    if (count == 0) return null;
    final rmssd = math.sqrt(sumSquaredDiffs / count);
    return rmssd.clamp(5.0, 300.0);
  }

  /// Estimate nocturnal RMSSD when only optical 1-to-5 minute PPG pulse samples exist.
  ///
  /// Mathematical rationale: During nocturnal Slow-Wave Sleep (SWS), sympathetic
  /// tone reaches its circadian nadir. Heart rate variance across a sustained
  /// quiescent window correlates logarithmically with parasympathetic modulation.
  /// We derive a calibrated proxy from nocturnal heart-rate successive differences
  /// and variance, explicitly tagging it with [HrvSource.estimated].
  static double? estimateRmssdFromNocturnalHeartRates(
      List<({DateTime timestamp, double bpm})> nocturnalSamples) {
    if (nocturnalSamples.length < 6) return null;

    final sorted = List.of(nocturnalSamples)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Filter to plausible human resting nocturnal range (35 to 110 bpm)
    final valid =
        sorted.where((s) => s.bpm >= 35.0 && s.bpm <= 110.0).toList();
    if (valid.length < 5) return null;

    final successiveDiffsSquared = <double>[];
    for (int i = 0; i < valid.length - 1; i++) {
      final s1 = valid[i];
      final s2 = valid[i + 1];

      // Only evaluate consecutive samples within 10 minutes
      if (s2.timestamp.difference(s1.timestamp).inMinutes.abs() > 10) continue;

      final ibi1 = 60000.0 / s1.bpm;
      final ibi2 = 60000.0 / s2.bpm;
      final diff = ibi2 - ibi1;

      // Filter motion artifacts (> 250ms jump across minutes)
      if (diff.abs() <= 250.0) {
        successiveDiffsSquared.add(diff * diff);
      }
    }

    if (successiveDiffsSquared.length < 4) return null;

    final meanSquared = successiveDiffsSquared.reduce((a, b) => a + b) /
        successiveDiffsSquared.length;
    final rawEst = math.sqrt(meanSquared);

    // Damping factor: Minute-level heart rate differences inherently overestimate
    // micro beat-to-beat variability due to respiratory sinus arrhythmia envelope drifts.
    // Scale by 0.72 to align with polysomnographic ECG ground truth.
    // ASSUMPTION: needs calibration
    final calibratedEst = (rawEst * 0.72).clamp(15.0, 150.0);
    return calibratedEst;
  }

  /// Analyze today's nocturnal HRV against personal rolling and long-term baselines.
  HrvAnalysisResult analyze({
    required double todayRmssdMs,
    required HrvSource source,
    List<double>? historicalNightlyRmssd7d,
    List<double>? historicalNightlyRmssd60d,
  }) {
    final lnToday = math.log(todayRmssdMs);

    // 1. Compute 7-day rolling baseline of ln(RMSSD)
    double? baseline7d;
    double? cv7d;
    if (historicalNightlyRmssd7d != null &&
        historicalNightlyRmssd7d.length >=
            EngineConfig.hrvMinNightsInRollingBaseline) {
      final ln7d = historicalNightlyRmssd7d.map(math.log).toList();
      final mean7 = ln7d.reduce((a, b) => a + b) / ln7d.length;
      baseline7d = mean7;

      if (ln7d.length >= 3) {
        double variance = 0.0;
        for (final val in ln7d) {
          variance += (val - mean7) * (val - mean7);
        }
        final sd7 = math.sqrt(variance / ln7d.length);
        cv7d = mean7 > 0 ? (sd7 / mean7) : 0.0;
      }
    }

    // 2. Compute 60-day personal baseline & normal range band (mean ± 0.75 SD)
    double? mean60;
    double? sd60;
    double? lowerBound;
    double? upperBound;
    final total60dNights = historicalNightlyRmssd60d?.length ?? 0;

    if (historicalNightlyRmssd60d != null &&
        total60dNights >= EngineConfig.minDaysForStableNormalRange) {
      final ln60d = historicalNightlyRmssd60d.map(math.log).toList();
      mean60 = ln60d.reduce((a, b) => a + b) / ln60d.length;

      double variance60 = 0.0;
      for (final val in ln60d) {
        variance60 += (val - mean60) * (val - mean60);
      }
      sd60 = math.sqrt(variance60 / ln60d.length);

      // Protect against near-zero SD if data is synthetic or invariant
      if (sd60 < 0.05) sd60 = 0.15;

      lowerBound = mean60 - EngineConfig.hrvNormalRangeSdMultiplier * sd60;
      upperBound = mean60 + EngineConfig.hrvNormalRangeSdMultiplier * sd60;
    }

    // 3. Compute Z-Score
    double zScore;
    if (mean60 != null && sd60 != null && sd60 > 0) {
      zScore = (lnToday - mean60) / sd60;
    } else if (baseline7d != null) {
      // Fallback: compare against 7-day baseline with standard adult SD (0.22)
      // ASSUMPTION: needs calibration
      zScore = (lnToday - baseline7d) / 0.22;
    } else {
      // Clinical adaptive default comparison
      final adaptiveLn = math.log(EngineConfig.hrvAdaptiveFallbackRmssd);
      zScore = (lnToday - adaptiveLn) / 0.25;
    }
    zScore = zScore.clamp(
        -EngineConfig.hrvZScoreClamp, EngineConfig.hrvZScoreClamp);

    // 4. Determine Autonomic Trend Status
    HrvTrendStatus trendStatus;
    String explanation;

    if (total60dNights < EngineConfig.minDaysForProvisionalScore) {
      trendStatus = HrvTrendStatus.calibrating;
      explanation =
          'Collecting initial nocturnal baseline (${total60dNights + 1}/14 nights).';
    } else if (lowerBound != null && upperBound != null) {
      final isDailyLow = lnToday < lowerBound;
      final isDailyHigh = lnToday > upperBound;
      final isBaselineLow = baseline7d != null && baseline7d < lowerBound;
      final isBaselineHigh = baseline7d != null && baseline7d > upperBound;

      if (isBaselineLow) {
        trendStatus = HrvTrendStatus.sustainedSuppression;
        explanation =
            '7-day HRV baseline is suppressed below normal band. Prioritize restorative recovery.';
      } else if (isBaselineHigh) {
        trendStatus = HrvTrendStatus.sustainedElevation;
        explanation =
            '7-day HRV baseline is elevated above normal band. Autonomic parasympathetic supercompensation.';
      } else if (isDailyLow) {
        trendStatus = HrvTrendStatus.acuteSuppression;
        explanation =
            'Acute nocturnal HRV dip below personal normal range. Autonomic nervous system is under temporary stress.';
      } else if (isDailyHigh) {
        trendStatus = HrvTrendStatus.acuteElevation;
        explanation =
            'Acute HRV elevation above normal range. High parasympathetic recovery tone.';
      } else {
        trendStatus = HrvTrendStatus.stable;
        explanation =
            'HRV is stable within your personal 60-day baseline normal range.';
      }
    } else {
      // Provisional status (days 4 to 29)
      if (zScore < -1.0) {
        trendStatus = HrvTrendStatus.acuteSuppression;
        explanation = 'HRV is moderately below provisional baseline.';
      } else if (zScore > 1.0) {
        trendStatus = HrvTrendStatus.acuteElevation;
        explanation = 'HRV is elevated above provisional baseline.';
      } else {
        trendStatus = HrvTrendStatus.stable;
        explanation = 'HRV is stable relative to provisional baseline.';
      }
    }

    return HrvAnalysisResult(
      rmssdMs: todayRmssdMs,
      lnRmssd: lnToday,
      baseline7d: baseline7d,
      normalRangeMean60d: mean60,
      normalRangeSd60d: sd60,
      normalRangeLowerBound: lowerBound,
      normalRangeUpperBound: upperBound,
      cv7d: cv7d,
      zScore: zScore,
      trendStatus: trendStatus,
      source: source,
      explanation: explanation,
    );
  }
}

