import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoop/domain/usecases/compute_body_age.dart';
import 'package:whoop/presentation/components/edit_body_fat_dialog.dart';
import 'package:whoop/services/user_profile_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserProfileService body fat persistence', () {
    test('saves and retrieves body fat percentage correctly', () async {
      final initialProfile = await UserProfileService.getProfile();
      expect(initialProfile.bodyFatPct, isNull);

      const updated = UserProfile(
        age: 28,
        gender: 'male',
        heightCm: 180,
        weightKg: 75,
        bodyFatPct: 14.5,
      );
      await UserProfileService.saveProfile(updated);

      final loaded = await UserProfileService.getProfile();
      expect(loaded.bodyFatPct, equals(14.5));
      expect(loaded.age, equals(28));
      expect(loaded.gender, equals('male'));
    });

    test('copyWith properly updates or preserves bodyFatPct', () {
      const profile = UserProfile(
        age: 30,
        gender: 'female',
        bodyFatPct: 22.0,
      );

      final modified = profile.copyWith(bodyFatPct: 19.5);
      expect(modified.bodyFatPct, equals(19.5));

      final preserved = profile.copyWith(weightKg: 62.0);
      expect(preserved.bodyFatPct, equals(22.0));
      expect(preserved.weightKg, equals(62.0));
    });
  });

  group('ComputeBodyAge engine body fat calculations', () {
    test('incorporates bodyFatPct into derived metrics and body composition score', () {
      const compute = ComputeBodyAge();

      const input = BodyAgeInput(
        age: 30,
        sex: 'male',
        heightCm: 178,
        weightKg: 74,
        bodyFatPct: 12.0, // Athletic male
        restingHrAvg30d: 58,
        dataDays: 14,
      );

      final result = compute(input);
      expect(result, isNotNull);
      expect(result!.derivedMetrics.bodyFatPct, equals(12.0));

      final comp = result.components.firstWhere(
        (c) => c.category == 'Body Composition',
      );
      expect(comp.inputsUsed.any((i) => i.contains('Body fat (12.0%)')), isTrue);
    });

    test('bodyFatPct handles null gracefully', () {
      const compute = ComputeBodyAge();

      const input = BodyAgeInput(
        age: 30,
        sex: 'female',
        heightCm: 165,
        weightKg: 60,
        restingHrAvg30d: 65,
        dataDays: 14,
      );

      final result = compute(input);
      expect(result, isNotNull);
      expect(result!.derivedMetrics.bodyFatPct, isNull);
    });
  });

  group('EditBodyFatDialog Widget Tests', () {
    testWidgets('displays initial value and stepper increments/decrements by 0.5%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditBodyFatDialog(
              initialBodyFat: 12.0,
              gender: 'male',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('12.0'), findsOneWidget);
      expect(find.text('ATHLETIC'), findsOneWidget);

      // Tap plus button (+0.5%) to 12.5%
      final plusButton = find.byTooltip('Increase 0.5%');
      expect(plusButton, findsOneWidget);
      await tester.tap(plusButton);
      await tester.pumpAndSettle();
      expect(find.text('12.5'), findsOneWidget);

      // Tap plus twice more to reach 13.5% (crosses into FITNESS category for males)
      await tester.tap(plusButton);
      await tester.pumpAndSettle();
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      expect(find.text('13.5'), findsOneWidget);
      expect(find.text('FITNESS'), findsOneWidget);

      // Tap minus button (-0.5%) twice
      final minusButton = find.byTooltip('Decrease 0.5%');
      expect(minusButton, findsOneWidget);
      await tester.tap(minusButton);
      await tester.pumpAndSettle();
      await tester.tap(minusButton);
      await tester.pumpAndSettle();

      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('ATHLETIC'), findsOneWidget);
    });

    testWidgets('preset chips set value immediately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditBodyFatDialog(
              initialBodyFat: null,
              gender: 'female',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final preset22 = find.text('22%');
      expect(preset22, findsOneWidget);
      await tester.tap(preset22);
      await tester.pumpAndSettle();

      expect(find.text('22.0'), findsOneWidget);
      // For female 22% is FITNESS category
      expect(find.text('FITNESS'), findsOneWidget);
    });

    testWidgets('validates out of bounds body fat percentages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditBodyFatDialog(
              initialBodyFat: 15.0,
              gender: 'male',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '75.0');
      await tester.pumpAndSettle();

      final saveButton = find.text('SAVE BODY FAT');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Body fat must be between 3.0% and 60.0%'), findsOneWidget);
    });
  });
}
