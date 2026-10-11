import '../entities/body_age_result.dart';

/// Entity representing a persisted snapshot of fitness body age.
class BodyAgeSnapshotEntry {
  final int id;
  final String userId;
  final DateTime calculatedAt;
  final double bodyAge;
  final int chronologicalAge;
  final String factorAgesJson;
  final bool synced;

  const BodyAgeSnapshotEntry({
    required this.id,
    required this.userId,
    required this.calculatedAt,
    required this.bodyAge,
    required this.chronologicalAge,
    required this.factorAgesJson,
    required this.synced,
  });
}

/// Abstract contract for calculating and storing body age snapshots.
abstract class BodyAgeRepository {
  /// Save a calculated snapshot into local storage.
  Future<void> saveSnapshot(FitnessBodyAgeResult result);

  /// Fetch the latest calculated snapshot.
  Future<FitnessBodyAgeResult?> getLatestSnapshot();

  /// Fetch snapshot history for monthly trend graphs.
  Future<List<FitnessBodyAgeResult>> getSnapshotHistory({int limit = 12});

  /// Compute current functional fitness body age by aggregating wearable data & measurements.
  Future<FitnessBodyAgeResult?> calculateCurrentBodyAge();
}
