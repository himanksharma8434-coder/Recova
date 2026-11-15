import 'dart:math' as math;
import 'load_engine.dart';

/// Supported sports categories for cardiovascular load and recovery cost estimation.
enum SportCategory {
  running('Running', 'running'),
  cycling('Cycling', 'cycling'),
  swimming('Swimming', 'swimming'),
  strength('Strength Training', 'strength'),
  hiit('HIIT & Circuit', 'hiit'),
  walking('Walking / Hiking', 'walking'),
  recovery('Active Recovery & Yoga', 'recovery'),
  sports('General Sports', 'sports'),
  other('Other Activity', 'other');

  final String displayName;
  final String key;
  const SportCategory(this.displayName, this.key);

  static SportCategory fromKey(String key) {
    final lower = key.toLowerCase();
    for (final cat in values) {
      if (cat.key == lower || lower.contains(cat.key)) return cat;
    }
    if (lower.contains('run') || lower.contains('jog')) return running;
    if (lower.contains('bike') || lower.contains('cycl')) return cycling;
    if (lower.contains('swim')) return swimming;
    if (lower.contains('weight') || lower.contains('gym') || lower.contains('lift')) {
      return strength;
    }
    if (lower.contains('interval') || lower.contains('crossfit') || lower.contains('tabata')) {
      return hiit;
    }
    if (lower.contains('walk') || lower.contains('hike')) return walking;
    if (lower.contains('yoga') || lower.contains('stretch') || lower.contains('mobility')) {
      return recovery;
    }
    return other;
  }
}

/// Input parameters for evaluating a discrete workout session.
class WorkoutInput {
  final String sport;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? calories;
  final double? distanceMeters;
  final double? elevationGainMeters;
  final double restingHr;
  final double maxHr;
  final double? userWeightKg;
  final int? userAge;
  final bool? isMale;
  final List<double>? minuteHrSamples;

  const WorkoutInput({
    required this.sport,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    this.avgHeartRate,
    this.maxHeartRate,
    this.calories,
    this.distanceMeters,
    this.elevationGainMeters,
    this.restingHr = 60.0,
    this.maxHr = 190.0,
    this.userWeightKg,
    this.userAge,
    this.isMale,
    this.minuteHrSamples,
  });
}

/// Comprehensive physiological analysis of a workout session.
class WorkoutAnalysisResult {
  final String sport;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final HeartRateZoneBreakdown zones;
  final bool isZoneEstimated;
  final double trimp;
  final double strainScore; // 0.0 to 21.0
  final double recoveryCostHours; // Estimated hours to full autonomic baseline
  final String recoveryCostLabel; // 'Low (~10h)', 'Moderate (~20h)', etc.
  final double calories;
  final bool isCaloriesEstimated;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? distanceMeters;
  final double? elevationGainMeters;
  final String coachingSummary;

  const WorkoutAnalysisResult({
    required this.sport,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.zones,
    required this.isZoneEstimated,
    required this.trimp,
    required this.strainScore,
    required this.recoveryCostHours,
    required this.recoveryCostLabel,
    required this.calories,
    required this.isCaloriesEstimated,
    this.avgHeartRate,
    this.maxHeartRate,
    this.distanceMeters,
    this.elevationGainMeters,
    required this.coachingSummary,
  });
}

/// Pure Dart science engine for discrete workouts, Karvonen HR zones, TRIMP,
/// recovery cost, and caloric estimation.
class WorkoutEngine {
  const WorkoutEngine();

  /// Analyze a workout session with transparent physiology calculations.
  WorkoutAnalysisResult analyze(WorkoutInput input) {
    final endTime = input.startTime.add(Duration(minutes: input.durationMinutes));
    final rhr = input.restingHr;
    final maxHr = input.maxHr > rhr ? input.maxHr : (rhr + 80.0);

    HeartRateZoneBreakdown zones;
    bool isZoneEstimated = false;
    double trimp = 0.0;

    // 1. Zone distribution & TRIMP calculation
    if (input.minuteHrSamples != null && input.minuteHrSamples!.isNotEmpty) {
      // Precise minute-by-minute HR samples available
      int z1 = 0, z2 = 0, z3 = 0, z4 = 0, z5 = 0;
      for (final bpm in input.minuteHrSamples!) {
        final intensity = LoadEngine.calculateHrrIntensity(
          hr: bpm,
          restingHr: rhr,
          maxHr: maxHr,
        );
        final zone = LoadEngine.classifyZone(intensity);
        // Edwards exponential intensity weighting aligned with LoadEngine
        final trimpContribution = math.pow(intensity, 1.92) * 1.5;
        trimp += trimpContribution;

        switch (zone) {
          case 1:
            z1++;
            break;
          case 2:
            z2++;
            break;
          case 3:
            z3++;
            break;
          case 4:
            z4++;
            break;
          case 5:
            z5++;
            break;
        }
      }
      zones = HeartRateZoneBreakdown(
        zone1Minutes: z1,
        zone2Minutes: z2,
        zone3Minutes: z3,
        zone4Minutes: z4,
        zone5Minutes: z5,
      );
    } else if (input.avgHeartRate != null && input.avgHeartRate! > rhr) {
      // Estimate zone distribution from average HR and sport characteristics
      isZoneEstimated = true;
      final avgHr = input.avgHeartRate!;
      final intensity = LoadEngine.calculateHrrIntensity(
        hr: avgHr,
        restingHr: rhr,
        maxHr: maxHr,
      );
      final estimated = _estimateZonesFromAvgIntensity(
        durationMinutes: input.durationMinutes,
        intensity: intensity,
        sport: input.sport,
      );
      zones = estimated.zones;
      trimp = estimated.trimp;
    } else {
      // Fallback: estimate from duration and sport intensity
      isZoneEstimated = true;
      final estimated = _estimateZonesFromSportCategory(
        durationMinutes: input.durationMinutes,
        sport: input.sport,
      );
      zones = estimated.zones;
      trimp = estimated.trimp;
    }

    // 2. Map TRIMP to 0–21 cardiovascular strain scale
    final strain = LoadEngine.mapTrimpToLoadScale(trimp);

    // 3. Estimate Recovery Cost (hours to full autonomic readiness recovery)
    final recoveryCost = _calculateRecoveryCost(
      strain: strain,
      zone4And5Minutes: zones.zone4Minutes + zones.zone5Minutes,
      sport: input.sport,
    );

    // 4. Caloric expenditure (Keytel et al. 2005 or metabolic fallback)
    double calories = input.calories ?? 0.0;
    bool isCaloriesEstimated = false;
    if (calories <= 0) {
      isCaloriesEstimated = true;
      calories = _estimateCalories(
        durationMinutes: input.durationMinutes,
        avgHr: input.avgHeartRate,
        weightKg: input.userWeightKg ?? 70.0,
        age: input.userAge ?? 30,
        isMale: input.isMale ?? true,
        restingHr: rhr,
        maxHr: maxHr,
        sport: input.sport,
      );
    }

    // 5. Build coaching summary
    final summary = _generateWorkoutCoachingSummary(
      sport: input.sport,
      durationMinutes: input.durationMinutes,
      strain: strain,
      zones: zones,
      recoveryCostHours: recoveryCost.hours,
    );

    return WorkoutAnalysisResult(
      sport: input.sport,
      title: input.title,
      startTime: input.startTime,
      endTime: endTime,
      durationMinutes: input.durationMinutes,
      zones: zones,
      isZoneEstimated: isZoneEstimated,
      trimp: trimp,
      strainScore: strain,
      recoveryCostHours: recoveryCost.hours,
      recoveryCostLabel: recoveryCost.label,
      calories: double.parse(calories.toStringAsFixed(1)),
      isCaloriesEstimated: isCaloriesEstimated,
      avgHeartRate: input.avgHeartRate,
      maxHeartRate: input.maxHeartRate,
      distanceMeters: input.distanceMeters,
      elevationGainMeters: input.elevationGainMeters,
      coachingSummary: summary,
    );
  }

  /// Estimate Karvonen zones distribution when minute HR stream is absent.
  /// ASSUMPTION: needs calibration against gold-standard HR sensor streams.
  ({HeartRateZoneBreakdown zones, double trimp}) _estimateZonesFromAvgIntensity({
    required int durationMinutes,
    required double intensity,
    required String sport,
  }) {
    final cat = SportCategory.fromKey(sport);
    int z1 = 0, z2 = 0, z3 = 0, z4 = 0, z5 = 0;

    if (intensity < 0.55) {
      z1 = (durationMinutes * 0.70).round();
      z2 = (durationMinutes * 0.30).round();
    } else if (intensity < 0.68) {
      z1 = (durationMinutes * 0.25).round();
      z2 = (durationMinutes * 0.55).round();
      z3 = (durationMinutes * 0.20).round();
    } else if (intensity < 0.80) {
      z2 = (durationMinutes * 0.25).round();
      z3 = (durationMinutes * 0.50).round();
      z4 = (durationMinutes * 0.25).round();
    } else {
      if (cat == SportCategory.hiit) {
        z3 = (durationMinutes * 0.20).round();
        z4 = (durationMinutes * 0.45).round();
        z5 = (durationMinutes * 0.35).round();
      } else {
        z3 = (durationMinutes * 0.30).round();
        z4 = (durationMinutes * 0.50).round();
        z5 = (durationMinutes * 0.20).round();
      }
    }

    // Continuous exponential TRIMP weighting aligned with LoadEngine
    final trimp = (z1 * 0.48) + (z2 * 0.66) + (z3 * 0.86) + (z4 * 1.10) + (z5 * 1.36);

    return (
      zones: HeartRateZoneBreakdown(
        zone1Minutes: z1,
        zone2Minutes: z2,
        zone3Minutes: z3,
        zone4Minutes: z4,
        zone5Minutes: z5,
      ),
      trimp: trimp,
    );
  }

  /// Estimate zones based on sport category intensity when no HR is provided.
  /// ASSUMPTION: needs calibration.
  ({HeartRateZoneBreakdown zones, double trimp}) _estimateZonesFromSportCategory({
    required int durationMinutes,
    required String sport,
  }) {
    final cat = SportCategory.fromKey(sport);
    int z1 = 0, z2 = 0, z3 = 0, z4 = 0, z5 = 0;

    switch (cat) {
      case SportCategory.running:
      case SportCategory.cycling:
        z1 = (durationMinutes * 0.15).round();
        z2 = (durationMinutes * 0.45).round();
        z3 = (durationMinutes * 0.30).round();
        z4 = (durationMinutes * 0.10).round();
        break;
      case SportCategory.hiit:
        z2 = (durationMinutes * 0.20).round();
        z3 = (durationMinutes * 0.30).round();
        z4 = (durationMinutes * 0.35).round();
        z5 = (durationMinutes * 0.15).round();
        break;
      case SportCategory.strength:
        z1 = (durationMinutes * 0.45).round();
        z2 = (durationMinutes * 0.35).round();
        z3 = (durationMinutes * 0.20).round();
        break;
      case SportCategory.recovery:
      case SportCategory.walking:
        z1 = (durationMinutes * 0.80).round();
        z2 = (durationMinutes * 0.20).round();
        break;
      default:
        z1 = (durationMinutes * 0.30).round();
        z2 = (durationMinutes * 0.40).round();
        z3 = (durationMinutes * 0.30).round();
        break;
    }

    final trimp = (z1 * 0.48) + (z2 * 0.66) + (z3 * 0.86) + (z4 * 1.10) + (z5 * 1.36);

    return (
      zones: HeartRateZoneBreakdown(
        zone1Minutes: z1,
        zone2Minutes: z2,
        zone3Minutes: z3,
        zone4Minutes: z4,
        zone5Minutes: z5,
      ),
      trimp: trimp,
    );
  }

  /// Estimate Recovery Cost (hours required for parasympathetic autonomic recovery).
  ///
  /// Physiological Rationale:
  /// Higher cardiovascular strain and anaerobic threshold exposure (Zones 4 & 5)
  /// cause microtrauma, glycogen depletion, and prolonged sympathetic dominance,
  /// requiring 24–48 hours for full autonomic baseline recovery (Plews et al., 2013).
  ({double hours, String label}) _calculateRecoveryCost({
    required double strain,
    required int zone4And5Minutes,
    required String sport,
  }) {
    double hours;
    String label;

    if (strain < 6.0) {
      hours = 8.0 + (strain * 0.8);
      label = 'Low (~${hours.round()}h)';
    } else if (strain < 11.0) {
      hours = 12.0 + ((strain - 6.0) * 1.8);
      label = 'Moderate (~${hours.round()}h)';
    } else if (strain < 16.0) {
      hours = 21.0 + ((strain - 11.0) * 2.5);
      label = 'Elevated (~${hours.round()}h)';
    } else {
      hours = 33.5 + ((strain - 16.0) * 2.9);
      if (hours > 48.0) hours = 48.0;
      label = 'High (~${hours.round()}h)';
    }

    // Additional recovery penalty for prolonged anaerobic exposure (>25 mins in Zone 4/5)
    if (zone4And5Minutes > 25) {
      hours = math.min(48.0, hours + 4.0);
      label = 'High (~${hours.round()}h)';
    }

    return (hours: double.parse(hours.toStringAsFixed(1)), label: label);
  }

  /// Caloric expenditure estimation using Keytel et al. (2005) or MET intensity fallback.
  /// Keytel, L. R., et al. (2005). Prediction of energy expenditure from heart rate.
  /// Journal of Sports Sciences, 23(3), 289-297.
  double _estimateCalories({
    required int durationMinutes,
    required double? avgHr,
    required double weightKg,
    required int age,
    required bool isMale,
    required double restingHr,
    required double maxHr,
    required String sport,
  }) {
    if (avgHr != null && avgHr > 70.0) {
      // Keytel equation:
      // Male: [(-55.0969 + (0.6309 x HR) + (0.1988 x W) + (0.2017 x A)) / 4.184] x 60 x (T / 60)
      // Female: [(-20.4022 + (0.4472 x HR) - (0.1263 x W) + (0.0740 x A)) / 4.184] x 60 x (T / 60)
      double kcalPerMin;
      if (isMale) {
        kcalPerMin = (-55.0969 + (0.6309 * avgHr) + (0.1988 * weightKg) + (0.2017 * age)) / 4.184;
      } else {
        kcalPerMin = (-20.4022 + (0.4472 * avgHr) - (0.1263 * weightKg) + (0.0740 * age)) / 4.184;
      }
      return math.max(0.0, kcalPerMin * durationMinutes);
    } else {
      // MET fallback based on sport category
      final cat = SportCategory.fromKey(sport);
      double met;
      switch (cat) {
        case SportCategory.running:
          met = 9.8;
          break;
        case SportCategory.cycling:
          met = 8.0;
          break;
        case SportCategory.swimming:
          met = 7.5;
          break;
        case SportCategory.hiit:
          met = 8.5;
          break;
        case SportCategory.strength:
          met = 5.0;
          break;
        case SportCategory.walking:
          met = 3.5;
          break;
        case SportCategory.recovery:
          met = 2.5;
          break;
        default:
          met = 6.0;
          break;
      }
      // kcal = MET x weight (kg) x duration (hours)
      return met * weightKg * (durationMinutes / 60.0);
    }
  }

  /// Generate a concise sports-science coaching explanation for the workout.
  String _generateWorkoutCoachingSummary({
    required String sport,
    required int durationMinutes,
    required double strain,
    required HeartRateZoneBreakdown zones,
    required double recoveryCostHours,
  }) {
    final cat = SportCategory.fromKey(sport);
    final highIntensityMins = zones.zone4Minutes + zones.zone5Minutes;
    final aerobicMins = zones.zone2Minutes + zones.zone3Minutes;

    if (strain >= 15.0) {
      return 'High-strain ${cat.displayName} session ($strain strain). '
          'Accumulated $highIntensityMins mins of anaerobic threshold stress. '
          'Prioritize hydration and ~${recoveryCostHours.round()}h of recovery before your next hard effort.';
    } else if (strain >= 10.0) {
      return 'Solid ${cat.displayName} session ($strain strain). '
          'Maintained $aerobicMins mins of aerobic training. '
          'Expected autonomic recovery in ~${recoveryCostHours.round()} hours.';
    } else {
      return 'Light ${cat.displayName} session ($strain strain). '
          'Gentle aerobic stimulation with minimal autonomic fatigue (~${recoveryCostHours.round()}h recovery cost).';
    }
  }
}
