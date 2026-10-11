import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/body_age_snapshots.dart';

part 'body_age_snapshot_dao.g.dart';

@DriftAccessor(tables: [BodyAgeSnapshots])
class BodyAgeSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$BodyAgeSnapshotDaoMixin {
  BodyAgeSnapshotDao(super.db);

  /// Insert a new calculated snapshot.
  Future<int> insertSnapshot(BodyAgeSnapshotsCompanion snapshot) =>
      into(bodyAgeSnapshots).insert(snapshot);

  /// Fetch the latest body age snapshot.
  Future<BodyAgeSnapshot?> getLatestSnapshot() {
    return (select(bodyAgeSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.calculatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch the latest snapshot for reactive UI updates.
  Stream<BodyAgeSnapshot?> watchLatestSnapshot() {
    return (select(bodyAgeSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.calculatedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Fetch historical snapshots sorted chronologically descending.
  Future<List<BodyAgeSnapshot>> getHistory({int limit = 12}) {
    return (select(bodyAgeSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.calculatedAt)])
          ..limit(limit))
        .get();
  }
}
