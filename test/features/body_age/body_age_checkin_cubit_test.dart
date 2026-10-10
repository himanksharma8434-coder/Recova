import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoop/features/body_age/domain/entities/body_age_result.dart';
import 'package:whoop/features/body_age/domain/repositories/body_age_repository.dart';
import 'package:whoop/features/body_age/domain/repositories/body_measurement_repository.dart';
import 'package:whoop/features/body_age/presentation/cubits/body_age_checkin/body_age_checkin_cubit.dart';
import 'package:whoop/features/body_age/presentation/cubits/body_age_checkin/body_age_checkin_state.dart';

class FakeMeasurementRepository implements BodyMeasurementRepository {
  BodyMeasurementEntry? latest;
  bool elapsedResult = true;

  @override
  Future<void> saveMeasurement({
    required double weightKg,
    double? bodyFatPct,
    String source = 'manual',
    DateTime? measuredAt,
  }) async {
    latest = BodyMeasurementEntry(
      id: 1,
      userId: 'test_user',
      measuredAt: measuredAt ?? DateTime.now(),
      weightKg: weightKg,
      bodyFatPct: bodyFatPct,
      source: source,
      synced: false,
    );
  }

  @override
  Future<BodyMeasurementEntry?> getLatestMeasurement() async => latest;

  @override
  Future<List<BodyMeasurementEntry>> getMeasurementHistory({int limit = 12}) async =>
      latest != null ? [latest!] : [];

  @override
  Future<bool> hasElapsedDaysSinceLastMeasurement(int days) async => elapsedResult;
}

class FakeBodyAgeRepository implements BodyAgeRepository {
  FitnessBodyAgeResult? latest;

  @override
  Future<void> saveSnapshot(FitnessBodyAgeResult result) async {
    latest = result;
  }

  @override
  Future<FitnessBodyAgeResult?> getLatestSnapshot() async => latest;

  @override
  Future<List<FitnessBodyAgeResult>> getSnapshotHistory({int limit = 12}) async =>
      latest != null ? [latest!] : [];

  @override
  Future<FitnessBodyAgeResult?> calculateCurrentBodyAge() async {
    return FitnessBodyAgeResult(
      bodyAge: 28.5,
      chronologicalAge: 30,
      difference: -1.5,
      factorAges: const {},
      topImprovements: const [],
      missingFactors: const [],
      calculatedAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMeasurementRepository fakeMeasurementRepo;
  late FakeBodyAgeRepository fakeBodyAgeRepo;
  late BodyAgeCheckinCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeMeasurementRepo = FakeMeasurementRepository();
    fakeBodyAgeRepo = FakeBodyAgeRepository();
    cubit = BodyAgeCheckinCubit(
      measurementRepo: fakeMeasurementRepo,
      bodyAgeRepo: fakeBodyAgeRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('BodyAgeCheckinCubit Tests', () {
    test('Initial state is BodyAgeCheckinInitial', () {
      expect(cubit.state, isA<BodyAgeCheckinInitial>());
    });

    test('Does not prompt if reminders are disabled in settings', () async {
      SharedPreferences.setMockInitialValues({
        BodyAgeCheckinCubit.keyMonthlyReminderEnabled: false,
      });

      await cubit.evaluateEligibility();
      expect(cubit.state, isA<BodyAgeCheckinInitial>());
    });

    test('Prompts when 30 days have elapsed and user is past onboarding', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      SharedPreferences.setMockInitialValues({
        BodyAgeCheckinCubit.keyFirstOpenDate: pastDate.millisecondsSinceEpoch,
        BodyAgeCheckinCubit.keyWeightUnitKg: true,
      });
      fakeMeasurementRepo.elapsedResult = true;

      await cubit.evaluateEligibility();
      expect(cubit.state, isA<BodyAgeCheckinPrompt>());
    });

    test('Does not prompt if less than 30 days elapsed', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      SharedPreferences.setMockInitialValues({
        BodyAgeCheckinCubit.keyFirstOpenDate: pastDate.millisecondsSinceEpoch,
      });
      fakeMeasurementRepo.elapsedResult = false; // < 30 days

      await cubit.evaluateEligibility();
      expect(cubit.state, isA<BodyAgeCheckinInitial>());
    });

    test('Snooze sets 3-day timestamp and emits dismissed', () async {
      await cubit.snoozeCheckin();
      expect(cubit.state, equals(const BodyAgeCheckinDismissed('snoozed')));

      final prefs = await SharedPreferences.getInstance();
      final snoozeMs = prefs.getInt(BodyAgeCheckinCubit.keySnoozeUntil);
      expect(snoozeMs, isNotNull);

      final snoozeDate = DateTime.fromMillisecondsSinceEpoch(snoozeMs!);
      final now = DateTime.now();
      expect(snoozeDate.difference(now).inDays, inInclusiveRange(2, 3));
    });

    test('Skip this month sets 30-day timestamp and emits dismissed', () async {
      await cubit.skipThisMonth();
      expect(cubit.state, equals(const BodyAgeCheckinDismissed('skipped')));

      final prefs = await SharedPreferences.getInstance();
      final snoozeMs = prefs.getInt(BodyAgeCheckinCubit.keySnoozeUntil);
      expect(snoozeMs, isNotNull);

      final snoozeDate = DateTime.fromMillisecondsSinceEpoch(snoozeMs!);
      final now = DateTime.now();
      expect(snoozeDate.difference(now).inDays, inInclusiveRange(29, 30));
    });

    test('SaveCheckin converts unit, updates DB and emits Success state', () async {
      // User enters 165 lbs
      await cubit.saveCheckin(
        weightInput: 165.0,
        isKg: false,
        bodyFatPct: 15.0,
      );

      expect(cubit.state, isA<BodyAgeCheckinSuccess>());
      final success = cubit.state as BodyAgeCheckinSuccess;
      expect(success.newBodyAge, equals(28.5));
      expect(fakeMeasurementRepo.latest, isNotNull);
      // 165 lbs ~ 74.8 kg
      expect(fakeMeasurementRepo.latest!.weightKg, closeTo(74.8, 0.2));
      expect(fakeMeasurementRepo.latest!.bodyFatPct, equals(15.0));
    });
  });
}
