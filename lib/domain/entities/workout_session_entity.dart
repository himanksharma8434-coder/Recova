import 'package:equatable/equatable.dart';

/// Domain entity representing a workout session with cardiovascular zone breakdown.
class WorkoutSessionEntity extends Equatable {
  final int? id;
  final String userId;
  final String sport;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int timeZoneOffsetMinutes;
  final int durationMinutes;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? caloriesBurned;
  final double? distanceMeters;
  final double? elevationGainMeters;
  final int zone1Minutes;
  final int zone2Minutes;
  final int zone3Minutes;
  final int zone4Minutes;
  final int zone5Minutes;
  final double strainScore; // 0–21 TRIMP-based load
  final double recoveryCost;
  final String? sourceDevice;
  final String qualityFlag;
  final DateTime syncedAt;

  const WorkoutSessionEntity({
    this.id,
    this.userId = 'local_user',
    required this.sport,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.timeZoneOffsetMinutes = 0,
    required this.durationMinutes,
    this.avgHeartRate,
    this.maxHeartRate,
    this.caloriesBurned,
    this.distanceMeters,
    this.elevationGainMeters,
    this.zone1Minutes = 0,
    this.zone2Minutes = 0,
    this.zone3Minutes = 0,
    this.zone4Minutes = 0,
    this.zone5Minutes = 0,
    this.strainScore = 0.0,
    this.recoveryCost = 0.0,
    this.sourceDevice,
    this.qualityFlag = 'good',
    required this.syncedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        sport,
        title,
        startTime,
        endTime,
        timeZoneOffsetMinutes,
        durationMinutes,
        avgHeartRate,
        maxHeartRate,
        caloriesBurned,
        distanceMeters,
        elevationGainMeters,
        zone1Minutes,
        zone2Minutes,
        zone3Minutes,
        zone4Minutes,
        zone5Minutes,
        strainScore,
        recoveryCost,
        sourceDevice,
        qualityFlag,
        syncedAt,
      ];
}

