// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkoutSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  WorkoutSessionDaoManager get managers => WorkoutSessionDaoManager(this);
}

class WorkoutSessionDaoManager {
  final _$WorkoutSessionDaoMixin _db;
  WorkoutSessionDaoManager(this._db);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
}
