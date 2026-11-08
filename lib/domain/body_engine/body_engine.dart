import 'hrv_engine.dart';
import 'rhr_engine.dart';
import 'sleep_engine.dart';
import 'load_engine.dart';
import 'readiness_engine.dart';
import 'stress_energy_engine.dart';
import 'training_readiness_engine.dart';
import 'health_monitor_engine.dart';
import 'workout_engine.dart';
import 'journal_engine.dart';
import 'insights_engine.dart';

export 'hrv_engine.dart';
export 'rhr_engine.dart';
export 'sleep_engine.dart';
export 'load_engine.dart';
export 'readiness_engine.dart';
export 'stress_energy_engine.dart';
export 'training_readiness_engine.dart';
export 'health_monitor_engine.dart';
export 'workout_engine.dart';
export 'journal_engine.dart';
export 'insights_engine.dart';
export 'engine_isolate_runner.dart';
export 'comparator_engine.dart';

/// Consolidated output of the daily Body Engine analysis pipeline.
class DailyEngineOutput {
  final HrvAnalysisResult? hrv;
  final RhrAnalysisResult? rhr;
  final SleepAnalysisResult? sleep;
  final LoadAnalysisResult? load;
  final ReadinessResult readiness;
  final StressAnalysisResult? stress;
  final EnergyReserveResult? energyReserve;
  final TrainingReadinessResult trainingReadiness;
  final HealthMonitorReport? healthMonitor;

  const DailyEngineOutput({
    this.hrv,
    this.rhr,
    this.sleep,
    this.load,
    required this.readiness,
    this.stress,
    this.energyReserve,
    required this.trainingReadiness,
    this.healthMonitor,
  });
}

/// Unified entry-point facade for the pure Dart Body Science Engine.
class BodyEngine {
  final HrvEngine hrvEngine;
  final RhrEngine rhrEngine;
  final SleepEngine sleepEngine;
  final LoadEngine loadEngine;
  final ReadinessEngine readinessEngine;
  final StressEnergyEngine stressEnergyEngine;
  final TrainingReadinessEngine trainingReadinessEngine;
  final HealthMonitorEngine healthMonitorEngine;
  final WorkoutEngine workoutEngine;
  final JournalEngine journalEngine;
  final InsightsEngine insightsEngine;

  const BodyEngine({
    this.hrvEngine = const HrvEngine(),
    this.rhrEngine = const RhrEngine(),
    this.sleepEngine = const SleepEngine(),
    this.loadEngine = const LoadEngine(),
    this.readinessEngine = const ReadinessEngine(),
    this.stressEnergyEngine = const StressEnergyEngine(),
    this.trainingReadinessEngine = const TrainingReadinessEngine(),
    this.healthMonitorEngine = const HealthMonitorEngine(),
    this.workoutEngine = const WorkoutEngine(),
    this.journalEngine = const JournalEngine(),
    this.insightsEngine = const InsightsEngine(),
  });

  /// Run the full daily physiological evaluation pipeline.
  DailyEngineOutput processDailyPipeline({
    required int daysOfData,
    // HRV
    double? todayRmssdMs,
    HrvSource hrvSource = HrvSource.vendor,
    List<double>? hrvHistory7d,
    List<double>? hrvHistory60d,
    // RHR
    double? todayRhrBpm,
    List<double>? rhrHistory7d,
    List<double>? rhrHistory60d,
    // Sleep
    int? lastNightAsleepMinutes,
    int? inBedMinutes,
    int? deepMinutes,
    int? remMinutes,
    int? lightMinutes,
    int? awakeMinutes,
    int? baselineNeedMinutes,
    int? previousDebtMinutes,
    int? napMinutesToday,
    List<DateTime>? recentBedTimes7d,
    // Pulmonary & Vitals
    double? todayRespiratoryRate,
    double? baselineRespiratoryRate,
    double? todaySpo2,
    double? baselineSpo2,
    double? todaySkinTempDeviationCelsius,
    double? baselineSkinTempDeviationCelsius,
    // Load / Workouts
    List<({DateTime timestamp, double bpm, bool isWorkout})>? hrSamples,
    double? userMaxHr,
    int? todaySteps,
    List<double>? dailyLoadsPast28Days,
    List<double>? sleepSufficienciesPast3Days,
    // Intraday Stress & Rest
    double? currentRestingBpm,
    double? shortWindowRmssd,
    double restfulHoursToday = 0.0,
  }) {
    // 1. HRV Analysis
    HrvAnalysisResult? hrvResult;
    if (todayRmssdMs != null && todayRmssdMs > 0) {
      hrvResult = hrvEngine.analyze(
        todayRmssdMs: todayRmssdMs,
        source: hrvSource,
        historicalNightlyRmssd7d: hrvHistory7d,
        historicalNightlyRmssd60d: hrvHistory60d,
      );
    }

    // 2. RHR Analysis
    RhrAnalysisResult? rhrResult;
    if (todayRhrBpm != null && todayRhrBpm > 0) {
      rhrResult = rhrEngine.analyze(
        todayBpm: todayRhrBpm,
        historicalNightlyRhr7d: rhrHistory7d,
        historicalNightlyRhr60d: rhrHistory60d,
      );
    }

    // 3. Sleep Analysis
    SleepAnalysisResult? sleepResult;
    if (lastNightAsleepMinutes != null && lastNightAsleepMinutes > 0) {
      sleepResult = sleepEngine.analyze(
        asleepMinutes: lastNightAsleepMinutes,
        inBedMinutes: inBedMinutes ?? lastNightAsleepMinutes,
        deepMinutes: deepMinutes,
        remMinutes: remMinutes,
        lightMinutes: lightMinutes,
        awakeMinutes: awakeMinutes,
        baselineNeedMinutes: baselineNeedMinutes,
        previousDebtMinutes: previousDebtMinutes,
        napMinutesToday: napMinutesToday,
        recentBedTimes7d: recentBedTimes7d,
      );
    }

    // 4. Composite Morning Readiness Score
    final readinessResult = readinessEngine.compute(
      daysOfData: daysOfData,
      hrvZ: hrvResult?.zScore,
      rhrInvertedZ: rhrResult?.invertedZScore,
      sleepZ: sleepResult?.sleepZScore,
      lastNightSleepMinutes: lastNightAsleepMinutes,
      isHrvEstimated: hrvSource == HrvSource.estimated,
    );

    // 5. Load / Strain
    LoadAnalysisResult? loadResult;
    final effectiveMaxHr = userMaxHr ?? 190.0;
    if (hrSamples != null && hrSamples.isNotEmpty) {
      loadResult = loadEngine.analyze(
        hrSamples: hrSamples,
        restingHr: todayRhrBpm ?? 60.0,
        maxHr: effectiveMaxHr,
        morningReadinessScore: readinessResult.score,
        todaySteps: todaySteps,
      );
    } else if (userMaxHr != null || todayRhrBpm != null || todaySteps != null || readinessResult.score != null) {
      loadResult = loadEngine.analyze(
        hrSamples: hrSamples ?? const [],
        restingHr: todayRhrBpm ?? 60.0,
        maxHr: effectiveMaxHr,
        morningReadinessScore: readinessResult.score,
        todaySteps: todaySteps,
      );
    }

    // 6. Daytime Stress
    StressAnalysisResult? stressResult;
    if (currentRestingBpm != null && todayRhrBpm != null) {
      stressResult = stressEnergyEngine.evaluateStress(
        currentBpm: currentRestingBpm,
        restingHrBaseline: rhrResult?.baseline7d ?? todayRhrBpm,
        shortWindowRmssd: shortWindowRmssd,
        hrvBaseline: hrvResult?.baseline7d,
      );
    }

    // 7. Intraday Energy Reserve
    EnergyReserveResult? energyResult;
    energyResult = stressEnergyEngine.evaluateEnergyReserve(
      daysOfData: daysOfData,
      morningReadinessScore: readinessResult.score,
      sleepScore: sleepResult?.sleepScore,
      dayStrain: loadResult?.dayLoadScore ?? 0.0,
      restfulHoursToday: restfulHoursToday,
      avgDaytimeStress: stressResult?.score ?? 35.0,
    );

    // 8. Training Readiness & Coaching Guidance
    final trainingReadiness = trainingReadinessEngine.evaluate(
      readinessScore: readinessResult.score,
      dailyLoadsPast28Days: dailyLoadsPast28Days,
      sleepSufficienciesPast3Days: sleepSufficienciesPast3Days,
    );

    // 9. Comprehensive Health Monitor Panel
    final healthMonitorReport = healthMonitorEngine.evaluateReport(
      daysOfData: daysOfData,
      todayHrvMs: todayRmssdMs,
      baselineHrvMs: hrvResult?.baseline7d,
      hrvStdDev: hrvResult?.normalRangeSd60d,
      isHrvEstimated: hrvSource == HrvSource.estimated,
      todayRhrBpm: todayRhrBpm,
      baselineRhrBpm: rhrResult?.baseline7d,
      rhrStdDev: rhrResult?.normalRangeSd60d,
      todayRespiratoryRate: todayRespiratoryRate,
      baselineRespiratoryRate: baselineRespiratoryRate,
      todaySpo2: todaySpo2,
      baselineSpo2: baselineSpo2,
      todaySkinTempDeviationCelsius: todaySkinTempDeviationCelsius,
      baselineSkinTempDeviationCelsius: baselineSkinTempDeviationCelsius,
    );

    return DailyEngineOutput(
      hrv: hrvResult,
      rhr: rhrResult,
      sleep: sleepResult,
      load: loadResult,
      readiness: readinessResult,
      stress: stressResult,
      energyReserve: energyResult,
      trainingReadiness: trainingReadiness,
      healthMonitor: healthMonitorReport,
    );
  }
}
