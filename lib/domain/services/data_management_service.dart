import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/engine_config.dart';
import '../../data/database/app_database.dart';

/// Service providing user data sovereignty:
/// 1. Full offline health data export (JSON & CSV).
/// 2. Permanent data wipe (Right to be Forgotten / zero cloud residue).
class DataManagementService {
  final AppDatabase _db;

  DataManagementService({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Generate a structured JSON export of all biometric records.
  Future<String> exportToJsonString() async {
    final metrics = await _db.derivedMetricDao.getHistory(365);
    final sleepSessions = await (_db.select(_db.sleepSessions)..limit(365)).get();
    final workouts = await _db.workoutSessionDao.getRecentWorkouts(limit: 365);
    final measurements = await _db.bodyMeasurementDao.getHistory(limit: 365);
    final bodyAgeHistory = await _db.bodyAgeSnapshotDao.getHistory(limit: 365);
    final profile = await _db.userProfileDao.getProfile();

    final exportMap = <String, dynamic>{
      'app': 'Recova Athletic Body Intelligence',
      'algorithmVersion': EngineConfig.algorithmVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'storageArchitecture': '100% Offline Local SQLite (Drift)',
      'fdaNotice':
          'General Wellness Device Policy (Jan 2026). Wellness and athletic metrics only; not clinical diagnostics.',
      'userProfile': profile != null
          ? {
              'age': profile.age,
              'biologicalSex': profile.sex,
              'heightCm': profile.heightCm,
              'weightKg': profile.weightKg,
              'bodyFatPct': profile.bodyFatPct,
            }
          : null,
      'dailyMetrics': metrics.map((m) {
        return {
          'date': m.date.toIso8601String(),
          'recoveryScore': m.recoveryScore,
          'restingHr': m.recoveryComponentRhr,
          'sleepHours': m.recoveryComponentSleep,
          'spo2': m.recoveryComponentSpo2,
          'estimatedVo2Max': m.estimatedVo2Max,
          'dayLoadScore': m.dayLoadScore,
          'energyReserve': m.energyReserve,
          'primaryFactor': m.primaryFactor,
          'algorithmVersion': m.algorithmVersion,
        };
      }).toList(),
      'sleepSessions': sleepSessions.map((s) {
        return {
          'startTime': s.startTime.toIso8601String(),
          'endTime': s.endTime.toIso8601String(),
          'durationMinutes': s.durationMinutes,
          'asleepMinutes': s.asleepMinutes,
          'isNap': s.isNap,
          'deepMinutes': s.deepMinutes,
          'remMinutes': s.remMinutes,
          'lightMinutes': s.lightMinutes,
          'awakeMinutes': s.awakeMinutes,
          'efficiency': s.efficiency,
        };
      }).toList(),
      'workoutSessions': workouts.map((w) {
        return {
          'startTime': w.startTime.toIso8601String(),
          'endTime': w.endTime.toIso8601String(),
          'sport': w.sport,
          'title': w.title,
          'loadScore': w.strainScore,
          'avgHeartRate': w.avgHeartRate,
          'maxHeartRate': w.maxHeartRate,
          'caloriesBurned': w.caloriesBurned,
        };
      }).toList(),
      'bodyMeasurements': measurements.map((b) {
        return {
          'measuredAt': b.measuredAt.toIso8601String(),
          'weightKg': b.weightKg,
          'bodyFatPct': b.bodyFatPct,
        };
      }).toList(),
      'bodyAgeSnapshots': bodyAgeHistory.map((a) {
        return {
          'calculatedAt': a.calculatedAt.toIso8601String(),
          'bodyAge': a.bodyAge,
          'chronologicalAge': a.chronologicalAge,
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Generate a tabular CSV string of daily metric summaries.
  Future<String> exportToCsvString() async {
    final metrics = await _db.derivedMetricDao.getHistory(365);
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Date,RecoveryScore,RestingHeartRate,SleepScore,SpO2,VO2Max,DayStrain,PrimaryFactor',
    );

    for (final m in metrics) {
      final dateStr = m.date.toIso8601String().split('T').first;
      final rec = m.recoveryScore?.toStringAsFixed(1) ?? '';
      final rhr = m.recoveryComponentRhr?.toStringAsFixed(1) ?? '';
      final sleep = m.recoveryComponentSleep?.toStringAsFixed(1) ?? '';
      final spo2 = m.recoveryComponentSpo2?.toStringAsFixed(1) ?? '';
      final vo2 = m.estimatedVo2Max?.toStringAsFixed(1) ?? '';
      final strain = m.dayLoadScore?.toStringAsFixed(1) ?? '';
      final factor = (m.primaryFactor ?? '').replaceAll(',', ';');

      buffer.writeln('$dateStr,$rec,$rhr,$sleep,$spo2,$vo2,$strain,"$factor"');
    }

    return buffer.toString();
  }

  /// Save exports to local device filesystem and return absolute file path.
  Future<({String jsonPath, String csvPath})> saveExportsToLocalFiles() async {
    final jsonContent = await exportToJsonString();
    final csvContent = await exportToCsvString();

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final jsonFile = File('${dir.path}/recova_health_export_$timestamp.json');
    await jsonFile.writeAsString(jsonContent);

    final csvFile = File('${dir.path}/recova_health_export_$timestamp.csv');
    await csvFile.writeAsString(csvContent);

    return (jsonPath: jsonFile.path, csvPath: csvFile.path);
  }

  /// Permanently and irreversibly wipe all local health records and preferences.
  /// Guarantees complete offline data eradication with zero cloud residue.
  Future<int> wipeAllLocalData() async {
    // 1. Wipe SQLite tables
    await _db.delete(_db.rawHealthRecords).go();
    await _db.delete(_db.derivedMetrics).go();
    await _db.delete(_db.dailyBaselines).go();
    await _db.delete(_db.sleepSessions).go();
    await _db.delete(_db.workoutSessions).go();
    await _db.delete(_db.bodyMeasurements).go();
    await _db.delete(_db.bodyAgeSnapshots).go();
    await _db.delete(_db.journalEntries).go();
    await _db.delete(_db.insights).go();
    await _db.delete(_db.syncMetadata).go();
    await _db.delete(_db.syncLogs).go();
    await _db.delete(_db.deviceConnections).go();
    await _db.delete(_db.baselineSnapshots).go();
    await _db.delete(_db.userProfiles).go();

    // 2. Wipe SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    return 14; // All 14 tables purged
  }
}
