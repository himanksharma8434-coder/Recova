import 'package:drift/drift.dart';


import '../tables/raw_health_records.dart';
import '../app_database.dart';
import '../../../core/utils/ppg_hrv_calculator.dart';
import '../../../domain/entities/daily_metric_point.dart';
import '../../../domain/services/vo2_max_estimator.dart';

part 'health_record_dao.g.dart';

@DriftAccessor(tables: [RawHealthRecords])
class HealthRecordDao extends DatabaseAccessor<AppDatabase>
    with _$HealthRecordDaoMixin {
  HealthRecordDao(super.db);

  /// Upsert a health record. Uses the composite unique key
  /// (recordType, sourceId, startTime) to handle re-reported values.
  Future<void> upsertRecord(RawHealthRecordsCompanion record) async {
    await into(rawHealthRecords).insert(
      record,
      onConflict: DoUpdate(
        (_) => record,
        target: [
          rawHealthRecords.recordType,
          rawHealthRecords.sourceId,
          rawHealthRecords.startTime,
        ],
      ),
    );
  }

  /// Batch upsert multiple records.
  Future<void> upsertRecords(List<RawHealthRecordsCompanion> records) async {
    await batch((batch) {
      for (final record in records) {
        batch.insert(
          rawHealthRecords,
          record,
          onConflict: DoUpdate(
            (_) => record,
            target: [
              rawHealthRecords.recordType,
              rawHealthRecords.sourceId,
              rawHealthRecords.startTime,
            ],
          ),
        );
      }
    });
  }

  /// Get records of a specific type within a date range.
  Future<List<RawHealthRecord>> getRecordsByType(
    String type, {
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals(type) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Get resting HR records for a trailing window.
  /// Prioritizes explicit RESTING_HEART_RATE records written by wearable/Health Connect.
  /// Only falls back to raw HEART_RATE records if no RESTING_HEART_RATE records exist.
  Future<List<RawHealthRecord>> getRestingHrRecords({
    required DateTime start,
    required DateTime end,
  }) async {
    final rhrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('RESTING_HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    if (rhrRecords.isNotEmpty) {
      return rhrRecords;
    }

    // Fallback: only if no RESTING_HEART_RATE records exist in the entire window
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Get the max HR observed during exercise sessions in a trailing window.
  ///
  /// 1. Finds actual WORKOUT sessions within [start, end].
  /// 2. For each workout, inspects heart rates recorded during that workout window.
  /// 3. Filters out single-sample optical sensor spikes (> 220 bpm or isolated glitches)
  ///    by taking the sustained peak HR (98th percentile for >= 5 samples, or max).
  /// 4. If no workouts exist, looks for sustained aerobic exertion (> 120 bpm, <= 215 bpm).
  /// 5. Returns null if no exercise data is available (allowing age fallback).
  Future<double?> getMaxExerciseHr({
    required DateTime start,
    required DateTime end,
  }) async {
    // 1. Fetch workout sessions in window, ordered by most recent first
    final workouts = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('WORKOUT') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)]))
        .get();

    if (workouts.isNotEmpty) {
      final List<({DateTime date, String type, double peakHr, double maxHr})> workoutPeaks = [];
      for (final w in workouts) {
        final hrs = await (select(rawHealthRecords)
              ..where((r) =>
                  r.recordType.equals('HEART_RATE') &
                  r.startTime.isBiggerOrEqualValue(w.startTime) &
                  r.endTime.isSmallerOrEqualValue(w.endTime) &
                  r.value.isSmallerOrEqualValue(220.0) &
                  r.value.isBiggerOrEqualValue(60.0))
              ..orderBy([(r) => OrderingTerm.asc(r.value)]))
            .get();

        if (hrs.isNotEmpty) {
          final maxVal = hrs.last.value;
          double peakVal = maxVal;
          if (hrs.length >= 5) {
            // Sustained peak (98th percentile to eliminate 1-sample optical spikes)
            final p98Index =
                ((hrs.length - 1) * 0.98).floor().clamp(0, hrs.length - 1);
            peakVal = hrs[p98Index].value;
          }
          final effectivePeak = (maxVal - peakVal <= 8) ? maxVal : peakVal;
          workoutPeaks.add((
            date: w.startTime,
            type: w.unit.toUpperCase(),
            peakHr: effectivePeak,
            maxHr: maxVal,
          ));
        }
      }

      if (workoutPeaks.isNotEmpty) {
        // Prioritize recent cardio / running workouts within the trailing 14 days
        final recentCutoff = end.subtract(const Duration(days: 14));
        final recentCardio = workoutPeaks.where((w) =>
            (w.type.contains('RUN') ||
             w.type.contains('CARDIO') ||
             w.type.contains('CYCLE') ||
             w.type.contains('AEROBIC')) &&
            w.date.isAfter(recentCutoff)).toList();

        if (recentCardio.isNotEmpty) {
          return recentCardio.first.peakHr;
        }

        // Next preference: any workout in trailing 14 days
        final recentWorkouts =
            workoutPeaks.where((w) => w.date.isAfter(recentCutoff)).toList();
        if (recentWorkouts.isNotEmpty) {
          return recentWorkouts.first.peakHr;
        }

        // Fallback: highest sustained peak across the window
        workoutPeaks.sort((a, b) => b.peakHr.compareTo(a.peakHr));
        return workoutPeaks.first.peakHr;
      }
    }

    // 2. Fallback: if no WORKOUT records logged, look for sustained aerobic heart rates
    final aerobicHrs = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end) &
              r.value.isBiggerOrEqualValue(120.0) &
              r.value.isSmallerOrEqualValue(215.0))
          ..orderBy([(r) => OrderingTerm.desc(r.value)]))
        .get();


    if (aerobicHrs.length >= 3) {
      // Avoid isolated single-sample spike
      return aerobicHrs[1].value;
    } else if (aerobicHrs.isNotEmpty) {
      return aerobicHrs.first.value;
    }

    return null;
  }

  /// Batch retrieves exercise max HR for 7D, 30D, 60D, and All-Time windows
  /// in a single efficient query pass to eliminate 4x redundant database queries.
  Future<({double? max7d, double? max30d, double? max60d, double? maxAllTime})>
      getExerciseMaxHrsByWindows(DateTime now) async {
    final startAllTime = DateTime(2000);

    // 1. Fetch all workout sessions across all time, ordered by most recent first
    final workouts = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('WORKOUT') &
              r.startTime.isBiggerOrEqualValue(startAllTime) &
              r.endTime.isSmallerOrEqualValue(now))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)]))
        .get();

    final List<({DateTime date, String type, double peakHr, double maxHr})>
        workoutPeaks = [];

    if (workouts.isNotEmpty) {
      for (final w in workouts) {
        final hrs = await (select(rawHealthRecords)
              ..where((r) =>
                  r.recordType.equals('HEART_RATE') &
                  r.startTime.isBiggerOrEqualValue(w.startTime) &
                  r.endTime.isSmallerOrEqualValue(w.endTime) &
                  r.value.isSmallerOrEqualValue(220.0) &
                  r.value.isBiggerOrEqualValue(60.0))
              ..orderBy([(r) => OrderingTerm.asc(r.value)]))
            .get();

        if (hrs.isNotEmpty) {
          final maxVal = hrs.last.value;
          double peakVal = maxVal;
          if (hrs.length >= 5) {
            final p98Index =
                ((hrs.length - 1) * 0.98).floor().clamp(0, hrs.length - 1);
            peakVal = hrs[p98Index].value;
          }
          final effectivePeak = (maxVal - peakVal <= 8) ? maxVal : peakVal;
          workoutPeaks.add((
            date: w.startTime,
            type: w.unit.toUpperCase(),
            peakHr: effectivePeak,
            maxHr: maxVal,
          ));
        }
      }
    }

    // 2. Fetch aerobic heart rates across all time once (for fallback windows with no workouts)
    List<RawHealthRecord>? aerobicHrsCache;
    Future<List<RawHealthRecord>> getAerobicHrs() async {
      return aerobicHrsCache ??= await (select(rawHealthRecords)
            ..where((r) =>
                r.recordType.equals('HEART_RATE') &
                r.startTime.isBiggerOrEqualValue(startAllTime) &
                r.endTime.isSmallerOrEqualValue(now) &
                r.value.isBiggerOrEqualValue(120.0) &
                r.value.isSmallerOrEqualValue(215.0))
            ..orderBy([(r) => OrderingTerm.desc(r.value)]))
          .get();
    }

    double? resolveForWindow(
        DateTime windowStart, List<RawHealthRecord> aerobicHrs) {
      final peaksInWindow = workoutPeaks
          .where((w) =>
              (w.date.isAfter(windowStart) ||
                  w.date.isAtSameMomentAs(windowStart)) &&
              (w.date.isBefore(now) || w.date.isAtSameMomentAs(now)))
          .toList();

      if (peaksInWindow.isNotEmpty) {
        final recentCutoff = now.subtract(const Duration(days: 14));
        final recentCardio = peaksInWindow.where((w) =>
            (w.type.contains('RUN') ||
                w.type.contains('CARDIO') ||
                w.type.contains('CYCLE') ||
                w.type.contains('AEROBIC')) &&
            w.date.isAfter(recentCutoff)).toList();

        if (recentCardio.isNotEmpty) {
          return recentCardio.first.peakHr;
        }

        final recentWorkouts =
            peaksInWindow.where((w) => w.date.isAfter(recentCutoff)).toList();
        if (recentWorkouts.isNotEmpty) {
          return recentWorkouts.first.peakHr;
        }

        final sorted = List.of(peaksInWindow)
          ..sort((a, b) => b.peakHr.compareTo(a.peakHr));
        return sorted.first.peakHr;
      }

      final aerobicInWindow = aerobicHrs
          .where((r) =>
              (r.startTime.isAfter(windowStart) ||
                  r.startTime.isAtSameMomentAs(windowStart)) &&
              (r.endTime.isBefore(now) || r.endTime.isAtSameMomentAs(now)))
          .toList();

      if (aerobicInWindow.length >= 3) {
        return aerobicInWindow[1].value;
      } else if (aerobicInWindow.isNotEmpty) {
        return aerobicInWindow.first.value;
      }

      return null;
    }

    final aerobicHrs = await getAerobicHrs();
    final cutoff7d = now.subtract(const Duration(days: 7));
    final cutoff30d = now.subtract(const Duration(days: 30));
    final cutoff60d = now.subtract(const Duration(days: 60));

    return (
      max7d: resolveForWindow(cutoff7d, aerobicHrs),
      max30d: resolveForWindow(cutoff30d, aerobicHrs),
      max60d: resolveForWindow(cutoff60d, aerobicHrs),
      maxAllTime: resolveForWindow(startAllTime, aerobicHrs),
    );
  }

  /// Get sleep session records for baseline computation.
  Future<List<RawHealthRecord>> getSleepRecords({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('SLEEP_SESSION') |
                  r.recordType.equals('SLEEP_ASLEEP')) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Get SpO2 records for baseline computation.
  Future<List<RawHealthRecord>> getSpo2Records({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('BLOOD_OXYGEN') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Total record count (for UI stats).
  Future<int> getRecordCount() async {
    final count = rawHealthRecords.id.count();
    final query = selectOnly(rawHealthRecords)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }

  /// Get total steps within a date range (strictly for the requested interval).
  ///
  /// Prevents:
  /// 1. Weekly/multi-day rollups (>24h duration) from contaminating day steps.
  /// 2. Multi-source doubling (e.g. Phone accelerometer + CMF Watch).
  /// 3. Cumulative daily updates from being repeatedly summed.
  Future<int> getTotalSteps({required DateTime start, required DateTime end}) async {
    final rawRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('STEPS') &
              r.startTime.isSmallerOrEqualValue(end) &
              r.endTime.isBiggerOrEqualValue(start))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    if (rawRecords.isEmpty) return 0;

    // 1. Filter out records that span > 24 hours (weekly or multi-day rollups)
    final validRecords = rawRecords.where((r) {
      final duration = r.endTime.difference(r.startTime);
      if (duration.inHours > 24) return false;
      if (r.value <= 0) return false;
      return true;
    }).toList();

    if (validRecords.isEmpty) return 0;

    // 2. Group records by sourceId
    final Map<String, List<RawHealthRecord>> recordsBySource = {};
    for (final r in validRecords) {
      recordsBySource.putIfAbsent(r.sourceId, () => []).add(r);
    }

    // 3. For each source, compute its daily total, detecting cumulative vs delta reporting
    final Map<String, int> sourceTotals = {};
    for (final entry in recordsBySource.entries) {
      final source = entry.key;
      final srcRecords = entry.value;

      if (srcRecords.isEmpty) continue;
      if (srcRecords.length == 1) {
        sourceTotals[source] = srcRecords.first.value.round();
        continue;
      }

      // Check if records represent cumulative daily updates via temporal interval overlap
      bool hasTimeOverlaps = false;
      for (int i = 0; i < srcRecords.length; i++) {
        for (int j = i + 1; j < srcRecords.length; j++) {
          final a = srcRecords[i];
          final b = srcRecords[j];
          if (a.startTime == b.startTime) {
            hasTimeOverlaps = true;
            break;
          }
          final overlapStart =
              a.startTime.isAfter(b.startTime) ? a.startTime : b.startTime;
          final overlapEnd =
              a.endTime.isBefore(b.endTime) ? a.endTime : b.endTime;
          if (overlapEnd.isAfter(overlapStart)) {
            if (overlapEnd.difference(overlapStart).inMinutes > 5) {
              hasTimeOverlaps = true;
              break;
            }
          }
        }
        if (hasTimeOverlaps) break;
      }

      double maxVal = 0;
      double sumVal = 0;
      for (final r in srcRecords) {
        if (r.value > maxVal) maxVal = r.value;
        sumVal += r.value;
      }

      if (hasTimeOverlaps) {
        sourceTotals[source] = maxVal.round();
      } else {
        sourceTotals[source] = sumVal.round();
      }
    }

    if (sourceTotals.isEmpty) return 0;

    // 4. Multi-source de-duplication:
    // If multiple sources exist (e.g. phone pedometer + Nothing X / CMF Watch),
    // DO NOT SUM THEM TOGETHER! Summing them doubles or triples steps.
    // Instead, prefer Nothing/CMF/wearable source, or take the maximum realistic source count.
    int bestSteps = 0;
    String? preferredSource;

    for (final source in sourceTotals.keys) {
      final lower = source.toLowerCase();
      if (lower.contains('nothing') ||
          lower.contains('cmf') ||
          lower.contains('watch') ||
          lower.contains('wear')) {
        preferredSource = source;
        break;
      }
    }

    if (preferredSource != null && sourceTotals[preferredSource]! > 0) {
      bestSteps = sourceTotals[preferredSource]!;
    } else {
      bestSteps = sourceTotals.values.reduce((a, b) => a > b ? a : b);
    }

    // 5. Sanity cap: single-day human limit (80,000 steps)
    return bestSteps.clamp(0, 80000);
  }


  /// Get total calories (active or total) within a date range.
  Future<double> getTotalCalories({
    required DateTime start,
    required DateTime end,
    bool activeOnly = false,
  }) async {
    final records = await (select(rawHealthRecords)
          ..where((r) =>
              (activeOnly
                  ? r.recordType.equals('ACTIVE_ENERGY_BURNED')
                  : (r.recordType.equals('TOTAL_CALORIES_BURNED') |
                      r.recordType.equals('ACTIVE_ENERGY_BURNED'))) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end)))
        .get();
    double sum = 0;
    for (final r in records) {
      sum += r.value;
    }
    return sum;
  }

  /// Get all workouts within a date range.
  Future<List<RawHealthRecord>> getWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('WORKOUT') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)]))
        .get();
  }

  /// Get merged high-resolution workout streams (Heart Rate + Speed) for Garmin-style VO2 max.
  ///
  /// Uses a 3-tier data strategy:
  /// 1. Distance records (DISTANCE_DELTA / DISTANCE_WALKING_RUNNING) → exact speed
  /// 2. Step records during workout → cadence-derived speed (stride length × steps/s)
  /// 3. HR-only → speed set to 0, handled by Tier 3 in Vo2MaxEstimator
  Future<List<WorkoutDataPoint>> getWorkoutDataPoints({
    required DateTime start,
    required DateTime end,
  }) async {
    final hrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    if (hrRecords.isEmpty) return [];

    // ── Tier 1: Try distance-based speed ──
    final distRecords = await (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('DISTANCE_DELTA') |
                  r.recordType.equals('DISTANCE_WALKING_RUNNING') |
                  r.recordType.equals('SPEED')) &
              r.startTime.isSmallerOrEqualValue(end) &
              r.endTime.isBiggerOrEqualValue(start))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    if (distRecords.isNotEmpty) {
      final points = <WorkoutDataPoint>[];
      for (final hr in hrRecords) {
        final t = hr.startTime;
        // Check for direct SPEED records first
        final speedRecord = distRecords.where((d) =>
          d.recordType == 'SPEED' &&
          (d.startTime.isBefore(t) || d.startTime.isAtSameMomentAs(t)) &&
          d.endTime.isAfter(t)
        ).firstOrNull;

        if (speedRecord != null) {
          points.add(WorkoutDataPoint(
            timestamp: t,
            heartRateBpm: hr.value,
            speedMetersPerSec: speedRecord.value,
          ));
          continue;
        }

        // Distance chunk → derive speed
        final distChunk = distRecords.where((d) =>
          d.recordType != 'SPEED' &&
          (d.startTime.isBefore(t) || d.startTime.isAtSameMomentAs(t)) &&
          d.endTime.isAfter(t)
        ).firstOrNull;

        if (distChunk != null) {
          final durationSecs = distChunk.endTime.difference(distChunk.startTime).inSeconds;
          if (durationSecs > 0) {
            final speedMps = distChunk.value / durationSecs;
            points.add(WorkoutDataPoint(
              timestamp: t,
              heartRateBpm: hr.value,
              speedMetersPerSec: speedMps,
            ));
          }
        }
      }
      if (points.isNotEmpty) return points;
    }

    // ── Tier 2: Try step-cadence derived speed ──
    final stepRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('STEPS') &
              r.startTime.isSmallerOrEqualValue(end) &
              r.endTime.isBiggerOrEqualValue(start) &
              r.value.isBiggerOrEqualValue(1.0))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    if (stepRecords.isNotEmpty) {
      final points = <WorkoutDataPoint>[];
      // Assumed average stride length for running (0.78m walking, ~1.2m running)
      const runningStrideLengthM = 1.1;

      for (final hr in hrRecords) {
        final t = hr.startTime;
        final stepChunk = stepRecords.where((s) =>
          (s.startTime.isBefore(t) || s.startTime.isAtSameMomentAs(t)) &&
          s.endTime.isAfter(t)
        ).firstOrNull;

        if (stepChunk != null) {
          final durationSecs = stepChunk.endTime.difference(stepChunk.startTime).inSeconds;
          if (durationSecs > 0) {
            final stepsPerSec = stepChunk.value / durationSecs;
            final speedMps = stepsPerSec * runningStrideLengthM;
            if (speedMps > 0.3) {
              points.add(WorkoutDataPoint(
                timestamp: t,
                heartRateBpm: hr.value,
                speedMetersPerSec: speedMps,
              ));
            }
          }
        }
      }
      if (points.isNotEmpty) return points;
    }

    // ── Tier 3: HR-only (speed = 0, Vo2MaxEstimator handles via Tier 3) ──
    return hrRecords.map((hr) => WorkoutDataPoint(
      timestamp: hr.startTime,
      heartRateBpm: hr.value,
      speedMetersPerSec: 0.0,
    )).toList();
  }

  /// Get latest HRV (SDNN or RMSSD) record within a date range.
  /// If no direct HRV records exist from the wearable, derives HRV (rMSSD)
  /// from optical Photoplethysmography (PPG) heart rate telemetry samples.
  Future<double?> getLatestHrv({
    required DateTime start,
    required DateTime end,
  }) async {
    final records = await (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('HEART_RATE_VARIABILITY_SDNN') |
                  r.recordType.equals('HEART_RATE_VARIABILITY_RMSSD')) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    if (records.isNotEmpty) return records.first.value;

    // Fallback: derive HRV (rMSSD) from resting / overnight PPG heart rate records
    final hrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
    return PpgHrvCalculator.computeRmssdFromHeartRates(hrRecords);
  }

  /// Get sleep stages records within a date range.
  /// Only returns actual stage breakdowns (deep, light, rem, awake),
  /// NOT session-level records (SLEEP_SESSION, SLEEP_ASLEEP).
  Future<List<RawHealthRecord>> getSleepStages({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('SLEEP_DEEP') |
                  r.recordType.equals('SLEEP_LIGHT') |
                  r.recordType.equals('SLEEP_REM') |
                  r.recordType.equals('SLEEP_AWAKE')) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Get heart rate records within a date range.
  Future<List<RawHealthRecord>> getHeartRates({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Get last night's sleep session (most recent SLEEP_SESSION or SLEEP_ASLEEP).
  /// Searches from [start] to [end] for the latest session-level sleep record.
  Future<RawHealthRecord?> getLastNightSleep({
    required DateTime start,
    required DateTime end,
  }) async {
    final records = await (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('SLEEP_SESSION') |
                  r.recordType.equals('SLEEP_ASLEEP')) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    return records.isEmpty ? null : records.first;
  }

  /// Get today's latest SpO2 reading.
  Future<double?> getTodayLatestSpo2({
    required DateTime start,
    required DateTime end,
  }) async {
    final records = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('BLOOD_OXYGEN') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    return records.isEmpty ? null : records.first.value;
  }

  /// Get today's resting heart rate.
  /// Prefers RESTING_HEART_RATE records, falls back to minimum HEART_RATE.
  Future<double?> getTodayRestingHr({
    required DateTime start,
    required DateTime end,
  }) async {
    // First try explicit RESTING_HEART_RATE records
    final rhrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('RESTING_HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    if (rhrRecords.isNotEmpty) return rhrRecords.first.value;

    // Fallback: minimum HEART_RATE value today
    final hrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.value)])
          ..limit(1))
        .get();
    return hrRecords.isEmpty ? null : hrRecords.first.value;
  }

  /// Get today's latest respiratory rate reading.
  Future<double?> getTodayLatestRespiratoryRate({
    required DateTime start,
    required DateTime end,
  }) async {
    final records = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('RESPIRATORY_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    return records.isEmpty ? null : records.first.value;
  }

  /// Get HRV records for charting and analysis.
  /// If direct records are not present from the wearable, derives optical PPG rMSSD records from heart rate telemetry.
  Future<List<RawHealthRecord>> getHrvRecords({
    required DateTime start,
    required DateTime end,
    bool allowIntraday = false,
  }) async {
    final direct = await (select(rawHealthRecords)
          ..where((r) =>
              (r.recordType.equals('HEART_RATE_VARIABILITY_SDNN') |
                  r.recordType.equals('HEART_RATE_VARIABILITY_RMSSD')) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
    if (direct.isNotEmpty) return direct;

    // Fallback: derive optical PPG HRV from heart rate records
    final hrRecords = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('HEART_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();

    final buckets = <String, List<RawHealthRecord>>{};
    for (final r in hrRecords) {
      final key = allowIntraday
          ? '${r.startTime.year}-${r.startTime.month}-${r.startTime.day}-${(r.startTime.hour ~/ 2) * 2}'
          : '${r.startTime.year}-${r.startTime.month}-${r.startTime.day}';
      buckets.putIfAbsent(key, () => []).add(r);
    }

    final ppgRecords = <RawHealthRecord>[];
    for (final bucketRecords in buckets.values) {
      final rmssd = PpgHrvCalculator.computeRmssdFromHeartRates(bucketRecords);
      if (rmssd != null) {
        ppgRecords.add(bucketRecords.first.copyWith(
          recordType: 'HEART_RATE_VARIABILITY_RMSSD',
          value: rmssd,
          unit: 'MILLISECOND',
        ));
      }
    }
    return ppgRecords;
  }

  /// Get all HRV records for rolling baseline calculation.
  /// If no direct HRV records exist from the wearable, derives daily PPG rMSSD records from heart rates.
  Future<List<RawHealthRecord>> getHrvBaselineRecords({
    required DateTime start,
    required DateTime end,
  }) async {
    return getHrvRecords(start: start, end: end, allowIntraday: false);
  }

  /// Get all respiratory rate records for rolling baseline calculation.
  Future<List<RawHealthRecord>> getRespiratoryRateBaselineRecords({
    required DateTime start,
    required DateTime end,
  }) async {
    return (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals('RESPIRATORY_RATE') &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.asc(r.startTime)]))
        .get();
  }

  /// Returns daily max heart rates (highest sustained HR per day)
  /// for the last [days] days, or all time if [days] is null or 0.
  Future<List<DailyMetricPoint>> getDailyMaxHeartRates([int? days]) async {
    String query = '''
      SELECT 
        date(datetime(start_time, 'unixepoch', 'localtime')) as day_str,
        MAX(value) as max_val
      FROM raw_health_records
      WHERE record_type = 'HEART_RATE'
        AND value >= 60.0 AND value <= 220.0
    ''';
    final variables = <Variable>[];
    if (days != null && days > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time >= ? ';
      variables.add(Variable<int>(cutoffSec));
    }
    query += ' GROUP BY day_str ORDER BY day_str ASC ';

    final rows = await customSelect(
      query,
      variables: variables,
      readsFrom: {rawHealthRecords},
    ).get();

    return rows.map((r) {
      final dayStr = r.read<String>('day_str');
      final val = r.read<double>('max_val');
      final date = DateTime.tryParse(dayStr) ?? DateTime.now();
      return DailyMetricPoint(date: date, value: val);
    }).toList();
  }

  /// Returns the average of the top 3 highest daily max heart rates
  /// within the last [days] days, or between [start] and [end].
  /// Used for the VO2 max formula: VO2max = 15.3 × (avg top 2 HRmax / avg RHR).
  /// Returns null if no heart rate data exists.
  Future<double?> getAvgTop2DailyMaxHr({int? days, DateTime? relativeTo, DateTime? start, DateTime? end}) async {
    String query = '''
      SELECT max_val FROM (
        SELECT 
          date(datetime(start_time, 'unixepoch', 'localtime')) as day_str,
          MAX(value) as max_val
        FROM raw_health_records
        WHERE record_type = 'HEART_RATE'
          AND value >= 60.0 AND value <= 220.0
    ''';
    final variables = <Variable>[];
    if (start != null) {
      variables.add(Variable<int>(start.millisecondsSinceEpoch ~/ 1000));
      query += ' AND start_time >= ? ';
    }
    if (end != null) {
      variables.add(Variable<int>(end.millisecondsSinceEpoch ~/ 1000));
      query += ' AND start_time <= ? ';
    }
    if (days != null && days > 0) {
      final base = relativeTo ?? DateTime.now();
      final cutoff = base.subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time >= ? ';
      variables.add(Variable<int>(cutoffSec));
      if (relativeTo != null) {
        final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
        query += ' AND start_time <= ? ';
        variables.add(Variable<int>(endSec));
      }
    } else if (relativeTo != null && start == null && end == null) {
      final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time <= ? ';
      variables.add(Variable<int>(endSec));
    }
    query += '''
        GROUP BY day_str
        ORDER BY max_val DESC
        LIMIT 2

      )
    ''';

    final rows = await customSelect(
      query,
      variables: variables,
      readsFrom: {rawHealthRecords},
    ).get();

    if (rows.isEmpty) return null;
    final sum = rows.fold<double>(0.0, (s, r) => s + r.read<double>('max_val'));
    return sum / rows.length;
  }

  /// Returns the single highest daily max heart rate from the week (or period).
  /// Used for the "best possible" VO2 max calculation at the bottom of the screen.
  Future<double?> getBestMaxHr([int? days, DateTime? relativeTo]) async {
    String query = '''
      SELECT MAX(value) as best_max
      FROM raw_health_records
      WHERE record_type = 'HEART_RATE'
        AND value >= 60.0 AND value <= 220.0
    ''';
    final variables = <Variable>[];
    if (days != null && days > 0) {
      final base = relativeTo ?? DateTime.now();
      final cutoff = base.subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time >= ? ';
      variables.add(Variable<int>(cutoffSec));
      if (relativeTo != null) {
        final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
        query += ' AND start_time <= ? ';
        variables.add(Variable<int>(endSec));
      }
    } else if (relativeTo != null) {
      final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time <= ? ';
      variables.add(Variable<int>(endSec));
    }

    final rows = await customSelect(
      query,
      variables: variables,
      readsFrom: {rawHealthRecords},
    ).get();

    if (rows.isEmpty) return null;
    return rows.first.readNullable<double>('best_max');
  }

  /// Returns the lowest daily resting heart rate from the week (or period).
  /// Used for the "best possible" VO2 max calculation at the bottom of the screen.
  Future<double?> getBestRestingHr([int? days, DateTime? relativeTo]) async {
    final base = relativeTo ?? DateTime.now();
    // First try explicit RESTING_HEART_RATE records
    String query = '''
      SELECT MIN(avg_rhr) as best_rhr FROM (
        SELECT 
          date(datetime(start_time, 'unixepoch', 'localtime')) as day_str,
          AVG(value) as avg_rhr
        FROM raw_health_records
        WHERE record_type = 'RESTING_HEART_RATE'
    ''';
    final variables = <Variable>[];
    if (days != null && days > 0) {
      final cutoff = base.subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time >= ? ';
      variables.add(Variable<int>(cutoffSec));
      if (relativeTo != null) {
        final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
        query += ' AND start_time <= ? ';
        variables.add(Variable<int>(endSec));
      }
    } else if (relativeTo != null) {
      final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time <= ? ';
      variables.add(Variable<int>(endSec));
    }
    query += ' GROUP BY day_str )';

    final rows = await customSelect(
      query,
      variables: variables,
      readsFrom: {rawHealthRecords},
    ).get();

    if (rows.isNotEmpty) {
      final val = rows.first.readNullable<double>('best_rhr');
      if (val != null) return val;
    }

    // Fallback: minimum resting-range HR
    String fbQuery = '''
      SELECT MIN(value) as best_rhr
      FROM raw_health_records
      WHERE record_type = 'HEART_RATE'
        AND value >= 40.0 AND value <= 120.0
    ''';
    final fbVars = <Variable>[];
    if (days != null && days > 0) {
      final cutoff = base.subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      fbQuery += ' AND start_time >= ? ';
      fbVars.add(Variable<int>(cutoffSec));
      if (relativeTo != null) {
        final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
        fbQuery += ' AND start_time <= ? ';
        fbVars.add(Variable<int>(endSec));
      }
    } else if (relativeTo != null) {
      final endSec = relativeTo.millisecondsSinceEpoch ~/ 1000;
      fbQuery += ' AND start_time <= ? ';
      fbVars.add(Variable<int>(endSec));
    }

    final fbRows = await customSelect(
      fbQuery,
      variables: fbVars,
      readsFrom: {rawHealthRecords},
    ).get();

    if (fbRows.isEmpty) return null;
    return fbRows.first.readNullable<double>('best_rhr');
  }


  /// Returns daily resting heart rates for the last [days] days,
  /// or all time if [days] is null or 0.
  Future<List<DailyMetricPoint>> getDailyRestingHeartRates([int? days]) async {
    String query = '''
      SELECT 
        date(datetime(start_time, 'unixepoch', 'localtime')) as day_str,
        ROUND(AVG(value), 1) as avg_val
      FROM raw_health_records
      WHERE record_type = 'RESTING_HEART_RATE'
    ''';
    final variables = <Variable>[];
    if (days != null && days > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      query += ' AND start_time >= ? ';
      variables.add(Variable<int>(cutoffSec));
    }
    query += ' GROUP BY day_str ORDER BY day_str ASC ';

    final rows = await customSelect(
      query,
      variables: variables,
      readsFrom: {rawHealthRecords},
    ).get();

    if (rows.isNotEmpty) {
      return rows.map((r) {
        final dayStr = r.read<String>('day_str');
        final val = r.read<double>('avg_val');
        final date = DateTime.tryParse(dayStr) ?? DateTime.now();
        return DailyMetricPoint(date: date, value: val);
      }).toList();
    }

    // Fallback if no explicit RESTING_HEART_RATE: use minimum HEART_RATE in resting range
    String fallbackQuery = '''
      SELECT 
        date(datetime(start_time, 'unixepoch', 'localtime')) as day_str,
        MIN(value) as min_val
      FROM raw_health_records
      WHERE record_type = 'HEART_RATE'
        AND value >= 40.0 AND value <= 120.0
    ''';
    final fbVariables = <Variable>[];
    if (days != null && days > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      fallbackQuery += ' AND start_time >= ? ';
      fbVariables.add(Variable<int>(cutoffSec));
    }
    fallbackQuery += ' GROUP BY day_str ORDER BY day_str ASC ';

    final fbRows = await customSelect(
      fallbackQuery,
      variables: fbVariables,
      readsFrom: {rawHealthRecords},
    ).get();

    return fbRows.map((r) {
      final dayStr = r.read<String>('day_str');
      final val = r.read<double>('min_val');
      final date = DateTime.tryParse(dayStr) ?? DateTime.now();
      return DailyMetricPoint(date: date, value: val);
    }).toList();
  }

  /// Get the most recent record of a given [recordType] within a date range.
  /// Returns null if no matching record is found.
  Future<RawHealthRecord?> getLatestRecordByType({
    required String recordType,
    required DateTime start,
    required DateTime end,
  }) async {
    final results = await (select(rawHealthRecords)
          ..where((r) =>
              r.recordType.equals(recordType) &
              r.startTime.isBiggerOrEqualValue(start) &
              r.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(1))
        .get();
    return results.isNotEmpty ? results.first : null;
  }
}

