import 'dart:math';

import '../entities/body_age_result.dart';

/// Raw input data for the Body Age Estimation Engine.
/// All fields except [age] and [sex] are optional.
/// This class is populated automatically from wearable data + optional manual inputs.
class BodyAgeInput {
  // ── Required ──
  final int age;
  final String? sex; // 'male' | 'female' | null

  // ── Body Composition (from Health Connect / manual) ──
  final double? heightCm;
  final double? weightKg;

  // ── Wearable: Cardiorespiratory ──
  final double? vo2maxDevice;
  final double? restingHrAvg30d;
  final double? hrRecovery1min; // bpm drop 1 min after peak exercise

  // ── Wearable: Autonomic / Recovery ──
  final double? hrvAvg30d; // ms
  final String? hrvMetricType; // 'RMSSD' | 'SDNN' | null
  final String? hrvTrend; // 'rising' | 'stable' | 'falling'
  final double? restingHrBaseline7d;

  // ── Wearable: Sleep ──
  final double? sleepDurationAvgHours; // 14-30 day avg
  final double? sleepEfficiency; // 0-100%
  final double? deepSleepPct; // 0-100%
  final double? remSleepPct; // 0-100%

  // ── Wearable: Blood Oxygen & Respiration ──
  final double? spo2AvgSleep;
  final double? respiratoryRateSleep;

  // ── Activity & Lifestyle ──
  final int? dailyStepsAvg;
  final int? activityMinutesWeek; // moderate-to-vigorous
  final int? dataDays; // days of wearable data provided

  // ── Blood Pressure (if available from Health Connect) ──
  final double? systolicBp;
  final double? diastolicBp;

  const BodyAgeInput({
    required this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.vo2maxDevice,
    this.restingHrAvg30d,
    this.hrRecovery1min,
    this.hrvAvg30d,
    this.hrvMetricType,
    this.hrvTrend,
    this.restingHrBaseline7d,
    this.sleepDurationAvgHours,
    this.sleepEfficiency,
    this.deepSleepPct,
    this.remSleepPct,
    this.spo2AvgSleep,
    this.respiratoryRateSleep,
    this.dailyStepsAvg,
    this.activityMinutesWeek,
    this.dataDays,
    this.systolicBp,
    this.diastolicBp,
  });
}

/// Computes a functional "body age" by comparing user metrics against
/// population norms, following the scoring method defined in the master prompt.
///
/// This is a pure, stateless use case — no database or platform dependencies.
/// It produces an evidence-based **estimate** with explicit confidence.
class ComputeBodyAge {
  const ComputeBodyAge();

  static const String _disclaimer =
      'This is an estimate based on population norms, not a medical test. '
      'It does not diagnose any condition. Consult a clinician for medical advice.';

  /// Compute the body age result from the given input.
  /// Returns null if age < 18 (not applicable for minors).
  BodyAgeResult? call(BodyAgeInput input) {
    // ── Age Gate ──
    if (input.age < 18) return null;

    // ── Pre-processing & Validation ──
    final dataQualityFlags = <String>[];
    final missingInputs = <String>[];

    // Validate implausible values
    if (input.restingHrAvg30d != null &&
        (input.restingHrAvg30d! < 30 || input.restingHrAvg30d! > 120)) {
      dataQualityFlags.add(
          'Resting HR ${input.restingHrAvg30d} bpm excluded (implausible range)');
    }
    if (input.heightCm != null && input.heightCm! < 120) {
      dataQualityFlags.add(
          'Height ${input.heightCm} cm excluded (below 120 cm)');
    }
    if (input.weightKg != null && input.weightKg! < 30) {
      dataQualityFlags.add(
          'Weight ${input.weightKg} kg excluded (below 30 kg)');
    }

    // Validate safe values
    final rhrValid = input.restingHrAvg30d != null &&
        input.restingHrAvg30d! >= 30 &&
        input.restingHrAvg30d! <= 120;
    final heightValid = input.heightCm != null && input.heightCm! >= 120;
    final weightValid = input.weightKg != null && input.weightKg! >= 30;

    // Data days warning
    if (input.dataDays != null && input.dataDays! < 7) {
      dataQualityFlags.add(
          'Only ${input.dataDays} days of wearable data (7+ recommended)');
    }

    // HRV metric type warning
    if (input.hrvAvg30d != null &&
        (input.hrvMetricType == null || input.hrvMetricType!.isEmpty)) {
      dataQualityFlags.add(
          'HRV metric type unknown; given lower scoring weight');
    }

    if (input.sex == null) {
      dataQualityFlags.add(
          'Sex not provided; using averaged population norms');
    }

    if (input.age > 90) {
      dataQualityFlags.add(
          'Age above 90; population norms have limited accuracy');
    }

    // ── Derived Metrics ──
    double? bmi;
    if (heightValid && weightValid) {
      final heightM = input.heightCm! / 100.0;
      bmi = input.weightKg! / (heightM * heightM);
    }

    double? bmrKcal;
    if (heightValid && weightValid) {
      if (input.sex == 'male') {
        bmrKcal = 10 * input.weightKg! +
            6.25 * input.heightCm! -
            5 * input.age +
            5;
      } else if (input.sex == 'female') {
        bmrKcal = 10 * input.weightKg! +
            6.25 * input.heightCm! -
            5 * input.age -
            161;
      } else {
        // Averaged
        final male = 10 * input.weightKg! +
            6.25 * input.heightCm! -
            5 * input.age +
            5;
        final female = 10 * input.weightKg! +
            6.25 * input.heightCm! -
            5 * input.age -
            161;
        bmrKcal = (male + female) / 2;
      }
    }

    final vo2maxUsed = input.vo2maxDevice;

    // ── Score Each Category ──
    final scoredComponents = <_ScoredCategory>[];

    // 1. Cardiorespiratory Fitness (30%)
    final cardioPercentile = _scoreCardiorespiratory(input, rhrValid);
    if (cardioPercentile != null) {
      scoredComponents.add(cardioPercentile);
    } else {
      missingInputs.add('VO2 max or heart rate recovery');
    }

    // 2. Body Composition (20%)
    final bodyCompPercentile =
        _scoreBodyComposition(input, bmi, heightValid, weightValid);
    if (bodyCompPercentile != null) {
      scoredComponents.add(bodyCompPercentile);
    } else {
      missingInputs.add('Height, weight, or body composition data');
    }

    // 3. Autonomic & Recovery (15%)
    final autonomicPercentile = _scoreAutonomic(input, rhrValid);
    if (autonomicPercentile != null) {
      scoredComponents.add(autonomicPercentile);
    } else {
      missingInputs.add('HRV or resting heart rate trend data');
    }

    // 4. Sleep (10%)
    final sleepPercentile = _scoreSleep(input);
    if (sleepPercentile != null) {
      scoredComponents.add(sleepPercentile);
    } else {
      missingInputs.add('Sleep duration and quality data');
    }

    // 5. Lifestyle & Risk Factors (10%)
    final lifestylePercentile = _scoreLifestyle(input);
    if (lifestylePercentile != null) {
      scoredComponents.add(lifestylePercentile);
    } else {
      missingInputs.add('Daily steps or weekly activity minutes');
    }

    // ── Handle No Scored Categories ──
    if (scoredComponents.isEmpty) {
      return BodyAgeResult(
        chronologicalAge: input.age,
        bodyAge: input.age.toDouble(),
        ageDifferenceYears: 0,
        confidence: BodyAgeConfidence.low,
        components: [],
        derivedMetrics: BodyAgeDerivedMetrics(
          bmi: bmi,
          bmrKcal: bmrKcal,
          vo2maxUsed: vo2maxUsed,
        ),
        missingInputs: missingInputs,
        dataQualityFlags: dataQualityFlags,
        topLevers: const [],
        disclaimer: _disclaimer,
      );
    }

    // ── Renormalize Weights ──
    final totalWeight =
        scoredComponents.fold(0.0, (sum, c) => sum + c.baseWeight);
    for (final c in scoredComponents) {
      c.normalizedWeight = c.baseWeight / totalWeight;
    }

    // ── Combine ──
    double totalOffset = 0;
    for (final c in scoredComponents) {
      totalOffset += c.normalizedWeight * c.offsetYears;
    }

    // ── Cap, round, floor ──
    totalOffset = totalOffset.clamp(-15.0, 15.0);
    double bodyAge = input.age + totalOffset;
    bodyAge = (bodyAge * 2).round() / 2.0; // round to nearest 0.5
    if (bodyAge < 18) bodyAge = 18;

    final ageDiff = bodyAge - input.age;

    // ── Confidence Level ──
    final hasCardio = cardioPercentile != null;
    final dataDaysSufficient = (input.dataDays ?? 0) >= 14;
    final dataDaysModerate =
        (input.dataDays ?? 0) >= 7 && (input.dataDays ?? 0) < 14;

    BodyAgeConfidence confidence;
    if (scoredComponents.length >= 4 && hasCardio && dataDaysSufficient) {
      confidence = BodyAgeConfidence.high;
    } else if (scoredComponents.length >= 3 || dataDaysModerate) {
      confidence = BodyAgeConfidence.medium;
    } else {
      confidence = BodyAgeConfidence.low;
    }

    if (input.age > 90 || input.sex == null) {
      confidence = BodyAgeConfidence.low;
    }

    // ── Build Components ──
    final components = scoredComponents.map((c) {
      return BodyAgeComponent(
        category: c.category,
        weightUsed: double.parse(
            (c.normalizedWeight * 100).toStringAsFixed(1)),
        percentileEstimate: c.percentileRange,
        offsetYears:
            double.parse(c.offsetYears.toStringAsFixed(1)),
        inputsUsed: c.inputsUsed,
        note: c.note,
      );
    }).toList();

    // ── Top 3 Levers ──
    final levers = _generateTopLevers(
        scoredComponents, input, missingInputs);

    return BodyAgeResult(
      chronologicalAge: input.age,
      bodyAge: bodyAge,
      ageDifferenceYears:
          double.parse(ageDiff.toStringAsFixed(1)),
      confidence: confidence,
      components: components,
      derivedMetrics: BodyAgeDerivedMetrics(
        bmi: bmi != null ? double.parse(bmi.toStringAsFixed(1)) : null,
        bmrKcal:
            bmrKcal != null ? double.parse(bmrKcal.toStringAsFixed(0)) : null,
        vo2maxUsed: vo2maxUsed,
      ),
      missingInputs: missingInputs,
      dataQualityFlags: dataQualityFlags,
      topLevers: levers,
      disclaimer: _disclaimer,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY SCORING FUNCTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cardiorespiratory Fitness — 30% base weight.
  /// Uses VO2 max and/or HR recovery.
  _ScoredCategory? _scoreCardiorespiratory(
      BodyAgeInput input, bool rhrValid) {
    final inputs = <String>[];
    final percentiles = <double>[];

    // VO2 max percentile (ACSM / Cooper Institute norms)
    if (input.vo2maxDevice != null && input.vo2maxDevice! > 0) {
      inputs.add('VO2 max (${input.vo2maxDevice!.toStringAsFixed(1)} mL/kg/min)');
      percentiles
          .add(_vo2maxPercentile(input.vo2maxDevice!, input.age, input.sex));
    }

    // HR Recovery percentile
    if (input.hrRecovery1min != null && input.hrRecovery1min! > 0) {
      inputs.add('HR recovery (${input.hrRecovery1min!.toStringAsFixed(0)} bpm drop)');
      percentiles.add(_hrRecoveryPercentile(input.hrRecovery1min!));
    }

    // Resting HR as supplementary cardio signal
    if (rhrValid && percentiles.isEmpty) {
      inputs.add('Resting HR (${input.restingHrAvg30d!.toStringAsFixed(0)} bpm)');
      percentiles.add(_restingHrPercentile(
          input.restingHrAvg30d!, input.age, input.sex));
    }

    if (percentiles.isEmpty) return null;

    final avgPercentile =
        percentiles.reduce((a, b) => a + b) / percentiles.length;
    final offset = _percentileToOffset(avgPercentile);

    return _ScoredCategory(
      category: 'Cardiorespiratory Fitness',
      baseWeight: 0.30,
      percentile: avgPercentile,
      percentileRange: _percentileRangeString(avgPercentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _cardioNote(avgPercentile),
    );
  }

  /// Body Composition — 20% base weight.
  _ScoredCategory? _scoreBodyComposition(
      BodyAgeInput input, double? bmi, bool heightValid, bool weightValid) {
    if (!heightValid || !weightValid || bmi == null) return null;

    final inputs = <String>[];
    inputs.add('BMI (${bmi.toStringAsFixed(1)})');

    // BMI percentile (NHANES norms — BMI is a weak indicator, de-emphasized)
    final percentile = _bmiPercentile(bmi, input.sex);

    final offset = _percentileToOffset(percentile);

    return _ScoredCategory(
      category: 'Body Composition',
      baseWeight: 0.20,
      percentile: percentile,
      percentileRange: _percentileRangeString(percentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _bodyCompNote(bmi),
    );
  }

  /// Autonomic & Recovery — 15% base weight.
  _ScoredCategory? _scoreAutonomic(BodyAgeInput input, bool rhrValid) {
    final inputs = <String>[];
    final percentiles = <double>[];

    // HRV
    if (input.hrvAvg30d != null && input.hrvAvg30d! > 0) {
      final hrvWeight = (input.hrvMetricType != null &&
              input.hrvMetricType!.isNotEmpty)
          ? 1.0
          : 0.6; // lower weight if metric type unknown
      final p = _hrvPercentile(input.hrvAvg30d!, input.age, input.sex);
      percentiles.add(p * hrvWeight + 50 * (1 - hrvWeight));
      inputs.add('HRV (${input.hrvAvg30d!.toStringAsFixed(0)} ms'
          '${input.hrvMetricType != null ? " ${input.hrvMetricType}" : ""})');
    }

    // Resting HR trend (supplement)
    if (rhrValid) {
      final p = _restingHrPercentile(
          input.restingHrAvg30d!, input.age, input.sex);
      percentiles.add(p);
      inputs.add('Resting HR trend (${input.restingHrAvg30d!.toStringAsFixed(0)} bpm)');
    }

    // HRV trend adjustment
    if (input.hrvTrend == 'rising' && percentiles.isNotEmpty) {
      final lastIdx = percentiles.length - 1;
      percentiles[lastIdx] = (percentiles[lastIdx] + 5).clamp(0, 100);
      inputs.add('HRV trend: rising');
    } else if (input.hrvTrend == 'falling' && percentiles.isNotEmpty) {
      final lastIdx = percentiles.length - 1;
      percentiles[lastIdx] = (percentiles[lastIdx] - 5).clamp(0, 100);
      inputs.add('HRV trend: falling');
    }

    if (percentiles.isEmpty) return null;

    final avgPercentile =
        percentiles.reduce((a, b) => a + b) / percentiles.length;
    final offset = _percentileToOffset(avgPercentile);

    return _ScoredCategory(
      category: 'Autonomic & Recovery',
      baseWeight: 0.15,
      percentile: avgPercentile,
      percentileRange: _percentileRangeString(avgPercentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _autonomicNote(avgPercentile),
    );
  }

  /// Sleep — 10% base weight.
  _ScoredCategory? _scoreSleep(BodyAgeInput input) {
    final inputs = <String>[];
    final percentiles = <double>[];

    if (input.sleepDurationAvgHours != null &&
        input.sleepDurationAvgHours! > 0) {
      final p = _sleepDurationPercentile(input.sleepDurationAvgHours!);
      percentiles.add(p);
      inputs.add('Sleep duration (${input.sleepDurationAvgHours!.toStringAsFixed(1)}h avg)');
    }

    if (input.sleepEfficiency != null && input.sleepEfficiency! > 0) {
      final p = _sleepEfficiencyPercentile(input.sleepEfficiency!);
      percentiles.add(p);
      inputs.add('Sleep efficiency (${input.sleepEfficiency!.toStringAsFixed(0)}%)');
    }

    if (input.deepSleepPct != null && input.remSleepPct != null) {
      final restorative = input.deepSleepPct! + input.remSleepPct!;
      final p = _restorativeSleepPercentile(restorative);
      percentiles.add(p);
      inputs.add('Deep+REM (${restorative.toStringAsFixed(0)}%)');
    }

    if (percentiles.isEmpty) return null;

    final avgPercentile =
        percentiles.reduce((a, b) => a + b) / percentiles.length;
    final offset = _percentileToOffset(avgPercentile);

    return _ScoredCategory(
      category: 'Sleep Quality',
      baseWeight: 0.10,
      percentile: avgPercentile,
      percentileRange: _percentileRangeString(avgPercentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _sleepNote(avgPercentile),
    );
  }

  /// Lifestyle & Risk Factors — 10% base weight.
  _ScoredCategory? _scoreLifestyle(BodyAgeInput input) {
    final inputs = <String>[];
    final percentiles = <double>[];

    if (input.activityMinutesWeek != null &&
        input.activityMinutesWeek! >= 0) {
      final p =
          _activityMinutesPercentile(input.activityMinutesWeek!);
      percentiles.add(p);
      inputs.add('Weekly activity (${input.activityMinutesWeek} min)');
    }

    if (input.dailyStepsAvg != null && input.dailyStepsAvg! > 0) {
      final p = _stepsPercentile(input.dailyStepsAvg!);
      percentiles.add(p);
      inputs.add('Daily steps (${input.dailyStepsAvg})');
    }

    if (input.spo2AvgSleep != null && input.spo2AvgSleep! > 0) {
      final p = _spo2Percentile(input.spo2AvgSleep!);
      percentiles.add(p);
      inputs.add('SpO2 (${input.spo2AvgSleep!.toStringAsFixed(1)}%)');
    }

    if (input.respiratoryRateSleep != null &&
        input.respiratoryRateSleep! > 0) {
      final p = _respiratoryRatePercentile(input.respiratoryRateSleep!);
      percentiles.add(p);
      inputs.add('Respiratory rate (${input.respiratoryRateSleep!.toStringAsFixed(1)} rpm)');
    }

    if (percentiles.isEmpty) return null;

    final avgPercentile =
        percentiles.reduce((a, b) => a + b) / percentiles.length;
    final offset = _percentileToOffset(avgPercentile);

    return _ScoredCategory(
      category: 'Lifestyle & Activity',
      baseWeight: 0.10,
      percentile: avgPercentile,
      percentileRange: _percentileRangeString(avgPercentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _lifestyleNote(avgPercentile),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERCENTILE ESTIMATION FUNCTIONS (approximated from published norms)
  // ═══════════════════════════════════════════════════════════════════════════

  /// VO2max percentile vs age/sex norms.
  /// Approximate ranges from ACSM's Guidelines for Exercise Testing (11th ed)
  /// and Cooper Institute normative data.
  double _vo2maxPercentile(double vo2, int age, String? sex) {
    // Age-adjusted expected VO2max (50th percentile estimates)
    double expected;
    if (sex == 'female') {
      if (age <= 29) {
        expected = 36;
      } else if (age <= 39) {
        expected = 34;
      } else if (age <= 49) {
        expected = 31;
      } else if (age <= 59) {
        expected = 28;
      } else {
        expected = 24;
      }
    } else {
      // male or averaged
      if (age <= 29) {
        expected = 44;
      } else if (age <= 39) {
        expected = 42;
      } else if (age <= 49) {
        expected = 39;
      } else if (age <= 59) {
        expected = 35;
      } else {
        expected = 31;
      }
      if (sex == null) {
        // average male/female
        expected = expected * 0.85;
      }
    }

    // Map VO2 to percentile using sigmoid-like curve around expected
    final deviation = (vo2 - expected) / expected;
    // +25% → ~90th, -25% → ~10th
    final percentile = 50.0 + deviation * 160;
    return percentile.clamp(2, 98);
  }

  /// Resting HR percentile. Lower is better.
  double _restingHrPercentile(double rhr, int age, String? sex) {
    // Population median RHR varies but ~68-72 is typical for adults.
    double expected;
    if (sex == 'female') {
      expected = 74;
    } else if (sex == 'male') {
      expected = 70;
    } else {
      expected = 72;
    }

    // Lower RHR = higher percentile (better)
    final deviation = (expected - rhr) / expected;
    final percentile = 50.0 + deviation * 180;
    return percentile.clamp(2, 98);
  }

  /// HR Recovery 1-min drop percentile. Higher drop is better.
  double _hrRecoveryPercentile(double drop) {
    // Normal: 20+ bpm drop in first minute = good autonomic function
    // < 12 bpm = concerning (Cole et al. NEJM 1999)
    if (drop >= 40) return 90;
    if (drop >= 30) return 75;
    if (drop >= 20) return 60;
    if (drop >= 15) return 45;
    if (drop >= 12) return 30;
    return 15;
  }

  /// BMI percentile for body composition. Optimum ~20-24.
  double _bmiPercentile(double bmi, String? sex) {
    // U-shaped mortality curve; optimum 20-24
    if (bmi >= 20 && bmi <= 24) return 70;
    if (bmi >= 18.5 && bmi < 20) return 60;
    if (bmi > 24 && bmi <= 25) return 60;
    if (bmi > 25 && bmi <= 27) return 45;
    if (bmi > 27 && bmi <= 30) return 35;
    if (bmi > 30 && bmi <= 35) return 22;
    if (bmi > 35) return 12;
    if (bmi < 18.5 && bmi >= 17) return 40;
    if (bmi < 17) return 25;
    return 50;
  }

  /// HRV percentile vs age norms.
  /// RMSSD norms from Nunan et al. 2010, HUNT Fitness Study.
  double _hrvPercentile(double hrv, int age, String? sex) {
    // Age-adjusted 50th percentile HRV (RMSSD, ms)
    double expected;
    if (age <= 29) {
      expected = 45;
    } else if (age <= 39) {
      expected = 38;
    } else if (age <= 49) {
      expected = 30;
    } else if (age <= 59) {
      expected = 25;
    } else {
      expected = 20;
    }

    final deviation = (hrv - expected) / expected;
    final percentile = 50.0 + deviation * 120;
    return percentile.clamp(2, 98);
  }

  /// Sleep duration percentile. Optimum ~7-9h.
  double _sleepDurationPercentile(double hours) {
    if (hours >= 7.0 && hours <= 9.0) return 70;
    if (hours >= 6.5 && hours < 7.0) return 50;
    if (hours > 9.0 && hours <= 9.5) return 60;
    if (hours >= 6.0 && hours < 6.5) return 35;
    if (hours > 9.5 && hours <= 10) return 45;
    if (hours < 6.0) return 15;
    return 30; // >10h
  }

  /// Sleep efficiency percentile. Higher is better.
  double _sleepEfficiencyPercentile(double efficiency) {
    if (efficiency >= 90) return 80;
    if (efficiency >= 85) return 65;
    if (efficiency >= 80) return 50;
    if (efficiency >= 75) return 35;
    return 20;
  }

  /// Restorative sleep (Deep + REM %) percentile.
  double _restorativeSleepPercentile(double pct) {
    if (pct >= 45) return 80;
    if (pct >= 40) return 70;
    if (pct >= 35) return 55;
    if (pct >= 30) return 45;
    if (pct >= 25) return 30;
    return 15;
  }

  /// Weekly moderate-to-vigorous activity minutes percentile.
  /// WHO recommends 150-300 min/week.
  double _activityMinutesPercentile(int minutes) {
    if (minutes >= 300) return 85;
    if (minutes >= 225) return 72;
    if (minutes >= 150) return 60;
    if (minutes >= 100) return 45;
    if (minutes >= 60) return 30;
    return 15;
  }

  /// Daily steps percentile.
  double _stepsPercentile(int steps) {
    if (steps >= 12000) return 85;
    if (steps >= 10000) return 72;
    if (steps >= 8000) return 60;
    if (steps >= 6000) return 48;
    if (steps >= 4000) return 35;
    return 18;
  }

  /// SpO2 percentile (nocturnal). Normal ≥95%.
  double _spo2Percentile(double spo2) {
    if (spo2 >= 97) return 75;
    if (spo2 >= 95) return 60;
    if (spo2 >= 93) return 40;
    if (spo2 >= 92) return 25;
    return 12;
  }

  /// Respiratory rate percentile. Normal 12-18 rpm.
  double _respiratoryRatePercentile(double rate) {
    if (rate >= 12 && rate <= 16) return 72;
    if (rate > 16 && rate <= 18) return 55;
    if (rate > 18 && rate <= 20) return 35;
    if (rate < 12 && rate >= 10) return 55;
    if (rate > 20) return 18;
    return 25;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSION & UTILITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert percentile to year offset.
  /// 50th → 0 years. 90th → -8 years. 10th → +8 years.
  double _percentileToOffset(double percentile) {
    final offset = (50 - percentile) * 0.2;
    return offset.clamp(-10.0, 10.0);
  }

  /// Produce a human-readable percentile range string.
  String _percentileRangeString(double p) {
    final lower = max(0, (p - 5).floor());
    final upper = min(100, (p + 5).ceil());
    return '$lower–$upper';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESCRIPTIVE NOTES
  // ═══════════════════════════════════════════════════════════════════════════

  String _cardioNote(double p) {
    if (p >= 75) return 'Above-average cardiovascular fitness for your age';
    if (p >= 50) return 'Average cardiovascular fitness for your age';
    if (p >= 30) return 'Below-average; consistent aerobic exercise can improve this';
    return 'Significantly below average; gradual exercise progression recommended';
  }

  String _bodyCompNote(double bmi) {
    if (bmi >= 20 && bmi <= 24) return 'BMI in the optimal range';
    if (bmi >= 18.5 && bmi <= 25) return 'BMI within the healthy range';
    if (bmi > 25 && bmi <= 30) return 'BMI suggests overweight; waist measurement would improve accuracy';
    if (bmi > 30) return 'BMI suggests elevated body fat; this pattern is worth discussing with a clinician';
    return 'BMI below typical range';
  }

  String _autonomicNote(double p) {
    if (p >= 70) return 'Strong autonomic tone — parasympathetic recovery is robust';
    if (p >= 50) return 'Typical autonomic function for your age';
    if (p >= 30) return 'Below-average autonomic markers; stress management may help';
    return 'Autonomic indicators suggest elevated sympathetic tone';
  }

  String _sleepNote(double p) {
    if (p >= 70) return 'Sleep patterns support recovery well';
    if (p >= 50) return 'Adequate sleep, with room for improvement';
    if (p >= 30) return 'Sleep duration or quality is below recommendations';
    return 'Sleep is significantly under-optimized';
  }

  String _lifestyleNote(double p) {
    if (p >= 70) return 'Active lifestyle with good vital signs';
    if (p >= 50) return 'Moderately active with average vitals';
    if (p >= 30) return 'Below recommended activity levels';
    return 'Low activity and/or concerning vital trends';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP LEVERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<BodyAgeLever> _generateTopLevers(
      List<_ScoredCategory> scored, BodyAgeInput input,
      List<String> missing) {
    // Sort by worst offset (largest positive = most aging)
    final worst = List<_ScoredCategory>.from(scored)
      ..sort((a, b) => b.offsetYears.compareTo(a.offsetYears));

    final levers = <BodyAgeLever>[];

    for (final c in worst) {
      if (levers.length >= 3) break;
      if (c.offsetYears <= 0) continue; // only suggest for aging categories

      switch (c.category) {
        case 'Cardiorespiratory Fitness':
          levers.add(const BodyAgeLever(
            action:
                'Add 3 sessions of 30-minute moderate-intensity cardio per week '
                '(brisk walking, cycling, or swimming)',
            expectedEffect: 'Could improve VO2 max by 10–15% and lower body age by 2–4 years',
            timeframe: '8–12 weeks',
          ));
        case 'Body Composition':
          levers.add(const BodyAgeLever(
            action:
                'Target a gradual caloric deficit of 300–500 kcal/day via '
                'portion control and increased protein intake',
            expectedEffect: 'Each 5% reduction in excess body fat can lower body age by 1–2 years',
            timeframe: '12–24 weeks',
          ));
        case 'Autonomic & Recovery':
          levers.add(const BodyAgeLever(
            action:
                'Practice 10 minutes of daily breathwork or meditation '
                'and ensure 2 rest days per week',
            expectedEffect: 'Can improve HRV by 10–20% and lower resting heart rate',
            timeframe: '4–8 weeks',
          ));
        case 'Sleep Quality':
          levers.add(const BodyAgeLever(
            action:
                'Set a consistent sleep schedule (same bedtime ±30 min) and aim for 7–9 hours',
            expectedEffect: 'Optimized sleep can lower body age by 1–3 years',
            timeframe: '2–4 weeks for habit formation',
          ));
        case 'Lifestyle & Activity':
          levers.add(const BodyAgeLever(
            action:
                'Increase daily steps to 8,000+ and add 150 min/week of moderate activity',
            expectedEffect: 'Meeting WHO guidelines can lower body age by 1–3 years',
            timeframe: '4–8 weeks',
          ));
      }
    }

    // Fill remaining slots with missing-data suggestions
    if (levers.length < 3 && missing.isNotEmpty) {
      levers.add(BodyAgeLever(
        action: 'Provide ${missing.first} for a more accurate estimate',
        expectedEffect: 'Could significantly change the body age calculation',
        timeframe: 'Immediate improvement in accuracy',
      ));
    }

    // If still < 3, add general positive levers
    if (levers.length < 3) {
      levers.add(const BodyAgeLever(
        action: 'Add 2 strength-training sessions per week targeting major muscle groups',
        expectedEffect: 'Improved muscular fitness can reduce functional age by 1–3 years',
        timeframe: '8–12 weeks',
      ));
    }

    return levers.take(3).toList();
  }
}

/// Internal scored category used during computation.
class _ScoredCategory {
  final String category;
  final double baseWeight;
  double normalizedWeight;
  final double percentile;
  final String percentileRange;
  final double offsetYears;
  final List<String> inputsUsed;
  final String note;

  _ScoredCategory({
    required this.category,
    required this.baseWeight,
    this.normalizedWeight = 0,
    required this.percentile,
    required this.percentileRange,
    required this.offsetYears,
    required this.inputsUsed,
    required this.note,
  });
}
