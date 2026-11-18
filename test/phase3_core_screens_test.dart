import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/body_engine/body_engine.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/presentation/cubits/health_sync/health_sync_cubit.dart';
import 'package:whoop/presentation/screens/methodology_sheet.dart';
import 'package:whoop/presentation/screens/pulse_screen.dart';
import 'package:whoop/presentation/screens/recovery_calculation_screen.dart';

class _FakeHealthRepo implements HealthSourceRepository {
  @override
  DerivedMetricSummary? get cachedSummary => null;

  @override
  Future<DerivedMetricSummary?> getLatestSummary() async => null;

  @override
  Future<bool> hasBackgroundReadPermission() async => false;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<int> syncHealthData({required String taskType}) async => 0;

  @override
  Stream<DerivedMetricSummary?> watchLatestSummary() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  final fakeRepo = _FakeHealthRepo();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrapWithScaffold(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => HealthSyncCubit(repository: fakeRepo),
          child: child,
        ),
      ),
    );
  }

  group('Phase 3 Core Screens & Explainability Tests', () {
    testWidgets('Scenario 1: New User (Day 2 Calibrating State)', (tester) async {
      final summaryDay2 = DerivedMetricSummary(
        recoveryScore: null,
        daysOfData: 2,
        restingHr: 62.0,
        hrvMs: 50.0,
        sleepHours: 7.5,
      );

      await tester.pumpWidget(wrapWithScaffold(PulseScreen(
        summary: summaryDay2,
        onSyncTap: () {},
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // Confidence badge displays calibrating day 2/3
      expect(find.text('CALIBRATING • DAY 2/3'), findsOneWidget);
      // Main headline reflects baseline accumulation
      expect(find.text('COLLECTING BASELINE'), findsOneWidget);
      // Gauge shows placeholder
      expect(find.text('--'), findsWidgets);
      // Energy reserve and gauge show calibrating state
      expect(find.text('CALIBRATING'), findsWidgets);
      expect(find.text('Unlocks in 8d'), findsOneWidget);
    });

    testWidgets('Scenario 2: Established User (Day 45 Optimal Readiness & High Confidence)', (tester) async {
      const bodyEngine = BodyEngine();
      final output = bodyEngine.processDailyPipeline(
        daysOfData: 45,
        todayRmssdMs: 82.0,
        hrvSource: HrvSource.rrIntervals,
        hrvHistory7d: [78.0, 80.0, 82.0, 81.0, 80.0, 82.0, 81.0],
        hrvHistory60d: List.generate(45, (i) => 75.0),
        todayRhrBpm: 48.0,
        rhrHistory7d: [50.0, 49.0, 50.0, 48.0, 49.0, 50.0, 49.0],
        rhrHistory60d: List.generate(45, (i) => 52.0),
        lastNightAsleepMinutes: 495,
        inBedMinutes: 520,
        baselineNeedMinutes: 480,
        userMaxHr: 195.0,
        todaySteps: 6500,
      );

      final summaryDay45 = DerivedMetricSummary(
        recoveryScore: output.readiness.score,
        engineOutput: output,
        daysOfData: 45,
        hrvMs: 82.0,
        baselineHrv: 75.0,
        restingHr: 48.0,
        baselineRestingHr: 52.0,
        sleepHours: 8.25,
        dayStrain: 6.5,
        todaySteps: 6500,
      );

      await tester.pumpWidget(wrapWithScaffold(PulseScreen(
        summary: summaryDay45,
        onSyncTap: () {},
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // Confidence badge
      expect(find.text('HIGH CONFIDENCE'), findsOneWidget);
      // Readiness Score displayed
      expect(find.text('${output.readiness.score!.round()}'), findsOneWidget);
      // Headline
      expect(find.text(output.trainingReadiness.headline.toUpperCase()), findsOneWidget);
      // Load Target Range is optimal
      expect(find.text('TARGET 14.0 - 18.0'), findsOneWidget);
      // Sleep advisor shows target
      expect(find.text('TONIGHT\'S SLEEP NEED'), findsOneWidget);
      // Key biometrics
      expect(find.text('KEY BIOMETRICS'), findsOneWidget);
    });

    testWidgets('Scenario 3: Anomalous Night (Acute Alcohol/Late Heavy Dinner)', (tester) async {
      const bodyEngine = BodyEngine();
      final output = bodyEngine.processDailyPipeline(
        daysOfData: 40,
        todayRmssdMs: 22.0, // Acute drop
        hrvSource: HrvSource.vendor,
        hrvHistory7d: [68.0, 70.0, 69.0, 68.0, 71.0, 70.0, 69.0],
        hrvHistory60d: List.generate(40, (i) => 70.0),
        todayRhrBpm: 66.0, // Elevated
        rhrHistory7d: [50.0, 51.0, 50.0, 52.0, 50.0, 51.0, 50.0],
        rhrHistory60d: List.generate(40, (i) => 50.0),
        lastNightAsleepMinutes: 300,
        baselineNeedMinutes: 480,
      );

      final summaryAnomalous = DerivedMetricSummary(
        recoveryScore: output.readiness.score,
        engineOutput: output,
        daysOfData: 40,
        hrvMs: 22.0,
        baselineHrv: 70.0,
        restingHr: 66.0,
        baselineRestingHr: 50.0,
        sleepHours: 5.0,
      );

      await tester.pumpWidget(wrapWithScaffold(PulseScreen(
        summary: summaryAnomalous,
        onSyncTap: () {},
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // Low readiness score
      expect(output.readiness.score, lessThan(35.0));
      // Restorative training target
      expect(find.text('TARGET 6.0 - 9.9'), findsOneWidget);
    });

    testWidgets('Scenario 4: Missing Telemetry with Nocturnal PPG Fallback', (tester) async {
      final summaryFallback = DerivedMetricSummary(
        recoveryScore: 58.0,
        daysOfData: 20,
        isHrvEstimated: true,
        restingHr: 56.0,
        sleepHours: 7.0,
      );

      await tester.pumpWidget(wrapWithScaffold(PulseScreen(
        summary: summaryFallback,
        onSyncTap: () {},
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // Tags estimated nocturnal PPG
      expect(find.text('ESTIMATED (NOCTURNAL PPG)'), findsOneWidget);
    });

    testWidgets('Tier 3 Deep Dive: RecoveryCalculationScreen displays version and opens methodology', (tester) async {
      final summary = DerivedMetricSummary(
        recoveryScore: 82.0,
        baselineRecoveryScore: 80.0,
        hrvMs: 65.0,
        baselineHrv: 60.0,
        restingHr: 52.0,
        baselineRestingHr: 54.0,
        sleepHours: 8.0,
      );

      await tester.pumpWidget(MaterialApp(
        home: RecoveryCalculationScreen(summary: summary),
      ));
      await tester.pumpAndSettle();

      expect(find.text('HOW RECOVERY IS CALCULATED'), findsOneWidget);
      expect(find.text('1. HEART RATE VARIABILITY (HRV)'), findsOneWidget);
      expect(find.text('2. RESTING HEART RATE'), findsOneWidget);
      expect(find.text('3. SLEEP DURATION & ARCHITECTURE'), findsOneWidget);
      expect(find.text('4. BLOOD OXYGEN & RESPIRATION'), findsOneWidget);
      expect(find.text('DYNAMIC RE-WEIGHTING'), findsOneWidget);

      // Method version badge
      expect(find.text('VERSION 2.0.0'), findsOneWidget);

      // Tapping methodology button opens MethodologySheet
      final methodologyButton = find.text('VIEW COMPLETE METHODOLOGY & CITATIONS');
      await tester.scrollUntilVisible(methodologyButton, 200);
      await tester.pumpAndSettle();
      expect(methodologyButton, findsOneWidget);
      await tester.tap(methodologyButton);
      await tester.pumpAndSettle();

      expect(find.byType(MethodologySheet), findsOneWidget);
      expect(find.text('ALGORITHM METHODOLOGY'), findsOneWidget);

      final sheetScrollable = find.descendant(
        of: find.byType(MethodologySheet),
        matching: find.byType(Scrollable),
      );
      final academicReferences = find.text('ACADEMIC REFERENCES');
      await tester.scrollUntilVisible(
        academicReferences,
        200,
        scrollable: sheetScrollable,
      );
      await tester.pumpAndSettle();
      expect(academicReferences, findsOneWidget);
    });
  });
}
