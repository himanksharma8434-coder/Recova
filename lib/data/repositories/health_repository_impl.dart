import 'package:drift/drift.dart';

import '../../core/constants/health_types.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../domain/usecases/compute_baselines.dart';
import '../../domain/usecases/compute_vo2max.dart';
import '../../domain/usecases/compute_recovery_score.dart';
import '../../domain/usecases/compute_body_age.dart';
import '../../domain/entities/body_age_result.dart';
import '../../domain/entities/daily_metric_point.dart';
import '../../domain/services/vo2_max_estimator.dart';
import '../../core/utils/sleep_data_sanitizer.dart';
import '../database/app_database.dart';
import '../datasources/health_platform_datasource.dart';

/// Concrete implementation of [HealthSourceRepository].
/// Orchestrates: platform reads → local DB upserts → baseline/metric recomputation.
class HealthRepositoryImpl implements HealthSourceRepository {
  final HealthPlatformDatasource _platform;
  final AppDatabase _db;
  final ComputeBaselines _computeBaselines;
  final ComputeVo2Max _computeVo2Max;
  final ComputeRecoveryScore _computeRecoveryScore;
  final ComputeBodyAge _computeBodyAge;
  DerivedMetricSummary? _cachedSummary;

  @override
  DerivedMetricSummary? get cachedSummary => _cachedSummary;

  HealthRepositoryImpl({
    required HealthPlatformDatasource platform,
    required AppDatabase db,
    ComputeBaselines? computeBaselines,
    ComputeVo2Max? computeVo2Max,
    ComputeRecoveryScore? computeRecoveryScore,
    ComputeBodyAge? computeBodyAge,
  // ignore: prefer_initializing_formals
  })  : _platform = platform,
        // ignore: prefer_initializing_formals
        _db = db,
        _computeBaselines = computeBaselines ?? const ComputeBaselines(),
        _computeVo2Max = computeVo2Max ?? const ComputeVo2Max(),
        _computeRecoveryScore =
            computeRecoveryScore ?? const ComputeRecoveryScore(),
        _computeBodyAge = computeBodyAge ?? const ComputeBodyAge();

  @override
  Future<bool> requestPermissions() async {
    await _platform.configure();
    return _platform.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() => _platform.hasPermissions();

  @override
  Future<bool> hasBackgroundReadPermission() =>
      _platform.hasBackgroundReadPermission();

  @override
  Future<List<HealthRecord>> fetchRecords({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return _platform.fetchRecords(startTime: startTime, endTime: endTime);
  }

  Future<int>? _activeSyncFuture;

  @override
  Future<int> syncHealthData({required String taskType}) {
    if (_activeSyncFuture != null) {
      return _activeSyncFuture!;
    }
    final future = _performSyncHealthData(taskType: taskType);
    final wrapped = future.whenComplete(() {
      _activeSyncFuture = null;
    });
    _activeSyncFuture = wrapped;
    return wrapped;
  }

  Future<int> _performSyncHealthData({required String taskType}) async {
    final syncDao = _db.syncDao;
    final recordDao = _db.healthRecordDao;
    final now = DateTime.now();
    int totalWritten = 0;

    try {
      await _platform.configure();

      final typesToSync = _platform.getAvailableTypes();

      // Delta sync all available types concurrently to minimize sync latency
      final syncTasks = typesToSync.map((type) async {
        final typeName = type.name;
        final lastSynced = await syncDao.getLastSyncedAt(typeName);

        // First sync: use initial lookback window
        final startTime =
            lastSynced ?? now.subtract(HealthTypes.initialLookback);

        try {
          final records = await _platform.fetchRecordsForType(
            type: type,
            startTime: startTime,
            endTime: now,
          );

          if (records.isNotEmpty) {
            final companions = records
                .map((r) => RawHealthRecordsCompanion(
                      recordType: Value(r.recordType),
                      value: Value(r.value),
                      valueSecondary: Value(r.valueSecondary),
                      unit: Value(r.unit),
                      startTime: Value(r.startTime),
                      endTime: Value(r.endTime),
                      sourceId: Value(r.sourceId),
                      syncedAt: Value(r.syncedAt),
                    ))
                .toList();

            await recordDao.upsertRecords(companions);
            await syncDao.updateLastSyncedAt(typeName, now);
            return records.length;
          }
        } catch (_) {}
        return 0;
      });

      final writtenCounts = await Future.wait(syncTasks);
      totalWritten = writtenCounts.fold<int>(0, (sum, count) => sum + count);

      // For STEPS: Also fetch authoritative de-duplicated day total from platform aggregate
      if (typesToSync.any((t) => t.name == 'STEPS')) {
        try {
          final dayStart = AppDateUtils.startOfDay(now);
          final aggSteps = await _platform.getTotalStepsInInterval(
            startTime: dayStart,
            endTime: now,
          );
          if (aggSteps != null && aggSteps > 0) {
            await recordDao.upsertRecord(RawHealthRecordsCompanion(
              recordType: const Value('STEPS'),
              value: Value(aggSteps.toDouble()),
              unit: const Value('COUNT'),
              startTime: Value(dayStart),
              endTime: Value(now),
              sourceId: const Value('health_connect_aggregate'),
              syncedAt: Value(now),
            ));
          }
        } catch (_) {}
      }

      // Recompute baselines and derived metrics:
      // If historical metrics are completely empty (e.g. first sync on fresh install),
      // backfill recent 7 days so baselines and trends are established.
      // On routine delta syncs, only recompute yesterday and today (sleep spans midnight),
      // dropping query volume by 95%!
      final recentHistory = await _db.derivedMetricDao.getHistory(3);
      if (recentHistory.isEmpty && totalWritten > 0) {
        await recomputeHistory(days: 7);
      } else {
        final yesterday = now.subtract(const Duration(days: 1));
        await _recomputeBaselines(yesterday);
        await _recomputeDerivedMetrics(yesterday);
        await _recomputeBaselines(now);
        await _recomputeDerivedMetrics(now);
      }

      // Invalidate cached summary so UI gets updated numbers immediately
      _cachedSummary = null;

      // Log success and update global sync timestamp
      await syncDao.logSync(
        taskType: taskType,
        recordsRead: totalWritten,
        recordsWritten: totalWritten,
        success: true,
      );
      await syncDao.updateLastSyncedAt('GLOBAL_SYNC', now);

      return totalWritten;
    } catch (e) {
      // Log failure — leave lastSyncedAt untouched so next run retries
      await syncDao.logSync(
        taskType: taskType,
        recordsRead: 0,
        recordsWritten: 0,
        success: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Recompute 7-day and 30-day baselines for today.
  Future<void> _recomputeBaselines(DateTime now) async {
    final today = AppDateUtils.startOfDay(now);
    final recordDao = _db.healthRecordDao;
    final baselineDao = _db.baselineDao;

    // ── Resting HR baselines ──
    final rhrRecords7d = await recordDao.getRestingHrRecords(
      start: AppDateUtils.daysAgo(7, from: now),
      end: now,
    );
    final rhrRecords30d = await recordDao.getRestingHrRecords(
      start: AppDateUtils.daysAgo(30, from: now),
      end: now,
    );

    final isExplicit7d =
        rhrRecords7d.any((r) => r.recordType == 'RESTING_HEART_RATE');
    final isExplicit30d =
        rhrRecords30d.any((r) => r.recordType == 'RESTING_HEART_RATE');

    final dailyRhrs7d = _computeBaselines.extractDailyRestingHrs(
      rhrRecords7d.map((r) => (date: r.startTime, value: r.value)).toList(),
      isExplicitRestingHr: isExplicit7d,
    );
    final dailyRhrs30d = _computeBaselines.extractDailyRestingHrs(
      rhrRecords30d.map((r) => (date: r.startTime, value: r.value)).toList(),
      isExplicitRestingHr: isExplicit30d,
    );

    // ── Sleep baseline (clean nightly extractions to prevent multi-source duplicates) ──
    final sleepRecords = await recordDao.getSleepRecords(
      start: AppDateUtils.daysAgo(10, from: now),
      end: now,
    );
    final stageRecords = await recordDao.getSleepStages(
      start: AppDateUtils.daysAgo(10, from: now),
      end: now,
    );

    final List<double> sleepDurations = [];
    for (int i = 1; i <= 7; i++) {
      final nightEnd = AppDateUtils.daysAgo(i - 1, from: today);
      final nightStart = nightEnd.subtract(const Duration(hours: 14));
      final nightWindowEnd = nightEnd.add(const Duration(hours: 12));

      final nightStages = stageRecords
          .where((r) =>
              r.endTime.isAfter(nightStart) && r.endTime.isBefore(nightWindowEnd))
          .toList();
      final nightSessions = sleepRecords
          .where((r) =>
              r.endTime.isAfter(nightStart) && r.endTime.isBefore(nightWindowEnd))
          .toList();

      if (nightStages.isNotEmpty || nightSessions.isNotEmpty) {
        final clean = SleepDataSanitizer.sanitizeOvernightStages(
          stageRecords: nightStages,
          sessionRecord: nightSessions.isNotEmpty ? nightSessions.last : null,
        );
        if (clean.totalAsleepMinutes >= 60 && clean.totalAsleepMinutes <= 720) {
          sleepDurations.add(clean.totalAsleepMinutes.toDouble());
        }
      }
    }

    // ── SpO2 baseline ──
    final spo2Records = await recordDao.getSpo2Records(
      start: AppDateUtils.daysAgo(7, from: now),
      end: now,
    );
    final spo2Values = spo2Records.map((r) => r.value).toList();

    await baselineDao.upsertBaseline(DailyBaselinesCompanion(
      date: Value(today),
      restingHrBaseline7d:
          Value(_computeBaselines.restingHrBaseline(dailyRhrs7d)),
      restingHrBaseline30d:
          Value(_computeBaselines.restingHrBaseline(dailyRhrs30d)),
      sleepDurationBaseline7d:
          Value(_computeBaselines.sleepDurationBaseline(sleepDurations)),
      spo2Baseline7d: Value(_computeBaselines.spo2Baseline(spo2Values)),
    ));
  }

  /// Tries to compute VO2 max using the Garmin/Firstbeat algorithm from workout streams.
  ///
  /// Uses a 3-tier approach:
  /// 1. GPS/distance speed + HR → ACSM running equation + HRR extrapolation
  /// 2. Step-cadence derived speed + HR → same ACSM approach
  @override
  Future<Vo2MaxResult?> getLatestVo2MaxResult() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // We need Max HR and Rest HR for the calculation
    final maxHr = await _db.healthRecordDao.getMaxExerciseHr(start: thirtyDaysAgo, end: now) ?? 183.0;
    final rhrs = await _db.healthRecordDao.getDailyRestingHeartRates(30);
    final restHr = rhrs.isNotEmpty ? (rhrs.fold<double>(0.0, (s, p) => s + p.value) / rhrs.length) : 60.0;

    final vo2 = _computeVo2Max(
      restingHr7dBaseline: restHr,
      maxHrFromExercise: maxHr,
    );

    if (vo2 == null) return null;

    return Vo2MaxResult(
      estimatedVo2Max: vo2,
      segmentsUsed: 0,
      userMaxHr: maxHr,
      userRestingHr: restHr,
      date: now,
    );
  }

  /// Recompute VO2max and recovery score for today.
  Future<void> _recomputeDerivedMetrics(DateTime now) async {
    final today = AppDateUtils.startOfDay(now);
    final recordDao = _db.healthRecordDao;
    final baselineDao = _db.baselineDao;
    final metricDao = _db.derivedMetricDao;

    final baseline = await baselineDao.getBaseline(today);
    final rhrBase = baseline?.restingHrBaseline7d ?? 60.0;
    final baselineSleep = baseline?.sleepDurationBaseline7d;
    final sleepBase = (baselineSleep != null && baselineSleep >= 420.0)
        ? baselineSleep
        : 480.0;
    final spo2Base = baseline?.spo2Baseline7d ?? 97.0;

    // ── VO2max ──
    // New formula: VO2max = 15.3 × (avg top 2 daily max HR from Monday-Sunday / avg RHR from Monday-Sunday)
    final startOfWk = AppDateUtils.startOfWeek(now);
    final endOfWk = AppDateUtils.endOfWeek(now);
    final avgTop2MaxHr = await recordDao.getAvgTop2DailyMaxHr(start: startOfWk, end: endOfWk);

    // Fallback to single max exercise HR if not enough daily data
    double? effectiveMaxHr = avgTop2MaxHr;
    effectiveMaxHr ??= await recordDao.getMaxExerciseHr(
      start: AppDateUtils.daysAgo(60, from: now),
      end: now,
    );

    // Determine age from health platform if no exercise max HR is available
    int? userAge;
    if (effectiveMaxHr == null) {
      final dob = await _platform.fetchDateOfBirth();
      if (dob != null) {
        userAge = (now.difference(dob).inDays / 365.25).floor();
      }
    }

    final wkRhrRecords = await recordDao.getRestingHrRecords(start: startOfWk, end: endOfWk);
    final wkRhrs = wkRhrRecords.map((r) => r.value).toList();
    double vo2Rhr = wkRhrs.isNotEmpty ? (wkRhrs.reduce((a, b) => a + b) / wkRhrs.length) : rhrBase;

    double? vo2max = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr,
      maxHrFromExercise: effectiveMaxHr ?? 190.0,
      userAge: userAge,
    );

    // ── Recovery Score Signals ──
    // 1. Real HRV (SDNN / RMSSD) & rolling baseline
    final latestHrv = await recordDao.getLatestHrv(
      start: AppDateUtils.daysAgo(1, from: now),
      end: now,
    );
    final hrvHistory = await recordDao.getHrvBaselineRecords(
      start: AppDateUtils.daysAgo(14, from: now),
      end: now,
    );
    final baselineHrv = _computeBaselines
            .hrvBaseline(hrvHistory.map((r) => r.value).toList()) ??
        55.0;

    // 2. Resting Heart Rate
    final todayRhrRecords = await recordDao.getRestingHrRecords(
      start: today,
      end: now,
    );
    double? todayRhr;
    final rhrOnly = todayRhrRecords.where((r) => r.recordType == 'RESTING_HEART_RATE');
    if (rhrOnly.isNotEmpty) {
      todayRhr = rhrOnly.last.value;
    } else if (todayRhrRecords.isNotEmpty) {
      todayRhr = todayRhrRecords.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    }

    // 3. Clean Overnight Sleep & Stages (including daytime and evening naps)
    final sleepSearchStart = today.subtract(const Duration(hours: 10));
    final nightStages = await recordDao.getSleepStages(
      start: sleepSearchStart,
      end: now,
    );
    final nightSessions = await recordDao.getSleepRecords(
      start: sleepSearchStart,
      end: now,
    );
    final cleanDistributed = SleepDataSanitizer.extractDistributedSessions(
      stageRecords: nightStages,
      sessionRecords: nightSessions,
      fallbackHours: sleepBase / 60.0,
    );
    final double? totalSleepMinutes = cleanDistributed.totalMinutes > 0
        ? cleanDistributed.totalMinutes.toDouble()
        : null;

    // 4. Blood Oxygen (SpO2)
    final spo2Records = await recordDao.getSpo2Records(
      start: today,
      end: now,
    );
    final todaySpo2 = spo2Records.isEmpty ? null : spo2Records.last.value;

    // 5. Respiratory Rate (RPM)
    final todayResp = await recordDao.getTodayLatestRespiratoryRate(
      start: today,
      end: now,
    );
    final respHistory = await recordDao.getRespiratoryRateBaselineRecords(
      start: AppDateUtils.daysAgo(14, from: now),
      end: now,
    );
    final baselineResp = _computeBaselines
            .respiratoryRateBaseline(respHistory.map((r) => r.value).toList()) ??
        14.0;

    final recovery = _computeRecoveryScore(
      todayHrv: latestHrv,
      hrvBaseline: baselineHrv,
      todayRhr: todayRhr,
      rhrBaseline7d: rhrBase,
      lastNightSleepMinutes: totalSleepMinutes,
      sleepBaseline7d: sleepBase,
      deepSleepMinutes: cleanDistributed.mainSleep.hasStageData
          ? cleanDistributed.mainSleep.deepMinutes
          : null,
      remSleepMinutes: cleanDistributed.mainSleep.hasStageData
          ? cleanDistributed.mainSleep.remMinutes
          : null,
      todaySpo2: todaySpo2,
      spo2Baseline7d: spo2Base,
      todayRespiratoryRate: todayResp,
      respiratoryRateBaseline: baselineResp,
    );

    await metricDao.upsertMetric(DerivedMetricsCompanion(
      date: Value(today),
      estimatedVo2Max: Value(vo2max),
      recoveryScore: Value(recovery.score),
      recoveryComponentRhr: Value(recovery.rhrComponent),
      recoveryComponentSleep: Value(recovery.sleepComponent),
      recoveryComponentSpo2: Value(recovery.spo2Component),
      primaryFactor: Value(recovery.primaryFactor),
    ));
  }

  /// Recomputes baselines and derived metrics for the last [days] days.
  /// Fixes historical data so that rolling 7D, 30D, and All-Time averages
  /// reflect accurate resting heart rate and exercise max HR values.
  Future<void> recomputeHistory({int days = 30}) async {
    final now = DateTime.now();
    for (int i = days; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final targetDate = DateTime(day.year, day.month, day.day, 23, 59, 59);
      await _recomputeBaselines(targetDate);
      await _recomputeDerivedMetrics(targetDate);
    }
  }


  @override
  Future<DerivedMetricSummary?> getLatestSummary({bool persistToday = true}) async {
    final metric = await _db.derivedMetricDao.getLatestMetric();
    final baseline = await _db.baselineDao.getLatestBaseline();
    final recordCount = await _db.healthRecordDao.getRecordCount();

    if (metric == null && baseline == null && recordCount == 0) return null;

    final now = DateTime.now();
    final todayStart = AppDateUtils.startOfDay(now);

    // Get the most recent sync timestamp
    DateTime? lastSync;
    final logs = await _db.syncDao.getRecentLogs(limit: 1);
    if (logs.isNotEmpty) lastSync = logs.first.timestamp;

    // ── Real Steps (Day Only, De-duplicated via Health Connect Aggregate) ──
    // Prefer reading cached steps from SQLite first (< 1ms retrieval)
    int todaySteps = await _db.healthRecordDao
        .getTotalSteps(start: todayStart, end: now);

    if (todaySteps == 0) {
      try {
        final platformSteps = await _platform.getTotalStepsInInterval(
          startTime: todayStart,
          endTime: now,
        );
        if (platformSteps != null && platformSteps >= 0) {
          todaySteps = platformSteps;
        }
      } catch (_) {}
    }

    final activeCals = await _db.healthRecordDao
        .getTotalCalories(start: todayStart, end: now, activeOnly: true);
    final totalCals = await _db.healthRecordDao
        .getTotalCalories(start: todayStart, end: now, activeOnly: false);

    // ── Real Workouts ──
    final rawWorkouts = await _db.healthRecordDao
        .getWorkouts(start: todayStart, end: now);
    final workouts = rawWorkouts.map((w) {
      final name = w.unit.isNotEmpty && w.unit != 'UNKNOWN'
          ? w.unit
          : 'Cardio Session';
      return WorkoutSessionSummary(
        title: name,
        durationMinutes: w.value.toInt(),
        calories: w.valueSecondary,
        startTime: w.startTime,
      );
    }).toList();

    // ── Real 7-Day Workouts & Activity Volume ──
    final start7d = AppDateUtils.daysAgo(7, from: now);
    final rawWorkouts7d = await _db.healthRecordDao
        .getWorkouts(start: start7d, end: now);
    final workouts7d = rawWorkouts7d.map((w) {
      final name = w.unit.isNotEmpty && w.unit != 'UNKNOWN'
          ? w.unit
          : 'Cardio Session';
      return WorkoutSessionSummary(
        title: name,
        durationMinutes: w.value.toInt(),
        calories: w.valueSecondary,
        startTime: w.startTime,
      );
    }).toList();

    final activeCals7d = await _db.healthRecordDao.getTotalCalories(
      start: start7d,
      end: now,
      activeOnly: true,
    );

    // ── Real HRV (SDNN) ──
    final latestHrv = await _db.healthRecordDao.getLatestHrv(
      start: AppDateUtils.daysAgo(1, from: now),
      end: now,
    );

    // ── Real Distributed Sleep & Stages (Night Sleep + Daytime/Evening Naps) ──
    final sleepSearchStart = todayStart.subtract(const Duration(hours: 10));
    final sleepSearchEnd = now;

    final rawSleepStages = await _db.healthRecordDao.getSleepStages(
      start: sleepSearchStart,
      end: sleepSearchEnd,
    );
    final rawSleepSessions = await _db.healthRecordDao.getSleepRecords(
      start: sleepSearchStart,
      end: sleepSearchEnd,
    );

    final cleanDistributed = SleepDataSanitizer.extractDistributedSessions(
      stageRecords: rawSleepStages,
      sessionRecords: rawSleepSessions,
      fallbackHours: baseline?.sleepDurationBaseline7d != null
          ? baseline!.sleepDurationBaseline7d! / 60.0
          : null,
    );

    final cleanSleep = cleanDistributed.mainSleep;

    final sleepStages = cleanSleep.hasStageData
        ? SleepStageBreakdown(
            deepMinutes: cleanSleep.deepMinutes,
            remMinutes: cleanSleep.remMinutes,
            lightMinutes: cleanSleep.coreMinutes,
            awakeMinutes: cleanSleep.awakeMinutes,
          )
        : null;

    final actualSleepHours = (cleanDistributed.totalHours > 0)
        ? cleanDistributed.totalHours
        : null;

    final distributedSessions = cleanDistributed.sessions.map((s) {
      final sData = s.sleepData;
      final stBreakdown = sData.hasStageData
          ? SleepStageBreakdown(
              deepMinutes: sData.deepMinutes,
              remMinutes: sData.remMinutes,
              lightMinutes: sData.coreMinutes,
              awakeMinutes: sData.awakeMinutes,
            )
          : null;

      final type = s.sessionType == 'NIGHT_SLEEP'
          ? SleepSessionType.nightSleep
          : s.sessionType == 'EVENING_NAP'
              ? SleepSessionType.eveningNap
              : s.sessionType == 'AFTERNOON_NAP'
                  ? SleepSessionType.afternoonNap
                  : SleepSessionType.morningNap;

      return DistributedSleepSession(
        title: s.title,
        type: type,
        startTime: s.startTime,
        endTime: s.endTime,
        durationHours: s.durationHours,
        durationMinutes: s.durationMinutes,
        stages: stBreakdown,
        isMainSleep: s.isMainSleep,
      );
    }).toList();

    // ── Real Day Strain Computation (0 - 21 scale) ──
    final hrRecords = await _db.healthRecordDao
        .getHeartRates(start: todayStart, end: now);
    double dayStrain = 0.0;
    if (hrRecords.isNotEmpty && baseline?.restingHrBaseline7d != null) {
      final rhr = baseline!.restingHrBaseline7d!;
      final maxHr = metric?.estimatedVo2Max != null
          ? (metric!.estimatedVo2Max! * rhr / 15.0)
          : 190.0;
      double accumulatedTrimp = 0.0;
      for (final hr in hrRecords) {
        if (hr.value > rhr && maxHr > rhr) {
          final intensity = ((hr.value - rhr) / (maxHr - rhr)).clamp(0.0, 1.0);
          accumulatedTrimp += intensity * intensity * 2.0;
        }
      }
      dayStrain = (21.0 * (1.0 - (1.0 / (1.0 + 0.02 * accumulatedTrimp))))
          .clamp(0.0, 21.0);
    } else if (todaySteps > 0 || workouts.isNotEmpty) {
      final workoutMins = workouts.fold<int>(0, (sum, w) => sum + w.durationMinutes);
      final activityScore = (workoutMins * 1.5) + (todaySteps / 1000.0) * 0.8;
      dayStrain = (21.0 * (1.0 - (1.0 / (1.0 + 0.03 * activityScore))))
          .clamp(0.0, 21.0);
    }

    // ── 7-Day Daily Strain History ──
    final List<HistoricalScorePoint> strainHistory7d = [];
    for (int i = 6; i >= 0; i--) {
      final dStart = AppDateUtils.daysAgo(i, from: todayStart);
      final dEnd = i == 0 ? now : dStart.add(const Duration(days: 1));
      if (i == 0) {
        strainHistory7d.add(HistoricalScorePoint(date: dStart, score: dayStrain));
      } else {
        final dayW = workouts7d.where((w) =>
            w.startTime.isAfter(dStart) && w.startTime.isBefore(dEnd));
        final dayWMin = dayW.fold<int>(0, (s, w) => s + w.durationMinutes);
        final dayScore = (dayWMin * 1.5) + (todaySteps > 0 ? 3.0 : 0.0);
        final dStrain = (21.0 * (1.0 - (1.0 / (1.0 + 0.03 * dayScore))))
            .clamp(0.0, 21.0);
        strainHistory7d.add(HistoricalScorePoint(date: dStart, score: dStrain));
      }
    }

    // ── Recommended Target Strain ──
    double? targetStrain;
    if (metric?.recoveryScore != null) {
      final rec = metric!.recoveryScore!;
      if (rec >= 67) {
        targetStrain = 14.0 + ((rec - 67) / 33.0) * 4.0;
      } else if (rec >= 34) {
        targetStrain = 10.0 + ((rec - 34) / 33.0) * 3.9;
      } else {
        targetStrain = 6.0 + (rec / 34.0) * 3.9;
      }
    }

    // ── 14-Day Historical Trend ──
    final history = await _db.derivedMetricDao.getHistory(14);
    final historyPoints = history
        .where((m) => m.recoveryScore != null)
        .map((m) => HistoricalScorePoint(
              date: m.date,
              score: m.recoveryScore!,
            ))
        .toList();

    // ── Today's Actual Resting HR (not baseline average) ──
    final todayRhr = await _db.healthRecordDao.getTodayRestingHr(
      start: todayStart,
      end: now,
    );

    // ── Today's Actual SpO2 (not 7-day average) ──
    final todaySpo2 = await _db.healthRecordDao.getTodayLatestSpo2(
      start: todayStart,
      end: now,
    );

    // ── Today's Actual Respiratory Rate ──
    final todayResp = await _db.healthRecordDao.getTodayLatestRespiratoryRate(
      start: todayStart,
      end: now,
    );

    // ── Baselines (7-day / 14-day with clinical defaults) ──
    final hrvHistory = await _db.healthRecordDao.getHrvBaselineRecords(
      start: AppDateUtils.daysAgo(14, from: now),
      end: now,
    );
    final baselineHrv = _computeBaselines
            .hrvBaseline(hrvHistory.map((r) => r.value).toList()) ??
        55.0;

    final respHistory = await _db.healthRecordDao.getRespiratoryRateBaselineRecords(
      start: AppDateUtils.daysAgo(14, from: now),
      end: now,
    );
    final baselineResp = _computeBaselines
            .respiratoryRateBaseline(respHistory.map((r) => r.value).toList()) ??
        14.0;

    final rhrBaseline = baseline?.restingHrBaseline30d ??
        baseline?.restingHrBaseline7d ??
        60.0;
    final baselineSleepMinutes = baseline?.sleepDurationBaseline7d;
    final sleepBaselineMinutes =
        (baselineSleepMinutes != null && baselineSleepMinutes >= 420.0)
            ? baselineSleepMinutes
            : 480.0;
    final spo2Baseline = baseline?.spo2Baseline7d ?? 97.0;

    // ── Live Real-Time Multi-Pillar Recovery Score ──
    final liveRecovery = _computeRecoveryScore(
      todayHrv: latestHrv,
      hrvBaseline: baselineHrv,
      todayRhr: todayRhr ?? baseline?.restingHrBaseline7d,
      rhrBaseline7d: rhrBaseline,
      lastNightSleepMinutes:
          actualSleepHours != null ? actualSleepHours * 60.0 : null,
      sleepBaseline7d: sleepBaselineMinutes,
      deepSleepMinutes:
          cleanSleep.hasStageData ? cleanSleep.deepMinutes : null,
      remSleepMinutes: cleanSleep.hasStageData ? cleanSleep.remMinutes : null,
      todaySpo2: todaySpo2,
      spo2Baseline7d: spo2Baseline,
      todayRespiratoryRate: todayResp,
      respiratoryRateBaseline: baselineResp,
    );

    // Dynamic Target Strain based on the live calculated score
    final rec = liveRecovery.score;
    if (rec >= 67) {
      targetStrain = 14.0 + ((rec - 67) / 33.0) * 4.0;
    } else if (rec >= 34) {
      targetStrain = 10.0 + ((rec - 34) / 33.0) * 3.9;
    } else {
      targetStrain = 6.0 + (rec / 34.0) * 3.9;
    }

    // Recompute VO2max with live window-specific resting HR baselines
    // New formula: VO2max = 15.3 × (avg top 2 daily max HR / avg RHR)
    final avgTop2MaxHr7d = await _db.healthRecordDao.getAvgTop2DailyMaxHr(days: 7, relativeTo: now);
    final avgTop2MaxHr30d = await _db.healthRecordDao.getAvgTop2DailyMaxHr(days: 30, relativeTo: now);
    final avgTop2MaxHrAllTime = await _db.healthRecordDao.getAvgTop2DailyMaxHr(relativeTo: now);

    // Fallback to batch exercise max HR if not enough daily data
    final maxHrs = await _db.healthRecordDao.getExerciseMaxHrsByWindows(now);
    final maxHr7d = avgTop2MaxHr7d ?? maxHrs.max7d;
    final maxHr30d = avgTop2MaxHr30d ?? maxHrs.max30d;
    final maxHr60d = maxHrs.max60d;
    final maxHrAllTime = avgTop2MaxHrAllTime ?? maxHrs.maxAllTime;

    int? userAge;
    if (maxHr60d == null) {
      final dob = await _platform.fetchDateOfBirth();
      if (dob != null) {
        userAge = (now.difference(dob).inDays / 365.25).floor();
      }
    }
    final rhr7d = baseline?.restingHrBaseline7d ?? 60.0;
    final rhr30d = baseline?.restingHrBaseline30d ?? rhr7d;

    double vo2Rhr7d = rhr7d;
    double vo2Rhr30d = rhr30d;

    double? vo2max7d = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr7d,
      maxHrFromExercise: maxHr7d ?? maxHr30d ?? maxHr60d,
      userAge: userAge,
    );

    double? vo2max30d = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr30d,
      maxHrFromExercise: maxHr30d ?? maxHr60d,
      userAge: userAge,
    );

    final allTimeRhrs = await _db.healthRecordDao.getDailyRestingHeartRates(null);
    double rhrAllTime = rhr30d;
    if (allTimeRhrs.isNotEmpty) {
      final sortedRhr = allTimeRhrs.map((p) => p.value).toList()..sort();
      rhrAllTime = sortedRhr[sortedRhr.length ~/ 2];
    }
    double vo2RhrAllTime = rhrAllTime;
    
    double? vo2maxAllTime = _computeVo2Max(
      restingHr7dBaseline: vo2RhrAllTime,
      maxHrFromExercise: maxHrAllTime ?? maxHr30d ?? maxHr60d,
      userAge: userAge,
    );
    vo2maxAllTime ??= await _db.derivedMetricDao.getAllTimeAverageVo2Max();

    final vo2max = vo2max7d;

    // Persist today's live computed metric to SQLite only when values changed and persistToday is true,
    // avoiding recursive stream re-triggers and redundant writes
    final needsPersist = persistToday &&
        (metric == null ||
            metric.date.year != todayStart.year ||
            metric.date.month != todayStart.month ||
            metric.date.day != todayStart.day ||
            metric.estimatedVo2Max != vo2max ||
            metric.recoveryScore != liveRecovery.score ||
            metric.primaryFactor != liveRecovery.primaryFactor);

    if (needsPersist) {
      await _db.derivedMetricDao.upsertMetric(DerivedMetricsCompanion(
        date: Value(todayStart),
        estimatedVo2Max: Value(vo2max),
        recoveryScore: Value(liveRecovery.score),
        recoveryComponentRhr: Value(liveRecovery.rhrComponent),
        recoveryComponentSleep: Value(liveRecovery.sleepComponent),
        recoveryComponentSpo2: Value(liveRecovery.spo2Component),
        primaryFactor: Value(liveRecovery.primaryFactor),
      ));
    }

    final summaryResult = DerivedMetricSummary(
      recoveryScore: liveRecovery.score,
      recoveryComponentHrv: liveRecovery.hrvComponent,
      recoveryComponentRhr: liveRecovery.rhrComponent,
      recoveryComponentSleep: liveRecovery.sleepComponent,
      recoveryComponentSpo2: liveRecovery.spo2Component,
      recoveryComponentRespiratory: liveRecovery.respiratoryComponent,
      primaryFactor: liveRecovery.primaryFactor,
      estimatedVo2Max: vo2max,
      estimatedVo2Max7d: vo2max7d,
      estimatedVo2Max30d: vo2max30d,
      estimatedVo2MaxAllTime: vo2maxAllTime,
      restingHr: todayRhr ?? baseline?.restingHrBaseline7d,
      baselineRestingHr: rhrBaseline,
      sleepHours: actualSleepHours ??
          (baseline?.sleepDurationBaseline7d != null
              ? (baseline!.sleepDurationBaseline7d! / 60.0).clamp(3.0, 12.0)
              : null),
      baselineSleepHours: sleepBaselineMinutes / 60.0,
      nightSleepHours: cleanDistributed.nightHours > 0 ? cleanDistributed.nightHours : null,
      napSleepHours: cleanDistributed.napHours > 0 ? cleanDistributed.napHours : null,
      sleepSessions: distributedSessions,
      spo2: todaySpo2 ?? baseline?.spo2Baseline7d,
      baselineSpo2: spo2Baseline,
      hrvMs: latestHrv,
      baselineHrv: baselineHrv,
      respiratoryRate: todayResp,
      baselineRespiratoryRate: baselineResp,
      dayStrain: dayStrain > 0.0 ? dayStrain : null,
      targetStrain: targetStrain,
      activeCalories: activeCals > 0.0 ? activeCals : null,
      totalCalories: totalCals > 0.0 ? totalCals : null,
      todaySteps: todaySteps > 0 ? todaySteps : null,
      sleepStages: sleepStages,
      workouts: workouts,
      workouts7d: workouts7d,
      activeCalories7d: activeCals7d > 0.0 ? activeCals7d : null,
      strainHistory7d: strainHistory7d,
      recoveryHistory14d: historyPoints,
      totalRecords: recordCount,
      lastSyncedAt: lastSync,
    );

    _cachedSummary = summaryResult;
    return summaryResult;
  }

  @override
  Stream<DerivedMetricSummary?> watchLatestSummary() {
    return _db.derivedMetricDao.watchLatestMetric().asyncMap((metric) async {
      if (metric == null) return null;
      return getLatestSummary(persistToday: false);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY AGE ESTIMATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<BodyAgeResult?> getBodyAge({
    required int age,
    String? sex,
    double? heightCm,
    double? weightKg,
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    String? smokingStatus,
    int? stressLevel,
  }) async {
    final now = DateTime.now();
    final start30d = AppDateUtils.daysAgo(30, from: now);
    final start14d = AppDateUtils.daysAgo(14, from: now);
    final start7d = AppDateUtils.daysAgo(7, from: now);

    // Parallelize all main independent DB queries to dramatically reduce load time/lag
    final dbResults = await Future.wait([
      _db.healthRecordDao.getDailyRestingHeartRates(30), // 0
      _db.baselineDao.getLatestBaseline(), // 1
      _db.healthRecordDao.getHrvBaselineRecords(start: start30d, end: now), // 2
      _db.healthRecordDao.getLatestRecordByType(recordType: 'HEIGHT', start: start30d, end: now), // 3
      _db.healthRecordDao.getLatestRecordByType(recordType: 'WEIGHT', start: start30d, end: now), // 4
      _db.healthRecordDao.getLatestRecordByType(recordType: 'BLOOD_PRESSURE_SYSTOLIC', start: start30d, end: now), // 5
      _db.healthRecordDao.getLatestRecordByType(recordType: 'BLOOD_PRESSURE_DIASTOLIC', start: start30d, end: now), // 6
      _db.derivedMetricDao.getLatestMetric(), // 7
    ]);

    final rhrRecords = dbResults[0] as List<DailyMetricPoint>;
    final baseline = dbResults[1] as DailyBaseline?;
    final hrvRecords = dbResults[2] as List<RawHealthRecord>;
    final heightRecords = dbResults[3] as RawHealthRecord?;
    final weightRecords = dbResults[4] as RawHealthRecord?;
    final bpSys = dbResults[5] as RawHealthRecord?;
    final bpDia = dbResults[6] as RawHealthRecord?;
    final latestMetric = dbResults[7] as DerivedMetric?;

    // ── Resting Heart Rate (30-day average) ──
    double? restingHrAvg30d;
    if (rhrRecords.isNotEmpty) {
      restingHrAvg30d = rhrRecords.map((p) => p.value).reduce((a, b) => a + b) / rhrRecords.length;
    }

    // ── RHR 7-day baseline ──
    final rhr7d = baseline?.restingHrBaseline7d;

    // ── HRV (30-day average) ──
    double? hrvAvg30d;
    String? hrvMetricType;
    if (hrvRecords.isNotEmpty) {
      hrvAvg30d =
          hrvRecords.map((r) => r.value).reduce((a, b) => a + b) /
              hrvRecords.length;
      // Determine HRV metric type from record type name
      final firstType = hrvRecords.first.recordType;
      if (firstType?.contains('RMSSD') == true) {
        hrvMetricType = 'RMSSD';
      } else if (firstType?.contains('SDNN') == true) {
        hrvMetricType = 'SDNN';
      }
    }

    // ── HRV Trend (compare last 7d vs prior 7d) ──
    String? hrvTrend;
    if (hrvRecords.length >= 7) {
      final recent = hrvRecords.where((r) => r.startTime.isAfter(start7d));
      final prior = hrvRecords.where(
          (r) => r.startTime.isAfter(start14d) && r.startTime.isBefore(start7d));
      if (recent.isNotEmpty && prior.isNotEmpty) {
        final recentAvg =
            recent.map((r) => r.value).reduce((a, b) => a + b) /
                recent.length;
        final priorAvg =
            prior.map((r) => r.value).reduce((a, b) => a + b) /
                prior.length;
        if (recentAvg > priorAvg * 1.05) {
          hrvTrend = 'rising';
        } else if (recentAvg < priorAvg * 0.95) {
          hrvTrend = 'falling';
        } else {
          hrvTrend = 'stable';
        }
      }
    }

    // ── VO2 Max (from latest derived metric) ──
    final vo2max = latestMetric?.estimatedVo2Max;

    // ── Sleep (14-day averages) ──
    double? sleepDurationAvgHours;
    double? deepSleepPct;
    double? remSleepPct;
    double? sleepEfficiency;

    // Use summary's sleep data when available
    final summary = _cachedSummary ?? await getLatestSummary(persistToday: false);
    if (summary != null && summary.sleepHours != null) {
      sleepDurationAvgHours = summary.baselineSleepHours;
      if (summary.sleepStages != null && summary.sleepStages!.hasStageData) {
        final stages = summary.sleepStages!;
        deepSleepPct = stages.deepPercentage;
        remSleepPct = stages.remPercentage;
        final totalMin = stages.totalTrackedMinutes;
        final sleepMin = stages.deepMinutes + stages.remMinutes + stages.lightMinutes;
        if (totalMin > 0) {
          sleepEfficiency = (sleepMin / totalMin) * 100;
        }
      }
    }

    // ── SpO2 (average from last 14 days) ──
    double? spo2Avg;
    if (summary?.spo2 != null) {
      spo2Avg = summary!.baselineSpo2 ?? summary.spo2;
    }

    // ── Respiratory Rate ──
    double? respRate;
    if (summary?.respiratoryRate != null) {
      respRate = summary!.baselineRespiratoryRate ?? summary.respiratoryRate;
    }

    // ── Daily Steps (7-day average) ──
    int? dailyStepsAvg;
    if (summary?.todaySteps != null || (summary?.steps7d ?? 0) > 0) {
      final steps7dTotal = summary?.steps7d ?? (summary?.todaySteps ?? 0);
      dailyStepsAvg = steps7dTotal > 0 ? (steps7dTotal / 7).round() : null;
    }

    // ── Activity Minutes (7d total from workouts) ──
    int? activityMinutesWeek;
    if (summary != null && summary.workouts7d.isNotEmpty) {
      activityMinutesWeek =
          summary.workouts7d.fold<int>(0, (s, w) => s + w.durationMinutes);
    }

    // ── Data Days ──
    // Count distinct days in the last 30 that have health records
    final dataDays = rhrRecords.length; // approximate by RHR data points

    // ── Height / Weight from Health Connect (if not provided manually) ──
    double? finalHeight = heightCm;
    double? finalWeight = weightKg;
    if (finalHeight == null && heightRecords != null && heightRecords.value > 0) {
      finalHeight = heightRecords.value;
    }
    if (finalWeight == null && weightRecords != null && weightRecords.value > 0) {
      finalWeight = weightRecords.value;
    }

    // ── Blood Pressure (if available) ──
    double? systolic = bpSys?.value;
    double? diastolic = bpDia?.value;

    // ── Build Input & Compute ──
    final input = BodyAgeInput(
      age: age,
      sex: sex,
      heightCm: finalHeight,
      weightKg: finalWeight,
      waistCircumferenceCm: waistCircumferenceCm,
      hipCircumferenceCm: hipCircumferenceCm,
      smokingStatus: smokingStatus,
      stressLevel: stressLevel,
      vo2maxDevice: vo2max,
      restingHrAvg30d: restingHrAvg30d,
      hrvAvg30d: hrvAvg30d,
      hrvMetricType: hrvMetricType,
      hrvTrend: hrvTrend,
      restingHrBaseline7d: rhr7d,
      sleepDurationAvgHours: sleepDurationAvgHours,
      sleepEfficiency: sleepEfficiency,
      deepSleepPct: deepSleepPct,
      remSleepPct: remSleepPct,
      spo2AvgSleep: spo2Avg,
      respiratoryRateSleep: respRate,
      dailyStepsAvg: dailyStepsAvg,
      activityMinutesWeek: activityMinutesWeek,
      dataDays: dataDays,
      systolicBp: systolic,
      diastolicBp: diastolic,
    );

    return _computeBodyAge(input);
  }
}
