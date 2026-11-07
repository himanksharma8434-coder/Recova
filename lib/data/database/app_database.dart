import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/raw_health_records.dart';
import 'tables/daily_baselines.dart';
import 'tables/derived_metrics.dart';
import 'tables/sync_metadata.dart';
import 'tables/sync_logs.dart';
import 'tables/body_measurements.dart';
import 'tables/body_age_snapshots.dart';
import 'tables/user_profiles.dart';
import 'tables/sleep_sessions.dart';
import 'tables/workout_sessions.dart';
import 'tables/baseline_snapshots.dart';
import 'tables/journal_entries.dart';
import 'tables/insights.dart';
import 'tables/device_connections.dart';

import 'daos/health_record_dao.dart';
import 'daos/baseline_dao.dart';
import 'daos/derived_metric_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/body_measurement_dao.dart';
import 'daos/body_age_snapshot_dao.dart';
import 'daos/user_profile_dao.dart';
import 'daos/sleep_session_dao.dart';
import 'daos/workout_session_dao.dart';
import 'daos/baseline_snapshot_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/insight_dao.dart';
import 'daos/device_connection_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RawHealthRecords,
    DailyBaselines,
    DerivedMetrics,
    SyncMetadata,
    SyncLogs,
    BodyMeasurements,
    BodyAgeSnapshots,
    UserProfiles,
    SleepSessions,
    WorkoutSessions,
    BaselineSnapshots,
    JournalEntries,
    Insights,
    DeviceConnections,
  ],
  daos: [
    HealthRecordDao,
    BaselineDao,
    DerivedMetricDao,
    SyncDao,
    BodyMeasurementDao,
    BodyAgeSnapshotDao,
    UserProfileDao,
    SleepSessionDao,
    WorkoutSessionDao,
    BaselineSnapshotDao,
    JournalDao,
    InsightDao,
    DeviceConnectionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(driftDatabase(name: 'recova_health'));

  /// Test constructor for in-memory testing.
  AppDatabase.forTesting(super.e);

  static AppDatabase? _instance;

  /// Singleton accessor. Use this everywhere.
  static AppDatabase get instance => _instance ??= AppDatabase._();

  /// For testing: replace the singleton with a custom instance.
  static set instance(AppDatabase db) => _instance = db;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(bodyMeasurements);
            await m.createTable(bodyAgeSnapshots);
          }
          if (from < 3) {
            // Target spec domain tables
            await m.createTable(userProfiles);
            await m.createTable(sleepSessions);
            await m.createTable(workoutSessions);
            await m.createTable(baselineSnapshots);
            await m.createTable(journalEntries);
            await m.createTable(insights);
            await m.createTable(deviceConnections);

            // Add new columns to raw_health_records
            await m.addColumn(rawHealthRecords, rawHealthRecords.qualityFlag);
            await m.addColumn(
                rawHealthRecords, rawHealthRecords.timeZoneOffsetMinutes);

            // Add new columns to derived_metrics
            await m.addColumn(
                derivedMetrics, derivedMetrics.readinessConfidence);
            await m.addColumn(derivedMetrics, derivedMetrics.dataQuality);
            await m.addColumn(
                derivedMetrics, derivedMetrics.algorithmVersion);
            await m.addColumn(derivedMetrics, derivedMetrics.dayLoadScore);
            await m.addColumn(derivedMetrics, derivedMetrics.sleepScore);
            await m.addColumn(derivedMetrics, derivedMetrics.energyReserve);
            await m.addColumn(derivedMetrics, derivedMetrics.daytimeStress);
            await m.addColumn(derivedMetrics, derivedMetrics.topDriversJson);
            await m.addColumn(
                derivedMetrics, derivedMetrics.calculationBreakdownJson);
            await m.addColumn(
                derivedMetrics, derivedMetrics.timeZoneOffsetMinutes);
          }
        },
        beforeOpen: (details) async {
          try {
            await customStatement('PRAGMA journal_mode = WAL;');
            await customStatement('PRAGMA synchronous = NORMAL;');
          } catch (_) {}
          try {
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_raw_records_type_start ON raw_health_records (record_type, start_time);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_raw_records_type_end ON raw_health_records (record_type, end_time);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_derived_metrics_date ON derived_metrics (date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_daily_baselines_date ON daily_baselines (date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_sync_metadata_type ON sync_metadata (record_type);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_sync_logs_timestamp ON sync_logs (timestamp);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_body_measurements_date ON body_measurements (measured_at);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_body_age_snapshots_date ON body_age_snapshots (calculated_at);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_user_profiles_user ON user_profiles (user_id);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_start ON sleep_sessions (start_time);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start ON workout_sessions (start_time);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_baseline_snapshots_date ON baseline_snapshots (date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_journal_entries_date ON journal_entries (date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_insights_date ON insights (date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_device_connections_id ON device_connections (device_id);');
          } catch (_) {}
        },
      );
}
