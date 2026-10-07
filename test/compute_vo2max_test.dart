import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/usecases/compute_vo2max.dart';

void main() {
  const computeVo2Max = ComputeVo2Max();

  group('ComputeVo2Max', () {
    test('computes correctly with known values', () {
      // HRrest=60, HRmax=190 → 15.0 × (190/60) = 47.5
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: 190,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(47.5, 0.01));
    });

    test('uses age fallback when no exercise data', () {
      // Age=30, HRmax=220-30=190, HRrest=60 → same as above
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: null,
        userAge: 30,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(47.5, 0.01));
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
      final result = computeVo2Max(
        restingHr7dBaseline: 100,
        maxHrFromExercise: 90,
      );
      expect(result, isNull);
    });

    test('prefers exercise HRmax over age-predicted', () {
      // Exercise HRmax=200, Age would predict 190
      final result = computeVo2Max(
        restingHr7dBaseline: 60,
        maxHrFromExercise: 200,
        userAge: 30,
      );
      expect(result, isNotNull);
      // Should use 200, not 190
      expect(result!, closeTo(15.0 * (200 / 60), 0.01));
    });

    test('handles typical athlete values', () {
      // Well-trained athlete: RHR=48, HRmax=185
      final result = computeVo2Max(
        restingHr7dBaseline: 48,
        maxHrFromExercise: 185,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(57.81, 0.1));
    });

    test('computes user verified VO2max accurately (HRmax=183, HRrest=60.2 -> 45.6)', () {
      final result = computeVo2Max(
        restingHr7dBaseline: 60.2,
        maxHrFromExercise: 183.0,
      );
      expect(result, isNotNull);
      expect(result!, closeTo(45.60, 0.01));
      expect(result.toStringAsFixed(1), '45.6');
    });

    test('returns null for impossible values outside physiological range', () {
      // Impossibly high ratio (e.g. sensor glitch HRmax 220, RHR 30 -> 112.2)
      expect(
        computeVo2Max(restingHr7dBaseline: 30, maxHrFromExercise: 220),
        isNull,
      );
    });

  });
}

