import 'package:drift/drift.dart';

import '../tables/workout_sessions.dart';
import '../app_database.dart';

part 'workout_session_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions])
class WorkoutSessionDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutSessionDaoMixin {
  WorkoutSessionDao(super.db);

  /// Upsert a single workout session.
  Future<void> upsertWorkout(WorkoutSessionsCompanion workout) async {
    await into(workoutSessions).insert(
      workout,
      onConflict: DoUpdate(
        (_) => workout,
        target: [workoutSessions.userId, workoutSessions.startTime],
      ),
    );
  }

  /// Bulk upsert workout sessions.
  Future<void> upsertWorkouts(List<WorkoutSessionsCompanion> workouts) async {
    await batch((b) {
      for (final w in workouts) {
        b.insert(
          workoutSessions,
          w,
          onConflict: DoUpdate(
            (_) => w,
            target: [workoutSessions.userId, workoutSessions.startTime],
          ),
        );
      }
    });
  }

  /// Fetch workouts for a specific interval.
  Future<List<WorkoutSession>> getWorkoutsForWindow({
    required DateTime start,
    required DateTime end,
  }) {
    return (select(workoutSessions)
          ..where((w) => w.startTime.isBiggerOrEqualValue(start))
          ..where((w) => w.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(w) => OrderingTerm.asc(w.startTime)]))
        .get();
  }

  /// Get the most recent workouts up to [limit].
  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 10}) {
    return (select(workoutSessions)
          ..orderBy([(w) => OrderingTerm.desc(w.startTime)])
          ..limit(limit))
        .get();
  }

  /// Watch workouts occurring today.
  Stream<List<WorkoutSession>> watchWorkoutsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return (select(workoutSessions)
          ..where((w) => w.startTime.isBiggerOrEqualValue(start))
          ..where((w) => w.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(w) => OrderingTerm.desc(w.startTime)]))
        .watch();
  }
}
