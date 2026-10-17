import 'package:drift/drift.dart';

/// Stores user body measurements (weight and body fat percentage)
/// entered monthly or imported from health services.
class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get bodyFatPct => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
