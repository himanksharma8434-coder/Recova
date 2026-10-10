import 'dart:math';

/// A data point in a workout stream for VO2 Max estimation.
class WorkoutDataPoint {
  final DateTime timestamp;
  final double heartRateBpm;
  final double speedMetersPerSec;

  const WorkoutDataPoint({
    required this.timestamp,
    required this.heartRateBpm,
    required this.speedMetersPerSec,
  });
}

/// Result of a single segment's VO2 Max estimation.
class SegmentVo2Result {
  final double estimatedVo2Max;
  final double averageHr;
  final double averageSpeed;

  const SegmentVo2Result({
    required this.estimatedVo2Max,
    required this.averageHr,
    required this.averageSpeed,
  });
}

/// The result of a VO2 Max estimation.
class Vo2MaxResult {
  final double estimatedVo2Max;
  final int segmentsUsed;
  final DateTime? date;
  final String? activityType;
  
  // Extra metadata
  final double? peakHr;
  final double? totalDistanceMeters;
  final double? userMaxHr;
  final double? userRestingHr;

  const Vo2MaxResult({
    required this.estimatedVo2Max,
    required this.segmentsUsed,
    this.date,
    this.activityType,
    this.peakHr,
    this.totalDistanceMeters,
    this.userMaxHr,
    this.userRestingHr,
  });

  Vo2MaxResult copyWith({
    double? estimatedVo2Max,
    int? segmentsUsed,
    DateTime? date,
    String? activityType,
    double? peakHr,
    double? totalDistanceMeters,
    double? userMaxHr,
    double? userRestingHr,
  }) {
    return Vo2MaxResult(
      estimatedVo2Max: estimatedVo2Max ?? this.estimatedVo2Max,
      segmentsUsed: segmentsUsed ?? this.segmentsUsed,
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      peakHr: peakHr ?? this.peakHr,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      userMaxHr: userMaxHr ?? this.userMaxHr,
      userRestingHr: userRestingHr ?? this.userRestingHr,
    );
  }
}

/// Basic VO2 Max estimator
class Vo2MaxEstimator {
  final double userMaxHr;
  final double userRestingHr;

  Vo2MaxEstimator({
    required this.userMaxHr,
    required this.userRestingHr,
  });

  /// Estimation from workout data points.
  /// Returns null if no valid estimation can be made.
  Vo2MaxResult? estimateFromWorkout(List<WorkoutDataPoint> workoutData) {
    if (workoutData.isEmpty) return null;

    final baselineVo2 = 15.3 * (userMaxHr / userRestingHr);

    return Vo2MaxResult(
      estimatedVo2Max: baselineVo2,
      segmentsUsed: workoutData.length,
      peakHr: userMaxHr,
      totalDistanceMeters: 0,
      userMaxHr: userMaxHr,
      userRestingHr: userRestingHr,
    );
  }

  /// Legacy method for backwards compatibility.
  double? processWorkout(List<WorkoutDataPoint> workoutData) {
    return estimateFromWorkout(workoutData)?.estimatedVo2Max;
  }

  /// Non-Exercise Baseline VO2 Max estimation.
  double? estimateFromHrOnly({
    double? peakExerciseHr,
    double? hrRecovery60s,
  }) {
    if (userRestingHr <= 0 || userMaxHr <= userRestingHr) return null;

    // Baseline Uth-Sørensen formula
    double vo2max = 15.3 * (userMaxHr / userRestingHr);

    if (vo2max < 15.0 || vo2max > 85.0) return null;
    return vo2max;
  }

}
