// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_session_dao.dart';

// ignore_for_file: type=lint
mixin _$SleepSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SleepSessionsTable get sleepSessions => attachedDatabase.sleepSessions;
  SleepSessionDaoManager get managers => SleepSessionDaoManager(this);
}

class SleepSessionDaoManager {
  final _$SleepSessionDaoMixin _db;
  SleepSessionDaoManager(this._db);
  $$SleepSessionsTableTableManager get sleepSessions =>
      $$SleepSessionsTableTableManager(_db.attachedDatabase, _db.sleepSessions);
}
