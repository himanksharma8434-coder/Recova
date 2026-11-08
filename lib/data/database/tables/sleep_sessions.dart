import 'package:drift/drift.dart';

/// Consolidated, deduplicated sleep sessions (night sleep and daytime/evening naps).
class SleepSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get timeZoneOffsetMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get durationMinutes => integer()();
  IntColumn get asleepMinutes => integer()();
  IntColumn get deepMinutes => integer().nullable()();
  IntColumn get lightMinutes => integer().nullable()();
  IntColumn get remMinutes => integer().nullable()();
  IntColumn get awakeMinutes => integer().nullable()();
  RealColumn get efficiency => real().nullable()(); // 0–100%
  IntColumn get disturbancesCount => integer().nullable()();
  RealColumn get respiratoryRate => real().nullable()();
  RealColumn get restingHeartRate => real().nullable()();
  RealColumn get hrvRmssd => real().nullable()();
  RealColumn get spo2Average => real().nullable()();
  RealColumn get spo2Min => real().nullable()();
  RealColumn get skinTempDeviation => real().nullable()();
  BoolColumn get isNap => boolean().withDefault(const Constant(false))();
  TextColumn get sourceDevice => text().nullable()();
  TextColumn get calculationMethod =>
      text().withDefault(const Constant('sensor'))(); // 'sensor' | 'estimated'
  TextColumn get qualityFlag =>
      text().withDefault(const Constant('good'))(); // 'good' | 'low_signal'
  DateTimeColumn get syncedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, startTime}
      ];
}

