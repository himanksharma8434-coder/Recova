import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';

import 'package:whoop/core/config/engine_config.dart';
import 'package:whoop/core/di/injection.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/entities/user_profile_entity.dart';
import 'package:whoop/domain/entities/sleep_session_entity.dart';
import 'package:whoop/domain/entities/workout_session_entity.dart';
import 'package:whoop/domain/entities/baseline_snapshot_entity.dart';
import 'package:whoop/domain/entities/journal_entry_entity.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await configureDependencies(database: db);
  });

  tearDown(() async {
    await db.close();
    await sl.reset();
  });

  group('Phase 1 Foundations: Engine Config & Versioning', () {
    test('algorithmVersion is defined as 2.0.0', () {
      expect(EngineConfig.algorithmVersion, equals('2.0.0'));
    });

    test('calibration timeline adheres to master spec', () {
      expect(EngineConfig.minDaysForBaselineCollection, equals(3));
      expect(EngineConfig.minDaysForProvisionalScore, equals(4));
      expect(EngineConfig.minDaysForFullScore, equals(14));
      expect(EngineConfig.idealDaysForNormalRange, equals(60));
    });

    test('readiness weights sum to 1.0', () {
      final total = EngineConfig.weightHrv +
          EngineConfig.weightRhr +
          EngineConfig.weightSleep +
          EngineConfig.weightRespiratory;
      expect((total - 1.0).abs(), lessThan(0.0001));
    });

    test('readiness tier thresholds match target specs', () {
      expect(EngineConfig.readinessTierHighThreshold, equals(67.0));
      expect(EngineConfig.readinessTierModerateThreshold, equals(34.0));
    });
  });

  group('Phase 1 Foundations: Drift Database & New DAOs', () {
    test('schema version is 3', () {
      expect(db.schemaVersion, equals(3));
    });

    test('UserProfileDao stores and retrieves user demographic profile',
        () async {
      final now = DateTime.utc(2026, 11, 7, 8, 0, 0);
      await db.userProfileDao.upsertProfile(UserProfilesCompanion(
        userId: const drift.Value('local_user'),
        age: const drift.Value(28),
        sex: const drift.Value('male'),
        heightCm: const drift.Value(180.5),
        weightKg: const drift.Value(75.2),
        bodyFatPct: const drift.Value(14.5),
        maxHr: const drift.Value(192.0),
        restingHrBaseline: const drift.Value(52.0),
        sleepNeedBaselineMinutes: const drift.Value(480),
        units: const drift.Value('metric'),
        timeZone: const drift.Value('UTC'),
        timeZoneOffsetMinutes: const drift.Value(330),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ));

      final profile = await db.userProfileDao.getProfile('local_user');
      expect(profile, isNotNull);
      expect(profile!.age, equals(28));
      expect(profile.sex, equals('male'));
      expect(profile.heightCm, equals(180.5));
      expect(profile.weightKg, equals(75.2));
      expect(profile.timeZoneOffsetMinutes, equals(330));
    });

    test('SleepSessionDao stores and retrieves sleep sessions', () async {
      final start = DateTime.utc(2026, 11, 6, 23, 0, 0);
      final end = DateTime.utc(2026, 11, 7, 7, 15, 0);
      final synced = DateTime.utc(2026, 11, 7, 7, 20, 0);

      await db.sleepSessionDao.upsertSession(SleepSessionsCompanion(
        userId: const drift.Value('local_user'),
        startTime: drift.Value(start),
        endTime: drift.Value(end),
        durationMinutes: const drift.Value(495),
        asleepMinutes: const drift.Value(460),
        deepMinutes: const drift.Value(95),
        lightMinutes: const drift.Value(245),
        remMinutes: const drift.Value(120),
        awakeMinutes: const drift.Value(35),
        efficiency: const drift.Value(92.9),
        restingHeartRate: const drift.Value(49.0),
        hrvRmssd: const drift.Value(64.2),
        spo2Average: const drift.Value(97.8),
        calculationMethod: const drift.Value('sensor'),
        qualityFlag: const drift.Value('good'),
        syncedAt: drift.Value(synced),
      ));

      final latest = await db.sleepSessionDao.getLatestNightSleep();
      expect(latest, isNotNull);
      expect(latest!.asleepMinutes, equals(460));
      expect(latest.deepMinutes, equals(95));
      expect(latest.hrvRmssd, equals(64.2));
      expect(latest.calculationMethod, equals('sensor'));
    });

    test('WorkoutSessionDao stores and retrieves workout sessions', () async {
      final start = DateTime.utc(2026, 11, 7, 10, 0, 0);
      final end = DateTime.utc(2026, 11, 7, 11, 0, 0);
      final synced = DateTime.utc(2026, 11, 7, 11, 5, 0);

      await db.workoutSessionDao.upsertWorkout(WorkoutSessionsCompanion(
        userId: const drift.Value('local_user'),
        sport: const drift.Value('running'),
        title: const drift.Value('Morning Threshold Run'),
        startTime: drift.Value(start),
        endTime: drift.Value(end),
        durationMinutes: const drift.Value(60),
        avgHeartRate: const drift.Value(156.0),
        maxHeartRate: const drift.Value(178.0),
        caloriesBurned: const drift.Value(620.0),
        distanceMeters: const drift.Value(10500.0),
        zone1Minutes: const drift.Value(5),
        zone2Minutes: const drift.Value(15),
        zone3Minutes: const drift.Value(20),
        zone4Minutes: const drift.Value(18),
        zone5Minutes: const drift.Value(2),
        strainScore: const drift.Value(14.8),
        recoveryCost: const drift.Value(8.5),
        syncedAt: drift.Value(synced),
      ));

      final recent = await db.workoutSessionDao.getRecentWorkouts(limit: 1);
      expect(recent.length, equals(1));
      expect(recent.first.sport, equals('running'));
      expect(recent.first.strainScore, equals(14.8));
      expect(recent.first.zone4Minutes, equals(18));
    });

    test('BaselineSnapshotDao stores and retrieves daily baseline snapshot',
        () async {
      final day = DateTime.utc(2026, 11, 7);
      final calcTime = DateTime.utc(2026, 11, 7, 7, 30, 0);

      await db.baselineSnapshotDao.upsertSnapshot(BaselineSnapshotsCompanion(
        date: drift.Value(day),
        hrvBaseline7d: const drift.Value(4.15), // ln(63.4)
        hrvBaseline60dMean: const drift.Value(4.10),
        hrvBaseline60dSd: const drift.Value(0.18),
        hrvCv7d: const drift.Value(0.045),
        rawHrvBaseline7dMs: const drift.Value(63.4),
        rhrBaseline7d: const drift.Value(50.5),
        rhrBaseline60dMean: const drift.Value(51.2),
        rhrBaseline60dSd: const drift.Value(2.1),
        sleepDurationBaseline7d: const drift.Value(475.0),
        sleepDurationBaseline60d: const drift.Value(468.0),
        totalRecordedNights: const drift.Value(42),
        calculatedAt: drift.Value(calcTime),
      ));

      final snap = await db.baselineSnapshotDao.getSnapshot(day);
      expect(snap, isNotNull);
      expect(snap!.hrvBaseline7d, equals(4.15));
      expect(snap.totalRecordedNights, equals(42));
      expect(snap.rawHrvBaseline7dMs, equals(63.4));
    });

    test('JournalDao records and queries behavior tags', () async {
      final day = DateTime.utc(2026, 11, 7);
      final loggedAt = DateTime.utc(2026, 11, 7, 21, 30, 0);

      final id = await db.journalDao.insertEntry(JournalEntriesCompanion(
        userId: const drift.Value('local_user'),
        date: drift.Value(day),
        timestamp: drift.Value(loggedAt),
        tag: const drift.Value('alcohol'),
        value: const drift.Value('2 beers'),
        notes: const drift.Value('Evening social dinner'),
      ));

      expect(id, isPositive);
      final entries = await db.journalDao.getEntriesForDay(day);
      expect(entries.length, equals(1));
      expect(entries.first.tag, equals('alcohol'));
      expect(entries.first.value, equals('2 beers'));
    });

    test('InsightDao inserts and queries explainable insights', () async {
      final day = DateTime.utc(2026, 11, 7);
      final id = await db.insightDao.insertInsight(InsightsCompanion(
        createdAt: drift.Value(day),
        date: drift.Value(day),
        category: const drift.Value('readiness'),
        title: const drift.Value('Optimal Autonomic Balance'),
        summary: const drift.Value(
            'Your resting HR dropped 3 bpm below baseline while HRV climbed to 64ms.'),
        actionableNudge: const drift.Value(
            'Your body is primed for high cardiovascular load today.'),
        metricReferencesJson:
            const drift.Value('["hrv_rmssd", "resting_hr", "sleep_score"]'),
      ));

      expect(id, isPositive);
      final insights = await db.insightDao.getInsightsForDate(day);
      expect(insights.length, equals(1));
      expect(insights.first.category, equals('readiness'));
      expect(insights.first.isRead, isFalse);
    });

    test('DeviceConnectionDao registers connected wearables', () async {
      await db.deviceConnectionDao.upsertDevice(DeviceConnectionsCompanion(
        deviceId: const drift.Value('cmf_watch_pro_2'),
        name: const drift.Value('CMF Watch Pro 2'),
        platform: const drift.Value('health_connect'),
        lastSyncTime: drift.Value(DateTime.now()),
        priority: const drift.Value(20),
        isActive: const drift.Value(true),
      ));

      final devices = await db.deviceConnectionDao.getAllDevices();
      expect(devices.length, equals(1));
      expect(devices.first.deviceId, equals('cmf_watch_pro_2'));
      expect(devices.first.priority, equals(20));
    });
  });

  group('Phase 1 Foundations: Domain Entities & Invariants', () {
    test('UserProfileEntity calculates BMI accurately', () {
      const profile = UserProfileEntity(
        heightCm: 180.0,
        weightKg: 72.0,
      );
      // BMI = 72 / (1.8 * 1.8) = 22.22
      expect(profile.calculatedBmi, closeTo(22.22, 0.01));
    });

    test('WorkoutSessionEntity instantiates with defaults', () {
      final now = DateTime.now();
      final workout = WorkoutSessionEntity(
        sport: 'running',
        title: 'Morning 5k',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        durationMinutes: 30,
        strainScore: 11.5,
        syncedAt: now,
      );
      expect(workout.sport, equals('running'));
      expect(workout.strainScore, equals(11.5));
      expect(workout.zone1Minutes, equals(0));
    });

    test('JournalEntryEntity instantiates with tag and timestamp', () {
      final now = DateTime.now();
      final entry = JournalEntryEntity(
        date: now,
        timestamp: now,
        tag: 'caffeine',
        value: 'Double espresso',
      );
      expect(entry.tag, equals('caffeine'));
      expect(entry.value, equals('Double espresso'));
    });

    test('SleepSessionEntity evaluates restorative sleep share', () {
      final session = SleepSessionEntity(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        durationMinutes: 480,
        asleepMinutes: 450,
        deepMinutes: 90,
        remMinutes: 90,
        lightMinutes: 270,
        syncedAt: DateTime.now(),
      );
      // Restorative = (90 + 90) / 450 = 40.0%
      expect(session.restorativeMinutes, equals(180));
      expect(session.restorativePercentage, equals(40.0));
      expect(session.hasStageBreakdown, isTrue);
    });

    test('BaselineSnapshotEntity calculates normal range bounds', () {
      final snapshot = BaselineSnapshotEntity(
        date: DateTime.now(),
        hrvBaseline60dMean: 4.10,
        hrvBaseline60dSd: 0.20,
        calculatedAt: DateTime.now(),
      );
      // Upper = 4.10 + 0.75 * 0.20 = 4.25
      // Lower = 4.10 - 0.75 * 0.20 = 3.95
      expect(snapshot.hrvNormalUpperBound, closeTo(4.25, 0.001));
      expect(snapshot.hrvNormalLowerBound, closeTo(3.95, 0.001));
    });
  });
}
