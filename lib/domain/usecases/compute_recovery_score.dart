/// Result of the recovery score computation.
/// Includes the final composite score plus per-component breakdown
/// so the UI can explain WHY the score is what it is.
class RecoveryResult {
  /// Composite score, 0–100. Higher = better recovered.
  final double score;

  /// Individual component scores, each 0–100.
  final double? hrvComponent;
  final double rhrComponent;
  final double sleepComponent;
  final double spo2Component;
  final double? respiratoryComponent;

  /// Human-readable explanation of the dominant factor.
  /// e.g. "Resting heart rate is elevated" or "Great recovery across all metrics".
  final String primaryFactor;

  const RecoveryResult({
    required this.score,
    this.hrvComponent,
    required this.rhrComponent,
    required this.sleepComponent,
    required this.spo2Component,
    this.respiratoryComponent,
    required this.primaryFactor,
  });
}

/// Computes a composite recovery score (0–100) from all available health signals.
///
/// Follows elite athletic recovery modeling (Whoop / autonomic balance):
///   - Heart Rate Variability (HRV): 40% (Primary parasympathetic tone)
///   - Resting Heart Rate (RHR):     30% (Cardiovascular basal efficiency)
///   - Sleep Duration & Stages:      20% (Cellular & neural restoration)
///   - Respiratory Rate:             5%  (Autonomic / pulmonary stability)
///   - Blood Oxygen (SpO2):          5%  (Nocturnal oxygen saturation)
///
/// When any sensor signal is unavailable, the remaining active pillars
/// are dynamically re-weighted proportionally to sum to 100%.
class ComputeRecoveryScore {
  const ComputeRecoveryScore();

  static const double _weightHrv = 0.40;
  static const double _weightRhr = 0.30;
  static const double _weightSleep = 0.20;
  static const double _weightRespiratory = 0.05;
  static const double _weightSpo2 = 0.05;

  /// Compute the recovery score.
  ///
  /// All parameters are optional — missing components are re-weighted proportionally.
  RecoveryResult call({
    double? todayHrv,
    double? hrvBaseline,
    double? todayRhr,
    double? rhrBaseline7d,
    double? lastNightSleepMinutes,
    double? sleepBaseline7d,
    int? deepSleepMinutes,
    int? remSleepMinutes,
    double? todaySpo2,
    double? spo2Baseline7d,
    double? todayRespiratoryRate,
    double? respiratoryRateBaseline,
  }) {
    double? hrvScore;
    double? rhrScore;
    double? sleepScore;
    double? respScore;
    double? spo2Score;

    // ── 1. HRV Component (40% default weight) ──
    // Evaluates today's HRV against baseline (or 55ms clinical adaptive baseline).
    // Higher HRV indicates parasympathetic dominance (high recovery).
    if (todayHrv != null && todayHrv > 0) {
      final baseHrv = (hrvBaseline != null && hrvBaseline > 0)
          ? hrvBaseline
          : 55.0; // Clinical adaptive default
      final deviation = (todayHrv - baseHrv) / baseHrv;

      if (deviation >= 0) {
        // At or above baseline: scales from 75 to 100.
        // +25% elevation yields 100% recovery for HRV.
        hrvScore = (75.0 + (deviation / 0.25) * 25.0).clamp(75.0, 100.0);
      } else {
        // Below baseline: scales from 75 down to 0.
        // -35% suppression drops to 0.
        hrvScore = (75.0 + (deviation / 0.35) * 75.0).clamp(0.0, 75.0);
      }
    }

    // ── 2. RHR Component (30% default weight) ──
    // 100 when at or below baseline, degrades linearly as RHR rises.
    // A 20% elevation above baseline → score of 0.
    if (todayRhr != null && todayRhr > 0) {
      final baseRhr = (rhrBaseline7d != null && rhrBaseline7d > 0)
          ? rhrBaseline7d
          : 60.0; // Clinical adaptive default
      final deviation = (todayRhr - baseRhr) / baseRhr;

      if (deviation <= 0) {
        rhrScore = 100.0;
      } else {
        rhrScore = (1.0 - (deviation / 0.20)).clamp(0.0, 1.0) * 100.0;
      }
    }

    // ── 3. Sleep Component (20% default weight) ──
    // Evaluates duration against baseline (or 480 min standard target),
    // with architecture quality adjustment if stages are present.
    if (lastNightSleepMinutes != null && lastNightSleepMinutes > 0) {
      // Clinical physiological baseline floor:
      // An adult human's biological sleep requirement never drops below 7.0 hours (420 min).
      final baseSleep = (sleepBaseline7d != null && sleepBaseline7d >= 420.0)
          ? sleepBaseline7d
          : 480.0; // 8.0 hours default baseline
      final ratio = lastNightSleepMinutes / baseSleep;

      // Realistic physiological curve:
      // Meeting 100%+ of sleep need = 100.
      // Sleeping 75% (e.g. 6h out of 8h) = ~65.
      // Sleeping 50% (4h) = 30.
      if (ratio >= 1.0) {
        sleepScore = 100.0;
      } else if (ratio >= 0.5) {
        sleepScore = 30.0 + ((ratio - 0.5) / 0.5) * 70.0;
      } else {
        sleepScore = (ratio / 0.5) * 30.0;
      }

      // Restorative sleep stage quality modulation (Deep + REM)
      if (deepSleepMinutes != null &&
          remSleepMinutes != null &&
          lastNightSleepMinutes > 0) {
        final restorativeMinutes = deepSleepMinutes + remSleepMinutes;
        final restorativeFraction = restorativeMinutes / lastNightSleepMinutes;
        // High restorative proportion (>= 40%) provides up to +10 boost
        if (restorativeFraction >= 0.40) {
          final bonus = ((restorativeFraction - 0.40) / 0.15) * 10.0;
          sleepScore = (sleepScore + bonus).clamp(0.0, 100.0);
        } else if (restorativeFraction < 0.25) {
          // Low restorative sleep reduces score slightly
          final penalty = ((0.25 - restorativeFraction) / 0.25) * 10.0;
          sleepScore = (sleepScore - penalty).clamp(0.0, 100.0);
        }
      }
      sleepScore = sleepScore.clamp(0.0, 100.0);
    }

    // ── 4. Respiratory Rate Component (5% default weight) ──
    // Stable nocturnal respiratory rate (around 14 rpm) is optimal.
    // Elevation above baseline is a sensitive early marker for strain or illness.
    if (todayRespiratoryRate != null && todayRespiratoryRate > 0) {
      final baseResp =
          (respiratoryRateBaseline != null && respiratoryRateBaseline > 0)
              ? respiratoryRateBaseline
              : 14.0;
      final diff = (todayRespiratoryRate - baseResp).abs();
      if (diff <= 0.5) {
        respScore = 100.0;
      } else {
        respScore = (1.0 - ((diff - 0.5) / 2.0)).clamp(0.0, 1.0) * 100.0;
      }
    }

    // ── 5. SpO2 Component (5% default weight) ──
    // 100 when at/above baseline or >= 95%.
    if (todaySpo2 != null && todaySpo2 > 0) {
      final baseSpo2 = (spo2Baseline7d != null && spo2Baseline7d > 0)
          ? spo2Baseline7d
          : 97.0;
      final drop = baseSpo2 - todaySpo2; // positive = drop
      if (drop <= 0) {
        spo2Score = 100.0;
      } else {
        spo2Score = (1.0 - (drop / 5.0)).clamp(0.0, 1.0) * 100.0;
      }
    }

    // ── Weighted Dynamic Composite ──
    final components = <_Weighted>[];
    if (hrvScore != null) {
      components.add(_Weighted(_weightHrv, hrvScore));
    }
    if (rhrScore != null) {
      components.add(_Weighted(_weightRhr, rhrScore));
    }
    if (sleepScore != null) {
      components.add(_Weighted(_weightSleep, sleepScore));
    }
    if (respScore != null) {
      components.add(_Weighted(_weightRespiratory, respScore));
    }
    if (spo2Score != null) {
      components.add(_Weighted(_weightSpo2, spo2Score));
    }

    double finalScore;
    if (components.isEmpty) {
      finalScore = 50.0; // default neutral when zero sensor telemetry exists
    } else {
      final totalWeight = components.fold(0.0, (sum, c) => sum + c.weight);
      finalScore = components.fold(0.0, (sum, c) => sum + c.weight * c.score) /
          totalWeight;
    }

    // ── Sleep Deficit Recovery Governor ──
    // In human athletic physiology, acute sleep debt restricts cellular & neuromuscular
    // recovery regardless of morning parasympathetic tone.
    // If sleep duration is under 6.0 hours (360 min), composite recovery cannot be in the peak Green tier (> 66%).
    bool sleepGovernorApplied = false;
    if (lastNightSleepMinutes != null &&
        lastNightSleepMinutes > 0 &&
        lastNightSleepMinutes < 360.0) {
      final ceiling = (45.0 + ((lastNightSleepMinutes - 240.0) / 120.0) * 21.0)
          .clamp(30.0, 66.0);
      if (finalScore > ceiling) {
        finalScore = ceiling;
        sleepGovernorApplied = true;
      }
    }

    // Determine the primary diagnostic factor
    final primaryFactor = _determinePrimaryFactor(
      hrvScore: hrvScore,
      rhrScore: rhrScore,
      sleepScore: sleepScore,
      respScore: respScore,
      spo2Score: spo2Score,
      finalScore: finalScore,
      sleepGovernorApplied: sleepGovernorApplied,
      sleepMinutes: lastNightSleepMinutes,
    );

    return RecoveryResult(
      score: finalScore.roundToDouble(),
      hrvComponent: hrvScore?.roundToDouble(),
      rhrComponent: (rhrScore ?? 50.0).roundToDouble(),
      sleepComponent: (sleepScore ?? 50.0).roundToDouble(),
      spo2Component: (spo2Score ?? 50.0).roundToDouble(),
      respiratoryComponent: respScore?.roundToDouble(),
      primaryFactor: primaryFactor,
    );
  }

  String _determinePrimaryFactor({
    double? hrvScore,
    double? rhrScore,
    double? sleepScore,
    double? respScore,
    double? spo2Score,
    required double finalScore,
    bool sleepGovernorApplied = false,
    double? sleepMinutes,
  }) {
    if (sleepGovernorApplied && sleepMinutes != null) {
      final hours = (sleepMinutes / 60.0).toStringAsFixed(1);
      return 'Sleep deficit (${hours}h sleep) restricts peak physiological recovery';
    }

    if (finalScore >= 80) {
      return 'Great recovery across all biometric signals';
    }

    final scores = <String, double>{};
    if (hrvScore != null) scores['hrv'] = hrvScore;
    if (rhrScore != null) scores['rhr'] = rhrScore;
    if (sleepScore != null) scores['sleep'] = sleepScore;
    if (respScore != null) scores['resp'] = respScore;
    if (spo2Score != null) scores['spo2'] = spo2Score;

    if (scores.isEmpty) return 'Insufficient data for detailed analysis';

    final worstKey = scores.entries.reduce((a, b) => a.value < b.value ? a : b);

    return switch (worstKey.key) {
      'hrv' => 'Autonomic tone is suppressed (lower HRV)',
      'rhr' => 'Resting heart rate is elevated',
      'sleep' => 'Sleep duration or restorative stages below target',
      'resp' => 'Respiratory rate elevated above baseline',
      'spo2' => 'Blood oxygen is lower than usual',
      _ => 'Recovery is below optimal',
    };
  }
}

class _Weighted {
  final double weight;
  final double score;
  const _Weighted(this.weight, this.score);
}
