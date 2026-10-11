// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_age_snapshot_dao.dart';

// ignore_for_file: type=lint
mixin _$BodyAgeSnapshotDaoMixin on DatabaseAccessor<AppDatabase> {
  $BodyAgeSnapshotsTable get bodyAgeSnapshots =>
      attachedDatabase.bodyAgeSnapshots;
  BodyAgeSnapshotDaoManager get managers => BodyAgeSnapshotDaoManager(this);
}

class BodyAgeSnapshotDaoManager {
  final _$BodyAgeSnapshotDaoMixin _db;
  BodyAgeSnapshotDaoManager(this._db);
  $$BodyAgeSnapshotsTableTableManager get bodyAgeSnapshots =>
      $$BodyAgeSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.bodyAgeSnapshots,
      );
}
