import 'package:drift/drift.dart';

import '../../../../data/database/app_database.dart';
import '../../domain/repositories/body_measurement_repository.dart';

/// Concrete implementation of [BodyMeasurementRepository] backed by Drift.
class BodyMeasurementRepositoryImpl implements BodyMeasurementRepository {
  final AppDatabase _db;

  BodyMeasurementRepositoryImpl([AppDatabase? db])
      : _db = db ?? AppDatabase.instance;

  @override
  Future<void> saveMeasurement({
    required double weightKg,
    double? bodyFatPct,
    String source = 'manual',
    DateTime? measuredAt,
  }) async {
    final entryTime = measuredAt ?? DateTime.now();
    await _db.bodyMeasurementDao.insertMeasurement(
      BodyMeasurementsCompanion.insert(
        userId: const Value('local_user'),
        measuredAt: entryTime,
        weightKg: weightKg,
        bodyFatPct: Value(bodyFatPct),
        source: Value(source),
        synced: const Value(false),
      ),
    );
  }

  @override
  Future<BodyMeasurementEntry?> getLatestMeasurement() async {
    final row = await _db.bodyMeasurementDao.getLatestMeasurement();
    if (row == null) return null;
    return _mapRowToEntry(row);
  }

  @override
  Future<List<BodyMeasurementEntry>> getMeasurementHistory({int limit = 12}) async {
    final rows = await _db.bodyMeasurementDao.getHistory(limit: limit);
    return rows.map(_mapRowToEntry).toList();
  }

  @override
  Future<bool> hasElapsedDaysSinceLastMeasurement(int days) async {
    return _db.bodyMeasurementDao.hasElapsedDaysSinceLast(days);
  }

  BodyMeasurementEntry _mapRowToEntry(BodyMeasurement row) {
    return BodyMeasurementEntry(
      id: row.id,
      userId: row.userId,
      measuredAt: row.measuredAt,
      weightKg: row.weightKg,
      bodyFatPct: row.bodyFatPct,
      source: row.source,
      synced: row.synced,
    );
  }
}
