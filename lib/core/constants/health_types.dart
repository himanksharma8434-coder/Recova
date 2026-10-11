import 'dart:io';
import 'package:health/health.dart';

/// Central definition of all health data types this app reads.
///
/// The Nothing X / CMF Watch surfaces these via Health Connect:
/// HeartRate, RestingHeartRate, SleepSession, OxygenSaturation,
/// Steps, ExerciseSession, TotalCaloriesBurned.
///
/// HRV, VO2max, stress, and recovery are NOT available from the
/// wearable and must be computed locally.
class HealthTypes {
  HealthTypes._();

  /// Core essential types needed for baseline recovery tracking.
  static List<HealthDataType> get coreTypes {
    if (Platform.isAndroid) {
      return const [
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.SLEEP_SESSION,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.STEPS,
      ];
    } else {
      return const [
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.STEPS,
      ];
    }
  }

  static List<HealthDataAccess> get corePermissions =>
      coreTypes.map((_) => HealthDataAccess.READ).toList();

  /// Platform-specific list of supported health data types requested from Google Health Connect & HealthKit.
  static List<HealthDataType> get platformRequestedTypes {
    if (Platform.isAndroid) {
      return const [
        // Cardiovascular (Health Connect uses RMSSD, SDNN is not supported)
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.HEART_RATE_VARIABILITY_RMSSD,

        // Sleep Architecture
        HealthDataType.SLEEP_SESSION,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_AWAKE_IN_BED,
        HealthDataType.SLEEP_OUT_OF_BED,
        HealthDataType.SLEEP_UNKNOWN,

        // Blood Oxygen & Respiration
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.RESPIRATORY_RATE,

        // Activity, Strain & Energy
        HealthDataType.STEPS,
        HealthDataType.WORKOUT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.SPEED,
        HealthDataType.FLIGHTS_CLIMBED,

        // Biometrics & Body Vitals
        HealthDataType.BODY_TEMPERATURE,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
        HealthDataType.BODY_FAT_PERCENTAGE,
      ];
    } else {
      return const [
        // Cardiovascular (HealthKit uses SDNN)
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,

        // Sleep Architecture
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,

        // Blood Oxygen & Respiration
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.RESPIRATORY_RATE,

        // Activity, Strain & Energy
        HealthDataType.STEPS,
        HealthDataType.WORKOUT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.WALKING_SPEED,
        HealthDataType.FLIGHTS_CLIMBED,

        // Biometrics & Body Vitals
        HealthDataType.BODY_TEMPERATURE,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
        HealthDataType.BODY_FAT_PERCENTAGE,
      ];
    }
  }

  /// All requested types for backwards compatibility.
  static List<HealthDataType> get requestedTypes => platformRequestedTypes;

  /// All requested as READ-only.
  static List<HealthDataAccess> get permissions =>
      requestedTypes.map((_) => HealthDataAccess.READ).toList();

  /// Types that are recorded as simple numeric values.
  static const List<HealthDataType> numericTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.SPEED,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.SKIN_TEMPERATURE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.WATER,
  ];

  /// Maximum historical lookback on first sync (Health Connect allows ~30 days).
  static const Duration initialLookback = Duration(days: 30);
}
