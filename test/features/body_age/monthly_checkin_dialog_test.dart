import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoop/features/body_age/domain/entities/body_age_result.dart';
import 'package:whoop/features/body_age/domain/repositories/body_age_repository.dart';
import 'package:whoop/features/body_age/domain/repositories/body_measurement_repository.dart';
import 'package:whoop/features/body_age/presentation/components/monthly_checkin_dialog.dart';
import 'package:whoop/features/body_age/presentation/cubits/body_age_checkin/body_age_checkin_cubit.dart';

class MockMeasurementRepository implements BodyMeasurementRepository {
  double? savedWeight;
  double? savedFat;

  @override
  Future<void> saveMeasurement({
    required double weightKg,
    double? bodyFatPct,
    String source = 'manual',
    DateTime? measuredAt,
  }) async {
    savedWeight = weightKg;
    savedFat = bodyFatPct;
  }

  @override
  Future<BodyMeasurementEntry?> getLatestMeasurement() async => null;

  @override
  Future<List<BodyMeasurementEntry>> getMeasurementHistory({int limit = 12}) async => [];

  @override
  Future<bool> hasElapsedDaysSinceLastMeasurement(int days) async => true;
}

class MockBodyAgeRepository implements BodyAgeRepository {
  @override
  Future<void> saveSnapshot(FitnessBodyAgeResult result) async {}

  @override
  Future<FitnessBodyAgeResult?> getLatestSnapshot() async => null;

  @override
  Future<List<FitnessBodyAgeResult>> getSnapshotHistory({int limit = 12}) async => [];

  @override
  Future<FitnessBodyAgeResult?> calculateCurrentBodyAge() async {
    return FitnessBodyAgeResult(
      bodyAge: 25.0,
      chronologicalAge: 28,
      difference: -3.0,
      factorAges: const {},
      topImprovements: const [],
      missingFactors: const [],
      calculatedAt: DateTime.now(),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MonthlyCheckinDialog validates weight and body fat bounds', (tester) async {
    final mockMeasurementRepo = MockMeasurementRepository();
    final mockBodyAgeRepo = MockBodyAgeRepository();

    final cubit = BodyAgeCheckinCubit(
      measurementRepo: mockMeasurementRepo,
      bodyAgeRepo: mockBodyAgeRepo,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const MonthlyCheckinDialog(
              prefilledWeight: null,
              initialIsKg: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Submit with empty weight
    final submitButton = find.text('SAVE & UPDATE BODY AGE');
    expect(submitButton, findsOneWidget);

    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your weight'), findsOneWidget);

    // 2. Submit with weight out of range (< 25 kg)
    final textFields = find.byType(TextField);
    final weightField = textFields.first;

    await tester.enterText(weightField, '10');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Weight must be between 25 and 300 kg'), findsOneWidget);

    // 3. Submit with valid weight (75 kg) but invalid body fat (80%)
    await tester.enterText(weightField, '75');
    final fatField = textFields.at(1);
    await tester.enterText(fatField, '80');

    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Body fat must be between 3% and 60%'), findsOneWidget);

    // 4. Check "Skip body fat" checkbox and submit
    final skipCheckbox = find.byType(Checkbox);
    await tester.tap(skipCheckbox);
    await tester.pumpAndSettle();

    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Check saved values
    expect(mockMeasurementRepo.savedWeight, equals(75.0));
    expect(mockMeasurementRepo.savedFat, isNull);

    // Verify success view appears
    expect(find.text('CHECK-IN COMPLETE'), findsOneWidget);
    expect(find.text('25.0'), findsOneWidget);
  });
}
