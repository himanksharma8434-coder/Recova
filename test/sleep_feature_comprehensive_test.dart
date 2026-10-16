import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/core/constants/health_types.dart';
import 'package:whoop/core/utils/sleep_data_sanitizer.dart';
import 'package:whoop/data/database/app_database.dart';

void main() {
  group('Sleep Feature Comprehensive Verification', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.instance = db;
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Interval Overlap Query in HealthRecordDao captures cross-midnight sleep', () async {
      final yesterday11pm = DateTime(2026, 10, 10, 23, 0);
      final today7am = DateTime(2026, 10, 11, 7, 0);
      final todayMidnight = DateTime(2026, 10, 11, 0, 0);
      final today9am = DateTime(2026, 10, 11, 9, 0);

      // Insert overnight SLEEP_SESSION starting yesterday
      await db.healthRecordDao.upsertRecord(RawHealthRecordsCompanion.insert(
        recordType: 'SLEEP_SESSION',
        value: 480.0,
        unit: 'MINUTES',
        startTime: yesterday11pm,
        endTime: today7am,
        sourceId: 'com.nothing.healt',
        syncedAt: DateTime.now(),
      ));

      // Also insert a stage record
      await db.healthRecordDao.upsertRecord(RawHealthRecordsCompanion.insert(
        recordType: 'SLEEP_DEEP',
        value: 120.0,
        unit: 'MINUTES',
        startTime: DateTime(2026, 10, 10, 23, 30),
        endTime: DateTime(2026, 10, 11, 1, 30),
        sourceId: 'com.nothing.healt',
        syncedAt: DateTime.now(),
      ));

      // Query today's window: 00:00 to 09:00
      final sessions = await db.healthRecordDao.getSleepRecords(
        start: todayMidnight,
        end: today9am,
      );

      final stages = await db.healthRecordDao.getSleepStages(
        start: todayMidnight,
        end: today9am,
      );

      final lastNight = await db.healthRecordDao.getLastNightSleep(
        start: todayMidnight,
        end: today9am,
      );

      // Verify that all queries correctly returned the record despite starting before midnight
      expect(sessions.length, 1, reason: 'getSleepRecords must match overlapping session');
      expect(sessions.first.recordType, 'SLEEP_SESSION');
      expect(stages.length, 1, reason: 'getSleepStages must match overlapping deep sleep');
      expect(stages.first.recordType, 'SLEEP_DEEP');
      expect(lastNight, isNotNull, reason: 'getLastNightSleep must find latest sleep session');
      expect(lastNight!.startTime, yesterday11pm);
    });

    test('2. Wearable providing only SLEEP_ASLEEP or SLEEP_IN_BED is recognized', () async {
      final nightStart = DateTime(2026, 10, 10, 23, 15);
      final nightEnd = DateTime(2026, 10, 11, 6, 45); // 7.5 hours = 450 min

      await db.healthRecordDao.upsertRecord(RawHealthRecordsCompanion.insert(
        recordType: 'SLEEP_ASLEEP',
        value: 450.0,
        unit: 'MINUTES',
        startTime: nightStart,
        endTime: nightEnd,
        sourceId: 'com.generic.wearable',
        syncedAt: DateTime.now(),
      ));

      final sessions = await db.healthRecordDao.getSleepRecords(
        start: DateTime(2026, 10, 11, 0, 0),
        end: DateTime(2026, 10, 11, 8, 0),
      );

      expect(sessions.length, 1);
      expect(sessions.first.recordType, 'SLEEP_ASLEEP');

      final clean = SleepDataSanitizer.extractDistributedSessions(
        stageRecords: [],
        sessionRecords: sessions,
      );

      expect(clean.totalHours, closeTo(7.5, 0.05));
      expect(clean.sessions.length, 1);
      expect(clean.sessions.first.title, 'Night Sleep');
    });

    test('3. Empty state cleanly returns zero without fabricating fake data', () {
      final clean = SleepDataSanitizer.extractDistributedSessions(
        stageRecords: [],
        sessionRecords: [],
      );

      expect(clean.totalHours, 0.0);
      expect(clean.totalMinutes, 0);
      expect(clean.nightHours, 0.0);
      expect(clean.napHours, 0.0);
      expect(clean.sessions, isEmpty);
      expect(clean.mainSleep.hasStageData, isFalse);
      expect(clean.mainSleep.totalHours, 0.0);
    });

    test('4. Platform requested sleep types contain all expected stages and sessions', () {
      final types = HealthTypes.platformRequestedTypes;
      final typeNames = types.map((t) => t.name).toSet();

      expect(typeNames.contains('SLEEP_ASLEEP'), isTrue);
      expect(typeNames.contains('SLEEP_AWAKE'), isTrue);
      expect(typeNames.contains('SLEEP_LIGHT'), isTrue);
      expect(typeNames.contains('SLEEP_DEEP'), isTrue);
      expect(typeNames.contains('SLEEP_REM'), isTrue);

      if (Platform.isAndroid) {
        expect(typeNames.contains('SLEEP_SESSION'), isTrue);
        expect(typeNames.contains('SLEEP_AWAKE_IN_BED'), isTrue);
        expect(typeNames.contains('SLEEP_OUT_OF_BED'), isTrue);
        expect(typeNames.contains('SLEEP_UNKNOWN'), isTrue);
      } else {
        expect(typeNames.contains('SLEEP_IN_BED'), isTrue);
      }
    });

    test('5. Multi-source stage deduplication preserves genuine stages and caps to night span', () {
      final start = DateTime(2026, 10, 10, 23, 0);
      final end = DateTime(2026, 10, 11, 6, 0); // 7 hours physical span

      // Two sources reporting identical stages
      final stageRecords = [
        RawHealthRecord(
          id: 1,
          recordType: 'SLEEP_DEEP',
          value: 90.0,
          unit: 'MINUTES',
          startTime: start.add(const Duration(minutes: 30)),
          endTime: start.add(const Duration(minutes: 120)),
          sourceId: 'com.nothing.healt',
          syncedAt: DateTime.now(),
        ),
        RawHealthRecord(
          id: 2,
          recordType: 'SLEEP_DEEP',
          value: 90.0,
          unit: 'MINUTES',
          startTime: start.add(const Duration(minutes: 30)),
          endTime: start.add(const Duration(minutes: 120)),
          sourceId: 'com.google.android.apps.fitness', // Duplicate!
          syncedAt: DateTime.now(),
        ),
        RawHealthRecord(
          id: 3,
          recordType: 'SLEEP_LIGHT',
          value: 210.0,
          unit: 'MINUTES',
          startTime: start.add(const Duration(minutes: 120)),
          endTime: start.add(const Duration(minutes: 330)),
          sourceId: 'com.nothing.healt',
          syncedAt: DateTime.now(),
        ),
        RawHealthRecord(
          id: 4,
          recordType: 'SLEEP_REM',
          value: 90.0,
          unit: 'MINUTES',
          startTime: start.add(const Duration(minutes: 330)),
          endTime: end,
          sourceId: 'com.nothing.healt',
          syncedAt: DateTime.now(),
        ),
      ];

      final clean = SleepDataSanitizer.sanitizeOvernightStages(
        stageRecords: stageRecords,
      );

      // Deep sleep should be 90 min, NOT 180 min
      expect(clean.deepMinutes, 90);
      expect(clean.coreMinutes, 210);
      expect(clean.remMinutes, 90);
      expect(clean.totalAsleepMinutes, 390); // 6.5 hours
      expect(clean.totalHours, 6.5);
    });

    test('6. Distributed sleep correctly isolates night sleep and today afternoon nap', () {
      final nightStart = DateTime(2026, 10, 10, 23, 0);
      final nightEnd = DateTime(2026, 10, 11, 6, 30); // 7.5h
      final napStart = DateTime(2026, 10, 11, 14, 0);
      final napEnd = DateTime(2026, 10, 11, 14, 45); // 45m

      final sessions = [
        RawHealthRecord(
          id: 1,
          recordType: 'SLEEP_SESSION',
          value: 450.0,
          unit: 'MINUTES',
          startTime: nightStart,
          endTime: nightEnd,
          sourceId: 'com.nothing.healt',
          syncedAt: DateTime.now(),
        ),
        RawHealthRecord(
          id: 2,
          recordType: 'SLEEP_SESSION',
          value: 45.0,
          unit: 'MINUTES',
          startTime: napStart,
          endTime: napEnd,
          sourceId: 'com.nothing.healt',
          syncedAt: DateTime.now(),
        ),
      ];

      final distributed = SleepDataSanitizer.extractDistributedSessions(
        stageRecords: [],
        sessionRecords: sessions,
      );

      expect(distributed.sessions.length, 2);
      expect(distributed.totalMinutes, 495);
      expect(distributed.totalHours, 8.25);
      expect(distributed.nightHours, 7.5);
      expect(distributed.napHours, 0.75);

      final main = distributed.sessions.firstWhere((s) => s.isMainSleep);
      expect(main.title, 'Night Sleep');
      expect(main.durationMinutes, 450);

      final nap = distributed.sessions.firstWhere((s) => !s.isMainSleep);
      expect(nap.title, 'Afternoon Nap');
      expect(nap.durationMinutes, 45);
    });
  });
}
