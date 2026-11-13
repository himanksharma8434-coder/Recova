import 'package:equatable/equatable.dart';

/// Domain entity representing an immutable daily baseline snapshot.
class BaselineSnapshotEntity extends Equatable {
  final DateTime date;
  final int timeZoneOffsetMinutes;

  // Natural-log transformed HRV (ln RMSSD)
  final double? hrvBaseline7d; // 7-day rolling mean of ln(RMSSD)
  final double? hrvBaseline60dMean; // 60-day mean of ln(RMSSD)
  final double? hrvBaseline60dSd; // 60-day standard deviation
  final double? hrvCv7d; // 7-day coefficient of variation
  final double? rawHrvBaseline7dMs; // Raw millisecond value

  // Resting Heart Rate
  final double? rhrBaseline7d;
  final double? rhrBaseline30d;
  final double? rhrBaseline60dMean;
  final double? rhrBaseline60dSd;

  // Sleep & Respiratory
  final double? sleepDurationBaseline7d; // minutes
  final double? sleepDurationBaseline60d;
  final double? respiratoryRateBaseline7d;
  final double? respiratoryRateBaseline60d;
  final double? spo2Baseline7d;
  final double? skinTempBaseline30d;

  final int totalRecordedNights;
  final DateTime calculatedAt;

  const BaselineSnapshotEntity({
    required this.date,
    this.timeZoneOffsetMinutes = 0,
    this.hrvBaseline7d,
    this.hrvBaseline60dMean,
    this.hrvBaseline60dSd,
    this.hrvCv7d,
    this.rawHrvBaseline7dMs,
    this.rhrBaseline7d,
    this.rhrBaseline30d,
    this.rhrBaseline60dMean,
    this.rhrBaseline60dSd,
    this.sleepDurationBaseline7d,
    this.sleepDurationBaseline60d,
    this.respiratoryRateBaseline7d,
    this.respiratoryRateBaseline60d,
    this.spo2Baseline7d,
    this.skinTempBaseline30d,
    this.totalRecordedNights = 0,
    required this.calculatedAt,
  });

  /// Normal range upper bound for HRV: mean + 0.75 * SD (applied to ln RMSSD)
  double? get hrvNormalUpperBound =>
      (hrvBaseline60dMean != null && hrvBaseline60dSd != null)
          ? hrvBaseline60dMean! + 0.75 * hrvBaseline60dSd!
          : null;

  /// Normal range lower bound for HRV: mean - 0.75 * SD (applied to ln RMSSD)
  double? get hrvNormalLowerBound =>
      (hrvBaseline60dMean != null && hrvBaseline60dSd != null)
          ? hrvBaseline60dMean! - 0.75 * hrvBaseline60dSd!
          : null;

  @override
  List<Object?> get props => [
        date,
        timeZoneOffsetMinutes,
        hrvBaseline7d,
        hrvBaseline60dMean,
        hrvBaseline60dSd,
        hrvCv7d,
        rawHrvBaseline7dMs,
        rhrBaseline7d,
        rhrBaseline30d,
        rhrBaseline60dMean,
        rhrBaseline60dSd,
        sleepDurationBaseline7d,
        sleepDurationBaseline60d,
        respiratoryRateBaseline7d,
        respiratoryRateBaseline60d,
        spo2Baseline7d,
        skinTempBaseline30d,
        totalRecordedNights,
        calculatedAt,
      ];
}

