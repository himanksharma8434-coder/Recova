import '../entities/body_age_result.dart';
import '../entities/health_record.dart';

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
  });
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

/// Real workout session logged by wearable / Health Connect.
class WorkoutSessionSummary {
  final String title;
  final int durationMinutes;
  final double? calories;
  final DateTime startTime;

  const WorkoutSessionSummary({
    required this.title,
    required this.durationMinutes,
    this.calories,
    required this.startTime,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  double get estimatedStrain =>
      (durationMinutes * 0.15).clamp(1.0, 18.0);

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

  const DerivedMetricSummary({
    this.recoveryScore,
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
  });
}
