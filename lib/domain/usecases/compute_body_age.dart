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

  // ── Body Measurements (manual) ──
  final double? waistCircumferenceCm;
  final double? hipCircumferenceCm;

  // ── Lifestyle & Risk Factors ──
  final String? smokingStatus; // 'never' | 'former' | 'current' | null
  final int? stressLevel; // 1 to 10

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
    this.waistCircumferenceCm,
    this.hipCircumferenceCm,
    this.smokingStatus,
    this.stressLevel,
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

    // Clinical referral alerts (Safety Rule 3 & 5)
    if (rhrValid &&
        (input.restingHrAvg30d! > 100 || input.restingHrAvg30d! < 40)) {
      dataQualityFlags.add(
          'Resting HR (${input.restingHrAvg30d!.toStringAsFixed(0)} bpm) is outside the typical 40–100 bpm range; discuss with a clinician');
    }
    if (input.systolicBp != null &&
        input.diastolicBp != null &&
        (input.systolicBp! >= 140 || input.diastolicBp! >= 90)) {
      dataQualityFlags.add(
          'Blood pressure (${input.systolicBp!.toStringAsFixed(0)}/${input.diastolicBp!.toStringAsFixed(0)} mmHg) is elevated (>=140/90); discuss with a clinician');
    }
    if (input.spo2AvgSleep != null && input.spo2AvgSleep! < 92) {
      dataQualityFlags.add(
          'Sleep SpO2 average (${input.spo2AvgSleep!.toStringAsFixed(1)}%) is below 92%; recommend discussing with a clinician');
    }

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
      if (bmi < 17.0) {
        dataQualityFlags.add(
            'BMI (${bmi.toStringAsFixed(1)}) is significantly low; recommend speaking with a healthcare professional');
      }
    }

    double? whtr;
    if (input.waistCircumferenceCm != null &&
        heightValid &&
        input.waistCircumferenceCm! > 30) {
      whtr = input.waistCircumferenceCm! / input.heightCm!;
    }

    double? whr;
    if (input.waistCircumferenceCm != null &&
        input.hipCircumferenceCm != null &&
        input.hipCircumferenceCm! > 30) {
      whr = input.waistCircumferenceCm! / input.hipCircumferenceCm!;
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
    final bodyCompPercentile = _scoreBodyComposition(
        input, bmi, whtr, whr, heightValid, weightValid);
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
    final levers =
        _generateTopLevers(scoredComponents, input, missingInputs, bmi);

    return BodyAgeResult(
      chronologicalAge: input.age,
      bodyAge: bodyAge,
      ageDifferenceYears: double.parse(ageDiff.toStringAsFixed(1)),
      confidence: confidence,
      components: components,
      derivedMetrics: BodyAgeDerivedMetrics(
        bmi: bmi != null ? double.parse(bmi.toStringAsFixed(1)) : null,
        whtr: whtr != null ? double.parse(whtr.toStringAsFixed(3)) : null,
        whr: whr != null ? double.parse(whr.toStringAsFixed(3)) : null,
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
  /// Prioritizes waist-to-height ratio (WHtR) and waist circumference,
  /// with BMI as secondary / de-emphasized.
  _ScoredCategory? _scoreBodyComposition(
      BodyAgeInput input,
      double? bmi,
      double? whtr,
      double? whr,
      bool heightValid,
      bool weightValid) {
    final inputs = <String>[];
    final percentiles = <double>[];

    // WHtR (Waist-to-Height Ratio) - highest clinical value for central adiposity
    if (whtr != null) {
      inputs.add('WHtR (${whtr.toStringAsFixed(3)})');
      double p;
      if (whtr <= 0.45) {
        p = 70.0 + (0.45 - whtr) * 120;
      } else if (whtr <= 0.50) {
        p = 50.0 + (0.50 - whtr) * 400;
      } else {
        p = 50.0 - (whtr - 0.50) * 300;
      }
      percentiles.add(p.clamp(5, 95));
    } else if (input.waistCircumferenceCm != null &&
        input.waistCircumferenceCm! > 40) {
      inputs.add(
          'Waist (${input.waistCircumferenceCm!.toStringAsFixed(0)} cm)');
      final threshold = input.sex == 'female' ? 80.0 : 94.0;
      final diff = threshold - input.waistCircumferenceCm!;
      final p = (50.0 + diff * 2.0).clamp(5, 95);
      percentiles.add(p.toDouble());
    }

    if (whr != null) {
      inputs.add('WHR (${whr.toStringAsFixed(2)})');
    }

    // BMI percentile (NHANES norms — lower weight if WHtR present)
    if (bmi != null && heightValid && weightValid) {
      inputs.add('BMI (${bmi.toStringAsFixed(1)})');
      final p = _bmiPercentile(bmi, input.sex);
      percentiles.add(p);
    }

    if (percentiles.isEmpty) return null;

    final avgPercentile =
        percentiles.reduce((a, b) => a + b) / percentiles.length;
    final offset = _percentileToOffset(avgPercentile);

    return _ScoredCategory(
      category: 'Body Composition',
      baseWeight: 0.20,
      percentile: avgPercentile,
      percentileRange: _percentileRangeString(avgPercentile),
      offsetYears: offset,
      inputsUsed: inputs,
      note: _bodyCompNote(bmi ?? 22.0),
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

    if (input.smokingStatus != null) {
      if (input.smokingStatus == 'never') {
        percentiles.add(60);
        inputs.add('Non-smoker');
      } else if (input.smokingStatus == 'former') {
        percentiles.add(45);
        inputs.add('Former smoker');
      } else if (input.smokingStatus == 'current') {
        percentiles.add(20);
        inputs.add('Current smoker');
      }
    }

    if (input.stressLevel != null &&
        input.stressLevel! >= 1 &&
        input.stressLevel! <= 10) {
      final stressP =
          (85.0 - (input.stressLevel! - 1) * 7.0).clamp(10.0, 90.0);
      percentiles.add(stressP);
      inputs.add('Stress level (${input.stressLevel}/10)');
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
    double offset = _percentileToOffset(avgPercentile);

    // Apply smoking override: current smoking adds a minimum of +2 years to the lifestyle offset before weighting
    if (input.smokingStatus == 'current') {
      offset = max(offset + 2.0, 2.0);
      inputs.add('Smoking override (+2 yr min)');
    }

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
      List<_ScoredCategory> scored,
      BodyAgeInput input,
      List<String> missing,
      double? bmi) {
    final levers = <BodyAgeLever>[];

    // Priority lever: Smoking cessation
    if (input.smokingStatus == 'current') {
      levers.add(const BodyAgeLever(
        action:
            'Begin a smoking cessation program with professional or behavioral support',
        expectedEffect:
            'Cardiorespiratory health recovers rapidly; removes the +2 year body age penalty',
        timeframe: '12–52 weeks',
      ));
    }

    // Sort by lowest percentile (greatest opportunity for improvement)
    final sortedByOpportunity = List<_ScoredCategory>.from(scored)
      ..sort((a, b) => a.percentile.compareTo(b.percentile));

    for (final c in sortedByOpportunity) {
      if (levers.length >= 3) break;
      // If category has room for improvement (percentile < 75 or offset > 0)
      if (c.percentile >= 80 && c.offsetYears < 0) continue;

      switch (c.category) {
        case 'Cardiorespiratory Fitness':
          levers.add(const BodyAgeLever(
            action:
                'Add 3 sessions of 30-minute moderate-intensity cardio per week '
                '(brisk walking, cycling, or swimming)',
            expectedEffect:
                'Could improve VO2 max by 10–15% and lower body age by 2–4 years',
            timeframe: '8–12 weeks',
          ));
        case 'Body Composition':
          if (bmi != null && bmi < 18.5) {
            levers.add(const BodyAgeLever(
              action:
                  'Prioritize nutrient-dense meals and consult a healthcare professional regarding healthy weight maintenance',
              expectedEffect:
                  'Supports lean body mass and long-term metabolic health',
              timeframe: 'Ongoing',
            ));
          } else {
            levers.add(const BodyAgeLever(
              action:
                  'Target a gradual caloric deficit of 300–500 kcal/day via '
                  'portion control and increased protein intake',
              expectedEffect:
                  'Each 5% reduction in excess body fat can lower body age by 1–2 years',
              timeframe: '12–24 weeks',
            ));
          }
        case 'Autonomic & Recovery':
          levers.add(const BodyAgeLever(
            action:
                'Practice 10 minutes of daily breathwork or meditation '
                'and ensure 2 rest days per week',
            expectedEffect:
                'Can improve HRV by 10–20% and lower resting heart rate',
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
            expectedEffect:
                'Meeting WHO guidelines can lower body age by 1–3 years',
            timeframe: '4–8 weeks',
          ));
      }
    }

    // Fill remaining slots with missing-data suggestions
    while (levers.length < 3 && missing.isNotEmpty) {
      final mIdx = levers.where((l) => l.action.startsWith('Provide ')).length;
      if (mIdx < missing.length) {
        levers.add(BodyAgeLever(
          action: 'Provide ${missing[mIdx]} for a more accurate estimate',
          expectedEffect:
              'Improves estimate accuracy across physiological domains',
          timeframe: 'Immediate',
        ));
      } else {
        break;
      }
    }

    // Curated high-impact levers to guarantee exactly 3 top levers
    const fallbackLevers = [
      BodyAgeLever(
        action:
            'Add 2 strength-training sessions per week targeting major muscle groups',
        expectedEffect:
            'Improved muscular fitness can reduce functional age by 1–3 years',
        timeframe: '8–12 weeks',
      ),
      BodyAgeLever(
        action: 'Perform 45 minutes of weekly Zone 2 aerobic base training',
        expectedEffect: 'Enhances mitochondrial density and aerobic efficiency',
        timeframe: '6–10 weeks',
      ),
      BodyAgeLever(
        action:
            'Practice 10 minutes of daily diaphragmatic breathwork before sleep',
        expectedEffect:
            'Supports vagal tone and overnight heart rate recovery',
        timeframe: '3–6 weeks',
      ),
    ];

    for (final fb in fallbackLevers) {
      if (levers.length >= 3) break;
      if (!levers.any((l) => l.action == fb.action)) {
        levers.add(fb);
      }
    }

    return levers.take(3).toList();
  }
}

/// Internal scored category used during computation.
class _ScoredCategory {
  final String category;
  final double baseWeight;
  double normalizedWeight = 0;
  final double percentile;
  final String percentileRange;
  final double offsetYears;
  final List<String> inputsUsed;
  final String note;

  _ScoredCategory({
    required this.category,
    required this.baseWeight,
    required this.percentile,
    required this.percentileRange,
    required this.offsetYears,
    required this.inputsUsed,
    required this.note,
  });
}
