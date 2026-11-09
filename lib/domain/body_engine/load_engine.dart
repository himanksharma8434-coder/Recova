import 'dart:math' as math;
import '../../core/config/engine_config.dart';

/// Breakdown of minutes spent in the 5 Karvonen Heart Rate Reserve zones.
class HeartRateZoneBreakdown {
  final int zone1Minutes; // 50% - 60% HRR (Recovery)
  final int zone2Minutes; // 60% - 70% HRR (Aerobic base)
  final int zone3Minutes; // 70% - 80% HRR (Aerobic endurance)
  final int zone4Minutes; // 80% - 90% HRR (Anaerobic threshold)
  final int zone5Minutes; // 90% - 100% HRR (Peak neuromuscular)

  const HeartRateZoneBreakdown({
    this.zone1Minutes = 0,
    this.zone2Minutes = 0,
    this.zone3Minutes = 0,
    this.zone4Minutes = 0,
    this.zone5Minutes = 0,
  });

  int get totalActiveMinutes =>
      zone1Minutes + zone2Minutes + zone3Minutes + zone4Minutes + zone5Minutes;
}

/// Analysis of daily cardiovascular load (strain) on the 0–21 scale.
class LoadAnalysisResult {
  /// Overall daily load score on the diminishing-returns 0–21 scale.
  final double dayLoadScore;

  /// Load accumulated strictly from discrete workout sessions (0–21).
  final double workoutLoadScore;

  /// All-day ambient cardiovascular load (from active movement, standing, daily stress).
  final double ambientLoadScore;

  /// Banister / Edwards total Training Impulse (TRIMP).
  final double accumulatedTrimp;

  /// Breakdown of minutes spent across the 5 heart rate zones.
  final HeartRateZoneBreakdown zones;

  /// Recommended daily target load lower bound based on morning readiness.
  final double targetLoadLower;

  /// Recommended daily target load upper bound based on morning readiness.
  final double targetLoadUpper;

  /// Progress toward target load range (0.0 to 1.0+).
  final double progressToTarget;

  /// Human-readable coaching explanation.
  final String explanation;

  const LoadAnalysisResult({
    required this.dayLoadScore,
    required this.workoutLoadScore,
    required this.ambientLoadScore,
    required this.accumulatedTrimp,
    required this.zones,
    required this.targetLoadLower,
    required this.targetLoadUpper,
    required this.progressToTarget,
    required this.explanation,
  });
}

/// Pure Dart science engine for Cardiovascular Load (Strain).
class LoadEngine {
  const LoadEngine();

  /// Calculate Karvonen Heart Rate Reserve (HRR) intensity for a given heart rate reading.
  ///
  /// Formula:
  ///   HRR = (HR - RHR) / (MaxHR - RHR)
  static double calculateHrrIntensity({
    required double hr,
    required double restingHr,
    required double maxHr,
  }) {
    if (maxHr <= restingHr) return 0.0;
    return ((hr - restingHr) / (maxHr - restingHr)).clamp(0.0, 1.0);
  }

  /// Classify intensity into Karvonen zone index (1 to 5, or 0 if below active threshold).
  static int classifyZone(double hrrIntensity) {
    if (hrrIntensity >= 0.90) return 5;
    if (hrrIntensity >= 0.80) return 4;
    if (hrrIntensity >= 0.70) return 3;
    if (hrrIntensity >= 0.60) return 2;
    if (hrrIntensity >= 0.50) return 1;
    return 0; // Below zone 1 (basal / resting)
  }

  /// Map cumulative TRIMP to the 0–21 diminishing returns display scale:
  ///   Load = 21 * (1 - exp(-TRIMP / S))
  static double mapTrimpToLoadScale(double trimp) {
    if (trimp <= 0) return 0.0;
    final load = 21.0 * (1.0 - math.exp(-trimp / EngineConfig.loadScalingFactor));
    return double.parse(load.clamp(0.0, 21.0).toStringAsFixed(1));
  }

  /// Compute load from discrete minute-by-minute heart rate telemetry.
  LoadAnalysisResult analyze({
    required List<({DateTime timestamp, double bpm, bool isWorkout})> hrSamples,
    required double restingHr,
    required double maxHr,
    double? morningReadinessScore,
    int? todaySteps,
  }) {
    int z1 = 0;
    int z2 = 0;
    int z3 = 0;
    int z4 = 0;
    int z5 = 0;

    double workoutTrimp = 0.0;
    double ambientTrimp = 0.0;

    if (hrSamples.isNotEmpty && maxHr > restingHr) {
      for (final sample in hrSamples) {
        final intensity = calculateHrrIntensity(
          hr: sample.bpm,
          restingHr: restingHr,
          maxHr: maxHr,
        );

        final zone = classifyZone(intensity);
        switch (zone) {
          case 1:
            z1++;
            break;
          case 2:
            z2++;
            break;
          case 3:
            z3++;
            break;
          case 4:
            z4++;
            break;
          case 5:
            z5++;
            break;
        }

        // Edwards exponential zone weighting
        final trimpContribution = math.pow(intensity, 1.92) * 1.5;
        if (sample.isWorkout) {
          workoutTrimp += trimpContribution;
        } else {
          ambientTrimp += trimpContribution;
        }
      }
    } else if (todaySteps != null && todaySteps > 0) {
      // Fallback estimation when minute HR streams are unavailable:
      // Derives ambient cardiovascular load from step cadence and daily movement.
      // ASSUMPTION: needs calibration
      final estimatedActiveMins = (todaySteps / 110.0).round();
      z1 = (estimatedActiveMins * 0.70).round();
      z2 = (estimatedActiveMins * 0.30).round();
      ambientTrimp = (todaySteps / 1000.0) * 1.8;
    }

    final totalTrimp = workoutTrimp + ambientTrimp;
    final dayLoad = mapTrimpToLoadScale(totalTrimp);
    final workoutLoad = mapTrimpToLoadScale(workoutTrimp);
    final ambientLoad = mapTrimpToLoadScale(ambientTrimp);

    // Recommended Target Band from Morning Readiness
    double targetLower = EngineConfig.targetLoadModerateBase;
    double targetUpper = EngineConfig.targetLoadModerateBase + 4.0;

    if (morningReadinessScore != null) {
      if (morningReadinessScore >= EngineConfig.readinessTierHighThreshold) {
        targetLower = EngineConfig.targetLoadHighBase;
        targetUpper = EngineConfig.targetLoadHighBase + 4.0;
      } else if (morningReadinessScore >=
          EngineConfig.readinessTierModerateThreshold) {
        targetLower = EngineConfig.targetLoadModerateBase;
        targetUpper = EngineConfig.targetLoadModerateBase + 3.9;
      } else {
        targetLower = EngineConfig.targetLoadLowBase;
        targetUpper = EngineConfig.targetLoadLowBase + 3.9;
      }
    }

    final progress = targetLower > 0 ? (dayLoad / targetLower) : 0.0;

    String explanation;
    if (dayLoad >= targetLower && dayLoad <= targetUpper) {
      explanation =
          'Optimal cardiovascular load. You have met today\'s training target.';
    } else if (dayLoad > targetUpper) {
      explanation =
          'Overreaching load. Cardiovascular strain exceeds recommended target.';
    } else {
      final remaining = (targetLower - dayLoad).toStringAsFixed(1);
      explanation =
          '$remaining load points to reach today\'s recommended target band.';
    }

    return LoadAnalysisResult(
      dayLoadScore: dayLoad,
      workoutLoadScore: workoutLoad,
      ambientLoadScore: ambientLoad,
      accumulatedTrimp: totalTrimp,
      zones: HeartRateZoneBreakdown(
        zone1Minutes: z1,
        zone2Minutes: z2,
        zone3Minutes: z3,
        zone4Minutes: z4,
        zone5Minutes: z5,
      ),
      targetLoadLower: targetLower,
      targetLoadUpper: targetUpper,
      progressToTarget: progress,
      explanation: explanation,
    );
  }
}

