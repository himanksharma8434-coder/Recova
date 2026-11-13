/// Categorical training readiness guidance for athletes.
enum TrainingReadinessTier {
  veryLow,
  low,
  moderate,
  high,
  peak,
}

/// Result of morning training readiness analysis.
class TrainingReadinessResult {
  /// Morning training readiness tier.
  final TrainingReadinessTier tier;

  /// Plain language headline recommendation (e.g. "Good day to push", "Active recovery").
  final String headline;

  /// Detailed coaching advice explaining why this recommendation was formed.
  final String coachingAdvice;

  /// Acute:Chronic Workload Ratio (ACWR): 7-day load / 28-day weekly average load.
  /// Typically optimal between 0.8 and 1.3 (Gabbett, 2016).
  final double? acwr;

  /// 3-night sleep sufficiency average percentage.
  final double? sleepSufficiency3d;

  const TrainingReadinessResult({
    required this.tier,
    required this.headline,
    required this.coachingAdvice,
    this.acwr,
    this.sleepSufficiency3d,
  });
}

/// Pure Dart science engine for Athlete Training Readiness and Workload Balance.
class TrainingReadinessEngine {
  const TrainingReadinessEngine();

  /// Calculate Acute:Chronic Workload Ratio (ACWR).
  ///
  /// In sports science (Gabbett, 2016):
  /// - Acute Load: Mean daily load over last 7 days.
  /// - Chronic Load: Mean daily load over last 28 days.
  /// - ACWR = Acute / Chronic.
  /// - "Sweet spot": 0.8 – 1.3 (high fitness, low injury risk).
  /// - "Danger zone": > 1.5 (spikes in acute load relative to chronic preparedness).
  static double? calculateAcwr({
    required List<double> dailyLoadsPast28Days,
  }) {
    if (dailyLoadsPast28Days.length < 14) return null;

    final acuteDays = dailyLoadsPast28Days.take(7).toList();
    final acuteMean = acuteDays.reduce((a, b) => a + b) / acuteDays.length;

    final chronicMean = dailyLoadsPast28Days.reduce((a, b) => a + b) /
        dailyLoadsPast28Days.length;

    if (chronicMean <= 0.1) return 1.0;
    final ratio = acuteMean / chronicMean;
    return double.parse(ratio.toStringAsFixed(2));
  }

  /// Evaluate training readiness from morning readiness score, ACWR, and recent sleep history.
  TrainingReadinessResult evaluate({
    required double? readinessScore,
    List<double>? dailyLoadsPast28Days,
    List<double>? sleepSufficienciesPast3Days,
  }) {
    double? acwr;
    if (dailyLoadsPast28Days != null && dailyLoadsPast28Days.length >= 14) {
      acwr = calculateAcwr(dailyLoadsPast28Days: dailyLoadsPast28Days);
    }

    double? avgSleep3d;
    if (sleepSufficienciesPast3Days != null &&
        sleepSufficienciesPast3Days.isNotEmpty) {
      avgSleep3d = sleepSufficienciesPast3Days.reduce((a, b) => a + b) /
          sleepSufficienciesPast3Days.length;
    }

    if (readinessScore == null) {
      return const TrainingReadinessResult(
        tier: TrainingReadinessTier.moderate,
        headline: 'Collecting Baseline',
        coachingAdvice:
            'Baseline telemetry is still accumulating. Maintain intuitive, moderate-intensity training.',
      );
    }

    // Determine tier and actionable guidance
    TrainingReadinessTier tier;
    String headline;
    String advice;

    final isHighAcwr = acwr != null && acwr > 1.4;
    final isLowSleep = avgSleep3d != null && avgSleep3d < 70.0;

    if (readinessScore >= 80.0 && !isHighAcwr) {
      tier = TrainingReadinessTier.peak;
      headline = 'Good Day to Push';
      advice =
          'Your nervous system and cardiovascular baselines are primed for high-intensity intervals, heavy lifts, or high strain.';
    } else if (readinessScore >= 67.0) {
      tier = TrainingReadinessTier.high;
      headline = isHighAcwr
          ? 'High Readiness • Watch Volume'
          : 'Normal Hard Training';
      advice = isHighAcwr
          ? 'Readiness is high, but your acute 7-day workload has spiked (ACWR $acwr). Train with intensity, but keep total volume controlled.'
          : 'Great physiological status. You are ready for a solid, productive training session.';
    } else if (readinessScore >= 34.0) {
      tier = TrainingReadinessTier.moderate;
      headline = 'Maintain Moderate Training';
      advice = isLowSleep
          ? 'Readiness is moderate with minor sleep debt over the last 3 nights. Focus on aerobic base or technique work.'
          : 'Your body is in balance. Steady aerobic training or maintenance volume is recommended today.';
    } else if (readinessScore >= 20.0) {
      tier = TrainingReadinessTier.low;
      headline = 'Keep it Easy';
      advice =
          'Autonomic tone is suppressed. Limit sessions to active recovery, light mobility, or a restful walk.';
    } else {
      tier = TrainingReadinessTier.veryLow;
      headline = 'Rest Day Recommended';
      advice =
          'Biometrics indicate deep systemic fatigue or autonomic strain. Full rest and early sleep are strongly advised.';
    }

    return TrainingReadinessResult(
      tier: tier,
      headline: headline,
      coachingAdvice: advice,
      acwr: acwr,
      sleepSufficiency3d: avgSleep3d,
    );
  }
}
