import 'package:drift/drift.dart';

import '../tables/baseline_snapshots.dart';
import '../app_database.dart';

part 'baseline_snapshot_dao.g.dart';

@DriftAccessor(tables: [BaselineSnapshots])
class BaselineSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$BaselineSnapshotDaoMixin {
  BaselineSnapshotDao(super.db);

  /// Upsert a daily baseline snapshot.
  Future<void> upsertSnapshot(BaselineSnapshotsCompanion snapshot) async {
    await into(baselineSnapshots).insert(
      snapshot,
      onConflict: DoUpdate(
        (_) => snapshot,
        target: [baselineSnapshots.date],
      ),
    );
  }

  /// Get baseline snapshot for a specific calendar date.
  Future<BaselineSnapshot?> getSnapshot(DateTime date) {
    final startOfDay = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
    return (select(baselineSnapshots)
          ..where((s) => s.date.equals(startOfDay)))
        .getSingleOrNull();
  }

  /// Get the most recent baseline snapshot.
  Future<BaselineSnapshot?> getLatestSnapshot() {
    return (select(baselineSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch latest snapshot.
  Stream<BaselineSnapshot?> watchLatestSnapshot() {
    return (select(baselineSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Get historical snapshots over the past [days] days.
  Future<List<BaselineSnapshot>> getHistory(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(baselineSnapshots)
          ..where((s) => s.date.isBiggerOrEqualValue(cutoff))
          ..orderBy([(s) => OrderingTerm.asc(s.date)]))
        .get();
  }
}
