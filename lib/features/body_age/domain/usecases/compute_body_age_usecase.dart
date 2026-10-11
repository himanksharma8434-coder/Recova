import 'dart:math' as math;
import '../entities/body_age_factor.dart';
import '../entities/body_age_result.dart';

/// Exception thrown when a user under 18 attempts to compute body age.
class UnderAgeException implements Exception {
  final int age;
  const UnderAgeException(this.age);

  @override
  String toString() => 'Body age is available for users 18+. Given: $age';
}

/// Exception thrown when fewer than 2 factors are available to compute body age.
class InsufficientDataException implements Exception {
  final List<BodyAgeFactor> missingFactors;
  const InsufficientDataException(this.missingFactors);

  @override
  String toString() =>
      'Not enough data yet. At least 2 factors are required. Missing: $missingFactors';
}

/// Parameter object for [ComputeFitnessBodyAgeUseCase].
class ComputeFitnessBodyAgeParams {
  final int chronologicalAge;
  final String? sex; // 'male' | 'female' | null
  final double? heightCm;
  final double? weightKg;
  final double? bodyFatPct;
  final double? vo2max;
  final DateTime? vo2maxRecordedAt;
  final double? restingHr30d;
  final DateTime? restingHrRecordedAt;
  final int? vigorousMinutesPerWeek;
  final int? vigorousDaysPerWeek;
  final DateTime? referenceDate;

  const ComputeFitnessBodyAgeParams({
    required this.chronologicalAge,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.bodyFatPct,
    this.vo2max,
    this.vo2maxRecordedAt,
    this.restingHr30d,
    this.restingHrRecordedAt,
    this.vigorousMinutesPerWeek,
    this.vigorousDaysPerWeek,
    this.referenceDate,
  });
}

/// Pure Dart calculation engine for functional Fitness Body Age.
///
/// Converts physiological metrics into age-equivalents using published
/// population normative tables, applies proportional weight distribution,
/// and computes achievable targets with actionable levers.
class ComputeFitnessBodyAgeUseCase {
  const ComputeFitnessBodyAgeUseCase();

  // Configurable factor weights
  static const double weightVo2Max = 0.40;
  static const double weightRestingHr = 0.20;
  static const double weightActivity = 0.20;
  static const double weightBodyComp = 0.20;

  // Maximum allowable age of wearable biometric inputs (days)
  static const int maxInputStalenessDays = 60;

  // Clamping constraints
  static const double minAllowedBodyAge = 18.0;
  static const double maxDeltaYears = 25.0;

  FitnessBodyAgeResult call(ComputeFitnessBodyAgeParams params) {
    if (params.chronologicalAge < 18) {
      throw UnderAgeException(params.chronologicalAge);
    }

    final now = params.referenceDate ?? DateTime.now();
    final isFemale = params.sex?.toLowerCase() == 'female';

    // ── 1. Validate & Filter Inputs for Freshness ──
    final double? validVo2Max = _validateVo2Max(
      params.vo2max,
      params.vo2maxRecordedAt,
      now,
    );

    final double? validRhr = _validateRhr(
      params.restingHr30d,
      params.restingHrRecordedAt,
      now,
    );

    final int? validVigorousMins = params.vigorousMinutesPerWeek;
    final int? validVigorousDays = params.vigorousDaysPerWeek;

    // Body composition (Body Fat takes priority over BMI)
    final double? validWeight = _validateWeight(params.weightKg);
    final double? validBodyFat = _validateBodyFat(params.bodyFatPct);
    final double? validBmi = _computeBmi(validWeight, params.heightCm);

    // ── 2. Compute Per-Factor Age-Equivalents ──
    final factorAges = <BodyAgeFactor, double>{};
    final factorWeights = <BodyAgeFactor, double>{};
    final missingFactors = <BodyAgeFactor>[];

    // Factor A: VO2 Max (0.40)
    if (validVo2Max != null) {
      factorAges[BodyAgeFactor.vo2Max] = _vo2MaxToAge(
        vo2: validVo2Max,
        isFemale: isFemale,
        chronologicalAge: params.chronologicalAge,
      );
      factorWeights[BodyAgeFactor.vo2Max] = weightVo2Max;
    } else {
      missingFactors.add(BodyAgeFactor.vo2Max);
    }

    // Factor B: Resting Heart Rate (0.20)
    if (validRhr != null) {
      factorAges[BodyAgeFactor.restingHeartRate] = _rhrToAge(
        rhr: validRhr,
        isFemale: isFemale,
        chronologicalAge: params.chronologicalAge,
      );
      factorWeights[BodyAgeFactor.restingHeartRate] = weightRestingHr;
    } else {
      missingFactors.add(BodyAgeFactor.restingHeartRate);
    }

    // Factor C: Vigorous Activity (0.20)
    if (validVigorousMins != null || validVigorousDays != null) {
      factorAges[BodyAgeFactor.vigorousActivity] = _activityToAge(
        minsPerWeek: validVigorousMins ?? 0,
        daysPerWeek: validVigorousDays ?? 0,
        chronologicalAge: params.chronologicalAge,
      );
      factorWeights[BodyAgeFactor.vigorousActivity] = weightActivity;
    } else {
      missingFactors.add(BodyAgeFactor.vigorousActivity);
    }

    // Factor D: Body Composition (0.20) - Body Fat % prioritized over BMI
    if (validBodyFat != null) {
      factorAges[BodyAgeFactor.bodyComposition] = _bodyFatToAge(
        bodyFatPct: validBodyFat,
        isFemale: isFemale,
        chronologicalAge: params.chronologicalAge,
      );
      factorWeights[BodyAgeFactor.bodyComposition] = weightBodyComp;
    } else if (validBmi != null) {
      factorAges[BodyAgeFactor.bodyComposition] = _bmiToAge(
        bmi: validBmi,
        chronologicalAge: params.chronologicalAge,
      );
      factorWeights[BodyAgeFactor.bodyComposition] = weightBodyComp;
    } else {
      missingFactors.add(BodyAgeFactor.bodyComposition);
    }

    // ── 3. Proportional Weight Redistribution & Factor Threshold Check ──
    if (factorAges.length < 2) {
      throw InsufficientDataException(missingFactors);
    }

    final totalAvailableWeight =
        factorWeights.values.fold<double>(0.0, (acc, w) => acc + w);

    double weightedAgeSum = 0.0;
    for (final entry in factorAges.entries) {
      final normalizedWeight = factorWeights[entry.key]! / totalAvailableWeight;
      weightedAgeSum += entry.value * normalizedWeight;
    }

    // ── 4. Clamping Constraints ──
    final double rawBodyAge = weightedAgeSum;
    final double lowerBound =
        math.max(minAllowedBodyAge, params.chronologicalAge - maxDeltaYears);
    final double upperBound = params.chronologicalAge + maxDeltaYears;
    final double clampedBodyAge =
        rawBodyAge.clamp(lowerBound, upperBound).toDouble();
    final double finalBodyAge =
        double.parse(clampedBodyAge.toStringAsFixed(1));
    final double ageDifference =
        double.parse((finalBodyAge - params.chronologicalAge).toStringAsFixed(1));

    // ── 5. Achievable Body Age & Top Improvement Levers ──
    // Rank available factors by potential improvement (how much they elevated body age)
    final improvableFactors = factorAges.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topImprovements = improvableFactors
        .take(3)
        .map((e) => e.key)
        .toList();

    double? achievableAge;
    if (improvableFactors.isNotEmpty) {
      // Simulate realistic 1-tier improvement in the single weakest factor
      final weakestFactor = improvableFactors.first.key;
      final currentWeakestAge = factorAges[weakestFactor]!;
      // An achievable target lowers that factor age towards (or below) chronological age
      final improvedWeakestAge = math.max(
        minAllowedBodyAge,
        currentWeakestAge - math.max(3.0, (currentWeakestAge - params.chronologicalAge) * 0.5),
      );

      double improvedWeightedSum = 0.0;
      for (final entry in factorAges.entries) {
        final factorAge = entry.key == weakestFactor
            ? improvedWeakestAge
            : entry.value;
        final normalizedWeight = factorWeights[entry.key]! / totalAvailableWeight;
        improvedWeightedSum += factorAge * normalizedWeight;
      }

      final clampedAchievable = improvedWeightedSum
          .clamp(lowerBound, upperBound)
          .toDouble();
      achievableAge =
          double.parse(clampedAchievable.toStringAsFixed(1));
      // Ensure achievable body age does not exceed current body age
      if (achievableAge >= finalBodyAge) {
        achievableAge = math.max(minAllowedBodyAge, finalBodyAge - 0.5);
      }
    }

    return FitnessBodyAgeResult(
      bodyAge: finalBodyAge,
      chronologicalAge: params.chronologicalAge,
      difference: ageDifference,
      achievableBodyAge: achievableAge,
      factorAges: factorAges,
      topImprovements: topImprovements,
      missingFactors: missingFactors,
      calculatedAt: now,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // NORMATIVE MODELS & CITATIONS
  // ═════════════════════════════════════════════════════════════════════════

  /// Converts VO2 Max (mL/kg/min) into an age-equivalent.
  ///
  /// Citation: The Cooper Institute & FRIEND (Fitness Registry and the Importance
  /// of Exercise National Database) 50th percentile cardiorespiratory norms by age & sex.
  /// Kaminsky LA et al., Mayo Clin Proc. 2015.
  double _vo2MaxToAge({
    required double vo2,
    required bool isFemale,
    required int chronologicalAge,
  }) {
    // Reference 50th percentile (median) VO2 max by age bracket midpoint
    // [Age Midpoint, Male Median VO2, Female Median VO2]
    const medianTable = [
      [25.0, 44.0, 38.0],
      [35.0, 41.0, 34.0],
      [45.0, 38.0, 31.0],
      [55.0, 34.0, 28.0],
      [65.0, 30.0, 24.0],
      [75.0, 25.0, 20.0],
    ];

    final targetCol = isFemale ? 2 : 1;

    // Above youngest median (elite/superior fitness)
    if (vo2 >= medianTable.first[targetCol]) {
      final surplus = vo2 - medianTable.first[targetCol];
      // 1 mL/kg/min above median ~ 0.8 years younger (clamped at 18)
      return math.max(18.0, 25.0 - (surplus * 0.8));
    }

    // Below oldest median (very low cardiorespiratory fitness)
    if (vo2 <= medianTable.last[targetCol]) {
      final deficit = medianTable.last[targetCol] - vo2;
      return math.min(85.0, 75.0 + (deficit * 1.2));
    }

    // Linear interpolation between brackets
    for (int i = 0; i < medianTable.length - 1; i++) {
      final top = medianTable[i];
      final bottom = medianTable[i + 1];
      final topVo2 = top[targetCol];
      final bottomVo2 = bottom[targetCol];

      if (vo2 <= topVo2 && vo2 >= bottomVo2) {
        final t = (topVo2 - vo2) / (topVo2 - bottomVo2);
        return top[0] + t * (bottom[0] - top[0]);
      }
    }

    return chronologicalAge.toDouble();
  }

  /// Converts 30-Day Resting Heart Rate (bpm) into an age-equivalent.
  ///
  /// Citation: NHANES (National Health and Nutrition Examination Survey) &
  /// American Heart Association (AHA) population heart rate distributions.
  /// Ostchega Y et al., Natl Health Stat Report. 2011.
  double _rhrToAge({
    required double rhr,
    required bool isFemale,
    required int chronologicalAge,
  }) {
    // Baseline median resting pulse for healthy adults: 65 bpm (men), 68 bpm (women)
    final double medianRhr = isFemale ? 68.0 : 65.0;
    final double diffBpm = rhr - medianRhr;

    // For every 3 bpm below median, reduce functional cardiovascular age by 1.5 years.
    // For every 3 bpm above median, increase cardiovascular age by 2.0 years.
    double deltaYears;
    if (diffBpm < 0) {
      deltaYears = (diffBpm / 3.0) * 1.5;
    } else {
      deltaYears = (diffBpm / 3.0) * 2.0;
    }

    final double ageEquiv = chronologicalAge + deltaYears;
    return ageEquiv.clamp(18.0, 85.0);
  }

  /// Converts Vigorous Physical Activity (min/week & days/week) into an age-equivalent.
  ///
  /// Citation: 2020 WHO & AHA Physical Activity Guidelines for Adults:
  /// Target: >= 75-150 min/week vigorous or >= 150-300 min/week moderate aerobic activity.
  /// Bull FC et al., Br J Sports Med. 2020.
  double _activityToAge({
    required int minsPerWeek,
    required int daysPerWeek,
    required int chronologicalAge,
  }) {
    double deltaYears = 0.0;

    if (minsPerWeek >= 150 || daysPerWeek >= 4) {
      // Exceeds guidelines: high cardiorespiratory stimulus
      deltaYears = -5.0;
    } else if (minsPerWeek >= 75 || daysPerWeek >= 3) {
      // Meets vigorous activity guidelines
      deltaYears = -2.5;
    } else if (minsPerWeek >= 30 || daysPerWeek >= 1) {
      // Insufficient activity
      deltaYears = 1.5;
    } else {
      // Sedentary lifestyle
      deltaYears = 5.0;
    }

    final double ageEquiv = chronologicalAge + deltaYears;
    return ageEquiv.clamp(18.0, 85.0);
  }

  /// Converts Body Fat Percentage into an age-equivalent.
  ///
  /// Citation: American Council on Exercise (ACE) & Jackson & Pollock
  /// Generalized Equations for Predicting Body Density and Percent Body Fat.
  /// Jackson AS, Pollock ML., Br J Nutr. 1978.
  double _bodyFatToAge({
    required double bodyFatPct,
    required bool isFemale,
    required int chronologicalAge,
  }) {
    // ACE Category Thresholds
    // Men: Athletes (6-13%), Fitness (14-17%), Average (18-24%), Obese (>=25%)
    // Women: Athletes (14-20%), Fitness (21-24%), Average (25-31%), Obese (>=32%)
    final athleticMax = isFemale ? 20.0 : 13.0;
    final fitnessMax = isFemale ? 24.0 : 17.0;
    final averageMax = isFemale ? 31.0 : 24.0;
    final overfatMax = isFemale ? 38.0 : 30.0;

    double deltaYears = 0.0;
    if (bodyFatPct <= athleticMax) {
      deltaYears = -5.0;
    } else if (bodyFatPct <= fitnessMax) {
      deltaYears = -2.5;
    } else if (bodyFatPct <= averageMax) {
      deltaYears = 0.0; // Normal population baseline
    } else if (bodyFatPct <= overfatMax) {
      deltaYears = 3.5;
    } else {
      deltaYears = 7.0;
    }

    final double ageEquiv = chronologicalAge + deltaYears;
    return ageEquiv.clamp(18.0, 85.0);
  }

  /// Fallback: Converts Body Mass Index (BMI) into an age-equivalent.
  ///
  /// Citation: WHO Technical Report Series 854: Physical Status: The use and
  /// interpretation of anthropometry. World Health Organization, 1995.
  double _bmiToAge({
    required double bmi,
    required int chronologicalAge,
  }) {
    double deltaYears = 0.0;
    if (bmi >= 18.5 && bmi < 25.0) {
      // Normal weight
      deltaYears = 0.0;
    } else if (bmi >= 25.0 && bmi < 30.0) {
      // Overweight
      deltaYears = 2.5;
    } else if (bmi >= 30.0 && bmi < 35.0) {
      // Obese Class I
      deltaYears = 5.5;
    } else if (bmi >= 35.0) {
      // Obese Class II+
      deltaYears = 9.0;
    } else {
      // Underweight (< 18.5)
      deltaYears = 1.5;
    }

    final double ageEquiv = chronologicalAge + deltaYears;
    return ageEquiv.clamp(18.0, 85.0);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // VALIDATION & HELPERS
  // ═════════════════════════════════════════════════════════════════════════

  double? _validateVo2Max(double? vo2, DateTime? recordedAt, DateTime now) {
    if (vo2 == null || vo2 < 10.0 || vo2 > 90.0) return null;
    if (recordedAt != null &&
        now.difference(recordedAt).inDays > maxInputStalenessDays) {
      return null;
    }
    return vo2;
  }

  double? _validateRhr(double? rhr, DateTime? recordedAt, DateTime now) {
    if (rhr == null || rhr < 30.0 || rhr > 180.0) return null;
    if (recordedAt != null &&
        now.difference(recordedAt).inDays > maxInputStalenessDays) {
      return null;
    }
    return rhr;
  }

  double? _validateWeight(double? weightKg) {
    if (weightKg == null || weightKg < 25.0 || weightKg > 300.0) return null;
    return weightKg;
  }

  double? _validateBodyFat(double? bodyFatPct) {
    if (bodyFatPct == null || bodyFatPct < 3.0 || bodyFatPct > 60.0) return null;
    return bodyFatPct;
  }

  double? _computeBmi(double? weightKg, double? heightCm) {
    if (weightKg == null || heightCm == null || heightCm <= 0) return null;
    final heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }
}
