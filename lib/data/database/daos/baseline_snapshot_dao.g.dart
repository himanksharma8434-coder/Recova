// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baseline_snapshot_dao.dart';

// ignore_for_file: type=lint
mixin _$BaselineSnapshotDaoMixin on DatabaseAccessor<AppDatabase> {
  $BaselineSnapshotsTable get baselineSnapshots =>
      attachedDatabase.baselineSnapshots;
  BaselineSnapshotDaoManager get managers => BaselineSnapshotDaoManager(this);
}

class BaselineSnapshotDaoManager {
  final _$BaselineSnapshotDaoMixin _db;
  BaselineSnapshotDaoManager(this._db);
  $$BaselineSnapshotsTableTableManager get baselineSnapshots =>
      $$BaselineSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.baselineSnapshots,
      );
}
