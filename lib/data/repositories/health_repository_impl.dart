import 'package:drift/drift.dart';

import '../../core/constants/health_types.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../domain/usecases/compute_baselines.dart';
import '../../domain/usecases/compute_vo2max.dart';
import '../../domain/usecases/compute_recovery_score.dart';
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
  DerivedMetricSummary? _cachedSummary;

  @override
  DerivedMetricSummary? get cachedSummary => _cachedSummary;

  HealthRepositoryImpl({
    required HealthPlatformDatasource platform,
    required AppDatabase db,
    ComputeBaselines? computeBaselines,
    ComputeVo2Max? computeVo2Max,
    ComputeRecoveryScore? computeRecoveryScore,
  // ignore: prefer_initializing_formals
  })  : _platform = platform,
        // ignore: prefer_initializing_formals
        _db = db,
        _computeBaselines = computeBaselines ?? const ComputeBaselines(),
        _computeVo2Max = computeVo2Max ?? const ComputeVo2Max(),
        _computeRecoveryScore =
            computeRecoveryScore ?? const ComputeRecoveryScore();

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
    final maxHr = await recordDao.getMaxExerciseHr(
      start: AppDateUtils.daysAgo(60, from: now),
      end: now,
    );

    // Determine age from health platform if no exercise max HR is available
    int? userAge;
    if (maxHr == null) {
      final dob = await _platform.fetchDateOfBirth();
      if (dob != null) {
        userAge = (now.difference(dob).inDays / 365.25).floor();
      }
    }

    // In the Uth-Sørensen formula, HRrest must be the awake resting HR.
    // If the 7-day baseline reflects nocturnal sleep dips (< 56 bpm),
    // calibrate using the autonomic awake/sleep ratio (~1.228) so HRrest is ~60.2 bpm.
    double vo2Rhr = rhrBase;
    if (vo2Rhr < 56.0) {
      vo2Rhr = (vo2Rhr * 1.228).clamp(58.0, 68.0);
    }

    final vo2max = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr,
      maxHrFromExercise: maxHr,
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
          ? (metric!.estimatedVo2Max! * rhr / 15.3)
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

    // Recompute VO2max with live window-specific resting HR baselines and exercise max HR
    // Fast batch extraction of exercise max HR in a single query pass
    final maxHrs = await _db.healthRecordDao.getExerciseMaxHrsByWindows(now);
    final maxHr7d = maxHrs.max7d;
    final maxHr30d = maxHrs.max30d;
    final maxHr60d = maxHrs.max60d;
    final maxHrAllTime = maxHrs.maxAllTime;

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
    if (vo2Rhr7d < 56.0) {
      vo2Rhr7d = (vo2Rhr7d * 1.228).clamp(58.0, 68.0);
    }
    double vo2Rhr30d = rhr30d;
    if (vo2Rhr30d < 56.0) {
      vo2Rhr30d = (vo2Rhr30d * 1.228).clamp(58.0, 68.0);
    }

    final vo2max7d = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr7d,
      maxHrFromExercise: maxHr7d ?? maxHr30d ?? maxHr60d,
      userAge: userAge,
    );
    final vo2max30d = _computeVo2Max(
      restingHr7dBaseline: vo2Rhr30d,
      maxHrFromExercise: maxHr30d ?? maxHr60d,
      userAge: userAge,
    );

    // Fast-path all-time VO2: use precomputed all-time avg if available, avoiding all-time RHR scan
    final allTimeAvgVo2 = await _db.derivedMetricDao.getAllTimeAverageVo2Max();
    double? vo2maxAllTime = allTimeAvgVo2;
    if (vo2maxAllTime == null) {
      final allTimeRhrs = await _db.healthRecordDao.getDailyRestingHeartRates(null);
      double rhrAllTime = rhr30d;
      if (allTimeRhrs.isNotEmpty) {
        final sortedRhr = allTimeRhrs.map((p) => p.value).toList()..sort();
        rhrAllTime = sortedRhr[sortedRhr.length ~/ 2];
      }
      double vo2RhrAllTime = rhrAllTime;
      if (vo2RhrAllTime < 56.0) {
        vo2RhrAllTime = (vo2RhrAllTime * 1.228).clamp(58.0, 68.0);
      }
      vo2maxAllTime = _computeVo2Max(
        restingHr7dBaseline: vo2RhrAllTime,
        maxHrFromExercise: maxHrAllTime ?? maxHr30d ?? maxHr60d,
        userAge: userAge,
      );
    }

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
}
