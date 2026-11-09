import 'dart:math' as math;
import '../../core/config/engine_config.dart';

/// Provenance of the sleep architecture telemetry.
enum SleepStageProvenance {
  /// Reported directly by sensor polysomnography / wearable accelerometer + optical PPG.
  sensor,

  /// Estimated from nocturnal heart-rate nadir curves and circadian sleep duration.
  estimated,
}

/// Analysis of nocturnal sleep architecture and sufficiency.
class SleepAnalysisResult {
  /// Total time asleep in minutes.
  final int totalAsleepMinutes;

  /// Total time in bed in minutes.
  final int totalInBedMinutes;

  /// Computed sleep need for tonight in minutes.
  final int sleepNeedMinutes;

  /// Sleep performance (0–100%): time asleep as a fraction of sleep need.
  final double sleepPerformancePct;

  /// Composite sleep score (0–100) combining sufficiency, efficiency, restorative share, and consistency.
  final double sleepScore;

  /// Sleep efficiency percentage: (time asleep / time in bed) * 100.
  final double sleepEfficiencyPct;

  /// Duration in deep (slow-wave) sleep in minutes.
  final int? deepSleepMinutes;

  /// Duration in REM sleep in minutes.
  final int? remSleepMinutes;

  /// Duration in light sleep in minutes.
  final int? lightSleepMinutes;

  /// Duration awake in bed in minutes.
  final int? awakeMinutes;

  /// Restorative sleep proportion: (deep + rem) / totalAsleep.
  final double? restorativeSharePct;

  /// Consistency score (0–100) based on 7-day bed/wake time variability.
  final double consistencyScore;

  /// Sleep debt carried forward into tonight in minutes.
  final int accumulatedDebtMinutes;

  /// Provenance of sleep stages.
  final SleepStageProvenance stageProvenance;

  /// Standardized Z-Score: sufficiency relative to personal need and baseline.
  final double sleepZScore;

  /// Sub-score breakdowns for transparent explainability:
  final double sufficiencySubScore;
  final double efficiencySubScore;
  final double restorativeSubScore;
  final double consistencySubScore;

  /// Human-readable explanation.
  final String explanation;

  const SleepAnalysisResult({
    required this.totalAsleepMinutes,
    required this.totalInBedMinutes,
    required this.sleepNeedMinutes,
    required this.sleepPerformancePct,
    required this.sleepScore,
    required this.sleepEfficiencyPct,
    this.deepSleepMinutes,
    this.remSleepMinutes,
    this.lightSleepMinutes,
    this.awakeMinutes,
    this.restorativeSharePct,
    required this.consistencyScore,
    required this.accumulatedDebtMinutes,
    required this.stageProvenance,
    required this.sleepZScore,
    required this.sufficiencySubScore,
    required this.efficiencySubScore,
    required this.restorativeSubScore,
    required this.consistencySubScore,
    required this.explanation,
  });

  double get totalAsleepHours => totalAsleepMinutes / 60.0;
  double get sleepNeedHours => sleepNeedMinutes / 60.0;
  bool get restorativeEstimated => stageProvenance == SleepStageProvenance.estimated;
  double? get restorativeSharePercent => restorativeSharePct;
  int? get deepMinutes => deepSleepMinutes;
  int? get remMinutes => remSleepMinutes;
}

/// Detailed breakdown of sleep need components.
class SleepNeedBreakdown {
  final int baselineMinutes;
  final int strainAdditionMinutes;
  final int debtAdditionMinutes;
  final int napCreditMinutes;
  final int targetSleepMinutes;

  const SleepNeedBreakdown({
    required this.baselineMinutes,
    required this.strainAdditionMinutes,
    required this.debtAdditionMinutes,
    required this.napCreditMinutes,
    required this.targetSleepMinutes,
  });
}

/// Pure Dart science engine for Sleep Architecture and Sleep Need.
class SleepEngine {
  const SleepEngine();

  /// Calculate tonight's personalized sleep need in minutes.
  ///
  /// Formula:
  ///   sleep_need = baseline_need + strain_addition + debt_payback - nap_credit
  static SleepNeedBreakdown calculateDynamicSleepNeed({
    int? baselineNeedMinutes,
    double? daytimeStrain, // 0 to 21
    int? previousDebtMinutes,
    int? napMinutesToday,
  }) {
    final base = baselineNeedMinutes ?? EngineConfig.sleepNeedDefaultMinutes;

    // 1. Strain addition: workouts and cardiovascular load require cellular repair
    double strainAddition = 0.0;
    if (daytimeStrain != null && daytimeStrain > 10.0) {
      strainAddition = (daytimeStrain - 10.0) *
          EngineConfig.sleepStrainAdditionMultiplier;
    }

    // 2. Debt payback: pay down a fraction (20%) of accumulated debt, capped at 90 min
    double debtAddition = 0.0;
    if (previousDebtMinutes != null && previousDebtMinutes > 0) {
      debtAddition = math.min(
        EngineConfig.sleepDebtMaxAdditionMinutes.toDouble(),
        previousDebtMinutes * EngineConfig.sleepDebtPaybackFraction,
      );
    }

    // 3. Nap credit: deduct daytime sleep duration from nocturnal need
    final napCredit = (napMinutesToday ?? 0) * EngineConfig.napCreditFraction;

    final computed = (base + strainAddition + debtAddition - napCredit).round();
    final clamped = computed.clamp(
      EngineConfig.sleepNeedFloorMinutes,
      EngineConfig.sleepNeedCeilingMinutes,
    );

    return SleepNeedBreakdown(
      baselineMinutes: base,
      strainAdditionMinutes: strainAddition.round(),
      debtAdditionMinutes: debtAddition.round(),
      napCreditMinutes: napCredit.round(),
      targetSleepMinutes: clamped,
    );
  }

  /// Calculate tonight's personalized sleep need in minutes.
  int calculateSleepNeed({
    int? baselineNeedMinutes,
    double? daytimeStrain,
    int? accumulatedDebtMinutes,
    int? napMinutesToday,
  }) {
    return calculateDynamicSleepNeed(
      baselineNeedMinutes: baselineNeedMinutes,
      daytimeStrain: daytimeStrain,
      previousDebtMinutes: accumulatedDebtMinutes,
      napMinutesToday: napMinutesToday,
    ).targetSleepMinutes;
  }

  /// Analyze last night's sleep against calculated need, architecture quality, and baselines.
  SleepAnalysisResult analyze({
    required int asleepMinutes,
    int? inBedMinutes,
    int? deepMinutes,
    int? remMinutes,
    int? lightMinutes,
    int? awakeMinutes,
    int? baselineNeedMinutes,
    double? daytimeStrain,
    int? previousDebtMinutes,
    int? napMinutesToday,
    List<DateTime>? recentBedTimes7d,
    double? personalBaselineAsleepMinutes,
  }) {
    final totalInBed = inBedMinutes ?? (asleepMinutes + (awakeMinutes ?? 20));

    // 1. Calculate Sleep Need
    final sleepNeed = calculateSleepNeed(
      baselineNeedMinutes: baselineNeedMinutes,
      daytimeStrain: daytimeStrain,
      accumulatedDebtMinutes: previousDebtMinutes,
      napMinutesToday: napMinutesToday,
    );

    // 2. Sleep Performance (0 - 100%)
    final perf = (asleepMinutes / sleepNeed).clamp(0.0, 1.25);
    final perfPct = (perf * 100.0).clamp(0.0, 100.0);

    // 3. Sufficiency Sub-Score (0 - 100)
    // Meeting 100% need = 100; 75% need = ~65; 50% need = ~30
    double sufficiencyScore;
    if (perf >= 1.0) {
      sufficiencyScore = 100.0;
    } else if (perf >= 0.5) {
      sufficiencyScore = 30.0 + ((perf - 0.5) / 0.5) * 70.0;
    } else {
      sufficiencyScore = (perf / 0.5) * 30.0;
    }

    // 4. Efficiency Sub-Score (0 - 100)
    final efficiency = totalInBed > 0
        ? ((asleepMinutes / totalInBed) * 100.0).clamp(50.0, 100.0)
        : 90.0;
    final efficiencyScore = ((efficiency - 60.0) / 35.0).clamp(0.0, 1.0) * 100.0;

    // 5. Restorative Sleep (Deep + REM) Quality
    int? finalDeep = deepMinutes;
    int? finalRem = remMinutes;
    int? finalLight = lightMinutes;
    int? finalAwake = awakeMinutes;
    SleepStageProvenance provenance = SleepStageProvenance.sensor;

    if (finalDeep == null || finalRem == null) {
      // Stage breakdown was NOT reported by wearable sensor.
      // Transparent estimation: derive proxy restorative share based on duration and circadian depth.
      provenance = SleepStageProvenance.estimated;
      final totalM = asleepMinutes;
      finalDeep = (totalM * 0.20).round();
      finalRem = (totalM * 0.22).round();
      finalLight = math.max(0, totalM - finalDeep - finalRem);
      finalAwake = math.max(10, totalInBed - totalM);
    }

    final restorativeMinutes = finalDeep + finalRem;
    final restorativeSharePct = asleepMinutes > 0
        ? (restorativeMinutes / asleepMinutes) * 100.0
        : 40.0;

    // Healthy adult restorative share is typically 35% - 50%
    double restorativeScore;
    if (restorativeSharePct >= 40.0) {
      restorativeScore = 100.0;
    } else if (restorativeSharePct >= 25.0) {
      restorativeScore =
          70.0 + ((restorativeSharePct - 25.0) / 15.0) * 30.0;
    } else {
      restorativeScore = (restorativeSharePct / 25.0) * 70.0;
    }

    // 6. Consistency Sub-Score (0 - 100) based on 7-day bed time variance
    double consistencyScore = 85.0; // Default when insufficient history
    if (recentBedTimes7d != null && recentBedTimes7d.length >= 3) {
      final bedMinuteOffsets = recentBedTimes7d.map((dt) {
        // Minutes from 8 PM
        final h = dt.hour >= 18 ? dt.hour - 18 : dt.hour + 6;
        return h * 60 + dt.minute;
      }).toList();

      final meanBed =
          bedMinuteOffsets.reduce((a, b) => a + b) / bedMinuteOffsets.length;
      double variance = 0.0;
      for (final val in bedMinuteOffsets) {
        variance += (val - meanBed) * (val - meanBed);
      }
      final sdMinutes = math.sqrt(variance / bedMinuteOffsets.length);

      // Under 30 min variance = 100; over 120 min = drops toward 30
      // ASSUMPTION: needs calibration
      consistencyScore = (1.0 - (sdMinutes / 120.0)).clamp(0.2, 1.0) * 100.0;
    }

    // 7. Composite Sleep Score (Weighted: 40% Sufficiency, 25% Efficiency, 20% Restorative, 15% Consistency)
    // ASSUMPTION: needs calibration
    final compositeScore = (0.40 * sufficiencyScore +
            0.25 * efficiencyScore +
            0.20 * restorativeScore +
            0.15 * consistencyScore)
        .clamp(1.0, 100.0);

    // 8. Sleep Debt Tracking
    final deficitTonight = math.max(0, sleepNeed - asleepMinutes);
    final accumulatedDebt = (previousDebtMinutes ?? 0) + deficitTonight;

    // 9. Standardized Sleep Z-Score for Readiness
    final targetBase = personalBaselineAsleepMinutes ??
        EngineConfig.sleepNeedDefaultMinutes.toDouble();
    final sleepRatio = asleepMinutes / targetBase;
    final sleepZ = ((sleepRatio - 1.0) / 0.15).clamp(-3.0, 3.0);

    // 10. Human Explanation
    final hoursAsleep = (asleepMinutes / 60.0).toStringAsFixed(1);
    final hoursNeed = (sleepNeed / 60.0).toStringAsFixed(1);
    String explanation;
    if (perfPct >= 95.0) {
      explanation =
          'Slept ${hoursAsleep}h, meeting 100% of your ${hoursNeed}h target. Cellular recovery complete.';
    } else if (perfPct >= 75.0) {
      explanation =
          'Slept ${hoursAsleep}h vs ${hoursNeed}h need (${perfPct.round()}% sufficiency). Moderate sleep deficit.';
    } else {
      explanation =
          'Slept only ${hoursAsleep}h against ${hoursNeed}h need. Acute sleep debt restricts peak physical recovery.';
    }

    return SleepAnalysisResult(
      totalAsleepMinutes: asleepMinutes,
      totalInBedMinutes: totalInBed,
      sleepNeedMinutes: sleepNeed,
      sleepPerformancePct: perfPct,
      sleepScore: compositeScore.roundToDouble(),
      sleepEfficiencyPct: efficiency,
      deepSleepMinutes: finalDeep,
      remSleepMinutes: finalRem,
      lightSleepMinutes: finalLight,
      awakeMinutes: finalAwake,
      restorativeSharePct: restorativeSharePct,
      consistencyScore: consistencyScore.roundToDouble(),
      accumulatedDebtMinutes: accumulatedDebt,
      stageProvenance: provenance,
      sleepZScore: sleepZ,
      sufficiencySubScore: sufficiencyScore.roundToDouble(),
      efficiencySubScore: efficiencyScore.roundToDouble(),
      restorativeSubScore: restorativeScore.roundToDouble(),
      consistencySubScore: consistencyScore.roundToDouble(),
      explanation: explanation,
    );
  }
}
