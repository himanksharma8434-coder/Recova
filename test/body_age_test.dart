import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/entities/body_age_result.dart';
import 'package:whoop/domain/usecases/compute_body_age.dart';

void main() {
  const computeBodyAge = ComputeBodyAge();

  group('Body Age Estimation Engine', () {
    test('Worked example from Master Prompt (age 21, male, healthy)', () {
      const input = BodyAgeInput(
        age: 21,
        sex: 'male',
        heightCm: 175,
        weightKg: 70,
        waistCircumferenceCm: 78,
        restingHrAvg30d: 62,
        vo2maxDevice: 46,
        sleepDurationAvgHours: 6.5,
        dailyStepsAvg: 7500,
        smokingStatus: 'never',
        dataDays: 14,
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);

      // Verify basic age properties
      expect(result!.chronologicalAge, 21);
      expect(result.bodyAge, lessThan(21.0));
      expect(result.bodyAge, greaterThanOrEqualTo(18.0));
      expect(result.ageDifferenceYears, lessThan(0.0));

      // Verify derived metrics
      expect(result.derivedMetrics.bmi, closeTo(22.86, 0.1));
      expect(result.derivedMetrics.whtr, closeTo(0.446, 0.005));
      expect(result.derivedMetrics.vo2maxUsed, 46.0);
      expect(result.derivedMetrics.bmrKcal, isNotNull);

      // Verify components scored
      expect(result.components.length, greaterThanOrEqualTo(4));
      final categories = result.components.map((c) => c.category).toList();
      expect(categories, contains('Cardiorespiratory Fitness'));
      expect(categories, contains('Body Composition'));
      expect(categories, contains('Sleep Quality'));
      expect(categories, contains('Lifestyle & Activity'));

      // Verify top levers
      expect(result.topLevers.length, 3);
      for (final lever in result.topLevers) {
        expect(lever.action, isNotEmpty);
        expect(lever.expectedEffect, isNotEmpty);
        expect(lever.timeframe, isNotEmpty);
      }

      // Verify Section 8 JSON serialization
      final json = result.toJson();
      expect(json['chronological_age'], 21);
      expect(json['body_age'], isA<double>());
      expect(json['age_difference_years'], isA<double>());
      expect(json['confidence'], isNotEmpty);
      expect(json['components'], isA<List>());
      expect(json['derived_metrics'], isA<Map<String, dynamic>>());
      expect(json['derived_metrics']['bmi'], isA<double>());
      expect(json['derived_metrics']['whtr'], isA<double>());
      expect(json['top_levers'], isA<List>());
      expect(json['disclaimer'], isNotEmpty);

      // Verify JSON round-trip / encoding validity
      final encoded = jsonEncode(json);
      expect(encoded, isNotEmpty);

      // Verify Part B user report
      final report = result.generateUserReport();
      expect(report, contains('Your estimated body age is'));
      expect(report, contains('21'));
      expect(report, contains('Top actionable levers:'));
      expect(report, contains('Confidence level:'));
      expect(report, contains(result.disclaimer));
    });

    test('Age gate: Underage (age < 18) returns null', () {
      const input = BodyAgeInput(
        age: 17,
        sex: 'female',
        heightCm: 165,
        weightKg: 55,
      );

      final result = computeBodyAge(input);
      expect(result, isNull);
    });

    test('Age gate: Age > 90 sets confidence to Low with data quality flag', () {
      const input = BodyAgeInput(
        age: 92,
        sex: 'female',
        restingHrAvg30d: 70,
        vo2maxDevice: 22,
        dataDays: 20,
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);
      expect(result!.confidence, BodyAgeConfidence.low);
      expect(
        result.dataQualityFlags.any((f) => f.contains('Age above 90')),
        isTrue,
      );
    });

    test('Sex unspecified sets confidence to Low and adds flag', () {
      const input = BodyAgeInput(
        age: 30,
        sex: null,
        restingHrAvg30d: 65,
        vo2maxDevice: 42,
        dataDays: 20,
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);
      expect(result!.confidence, BodyAgeConfidence.low);
      expect(
        result.dataQualityFlags.any((f) => f.contains('Sex not provided')),
        isTrue,
      );
    });

    test('Smoking override: current smoking adds minimum +2 years before weighting', () {
      const nonSmoker = BodyAgeInput(
        age: 35,
        sex: 'male',
        dailyStepsAvg: 9000,
        activityMinutesWeek: 180,
        smokingStatus: 'never',
      );

      const smoker = BodyAgeInput(
        age: 35,
        sex: 'male',
        dailyStepsAvg: 9000,
        activityMinutesWeek: 180,
        smokingStatus: 'current',
      );

      final nonSmokerResult = computeBodyAge(nonSmoker)!;
      final smokerResult = computeBodyAge(smoker)!;

      final nonSmokerLifestyle = nonSmokerResult.components
          .firstWhere((c) => c.category == 'Lifestyle & Activity');
      final smokerLifestyle = smokerResult.components
          .firstWhere((c) => c.category == 'Lifestyle & Activity');

      // Smoker offset should be at least 2.0 years
      expect(smokerLifestyle.offsetYears, greaterThanOrEqualTo(2.0));
      expect(smokerLifestyle.offsetYears, greaterThan(nonSmokerLifestyle.offsetYears));

      // Smoker's top levers must prioritize smoking cessation
      expect(
        smokerResult.topLevers.any((l) => l.action.toLowerCase().contains('smoking')),
        isTrue,
      );
    });

    test('Safety rules: Disordered eating caution for low BMI (<18.5)', () {
      const input = BodyAgeInput(
        age: 25,
        sex: 'female',
        heightCm: 170,
        weightKg: 45, // BMI ~ 15.6 (severely low)
        restingHrAvg30d: 68,
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);

      // BMI < 17 flag
      expect(
        result!.dataQualityFlags.any((f) => f.contains('significantly low')),
        isTrue,
      );

      // Levers should NEVER recommend caloric deficit
      for (final lever in result.topLevers) {
        expect(lever.action.toLowerCase(), isNot(contains('caloric deficit')));
      }
    });

    test('Clinical referral alerts: Elevated BP, SpO2, and abnormal RHR', () {
      const input = BodyAgeInput(
        age: 45,
        sex: 'male',
        restingHrAvg30d: 108, // > 100 bpm
        systolicBp: 145, // >= 140
        diastolicBp: 95, // >= 90
        spo2AvgSleep: 89.5, // < 92%
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);

      expect(
        result!.dataQualityFlags.any((f) => f.contains('40–100 bpm range')),
        isTrue,
      );
      expect(
        result.dataQualityFlags.any((f) => f.contains('Blood pressure')),
        isTrue,
      );
      expect(
        result.dataQualityFlags.any((f) => f.contains('Sleep SpO2 average')),
        isTrue,
      );
    });

    test('Offset capping and floor at 18', () {
      // Extremely high fitness young adult (age 19)
      const input = BodyAgeInput(
        age: 19,
        sex: 'male',
        restingHrAvg30d: 42,
        vo2maxDevice: 65,
        sleepDurationAvgHours: 8.5,
        sleepEfficiency: 95,
        deepSleepPct: 25,
        remSleepPct: 25,
        dailyStepsAvg: 16000,
        dataDays: 30,
      );

      final result = computeBodyAge(input);
      expect(result, isNotNull);
      // Floor at 18
      expect(result!.bodyAge, greaterThanOrEqualTo(18.0));
      // Offset clamp between -15 and +15
      expect(result.ageDifferenceYears, greaterThanOrEqualTo(-15.0));
      expect(result.ageDifferenceYears, lessThanOrEqualTo(15.0));
    });
  });
}
