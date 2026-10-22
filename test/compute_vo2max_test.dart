import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/usecases/compute_vo2max.dart';

void main() {
  const computeVo2Max = ComputeVo2Max();

  group('ComputeVo2Max', () {
    test('computes correctly with known values (15.3 multiplier and 190 HRmax)', () {
      // HRrest=60, HRmax=190 → 15.3 × (190/60) = 48.45
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: 190,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(48.45, 0.01));
    });

    test('uses age fallback when no exercise data', () {
      // Age=30, HRmax=220-30=190, HRrest=60 → same as above
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: null,
        userAge: 30,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(48.45, 0.01));
    });

    test('returns null when resting HR is missing', () {
      final result = computeVo2Max(
        restingHr7dBaseline: null,
        maxHrFromExercise: 190,
      );
      expect(result, isNull);
    });

    test('returns null when resting HR is zero', () {
      final result = computeVo2Max(
        restingHr7dBaseline: 0,
        maxHrFromExercise: 190,
      );
      expect(result, isNull);
    });

    test('returns null when no HRmax and no age', () {
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: null,
        userAge: null,
      );
      expect(result, isNull);
    });

    test('returns null when HRmax <= HRrest (unreasonable)', () {
      // With restingHr 195, maxHr 180 defaults to 190 <= 195
      final result = computeVo2Max(
        restingHr7dBaseline: 195,
        maxHrFromExercise: 180,
      );
      expect(result, isNull);
    });

    test('prefers exercise HRmax over age-predicted and uses higher peak', () {
      // Exercise HRmax=200, Age would predict 190
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: 200,
        userAge: 30,
      );
      expect(result, isNotNull);
      // Should use 200 with 15.3 multiplier
      expect(result!, closeTo(15.3 * (200 / 60), 0.01));
    });

    test('defaults to 190 when HRmax is not more than 190', () {
      // RHR=48, HRmax=185 -> defaults to 190
      final result = computeVo2Max(
        restingHr7dBaseline: 48,
        maxHrFromExercise: 185,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(15.3 * (190 / 48), 0.01));
    });

    test('computes VO2max accurately with 190 default and 60.2 RHR', () {
      // HRmax=183 (<= 190 -> defaults to 190), HRrest=60.2
      final result = computeVo2Max(
        restingHr7dBaseline: 60.2,
        maxHrFromExercise: 183.0,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(15.3 * (190 / 60.2), 0.01));
    });

    test('returns null for impossible values outside physiological range', () {
      // Impossibly high ratio (e.g. sensor glitch HRmax 220, RHR 30 -> 112.2 > 85.0)
      expect(
        computeVo2Max(restingHr7dBaseline: 30, maxHrFromExercise: 220),
        isNull,
      );
    });
  });
}

