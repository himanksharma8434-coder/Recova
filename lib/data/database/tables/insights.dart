import 'package:drift/drift.dart';

/// Explainable, rule-based daily physiological insights grounded in computed metrics.
class Insights extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category =>
      text()(); // 'readiness', 'sleep', 'load', 'health', 'trend'
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get actionableNudge => text().nullable()();
  TextColumn get metricReferencesJson =>
      text()(); // JSON list of cited metric keys
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

