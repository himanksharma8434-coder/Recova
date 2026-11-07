import 'package:drift/drift.dart';

/// Tracks discrete workouts, HR time-in-zones, and cardiovascular strain load.
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  TextColumn get sport => text()(); // 'running', 'cycling', 'strength', etc.
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get timeZoneOffsetMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get durationMinutes => integer()();
  RealColumn get avgHeartRate => real().nullable()();
  RealColumn get maxHeartRate => real().nullable()();
  RealColumn get caloriesBurned => real().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  RealColumn get elevationGainMeters => real().nullable()();
  // Time in 5 Karvonen Heart Rate Reserve Zones (minutes)
  IntColumn get zone1Minutes => integer().withDefault(const Constant(0))();
  IntColumn get zone2Minutes => integer().withDefault(const Constant(0))();
  IntColumn get zone3Minutes => integer().withDefault(const Constant(0))();
  IntColumn get zone4Minutes => integer().withDefault(const Constant(0))();
  IntColumn get zone5Minutes => integer().withDefault(const Constant(0))();
  RealColumn get strainScore =>
      real().withDefault(const Constant(0.0))(); // 0–21 TRIMP-based load
  RealColumn get recoveryCost => real().withDefault(const Constant(0.0))();
  TextColumn get sourceDevice => text().nullable()();
  TextColumn get qualityFlag =>
      text().withDefault(const Constant('good'))();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, startTime}
      ];
}

