import 'package:drift/drift.dart';

/// Stores every raw health record pulled from Health Connect / HealthKit.
/// Deduplication key: (recordType, sourceId, startTime).
class RawHealthRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordType => text()(); // e.g. "HEART_RATE", "SLEEP_SESSION"
  RealColumn get value => real()(); // primary numeric value
  RealColumn get valueSecondary =>
      real().nullable()(); // for types with two values
  TextColumn get unit => text()(); // e.g. "BEATS_PER_MINUTE", "PERCENTAGE"
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get sourceId => text()(); // device/app source identifier
  TextColumn get qualityFlag =>
      text().nullable()(); // 'good', 'low_signal', 'interpolated'
  IntColumn get timeZoneOffsetMinutes =>
      integer().nullable()();
  DateTimeColumn get syncedAt => dateTime()(); // when we pulled this record

  @override
  List<Set<Column>> get uniqueKeys => [
        {recordType, sourceId, startTime}
      ];
}
