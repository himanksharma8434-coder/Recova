import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../../domain/entities/daily_metric_point.dart';
import '../../../../services/user_profile_service.dart';
import '../../domain/entities/body_age_result.dart';
import '../../domain/repositories/body_age_repository.dart';
import '../../domain/usecases/compute_body_age_usecase.dart';

/// Concrete implementation of [BodyAgeRepository] backed by Drift.
class BodyAgeRepositoryImpl implements BodyAgeRepository {
  final AppDatabase _db;
  final ComputeFitnessBodyAgeUseCase _computeUseCase;

  BodyAgeRepositoryImpl({
    AppDatabase? db,
    ComputeFitnessBodyAgeUseCase? computeUseCase,
  })  : _db = db ?? AppDatabase.instance,
        _computeUseCase = computeUseCase ?? const ComputeFitnessBodyAgeUseCase();

  @override
  Future<void> saveSnapshot(FitnessBodyAgeResult result) async {
    await _db.bodyAgeSnapshotDao.insertSnapshot(
      BodyAgeSnapshotsCompanion.insert(
        userId: const Value('local_user'),
        calculatedAt: result.calculatedAt,
        bodyAge: result.bodyAge,
        chronologicalAge: result.chronologicalAge,
        factorAgesJson: jsonEncode(result.toJson()),
        synced: const Value(false),
      ),
    );
  }

  @override
  Future<FitnessBodyAgeResult?> getLatestSnapshot() async {
    final row = await _db.bodyAgeSnapshotDao.getLatestSnapshot();
    if (row == null) return null;
    return _mapRowToResult(row);
  }

  @override
  Future<List<FitnessBodyAgeResult>> getSnapshotHistory({int limit = 12}) async {
    final rows = await _db.bodyAgeSnapshotDao.getHistory(limit: limit);
    return rows.map(_mapRowToResult).toList();
  }

  @override
  Future<FitnessBodyAgeResult?> calculateCurrentBodyAge() async {
    final now = DateTime.now();
    final profile = await UserProfileService.getProfile();

    if (profile.age == null || profile.age! < 18) {
      return null;
    }

    final start7d = AppDateUtils.daysAgo(7, from: now);

    // Parallelize all DB reads for 60/120 FPS speed
    final results = await Future.wait([
      _db.bodyMeasurementDao.getLatestMeasurement(), // 0
      _db.healthRecordDao.getDailyRestingHeartRates(30), // 1
      _db.derivedMetricDao.getLatestMetric(), // 2
      _db.healthRecordDao.getWorkouts(start: start7d, end: now), // 3
    ]);

    final latestMeasurement = results[0] as BodyMeasurement?;
    final rhrPoints = results[1] as List<DailyMetricPoint>;
    final derivedMetric = results[2] as DerivedMetric?;
    final workouts7d = results[3] as List<RawHealthRecord>;

    // 1. Weight & Body Fat
    final weightKg = latestMeasurement?.weightKg ?? profile.weightKg;
    final bodyFatPct = latestMeasurement?.bodyFatPct ?? profile.bodyFatPct;

    // 2. Resting Heart Rate 30d average
    double? rhr30d;
    DateTime? rhrDate;
    if (rhrPoints.isNotEmpty) {
      rhr30d = rhrPoints.map((p) => p.value).reduce((a, b) => a + b) / rhrPoints.length;
      rhrDate = rhrPoints.last.date;
    }

    // 3. VO2 Max
    final vo2max = derivedMetric?.estimatedVo2Max;
    final vo2Date = derivedMetric?.date;

    // 4. Vigorous Activity from workouts
    int vigorousMins = 0;
    final workoutDaysSet = <String>{};
    for (final w in workouts7d) {
      vigorousMins += w.value.toInt();
      workoutDaysSet.add('${w.startTime.year}-${w.startTime.month}-${w.startTime.day}');
    }

    try {
      final result = _computeUseCase.call(ComputeFitnessBodyAgeParams(
        chronologicalAge: profile.age!,
        sex: profile.gender,
        heightCm: profile.heightCm,
        weightKg: weightKg,
        bodyFatPct: bodyFatPct,
        vo2max: vo2max,
        vo2maxRecordedAt: vo2Date,
        restingHr30d: rhr30d,
        restingHrRecordedAt: rhrDate,
        vigorousMinutesPerWeek: workouts7d.isNotEmpty ? vigorousMins : null,
        vigorousDaysPerWeek: workouts7d.isNotEmpty ? workoutDaysSet.length : null,
        referenceDate: now,
      ));

      // Persist snapshot in background
      await saveSnapshot(result);
      return result;
    } on InsufficientDataException {
      return null;
    } on UnderAgeException {
      return null;
    }
  }

  FitnessBodyAgeResult _mapRowToResult(BodyAgeSnapshot row) {
    try {
      final json = jsonDecode(row.factorAgesJson) as Map<String, dynamic>;
      return FitnessBodyAgeResult.fromJson(json);
    } catch (_) {
      return FitnessBodyAgeResult(
        bodyAge: row.bodyAge,
        chronologicalAge: row.chronologicalAge,
        difference: double.parse((row.bodyAge - row.chronologicalAge).toStringAsFixed(1)),
        factorAges: const {},
        topImprovements: const [],
        missingFactors: const [],
        calculatedAt: row.calculatedAt,
      );
    }
  }
}
