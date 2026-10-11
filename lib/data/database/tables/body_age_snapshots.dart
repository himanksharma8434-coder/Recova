import 'package:drift/drift.dart';

/// Stores monthly snapshots of calculated functional body age.
class BodyAgeSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local_user'))();
  DateTimeColumn get calculatedAt => dateTime()();
  RealColumn get bodyAge => real()();
  IntColumn get chronologicalAge => integer()();
  TextColumn get factorAgesJson => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
