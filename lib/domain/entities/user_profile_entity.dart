import 'package:equatable/equatable.dart';

/// User demographic profile and physiological baseline parameters.
class UserProfileEntity extends Equatable {
  final String userId;
  final int? age;
  final String? sex; // 'male', 'female', 'other'
  final double? heightCm;
  final double? weightKg;
  final double? bodyFatPct;
  final double? maxHr;
  final double? restingHrBaseline;
  final int sleepNeedBaselineMinutes;
  final double? targetStrain;
  final String units; // 'metric' | 'imperial'
  final String timeZone;
  final int timeZoneOffsetMinutes;
  final DateTime? updatedAt;

  const UserProfileEntity({
    this.userId = 'local_user',
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.bodyFatPct,
    this.maxHr,
    this.restingHrBaseline,
    this.sleepNeedBaselineMinutes = 480,
    this.targetStrain,
    this.units = 'metric',
    this.timeZone = 'UTC',
    this.timeZoneOffsetMinutes = 0,
    this.updatedAt,
  });

  bool get isComplete =>
      age != null && sex != null && heightCm != null && weightKg != null;

  double? get calculatedBmi {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      final hm = heightCm! / 100.0;
      return weightKg! / (hm * hm);
    }
    return null;
  }

  UserProfileEntity copyWith({
    String? userId,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    double? bodyFatPct,
    double? maxHr,
    double? restingHrBaseline,
    int? sleepNeedBaselineMinutes,
    double? targetStrain,
    String? units,
    String? timeZone,
    int? timeZoneOffsetMinutes,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      maxHr: maxHr ?? this.maxHr,
      restingHrBaseline: restingHrBaseline ?? this.restingHrBaseline,
      sleepNeedBaselineMinutes:
          sleepNeedBaselineMinutes ?? this.sleepNeedBaselineMinutes,
      targetStrain: targetStrain ?? this.targetStrain,
      units: units ?? this.units,
      timeZone: timeZone ?? this.timeZone,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        age,
        sex,
        heightCm,
        weightKg,
        bodyFatPct,
        maxHr,
        restingHrBaseline,
        sleepNeedBaselineMinutes,
        targetStrain,
        units,
        timeZone,
        timeZoneOffsetMinutes,
        updatedAt,
      ];
}

