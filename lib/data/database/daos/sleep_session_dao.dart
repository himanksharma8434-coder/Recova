import 'package:drift/drift.dart';

import '../tables/sleep_sessions.dart';
import '../app_database.dart';

part 'sleep_session_dao.g.dart';

@DriftAccessor(tables: [SleepSessions])
class SleepSessionDao extends DatabaseAccessor<AppDatabase>
    with _$SleepSessionDaoMixin {
  SleepSessionDao(super.db);

  /// Upsert a single sleep session.
  Future<void> upsertSession(SleepSessionsCompanion session) async {
    await into(sleepSessions).insert(
      session,
      onConflict: DoUpdate(
        (_) => session,
        target: [sleepSessions.userId, sleepSessions.startTime],
      ),
    );
  }

  /// Bulk upsert sleep sessions.
  Future<void> upsertSessions(List<SleepSessionsCompanion> sessions) async {
    await batch((b) {
      for (final s in sessions) {
        b.insert(
          sleepSessions,
          s,
          onConflict: DoUpdate(
            (_) => s,
            target: [sleepSessions.userId, sleepSessions.startTime],
          ),
        );
      }
    });
  }

  /// Fetch sleep sessions within a given time interval.
  Future<List<SleepSession>> getSessionsForWindow({
    required DateTime start,
    required DateTime end,
  }) {
    return (select(sleepSessions)
          ..where((s) => s.startTime.isBiggerOrEqualValue(start))
          ..where((s) => s.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(s) => OrderingTerm.asc(s.startTime)]))
        .get();
  }

  /// Get the most recent main night sleep session.
  Future<SleepSession?> getLatestNightSleep() {
    return (select(sleepSessions)
          ..where((s) => s.isNap.equals(false))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch latest main night sleep session.
  Stream<SleepSession?> watchLatestNightSleep() {
    return (select(sleepSessions)
          ..where((s) => s.isNap.equals(false))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
