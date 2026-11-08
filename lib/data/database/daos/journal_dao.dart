import 'package:drift/drift.dart';

import '../tables/journal_entries.dart';
import '../app_database.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase>
    with _$JournalDaoMixin {
  JournalDao(super.db);

  /// Add a behavior journal entry.
  Future<int> insertEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insert(entry);
  }

  /// Delete a behavior journal entry by id.
  Future<int> deleteEntry(int id) {
    return (delete(journalEntries)..where((e) => e.id.equals(id))).go();
  }

  /// Get all entries logged for a specific calendar date.
  Future<List<JournalEntry>> getEntriesForDay(DateTime date) {
    final start = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
    final end = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(journalEntries)
          ..where((e) => e.date.isBiggerOrEqualValue(start))
          ..where((e) => e.date.isSmallerOrEqualValue(end))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .get();
  }

  /// Watch entries for a specific calendar date.
  Stream<List<JournalEntry>> watchEntriesForDay(DateTime date) {
    final start = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
    final end = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(journalEntries)
          ..where((e) => e.date.isBiggerOrEqualValue(start))
          ..where((e) => e.date.isSmallerOrEqualValue(end))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .watch();
  }

  /// Get all occurrences of a specific behavior tag (e.g. 'alcohol') over the past [days] days.
  Future<List<JournalEntry>> getEntriesByTag({
    required String tag,
    int days = 60,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(journalEntries)
          ..where((e) => e.tag.equals(tag))
          ..where((e) => e.date.isBiggerOrEqualValue(cutoff))
          ..orderBy([(e) => OrderingTerm.asc(e.date)]))
        .get();
  }

  /// Get all journal entries within the past [days] days.
  Future<List<JournalEntry>> getRecentEntries({int days = 60}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(journalEntries)
          ..where((e) => e.date.isBiggerOrEqualValue(cutoff))
          ..orderBy([(e) => OrderingTerm.asc(e.date)]))
        .get();
  }

  /// Toggle a tag for a specific calendar date:
  /// If the tag is already logged for that date, deletes it; otherwise inserts it.
  Future<bool> toggleTag({
    required DateTime date,
    required String tag,
    String? value,
    String? notes,
  }) async {
    final start = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
    final end = date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day, 23, 59, 59);

    final existing = await (select(journalEntries)
          ..where((e) => e.date.isBiggerOrEqualValue(start))
          ..where((e) => e.date.isSmallerOrEqualValue(end))
          ..where((e) => e.tag.equals(tag)))
        .get();

    if (existing.isNotEmpty) {
      for (final e in existing) {
        await deleteEntry(e.id);
      }
      return false; // Removed
    } else {
      await insertEntry(JournalEntriesCompanion(
        date: Value(start),
        timestamp: Value(DateTime.now()),
        tag: Value(tag),
        value: Value(value),
        notes: Value(notes),
      ));
      return true; // Added
    }
  }
}
