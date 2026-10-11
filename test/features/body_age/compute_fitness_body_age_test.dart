import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/features/body_age/domain/entities/body_age_factor.dart';
import 'package:whoop/features/body_age/domain/usecases/compute_body_age_usecase.dart';

void main() {
  const useCase = ComputeFitnessBodyAgeUseCase();

  group('ComputeFitnessBodyAgeUseCase', () {
    test('Under 18 throws UnderAgeException', () {
      expect(
        () => useCase.call(const ComputeFitnessBodyAgeParams(
          chronologicalAge: 17,
          sex: 'male',
          vo2max: 45.0,
          restingHr30d: 60.0,
        )),
        throwsA(isA<UnderAgeException>()),
      );
    });

    test('Fewer than 2 factors throws InsufficientDataException', () {
      expect(
        () => useCase.call(const ComputeFitnessBodyAgeParams(
          chronologicalAge: 30,
          sex: 'male',
          vo2max: 45.0, // only 1 factor
        )),
        throwsA(isA<InsufficientDataException>()),
      );
    });

    test('VO2 Max mapping for males reflects Cooper/FRIEND norms', () {
      // 30 yo male with 44 mL/kg/min (median for age 25)
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        vo2max: 44.0,
        restingHr30d: 65.0, // baseline RHR = 65 -> age 30
      ));

      expect(result.factorAges[BodyAgeFactor.vo2Max], closeTo(25.0, 0.5));
      expect(result.factorAges[BodyAgeFactor.restingHeartRate], closeTo(30.0, 0.5));
      expect(result.bodyAge, lessThan(30.0));
    });

    test('VO2 Max mapping for females reflects female median standards', () {
      // 35 yo female with 38 mL/kg/min (median for female age 25)
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 35,
        sex: 'female',
        vo2max: 38.0,
        restingHr30d: 68.0, // female median RHR = 68 -> age 35
      ));

      expect(result.factorAges[BodyAgeFactor.vo2Max], closeTo(25.0, 0.5));
      expect(result.bodyAge, closeTo(28.3, 0.5));
    });

    test('Resting Heart Rate mapping reduces age for athletic pulse', () {
      // 40 yo with 50 bpm (15 bpm below male median 65 -> -7.5 years)
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 40,
        sex: 'male',
        restingHr30d: 50.0,
        vigorousMinutesPerWeek: 160,
        vigorousDaysPerWeek: 4,
      ));

      expect(result.factorAges[BodyAgeFactor.restingHeartRate], closeTo(32.5, 0.5));
      expect(result.factorAges[BodyAgeFactor.vigorousActivity], closeTo(35.0, 0.5));
    });

    test('Activity mapping follows WHO guidelines', () {
      // Sedentary (0 mins, 0 days) -> +5.0 years
      final resultSedentary = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        vigorousMinutesPerWeek: 0,
        vigorousDaysPerWeek: 0,
        restingHr30d: 65.0,
      ));
      expect(resultSedentary.factorAges[BodyAgeFactor.vigorousActivity], closeTo(35.0, 0.1));

      // Athletic (>150 mins) -> -5.0 years
      final resultActive = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        vigorousMinutesPerWeek: 180,
        vigorousDaysPerWeek: 4,
        restingHr30d: 65.0,
      ));
      expect(resultActive.factorAges[BodyAgeFactor.vigorousActivity], closeTo(25.0, 0.1));
    });

    test('Body Fat % takes priority over BMI when both are provided', () {
      // 30 yo male with 12% body fat (athletic -> -5 yrs) but BMI is high/muscular (28.0)
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        weightKg: 85.0,
        heightCm: 175.0, // BMI = 27.7
        bodyFatPct: 12.0, // Athletic <= 13% -> -5 yrs -> 25.0
        restingHr30d: 65.0,
      ));

      expect(result.factorAges[BodyAgeFactor.bodyComposition], closeTo(25.0, 0.1));
    });

    test('BMI fallback works when Body Fat % is absent', () {
      // 30 yo male, BMI 22.0 (normal -> delta 0)
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        weightKg: 70.0,
        heightCm: 178.0, // BMI ~ 22.1
        restingHr30d: 65.0,
      ));

      expect(result.factorAges[BodyAgeFactor.bodyComposition], closeTo(30.0, 0.1));
    });

    test('Proportional weight redistribution when 2 of 4 factors are missing', () {
      // Only VO2 max (0.40) and RHR (0.20) are available.
      // Total available weight = 0.60.
      // Normalized: VO2 max = 0.40 / 0.60 = 2/3 (~66.7%), RHR = 0.20 / 0.60 = 1/3 (~33.3%).
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 40,
        sex: 'male',
        vo2max: 44.0, // age equiv ~ 25.0
        restingHr30d: 65.0, // age equiv ~ 40.0
      ));

      // Weighted: (25.0 * 2/3) + (40.0 * 1/3) = 16.67 + 13.33 = 30.0
      expect(result.bodyAge, closeTo(30.0, 0.2));
      expect(result.missingFactors, containsAll([
        BodyAgeFactor.vigorousActivity,
        BodyAgeFactor.bodyComposition,
      ]));
    });

    test('Clamping enforces minimum age 18 and max delta 25 years', () {
      // 20 yo with extreme athletic metrics
      final resultMin = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 20,
        sex: 'male',
        vo2max: 75.0,
        restingHr30d: 38.0,
      ));
      expect(resultMin.bodyAge, greaterThanOrEqualTo(18.0));

      // 30 yo with extreme poor metrics: max age cannot exceed 30 + 25 = 55
      final resultMax = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 30,
        sex: 'male',
        vo2max: 15.0,
        restingHr30d: 110.0,
      ));
      expect(resultMax.bodyAge, lessThanOrEqualTo(55.0));
    });

    test('Stale inputs older than 60 days are ignored', () {
      final now = DateTime(2026, 10, 10);
      final staleDate = DateTime(2026, 7, 1); // > 100 days ago

      expect(
        () => useCase.call(ComputeFitnessBodyAgeParams(
          chronologicalAge: 30,
          sex: 'male',
          referenceDate: now,
          vo2max: 45.0,
          vo2maxRecordedAt: staleDate, // stale, should be ignored
          restingHr30d: 60.0, // only 1 fresh factor left!
          restingHrRecordedAt: now,
        )),
        throwsA(isA<InsufficientDataException>()),
      );
    });

    test('Achievable body age is computed and lower than current body age', () {
      final result = useCase.call(const ComputeFitnessBodyAgeParams(
        chronologicalAge: 45,
        sex: 'male',
        vo2max: 30.0, // ~ 65 yrs (weakest)
        restingHr30d: 65.0, // ~ 45 yrs
        vigorousMinutesPerWeek: 60, // ~ 46 yrs
      ));

      expect(result.achievableBodyAge, isNotNull);
      expect(result.achievableBodyAge!, lessThan(result.bodyAge));
      expect(result.topImprovements.first, equals(BodyAgeFactor.vo2Max));
    });
  });
}
