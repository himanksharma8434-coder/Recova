import 'package:equatable/equatable.dart';

/// Calculation provenance for sleep stages and telemetry.
enum SleepCalculationMethod {
  sensor,
  estimated,
  interpolated,
}

/// Data quality flag for sensor fidelity.
enum SleepQualityFlag {
  good,
  lowSignal,
  motionArtifact,
}

/// Domain entity representing a consolidated sleep session.
class SleepSessionEntity extends Equatable {
  final int? id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int timeZoneOffsetMinutes;
  final int durationMinutes;
  final int asleepMinutes;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? remMinutes;
  final int? awakeMinutes;
  final double? efficiency; // 0–100%
  final int? disturbancesCount;
  final double? respiratoryRate;
  final double? restingHeartRate;
  final double? hrvRmssd;
  final double? spo2Average;
  final double? spo2Min;
  final double? skinTempDeviation;
  final bool isNap;
  final String? sourceDevice;
  final SleepCalculationMethod calculationMethod;
  final SleepQualityFlag qualityFlag;
  final DateTime syncedAt;

  const SleepSessionEntity({
    this.id,
    this.userId = 'local_user',
    required this.startTime,
    required this.endTime,
    this.timeZoneOffsetMinutes = 0,
    required this.durationMinutes,
    required this.asleepMinutes,
    this.deepMinutes,
    this.lightMinutes,
    this.remMinutes,
    this.awakeMinutes,
    this.efficiency,
    this.disturbancesCount,
    this.respiratoryRate,
    this.restingHeartRate,
    this.hrvRmssd,
    this.spo2Average,
    this.spo2Min,
    this.skinTempDeviation,
    this.isNap = false,
    this.sourceDevice,
    this.calculationMethod = SleepCalculationMethod.sensor,
    this.qualityFlag = SleepQualityFlag.good,
    required this.syncedAt,
  });

  bool get hasStageBreakdown =>
      (deepMinutes ?? 0) + (lightMinutes ?? 0) + (remMinutes ?? 0) > 0;

  int get restorativeMinutes => (deepMinutes ?? 0) + (remMinutes ?? 0);

  double? get restorativePercentage {
    if (asleepMinutes > 0) {
      return (restorativeMinutes / asleepMinutes) * 100.0;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        startTime,
        endTime,
        timeZoneOffsetMinutes,
        durationMinutes,
        asleepMinutes,
        deepMinutes,
        lightMinutes,
        remMinutes,
        awakeMinutes,
        efficiency,
        disturbancesCount,
        respiratoryRate,
        restingHeartRate,
        hrvRmssd,
        spo2Average,
        spo2Min,
        skinTempDeviation,
        isNap,
        sourceDevice,
        calculationMethod,
        qualityFlag,
        syncedAt,
      ];
}

