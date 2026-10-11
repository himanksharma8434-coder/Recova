import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/body_measurements.dart';

part 'body_measurement_dao.g.dart';

@DriftAccessor(tables: [BodyMeasurements])
class BodyMeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$BodyMeasurementDaoMixin {
  BodyMeasurementDao(super.db);

  /// Insert a new measurement entry.
  Future<int> insertMeasurement(BodyMeasurementsCompanion measurement) =>
      into(bodyMeasurements).insert(measurement);

  /// Fetch the single most recent measurement.
  Future<BodyMeasurement?> getLatestMeasurement() {
    return (select(bodyMeasurements)
          ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch the latest measurement reactively.
  Stream<BodyMeasurement?> watchLatestMeasurement() {
    return (select(bodyMeasurements)
          ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Fetch historical measurements sorted chronologically descending.
  Future<List<BodyMeasurement>> getHistory({int limit = 12}) {
    return (select(bodyMeasurements)
          ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)])
          ..limit(limit))
        .get();
  }

  /// Check whether at least [days] have passed since the last measurement.
  /// Returns true if no measurements exist at all.
  Future<bool> hasElapsedDaysSinceLast(int days) async {
    final latest = await getLatestMeasurement();
    if (latest == null) return true;
    final diff = DateTime.now().difference(latest.measuredAt).inDays;
    return diff >= days;
  }
}
