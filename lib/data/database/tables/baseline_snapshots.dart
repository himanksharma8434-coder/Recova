import 'package:drift/drift.dart';

/// Immutable daily snapshots of personal rolling baselines (7d, 30d, 60d).
/// Guarantees that historical readiness and trend calculations are 100% reproducible.
class BaselineSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // Start of day, unique
  IntColumn get timeZoneOffsetMinutes =>
      integer().withDefault(const Constant(0))();

  // Natural-log transformed HRV (ln RMSSD)
  RealColumn get hrvBaseline7d => real().nullable()(); // 7-day rolling mean of ln(RMSSD)
  RealColumn get hrvBaseline60dMean => real().nullable()(); // 60-day mean of ln(RMSSD)
  RealColumn get hrvBaseline60dSd => real().nullable()(); // 60-day standard deviation
  RealColumn get hrvCv7d => real().nullable()(); // 7-day coefficient of variation (stability)
  RealColumn get rawHrvBaseline7dMs => real().nullable()(); // Raw millisecond value

  // Resting Heart Rate
  RealColumn get rhrBaseline7d => real().nullable()();
  RealColumn get rhrBaseline30d => real().nullable()();
  RealColumn get rhrBaseline60dMean => real().nullable()();
  RealColumn get rhrBaseline60dSd => real().nullable()();

  // Sleep & Respiratory
  RealColumn get sleepDurationBaseline7d => real().nullable()(); // minutes
  RealColumn get sleepDurationBaseline60d => real().nullable()();
  RealColumn get respiratoryRateBaseline7d => real().nullable()();
  RealColumn get respiratoryRateBaseline60d => real().nullable()();
  RealColumn get spo2Baseline7d => real().nullable()();
  RealColumn get skinTempBaseline30d => real().nullable()();

  IntColumn get totalRecordedNights =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get calculatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date}
      ];
}

