import 'package:drift/drift.dart';

/// Stores user demographic profile, physical baselines, and preferences.
/// Replaces unencrypted SharedPreferences storage with structured SQLite persistence.
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  IntColumn get age => integer().nullable()();
  TextColumn get sex => text().nullable()(); // 'male', 'female', 'other'
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get maxHr => real().nullable()();
  RealColumn get restingHrBaseline => real().nullable()();
  IntColumn get sleepNeedBaselineMinutes =>
      integer().withDefault(const Constant(480))();
  RealColumn get targetStrain => real().nullable()();
  TextColumn get units =>
      text().withDefault(const Constant('metric'))(); // 'metric' | 'imperial'
  TextColumn get timeZone => text().withDefault(const Constant('UTC'))();
  IntColumn get timeZoneOffsetMinutes =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId}
      ];
}

