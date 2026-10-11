/// Entity representing a physical body measurement entry.
class BodyMeasurementEntry {
  final int id;
  final String userId;
  final DateTime measuredAt;
  final double weightKg;
  final double? bodyFatPct;
  final String source; // 'manual' | 'imported'
  final bool synced;

  const BodyMeasurementEntry({
    required this.id,
    required this.userId,
    required this.measuredAt,
    required this.weightKg,
    this.bodyFatPct,
    required this.source,
    required this.synced,
  });
}

/// Abstract contract for reading and storing monthly body measurements.
abstract class BodyMeasurementRepository {
  /// Save a new body measurement entry.
  Future<void> saveMeasurement({
    required double weightKg,
    double? bodyFatPct,
    String source = 'manual',
    DateTime? measuredAt,
  });

  /// Retrieve the latest body measurement, if available.
  Future<BodyMeasurementEntry?> getLatestMeasurement();

  /// Retrieve full historical measurements sorted by date descending.
  Future<List<BodyMeasurementEntry>> getMeasurementHistory({int limit = 12});

  /// Check whether at least [days] have passed since the last measurement.
  Future<bool> hasElapsedDaysSinceLastMeasurement(int days);
}
