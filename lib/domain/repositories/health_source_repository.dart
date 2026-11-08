import '../body_engine/body_engine.dart';
import '../entities/body_age_result.dart';
import '../entities/health_record.dart';
import '../services/vo2_max_estimator.dart';

/// Abstract interface for the health data source.
/// Wraps Health Connect (Android) and HealthKit (iOS) behind a
/// testable seam so the Cubit layer never talks to the platform directly.
abstract class HealthSourceRepository {
  /// Request read authorization for all configured health data types.
  Future<bool> requestPermissions();

  /// Check whether all required permissions are currently granted.
  Future<bool> hasPermissions();

  /// Check whether background-read permission is granted (Android 14+ only).
  /// Always returns false on iOS or older Android.
  Future<bool> hasBackgroundReadPermission();

  /// Fetch health records from the platform store.
  /// [startTime] and [endTime] define the query window.
  Future<List<HealthRecord>> fetchRecords({
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Perform a delta sync: read new data since last sync, upsert to local DB,
  /// recompute baselines and derived metrics.
  /// Returns the number of new records written.
  Future<int> syncHealthData({required String taskType});

  /// Get the details of the most recent workout that successfully generated a VO2 Max estimate.
  Future<Vo2MaxResult?> getLatestVo2MaxResult();

  /// Get the latest derived metrics for the dashboard.
  Future<DerivedMetricSummary?> getLatestSummary();

  /// In-memory cached summary for instantaneous synchronous UI display.
  DerivedMetricSummary? get cachedSummary;

  /// Stream of the latest derived metrics for reactive UI.
  Stream<DerivedMetricSummary?> watchLatestSummary();

  /// Compute the user's estimated body age from all available wearable data.
  /// [age] and [sex] are provided by the user (or derived from platform DOB).
  /// All other inputs are gathered automatically from the local health database.
  Future<BodyAgeResult?> getBodyAge({
    required int age,
    String? sex,
    double? heightCm,
    double? weightKg,
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    String? smokingStatus,
    int? stressLevel,
    double? bodyFatPct,
  });

  /// Log a workout session with Karvonen HR zones, TRIMP strain, and recovery cost.
  Future<void> logWorkout(WorkoutInput input);

  /// Toggle a daily behavioral journal tag (e.g., 'alcohol', 'late_meal', 'magnesium').
  Future<bool> toggleJournalTag(String tag, {DateTime? date, String? value, String? notes});

  /// Compute habit correlations against next-day recovery across 30–60 days of data.
  Future<List<BehaviorCorrelation>> getHabitCorrelations();

  /// Retrieve or generate explainable daily physiological insights.
  Future<List<EngineInsight>> getDailyInsights({DateTime? date});

  /// Mark an insight as read.
  Future<void> markInsightRead(int insightId);
}

/// Breakdown of sleep architecture stages from wearable sensors.
class SleepStageBreakdown {
  final int deepMinutes;
  final int remMinutes;
  final int lightMinutes;
  final int awakeMinutes;

  const SleepStageBreakdown({
    this.deepMinutes = 0,
    this.remMinutes = 0,
    this.lightMinutes = 0,
    this.awakeMinutes = 0,
  });

  int get totalTrackedMinutes =>
      deepMinutes + remMinutes + lightMinutes + awakeMinutes;

  double get deepPercentage =>
      totalTrackedMinutes > 0 ? (deepMinutes / totalTrackedMinutes) * 100 : 0;

  double get remPercentage =>
      totalTrackedMinutes > 0 ? (remMinutes / totalTrackedMinutes) * 100 : 0;

  double get lightPercentage =>
      totalTrackedMinutes > 0 ? (lightMinutes / totalTrackedMinutes) * 100 : 0;

  double get awakePercentage =>
      totalTrackedMinutes > 0 ? (awakeMinutes / totalTrackedMinutes) * 100 : 0;

  bool get hasStageData => (deepMinutes + remMinutes + lightMinutes) > 0;
}

/// Classification of sleep sessions in the 24-hour cycle.
enum SleepSessionType {
  nightSleep('NIGHT SLEEP'),
  morningNap('MORNING NAP'),
  afternoonNap('AFTERNOON NAP'),
  eveningNap('EVENING NAP');

  final String label;
  const SleepSessionType(this.label);
}

/// An individual sleep session (e.g. nocturnal main sleep or daytime/evening nap).
class DistributedSleepSession {
  final String title;
  final SleepSessionType type;
  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;
  final int durationMinutes;
  final SleepStageBreakdown? stages;
  final bool isMainSleep;

  const DistributedSleepSession({
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.durationMinutes,
    this.stages,
    this.isMainSleep = false,
  });
}

/// Real workout session logged by wearable / Health Connect or manual entry.
class WorkoutSessionSummary {
  final String title;
  final String sport;
  final int durationMinutes;
  final double? calories;
  final DateTime startTime;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? strain;
  final double? recoveryCostHours;
  final HeartRateZoneBreakdown? zones;

  const WorkoutSessionSummary({
    required this.title,
    this.sport = 'general',
    required this.durationMinutes,
    this.calories,
    required this.startTime,
    this.avgHeartRate,
    this.maxHeartRate,
    this.strain,
    this.recoveryCostHours,
    this.zones,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  double get estimatedStrain =>
      strain ?? (durationMinutes * 0.15).clamp(1.0, 18.0);

  double get effectiveRecoveryCost =>
      recoveryCostHours ?? (estimatedStrain < 10.0 ? 12.0 : 24.0);

  String get formattedDuration {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${durationMinutes}m';
  }
}

/// Single point in historical trend.
class HistoricalScorePoint {
  final DateTime date;
  final double score;

  const HistoricalScorePoint({required this.date, required this.score});
}

/// Summary object for the dashboard and all tabs. 100% computed from real data.
class DerivedMetricSummary {
  final double? recoveryScore;
  final double? baselineRecoveryScore;
  final double? strainImpact;
  final double? restReplenishment;
  final double? restHours;
  final double? recoveryComponentHrv;
  final double? recoveryComponentRhr;
  final double? recoveryComponentSleep;
  final double? recoveryComponentSpo2;
  final double? recoveryComponentRespiratory;
  final String? primaryFactor;
  final double? estimatedVo2Max;
  final double? estimatedVo2Max7d;
  final double? estimatedVo2Max30d;
  final double? estimatedVo2MaxAllTime;
  final double? restingHr;
  final double? baselineRestingHr;
  final double? sleepHours;
  final double? baselineSleepHours;
  final double? nightSleepHours;
  final double? napSleepHours;
  final List<DistributedSleepSession> sleepSessions;
  final double? spo2;
  final double? baselineSpo2;
  final double? hrvMs;
  final double? baselineHrv;
  final double? respiratoryRate;
  final double? baselineRespiratoryRate;
  final double? skinTempDeviation;
  final double? baselineSkinTemp;
  final double? dayStrain;
  final double? targetStrain;
  final double? activeCalories;
  final double? totalCalories;
  final int? todaySteps;
  final SleepStageBreakdown? sleepStages;
  final List<WorkoutSessionSummary> workouts;
  final List<WorkoutSessionSummary> workouts7d;
  final double? activeCalories7d;
  final int? steps7d;
  final List<HistoricalScorePoint> strainHistory7d;
  final List<HistoricalScorePoint> recoveryHistory14d;
  final int totalRecords;
  final DateTime? lastSyncedAt;
  final DailyEngineOutput? engineOutput;
  final int daysOfData;
  final bool isHrvEstimated;
  final String? qualityFlag;
  final List<BehaviorCorrelation> habitCorrelations;
  final List<EngineInsight> dailyInsights;
  final List<String> todayLoggedTags;

  const DerivedMetricSummary({
    this.recoveryScore,
    this.baselineRecoveryScore,
    this.strainImpact,
    this.restReplenishment,
    this.restHours,
    this.recoveryComponentHrv,
    this.recoveryComponentRhr,
    this.recoveryComponentSleep,
    this.recoveryComponentSpo2,
    this.recoveryComponentRespiratory,
    this.primaryFactor,
    this.estimatedVo2Max,
    this.estimatedVo2Max7d,
    this.estimatedVo2Max30d,
    this.estimatedVo2MaxAllTime,
    this.restingHr,
    this.baselineRestingHr,
    this.sleepHours,
    this.baselineSleepHours,
    this.nightSleepHours,
    this.napSleepHours,
    this.sleepSessions = const [],
    this.spo2,
    this.baselineSpo2,
    this.hrvMs,
    this.baselineHrv,
    this.respiratoryRate,
    this.baselineRespiratoryRate,
    this.skinTempDeviation,
    this.baselineSkinTemp,
    this.dayStrain,
    this.targetStrain,
    this.activeCalories,
    this.totalCalories,
    this.todaySteps,
    this.sleepStages,
    this.workouts = const [],
    this.workouts7d = const [],
    this.activeCalories7d,
    this.steps7d,
    this.strainHistory7d = const [],
    this.recoveryHistory14d = const [],
    this.totalRecords = 0,
    this.lastSyncedAt,
    this.engineOutput,
    this.daysOfData = 14,
    this.isHrvEstimated = false,
    this.qualityFlag,
    this.habitCorrelations = const [],
    this.dailyInsights = const [],
    this.todayLoggedTags = const [],
  });

  /// Effective number of recorded biometric days.
  int get effectiveDaysOfData => engineOutput?.readiness.daysOfData ?? daysOfData;

  /// Confidence rating of the physiological evaluation.
  ReadinessConfidence get confidence {
    if (engineOutput != null) return engineOutput!.readiness.confidence;
    if (effectiveDaysOfData < 4) return ReadinessConfidence.calibrating;
    if (effectiveDaysOfData < 14) return ReadinessConfidence.calibrating;
    if (isHrvEstimated) return ReadinessConfidence.medium;
    return ReadinessConfidence.high;
  }

  /// Readiness tier (optimal, moderate, low, or collecting).
  ReadinessTier get readinessTier {
    if (engineOutput != null) return engineOutput!.readiness.tier;
    if (effectiveDaysOfData < 4 && recoveryScore == null) {
      return ReadinessTier.collecting;
    }
    final score = recoveryScore ?? 50.0;
    if (score >= 67.0) return ReadinessTier.optimal;
    if (score >= 34.0) return ReadinessTier.moderate;
    return ReadinessTier.low;
  }

  /// Explainable top drivers shifting the readiness score.
  List<ReadinessDriver> get topDrivers {
    if (engineOutput != null && engineOutput!.readiness.topDrivers.isNotEmpty) {
      return engineOutput!.readiness.topDrivers;
    }
    final list = <ReadinessDriver>[];
    if (hrvMs != null && baselineHrv != null) {
      final isPos = hrvMs! >= baselineHrv!;
      final pct = (((hrvMs! - baselineHrv!) / baselineHrv!) * 100).round();
      list.add(ReadinessDriver(
        metricKey: 'hrv',
        label: 'Heart Rate Variability',
        impactZ: isPos ? 1.0 : -1.0,
        direction: isPos ? 'positive' : 'negative',
        description: isPos
            ? 'HRV is ${pct.abs()}% above normal, signaling strong parasympathetic recovery.'
            : 'HRV is ${pct.abs()}% below normal, indicating autonomic fatigue.',
      ));
    }
    if (restingHr != null && baselineRestingHr != null) {
      final isPos = restingHr! <= baselineRestingHr!;
      final diff = (restingHr! - baselineRestingHr!).round().abs();
      list.add(ReadinessDriver(
        metricKey: 'resting_hr',
        label: 'Resting Heart Rate',
        impactZ: isPos ? 1.0 : -1.0,
        direction: isPos ? 'positive' : 'negative',
        description: isPos
            ? 'Resting HR is $diff bpm below baseline (efficient).'
            : 'Resting HR is $diff bpm elevated above baseline.',
      ));
    }
    if (sleepHours != null && baselineSleepHours != null) {
      final isPos = sleepHours! >= baselineSleepHours!;
      final pct = ((sleepHours! / baselineSleepHours!) * 100).round();
      list.add(ReadinessDriver(
        metricKey: 'sleep',
        label: 'Sleep Restoration',
        impactZ: isPos ? 1.0 : -1.0,
        direction: isPos ? 'positive' : 'negative',
        description: isPos
            ? 'Sleep met $pct% of your nightly requirement.'
            : 'Sleep duration fell short ($pct% of requirement).',
      ));
    }
    return list;
  }

  /// Target load lower bound based on morning readiness.
  double get targetLoadLower {
    if (engineOutput?.load != null) return engineOutput!.load!.targetLoadLower;
    final rec = recoveryScore ?? 50.0;
    if (rec >= 67) return 14.0;
    if (rec >= 34) return 10.0;
    return 6.0;
  }

  /// Target load upper bound based on morning readiness.
  double get targetLoadUpper {
    if (engineOutput?.load != null) return engineOutput!.load!.targetLoadUpper;
    final rec = recoveryScore ?? 50.0;
    if (rec >= 67) return 18.0;
    if (rec >= 34) return 13.9;
    return 9.9;
  }

  /// Tonight's personalized sleep need in minutes.
  int get personalizedSleepNeedMinutes {
    if (engineOutput?.sleep != null) {
      return engineOutput!.sleep!.sleepNeedMinutes;
    }
    final baseMin = ((baselineSleepHours ?? 8.0) * 60).round();
    final strainAdd = (dayStrain != null && dayStrain! > 10.0)
        ? ((dayStrain! - 10.0) * 2.5).round()
        : 0;
    return (baseMin + strainAdd).clamp(420, 600);
  }

  /// Actionable plain-language training headline.
  String get trainingHeadline {
    if (engineOutput != null) return engineOutput!.trainingReadiness.headline;
    final rec = recoveryScore;
    if (rec == null) return 'Collecting Baseline';
    if (rec >= 80.0) return 'Prime Day to Push';
    if (rec >= 67.0) return 'Good Day to Push';
    if (rec >= 34.0) return 'Maintain Moderate Training';
    return 'Recovery Priority';
  }

  /// Detailed coaching advice from the Science Engine.
  String get trainingAdvice {
    if (engineOutput != null) {
      return engineOutput!.trainingReadiness.coachingAdvice;
    }
    final rec = recoveryScore;
    if (rec == null) {
      return 'Biometric history is still accumulating. Maintain intuitive training volume.';
    }
    if (rec >= 67.0) {
      return 'Your autonomic nervous system is well-recovered. High-strain workouts or interval sessions are recommended.';
    }
    if (rec >= 34.0) {
      return 'Your body is in balance. Steady aerobic training or maintenance volume is recommended today.';
    }
    return 'Key biometrics indicate autonomic fatigue or elevated cardiac load. Prioritize light mobility and rest.';
  }

  /// Current energy reserve score (0 to 100), or null if calibrating.
  double? get energyReserveScore => engineOutput?.energyReserve?.currentReserve;

  /// Whether energy reserve is still in the 10-day calibration period.
  bool get isEnergyReserveCalibrating =>
      engineOutput?.energyReserve?.isCalibrating ?? (effectiveDaysOfData < 10);

  /// Current daytime autonomic stress category.
  StressBand get daytimeStressBand =>
      engineOutput?.stress?.band ?? StressBand.balanced;

  /// Comprehensive 5-vital Health Monitor report from the Science Engine.
  HealthMonitorReport get healthMonitorReport {
    if (engineOutput?.healthMonitor != null) {
      return engineOutput!.healthMonitor!;
    }
    const engine = HealthMonitorEngine();
    return engine.evaluateReport(
      daysOfData: effectiveDaysOfData,
      todayHrvMs: hrvMs,
      baselineHrvMs: baselineHrv,
      isHrvEstimated: isHrvEstimated,
      todayRhrBpm: restingHr,
      baselineRhrBpm: baselineRestingHr,
      todayRespiratoryRate: respiratoryRate,
      baselineRespiratoryRate: baselineRespiratoryRate,
      todaySpo2: spo2,
      baselineSpo2: baselineSpo2,
      todaySkinTempDeviationCelsius: skinTempDeviation,
      baselineSkinTempDeviationCelsius: baselineSkinTemp,
    );
  }
}
