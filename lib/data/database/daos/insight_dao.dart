import 'package:drift/drift.dart';

import '../tables/insights.dart';
import '../app_database.dart';

part 'insight_dao.g.dart';

@DriftAccessor(tables: [Insights])
class InsightDao extends DatabaseAccessor<AppDatabase>
    with _$InsightDaoMixin {
  InsightDao(super.db);

  /// Add a generated insight.
  Future<int> insertInsight(InsightsCompanion insight) {
    return into(insights).insert(insight);
  }

  /// Get insights for a specific calendar date.
  Future<List<Insight>> getInsightsForDate(DateTime date) {
    final start = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
    final end = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(insights)
          ..where((i) => i.date.isBiggerOrEqualValue(start))
          ..where((i) => i.date.isSmallerOrEqualValue(end))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
        .get();
  }

  /// Watch latest insights.
  Stream<List<Insight>> watchRecentInsights({int limit = 5}) {
    return (select(insights)
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Mark insight as read.
  Future<void> markAsRead(int id) async {
    await (update(insights)..where((i) => i.id.equals(id))).write(
      const InsightsCompanion(isRead: Value(true)),
    );
  }
}
