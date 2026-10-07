import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/data/datasources/health_platform_datasource.dart';
import 'package:whoop/data/repositories/health_repository_impl.dart';

class MockHealthPlatformDatasource extends HealthPlatformDatasource {
  @override
  Future<DateTime?> fetchDateOfBirth() async => null;
}

void main() {
  late AppDatabase db;
  late HealthRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = HealthRepositoryImpl(
      platform: MockHealthPlatformDatasource(),
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('VO2 Max 7-Day vs 30-Day Independent Window Calculation', () {
    test('computes distinct vo2max7d and vo2max30d when resting HR and exercise max HR differ across windows', () async {
      final now = DateTime.now();

      // Seed prior 23 days (days 8 through 30) with lower resting HR (50 bpm)
      // and a high peak exercise HR session (195 bpm) at day 15.
      for (int i = 8; i <= 30; i++) {
        final dayTime = now.subtract(Duration(days: i));
        await db.healthRecordDao.upsertRecords([
          RawHealthRecordsCompanion.insert(
            recordType: 'RESTING_HEART_RATE',
            value: 50.0,
            unit: 'BEATS_PER_MINUTE',
            startTime: dayTime,
            endTime: dayTime,
            sourceId: 'test_device',
            syncedAt: now,
          ),
        ]);
      }

      // Hard exercise session at day 15 (max HR 195)
      final day15Time = now.subtract(const Duration(days: 15));
      await db.healthRecordDao.upsertRecords([
        RawHealthRecordsCompanion.insert(
          recordType: 'HEART_RATE',
          value: 195.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day15Time,
          endTime: day15Time,
          sourceId: 'workout_tracker',
          syncedAt: now,
        ),
      ]);

      // Seed recent 7 days (days 0 through 7) with elevated resting HR (60 bpm)
      // and a lower peak exercise HR session (170 bpm) at day 3.
      for (int i = 0; i <= 7; i++) {
        final dayTime = now.subtract(Duration(days: i));
        await db.healthRecordDao.upsertRecords([
          RawHealthRecordsCompanion.insert(
            recordType: 'RESTING_HEART_RATE',
            value: 60.0,
            unit: 'BEATS_PER_MINUTE',
            startTime: dayTime,
            endTime: dayTime,
            sourceId: 'test_device',
            syncedAt: now,
          ),
        ]);
      }

      // Moderate exercise session at day 3 (max HR 170)
      final day3Time = now.subtract(const Duration(days: 3));
      await db.healthRecordDao.upsertRecords([
        RawHealthRecordsCompanion.insert(
          recordType: 'HEART_RATE',
          value: 170.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day3Time,
          endTime: day3Time,
          sourceId: 'workout_tracker',
          syncedAt: now,
        ),
      ]);

      // Recompute baselines and derived metrics across the historical window
      await repository.recomputeHistory(days: 30);

      // Fetch the latest summary
      final summary = await repository.getLatestSummary();
      expect(summary, isNotNull);

      final vo2max7d = summary!.estimatedVo2Max7d;
      final vo2max30d = summary.estimatedVo2Max30d;

      expect(vo2max7d, isNotNull);
      expect(vo2max30d, isNotNull);

      // Assert that 7-day and 30-day VO2 max values differ
      expect(vo2max7d, isNot(equals(vo2max30d)));

      // Expected values:
      // 7D: HRrest = 60.0, HRmax = 170.0 → 15.0 × (170 / 60) = 42.5 mL/kg/min
      // 30D: HRrest = 50.0 (calibrated to 60.5), HRmax = (195 + 170) / 2 = 182.5 → 15.0 × (182.5 / 60.5) ≈ 45.25 mL/kg/min
      expect(vo2max7d!, closeTo(42.5, 0.5));
      expect(vo2max30d!, closeTo(45.25, 0.5));
      expect(vo2max30d - vo2max7d, greaterThan(2.0));
      expect(summary.estimatedVo2MaxAllTime, isNotNull);
    });

    test('computes distinct vo2maxAllTime spanning historical records beyond 30 days', () async {
      final now = DateTime.now();

      // Seed records 45 days ago with an all-time peak workout (205 bpm)
      // and low resting HR (48 bpm)
      final day45Time = now.subtract(const Duration(days: 45));
      await db.healthRecordDao.upsertRecords([
        RawHealthRecordsCompanion.insert(
          recordType: 'RESTING_HEART_RATE',
          value: 48.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day45Time,
          endTime: day45Time,
          sourceId: 'test_device',
          syncedAt: now,
        ),
        RawHealthRecordsCompanion.insert(
          recordType: 'HEART_RATE',
          value: 205.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day45Time,
          endTime: day45Time,
          sourceId: 'workout_tracker',
          syncedAt: now,
        ),
      ]);

      // Seed 30-day window (days 8 through 30) with RHR 54 bpm, peak HR 185 bpm
      for (int i = 8; i <= 30; i++) {
        final dayTime = now.subtract(Duration(days: i));
        await db.healthRecordDao.upsertRecords([
          RawHealthRecordsCompanion.insert(
            recordType: 'RESTING_HEART_RATE',
            value: 54.0,
            unit: 'BEATS_PER_MINUTE',
            startTime: dayTime,
            endTime: dayTime,
            sourceId: 'test_device',
            syncedAt: now,
          ),
        ]);
      }
      final day12Time = now.subtract(const Duration(days: 12));
      await db.healthRecordDao.upsertRecords([
        RawHealthRecordsCompanion.insert(
          recordType: 'HEART_RATE',
          value: 185.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day12Time,
          endTime: day12Time,
          sourceId: 'workout_tracker',
          syncedAt: now,
        ),
      ]);

      // Seed 7-day window (days 0 through 7) with RHR 62 bpm, peak HR 165 bpm
      for (int i = 0; i <= 7; i++) {
        final dayTime = now.subtract(Duration(days: i));
        await db.healthRecordDao.upsertRecords([
          RawHealthRecordsCompanion.insert(
            recordType: 'RESTING_HEART_RATE',
            value: 62.0,
            unit: 'BEATS_PER_MINUTE',
            startTime: dayTime,
            endTime: dayTime,
            sourceId: 'test_device',
            syncedAt: now,
          ),
        ]);
      }
      final day2Time = now.subtract(const Duration(days: 2));
      await db.healthRecordDao.upsertRecords([
        RawHealthRecordsCompanion.insert(
          recordType: 'HEART_RATE',
          value: 165.0,
          unit: 'BEATS_PER_MINUTE',
          startTime: day2Time,
          endTime: day2Time,
          sourceId: 'workout_tracker',
          syncedAt: now,
        ),
      ]);

      await repository.recomputeHistory(days: 45);

      final summary = await repository.getLatestSummary();
      expect(summary, isNotNull);

      final vo2max7d = summary!.estimatedVo2Max7d;
      final vo2max30d = summary.estimatedVo2Max30d;
      final vo2maxAllTime = summary.estimatedVo2MaxAllTime;

      expect(vo2max7d, isNotNull);
      expect(vo2max30d, isNotNull);
      expect(vo2maxAllTime, isNotNull);

      // Verify that 7D, 30D, and All-Time are all distinctly computed
      expect(vo2max7d, isNot(equals(vo2max30d)));
      expect(vo2max30d, isNot(equals(vo2maxAllTime)));

      // 7D should be lower (higher RHR 62, lower max HR 165)
      // All-Time should be higher (all-time peak 205 bpm)
      expect(vo2maxAllTime!, greaterThan(vo2max30d!));
      expect(vo2max30d, greaterThan(vo2max7d!));
    });
  });
}
