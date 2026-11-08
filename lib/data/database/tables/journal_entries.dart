import 'package:drift/drift.dart';

/// Daily behavior tags logged by user (alcohol, caffeine, travel, illness, late meal, etc.).
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  DateTimeColumn get date => dateTime()(); // Associated calendar day
  DateTimeColumn get timestamp => dateTime()(); // Actual time tag was logged
  IntColumn get timeZoneOffsetMinutes =>
      integer().withDefault(const Constant(0))();
  TextColumn get tag =>
      text()(); // 'alcohol', 'caffeine', 'late_meal', 'travel', 'high_stress', etc.
  TextColumn get value => text().nullable()(); // '2 drinks', 'after 4pm', etc.
  TextColumn get notes => text().nullable()();
}

