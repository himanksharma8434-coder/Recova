import 'dart:math' as math;
import '../../core/config/engine_config.dart';

/// Readiness Tier classification.
enum ReadinessTier {
  /// Score >= 67: Optimal / Peak physiological recovery.
  optimal,

  /// Score 34 - 66: Moderate / Balanced recovery.
  moderate,

  /// Score <= 33: Low / Restorative recovery priority.
  low,

  /// Days 1-3: Baseline collection period.
  collecting,
}

/// Confidence rating based on data completeness, wearing consistency, and baseline depth.
enum ReadinessConfidence {
  calibrating,
  high,
  medium,
  low,
}

/// Key driver shifting the readiness score.
class ReadinessDriver {
  final String metricKey; // 'hrv', 'resting_hr', 'sleep', 'respiratory'
  final String label;
  final double impactZ;
  final String direction; // 'positive' | 'negative'
  final String description;

  const ReadinessDriver({
    required this.metricKey,
    required this.label,
    required this.impactZ,
    required this.direction,
    required this.description,
  });
}

/// Comprehensive morning readiness evaluation.
class ReadinessResult {
  /// Morning readiness score (0–100), or null during Days 1–3 baseline collection.
  final double? score;

  /// Readiness tier.
  final ReadinessTier tier;

  /// Confidence rating of the score calculation.
  final ReadinessConfidence confidence;

  /// Top 2–3 drivers explaining why the score is what it is.
  final List<ReadinessDriver> topDrivers;

  /// Days of biometric history recorded so far.
  final int daysOfData;

  /// Individual standardized Z-scores used in the composite:
  final double? hrvZ;
  final double? rhrInvertedZ;
  final double? sleepZ;
  final double? respiratoryInvertedZ;

  /// Individual component sub-scores (0–100 scale for UI explainability):
  final double? hrvSubScore;
  final double? rhrSubScore;
  final double? sleepSubScore;
  final double? respiratorySubScore;

  /// Whether the sleep deficit governor capped the peak score ceiling.
  final bool sleepGovernorApplied;

  /// Human-readable coaching summary.
  final String summary;

  const ReadinessResult({
    this.score,
    required this.tier,
    required this.confidence,
    required this.topDrivers,
    required this.daysOfData,
    this.hrvZ,
    this.rhrInvertedZ,
    this.sleepZ,
    this.respiratoryInvertedZ,
    this.hrvSubScore,
    this.rhrSubScore,
    this.sleepSubScore,
    this.respiratorySubScore,
    this.sleepGovernorApplied = false,
    required this.summary,
  });
}

/// Pure Dart science engine for Daily Morning Readiness.
class ReadinessEngine {
  const ReadinessEngine();

  /// Map a standardized z-score to a 0–100 sub-score using logistic sigmoid:
  ///   subScore = 100 / (1 + exp(-1.1 * z))
  static double zToScore(double z) {
    final s = 100.0 / (1.0 + math.exp(-EngineConfig.readinessSigmoidSlope * z));
    return double.parse(s.clamp(1.0, 99.0).toStringAsFixed(1));
  }

  /// Compute morning readiness score from component z-scores and telemetry.
  ReadinessResult compute({
    required int daysOfData,
    double? hrvZ,
    double? rhrInvertedZ,
    double? sleepZ,
    double? respiratoryInvertedZ,
    int? lastNightSleepMinutes,
    bool isHrvEstimated = false,
  }) {
    // 1. Calibration Phase Enforcement (Days 1–3: Collecting Baseline)
    if (daysOfData < EngineConfig.minDaysForProvisionalScore) {
      return ReadinessResult(
        score: null,
        tier: ReadinessTier.collecting,
        confidence: ReadinessConfidence.calibrating,
        topDrivers: const [],
        daysOfData: daysOfData,
        summary:
            'Collecting initial physiological baseline ($daysOfData/${EngineConfig.minDaysForBaselineCollection} nights). Wear your wearable to bed to unlock readiness.',
      );
    }

    // 2. Active Weight Distribution & Normalization
    final activeComponents = <({double weight, double z, String key, String label})>[];

    if (hrvZ != null) {
      activeComponents.add((
        weight: EngineConfig.weightHrv,
        z: hrvZ,
        key: 'hrv',
        label: 'Heart Rate Variability',
      ));
    }
    if (rhrInvertedZ != null) {
      activeComponents.add((
        weight: EngineConfig.weightRhr,
        z: rhrInvertedZ,
        key: 'resting_hr',
        label: 'Resting Heart Rate',
      ));
    }
    if (sleepZ != null) {
      activeComponents.add((
        weight: EngineConfig.weightSleep,
        z: sleepZ,
        key: 'sleep',
        label: 'Sleep Restoration',
      ));
    }
    if (respiratoryInvertedZ != null) {
      activeComponents.add((
        weight: EngineConfig.weightRespiratory,
        z: respiratoryInvertedZ,
        key: 'respiratory',
        label: 'Respiratory Stability',
      ));
    }

    if (activeComponents.isEmpty) {
      return ReadinessResult(
        score: null,
        tier: ReadinessTier.collecting,
        confidence: ReadinessConfidence.low,
        topDrivers: const [],
        daysOfData: daysOfData,
        summary: 'Insufficient overnight biometric data to evaluate readiness.',
      );
    }

    // Re-normalize active weights to sum strictly to 1.0
    final totalWeight =
        activeComponents.fold<double>(0.0, (sum, c) => sum + c.weight);
    double compositeZ = 0.0;
    for (final c in activeComponents) {
      final normalizedWeight = c.weight / totalWeight;
      compositeZ += normalizedWeight * c.z;
    }

    // 3. Logistic Sigmoid Mapping to 0–100 Scale
    double rawScore = 100.0 /
        (1.0 + math.exp(-EngineConfig.readinessSigmoidSlope * compositeZ));

    // 4. Sleep Deficit Governor
    // If sleep was under 6 hours (360 min), athlete cannot achieve peak tier (> 66%)
    bool sleepGovernorApplied = false;
    if (lastNightSleepMinutes != null &&
        lastNightSleepMinutes > 0 &&
        lastNightSleepMinutes < EngineConfig.sleepGovernorThresholdMinutes) {
      final ceiling =
          (45.0 + ((lastNightSleepMinutes - 240.0) / 120.0) * 21.0)
              .clamp(30.0, 66.0);
      if (rawScore > ceiling) {
        rawScore = ceiling;
        sleepGovernorApplied = true;
      }
    }

    final finalScore = double.parse(rawScore.clamp(1.0, 99.0).toStringAsFixed(0));

    // 5. Tier Classification
    ReadinessTier tier;
    if (finalScore >= EngineConfig.readinessTierHighThreshold) {
      tier = ReadinessTier.optimal;
    } else if (finalScore >= EngineConfig.readinessTierModerateThreshold) {
      tier = ReadinessTier.moderate;
    } else {
      tier = ReadinessTier.low;
    }

    // 6. Confidence Rating
    ReadinessConfidence confidence;
    if (daysOfData < EngineConfig.minDaysForFullScore) {
      confidence = ReadinessConfidence.calibrating;
    } else if (activeComponents.length >= 3 && !isHrvEstimated) {
      confidence = ReadinessConfidence.high;
    } else if (activeComponents.length >= 2) {
      confidence = ReadinessConfidence.medium;
    } else {
      confidence = ReadinessConfidence.low;
    }

    // 7. Driver Analysis (Find 2–3 strongest contributors)
    final sortedDrivers = List.of(activeComponents)
      ..sort((a, b) => b.z.abs().compareTo(a.z.abs()));

    final drivers = <ReadinessDriver>[];
    for (final item in sortedDrivers.take(3)) {
      final isPos = item.z >= 0;
      String desc;
      if (item.key == 'hrv') {
        desc = isPos
            ? 'HRV is elevated above normal, signaling strong parasympathetic tone.'
            : 'HRV is suppressed below normal, indicating autonomic fatigue.';
      } else if (item.key == 'resting_hr') {
        desc = isPos
            ? 'Resting HR is low, indicating cardiovascular efficiency.'
            : 'Resting HR is elevated, indicating physiological exertion.';
      } else if (item.key == 'sleep') {
        desc = isPos
            ? 'Sleep duration and quality met your biological requirement.'
            : 'Sleep duration fell short of your nightly requirement.';
      } else {
        desc = isPos
            ? 'Nocturnal respiratory rate is calm and stable.'
            : 'Nocturnal respiratory rate is elevated above baseline.';
      }

      drivers.add(ReadinessDriver(
        metricKey: item.key,
        label: item.label,
        impactZ: item.z,
        direction: isPos ? 'positive' : 'negative',
        description: desc,
      ));
    }

    // 8. Human Coaching Summary
    String summary;
    if (sleepGovernorApplied) {
      final hours = (lastNightSleepMinutes! / 60.0).toStringAsFixed(1);
      summary =
          'Sleep deficit (${hours}h sleep) restricts physiological readiness today.';
    } else if (tier == ReadinessTier.optimal) {
      summary =
          'Optimal readiness. Your autonomic nervous system is well-recovered and primed for training load.';
    } else if (tier == ReadinessTier.moderate) {
      summary =
          'Balanced recovery. Maintain normal training intensity or moderate cardiovascular load.';
    } else {
      summary =
          'Recovery priority. Key biometrics indicate physiological stress or fatigue. Prioritize rest today.';
    }

    return ReadinessResult(
      score: finalScore,
      tier: tier,
      confidence: confidence,
      topDrivers: drivers,
      daysOfData: daysOfData,
      hrvZ: hrvZ,
      rhrInvertedZ: rhrInvertedZ,
      sleepZ: sleepZ,
      respiratoryInvertedZ: respiratoryInvertedZ,
      hrvSubScore: hrvZ != null ? zToScore(hrvZ) : null,
      rhrSubScore: rhrInvertedZ != null ? zToScore(rhrInvertedZ) : null,
      sleepSubScore: sleepZ != null ? zToScore(sleepZ) : null,
      respiratorySubScore:
          respiratoryInvertedZ != null ? zToScore(respiratoryInvertedZ) : null,
      sleepGovernorApplied: sleepGovernorApplied,
      summary: summary,
    );
  }
}
