import '../../core/config/engine_config.dart';

/// 4-tier classification for daytime autonomic stress.
enum StressBand {
  /// 0–25: Autonomic calm, high parasympathetic tone.
  calm,

  /// 26–50: Balanced sympathetic / parasympathetic equilibrium.
  balanced,

  /// 51–75: Elevated physiological arousal or mental stress.
  elevated,

  /// 76–100: High sympathetic activation.
  high,
}

/// Analysis of current physiological daytime stress.
class StressAnalysisResult {
  /// Internal daytime stress score (0–100).
  final double score;

  /// Categorical stress band.
  final StressBand band;

  /// Human-readable explanation.
  final String explanation;

  const StressAnalysisResult({
    required this.score,
    required this.band,
    required this.explanation,
  });
}

/// Dynamic intraday Energy Reserve evaluation (0–100 scale).
class EnergyReserveResult {
  /// Current energy reserve (0–100).
  final double? currentReserve;

  /// Morning starting value upon waking.
  final double? morningStartingValue;

  /// Total points drained today from workouts and daytime stress.
  final double totalDrained;

  /// Total points charged today from verified daytime rest and naps.
  final double totalCharged;

  /// Whether the user has fewer than 10 days of data and is still calibrating.
  final bool isCalibrating;

  /// Human-readable explanation.
  final String explanation;

  const EnergyReserveResult({
    this.currentReserve,
    this.morningStartingValue,
    this.totalDrained = 0.0,
    this.totalCharged = 0.0,
    required this.isCalibrating,
    required this.explanation,
  });
}

/// Pure Dart science engine for Daytime Stress and Energy Reserve.
class StressEnergyEngine {
  const StressEnergyEngine();

  /// Calculate daytime stress from short-window resting heart rate and HRV telemetry.
  /// Only evaluated when the user is sedentary/inactive (motion is low).
  StressAnalysisResult evaluateStress({
    required double currentBpm,
    required double restingHrBaseline,
    double? shortWindowRmssd,
    double? hrvBaseline,
    bool isExercising = false,
  }) {
    if (isExercising) {
      // During active workouts, high heart rate is physical exertion, not passive stress.
      return const StressAnalysisResult(
        score: 0.0,
        band: StressBand.calm,
        explanation: 'Active workout in progress — physiological stress paused.',
      );
    }

    // 1. HR elevation component (0–60 points)
    final hrDiff = currentBpm - restingHrBaseline;
    double hrScore = 0.0;
    if (hrDiff > 0) {
      // Up to +30 bpm elevation = 60 pts
      hrScore = (hrDiff / 30.0).clamp(0.0, 1.0) * 60.0;
    }

    // 2. HRV suppression component (0–40 points)
    double hrvScore = 20.0; // Neutral default
    if (shortWindowRmssd != null && hrvBaseline != null && hrvBaseline > 0) {
      final ratio = shortWindowRmssd / hrvBaseline;
      if (ratio < 1.0) {
        // Lower HRV = higher sympathetic stress
        hrvScore = (1.0 - ratio).clamp(0.0, 1.0) * 40.0;
      } else {
        hrvScore = 0.0;
      }
    }

    final totalScore = (hrScore + hrvScore).clamp(0.0, 100.0);
    final score = double.parse(totalScore.toStringAsFixed(0));

    StressBand band;
    String explanation;
    if (score <= 25.0) {
      band = StressBand.calm;
      explanation = 'Calm autonomic state. Restful parasympathetic tone.';
    } else if (score <= 50.0) {
      band = StressBand.balanced;
      explanation = 'Balanced autonomic equilibrium.';
    } else if (score <= 75.0) {
      band = StressBand.elevated;
      explanation =
          'Elevated physiological stress. Heart rate is moderately elevated above resting.';
    } else {
      band = StressBand.high;
      explanation =
          'High sympathetic stress. Consider taking a brief breathwork or rest pause.';
    }

    return StressAnalysisResult(
      score: score,
      band: band,
      explanation: explanation,
    );
  }

  /// Calculate live dynamic Energy Reserve across the day.
  EnergyReserveResult evaluateEnergyReserve({
    required int daysOfData,
    double? morningReadinessScore,
    double? sleepScore,
    double dayStrain = 0.0,
    double restfulHoursToday = 0.0,
    double avgDaytimeStress = 35.0,
  }) {
    // 1. Calibration Gate (Require 10+ days of data for reliability)
    if (daysOfData < EngineConfig.minDaysForEnergyReserve) {
      return EnergyReserveResult(
        currentReserve: null,
        morningStartingValue: null,
        isCalibrating: true,
        explanation:
            'Calibrating Energy Reserve ($daysOfData/${EngineConfig.minDaysForEnergyReserve} days). Unlocks after baseline stabilization.',
      );
    }

    // 2. Morning Initial Battery Value (Derived from sleep and morning readiness)
    final sleepContrib = (sleepScore ?? 75.0) * 0.50;
    final readinessContrib = (morningReadinessScore ?? 75.0) * 0.50;
    final morningBase = (sleepContrib + readinessContrib).clamp(20.0, 100.0);

    // 3. Strain Drain (Workout load)
    final strainDrain = dayStrain * EngineConfig.energyReserveStrainDrainPerPoint;

    // 4. Stress Drain (Non-exercise mental / physical stress)
    final stressFactor = (avgDaytimeStress / 50.0).clamp(0.5, 2.0);
    final passiveStressDrain = restfulHoursToday * (1.2 * stressFactor);

    final totalDrained = (strainDrain + passiveStressDrain).clamp(0.0, 95.0);

    // 5. Charging from verified restful hours and naps
    final totalCharged = (restfulHoursToday *
            EngineConfig.energyReserveRestChargePerHour)
        .clamp(0.0, 25.0);

    // 6. Current Live Reserve
    final current = (morningBase - totalDrained + totalCharged).clamp(5.0, 100.0);

    final finalReserve = double.parse(current.toStringAsFixed(0));
    final finalMorning = double.parse(morningBase.toStringAsFixed(0));

    String explanation;
    if (finalReserve >= 70.0) {
      explanation = 'High energy reserves available for demanding tasks.';
    } else if (finalReserve >= 40.0) {
      explanation = 'Moderate energy reserves remaining.';
    } else {
      explanation =
          'Depleted reserves. Prioritize evening relaxation and early bedtime.';
    }

    return EnergyReserveResult(
      currentReserve: finalReserve,
      morningStartingValue: finalMorning,
      totalDrained: double.parse(totalDrained.toStringAsFixed(1)),
      totalCharged: double.parse(totalCharged.toStringAsFixed(1)),
      isCalibrating: false,
      explanation: explanation,
    );
  }
}

