import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/body_engine/body_engine.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/domain/services/data_management_service.dart';
import 'package:whoop/presentation/cubits/health_sync/health_sync_cubit.dart';
import 'package:whoop/presentation/screens/pulse_screen.dart';
import 'package:whoop/presentation/screens/trust_center_screen.dart';
import 'package:whoop/presentation/screens/wearable_signal_comparator_screen.dart';

class MockHealthRepo implements HealthSourceRepository {
  @override
  DerivedMetricSummary? get cachedSummary => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 6: Engine Background Isolate Offloading Tests', () {
    test('EngineIsolateRunner computes accurate physiological pipeline output', () async {
      const input = EnginePipelineInput(
        daysOfData: 14,
        todayRmssdMs: 65.0,
        hrvHistory7d: [62.0, 64.0, 66.0, 61.0, 65.0, 67.0, 63.0],
        hrvHistory60d: [60.0, 62.0, 65.0, 64.0, 63.0],
        todayRhrBpm: 52.0,
        rhrHistory7d: [53.0, 52.0, 54.0, 53.0, 51.0, 52.0, 53.0],
        rhrHistory60d: [53.0, 52.0, 54.0, 53.0],
        lastNightAsleepMinutes: 460,
        deepMinutes: 90,
        remMinutes: 110,
        lightMinutes: 230,
        awakeMinutes: 30,
        baselineNeedMinutes: 480,
        todayRespiratoryRate: 14.5,
        baselineRespiratoryRate: 14.2,
        todaySpo2: 98.0,
        baselineSpo2: 98.0,
        todaySkinTempDeviationCelsius: 0.1,
        userMaxHr: 190.0,
        todaySteps: 8500,
      );

      final result = await EngineIsolateRunner.run(input);

      expect(result.readiness.score, greaterThan(0));
      expect(result.readiness.score, lessThanOrEqualTo(100));
      expect(result.hrv?.trendStatus, equals(HrvTrendStatus.stable));
      expect(result.healthMonitor?.hasSystemicAnomaly, isFalse);
      expect(result.load?.dayLoadScore, greaterThan(0.0));
      expect(result.sleep?.sleepScore, greaterThan(0));
    });

    test('EngineIsolateRunner handles minimal and cold-start baseline without throwing', () async {
      const input = EnginePipelineInput(
        daysOfData: 1,
        todayRmssdMs: 45.0,
        todayRhrBpm: 60.0,
      );

      final result = await EngineIsolateRunner.run(input);
      expect(result.readiness.score, isNull);
      expect(result.readiness.confidence, equals(ReadinessConfidence.calibrating));
      expect(result.hrv?.trendStatus, equals(HrvTrendStatus.calibrating));
    });
  });

  group('Phase 6: Wearable BLE Signal Integrity & Comparator Tests', () {
    const comparator = ComparatorEngine();

    test('Resting Supine scenario produces high correlation and excellent quality', () {
      final ecg = [840.0, 860.0, 890.0, 875.0, 830.0, 810.0, 825.0, 870.0, 895.0, 910.0];
      final ppg = [842.0, 858.0, 893.0, 871.0, 834.0, 807.0, 828.0, 866.0, 899.0, 908.0];

      final result = comparator.compareSignals(
        ecgRrIntervalsMs: ecg,
        ppgPeakIntervalsMs: ppg,
      );

      expect(result.pairedBeatsCount, equals(10));
      expect(result.pearsonCorrelation, greaterThan(0.95));
      expect(result.meanAbsoluteErrorMs, lessThan(10.0));
      expect(result.signalQualityIndexPct, greaterThanOrEqualTo(90.0));
      expect(result.qualityLevel, equals(SignalQualityLevel.excellent));
      expect(result.ecgProvenance, equals(VitalProvenance.sensorHardware));
      expect(result.ppgProvenance, equals(VitalProvenance.sensorHardware));
      expect(result.rejectedArtifactCount, equals(0));
    });

    test('Dynamic Cadence scenario reflects motion displacement and degrades SQI', () {
      final ecg = [580.0, 575.0, 590.0, 585.0, 570.0, 565.0, 580.0, 595.0, 600.0, 590.0];
      final ppg = [550.0, 610.0, 560.0, 620.0, 540.0, 600.0, 550.0, 630.0, 570.0, 620.0];

      final result = comparator.compareSignals(
        ecgRrIntervalsMs: ecg,
        ppgPeakIntervalsMs: ppg,
      );

      expect(result.meanAbsoluteErrorMs, greaterThan(20.0));
      expect(result.qualityLevel, isNot(equals(SignalQualityLevel.excellent)));
      expect(result.ppgProvenance, equals(VitalProvenance.estimated));
    });

    test('Cold Perfusion scenario filters ectopic and movement artifact outliers', () {
      final ecg = [780.0, 790.0, 810.0, 800.0, 770.0, 760.0, 775.0, 795.0, 815.0, 820.0];
      // 120ms is non-physiological (<300ms), 2400ms is non-physiological (>2000ms)
      final ppg = [775.0, 798.0, 816.0, 792.0, 120.0, 755.0, 780.0, 802.0, 2400.0, 818.0];

      final result = comparator.compareSignals(
        ecgRrIntervalsMs: ecg,
        ppgPeakIntervalsMs: ppg,
      );

      expect(result.rejectedArtifactCount, greaterThanOrEqualTo(2));
      expect(result.pairedBeatsCount, lessThan(10));
    });

    test('Empty and small inputs return graceful degraded state without error', () {
      final result = comparator.compareSignals(
        ecgRrIntervalsMs: [],
        ppgPeakIntervalsMs: [],
      );

      expect(result.qualityLevel, equals(SignalQualityLevel.degraded));
      expect(result.pairedBeatsCount, equals(0));
      expect(result.diagnosticSummary, contains('Insufficient beat telemetry'));
    });
  });

  group('Phase 6: UI Widget & Accessibility Scaling Tests', () {
    testWidgets('WearableSignalComparatorScreen renders and switches telemetry scenarios',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearableSignalComparatorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SENSOR BENCHMARK'), findsOneWidget);
      expect(find.text('RESTING SUPINE'), findsOneWidget);
      expect(find.text('DYNAMIC CADENCE'), findsOneWidget);
      expect(find.text('COLD PERFUSION'), findsOneWidget);
      expect(find.text('SIGNAL QUALITY INDEX (SQI)'), findsOneWidget);
      expect(find.text('CHEST STRAP'), findsOneWidget);
      expect(find.text('WRIST WATCH'), findsOneWidget);

      // Tap 'DYNAMIC CADENCE' scenario
      await tester.tap(find.text('DYNAMIC CADENCE'));
      await tester.pumpAndSettle();

      expect(find.text('DYNAMIC CADENCE'), findsOneWidget);
      expect(find.text('WHY OPTICAL DIFFERS FROM ECG'), findsOneWidget);
    });

    testWidgets('TrustCenterScreen opens WearableSignalComparatorScreen on tap',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TrustCenterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('SENSOR ACCURACY & BLE COMPARATOR'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('SENSOR ACCURACY & BLE COMPARATOR'), findsOneWidget);

      await tester.tap(find.text('SENSOR ACCURACY & BLE COMPARATOR'));
      await tester.pumpAndSettle();

      expect(find.text('SENSOR BENCHMARK'), findsOneWidget);
    });

    testWidgets('Dynamic Type 1.5x Text Scaling renders on compact 360x640 screen without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final summary = DerivedMetricSummary(
        lastSyncedAt: DateTime.now(),
        recoveryScore: 84,
        primaryFactor: 'Optimal HRV & basal restorative sleep',
        restingHr: 50,
        baselineRestingHr: 52,
        daysOfData: 14,
        dayStrain: 12.4,
        targetStrain: 12.0,
        sleepHours: 7.8,
        baselineSleepHours: 8.0,
        todaySteps: 9400,
        habitCorrelations: const [],
        dailyInsights: const [],
        todayLoggedTags: const ['alcohol'],
      );

      final repo = MockHealthRepo();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
              ),
              child: child!,
            );
          },
          home: Scaffold(
            body: BlocProvider(
              create: (_) => HealthSyncCubit(repository: repo),
              child: PulseScreen(
                summary: summary,
                onSyncTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final err = tester.takeException();
      expect(err, isNull, reason: 'PulseScreen must not overflow at 1.5x text scale');
    });

    testWidgets('Screen reader accessibility semantics are present on core dials & cards',
        (tester) async {
      final summary = DerivedMetricSummary(
        lastSyncedAt: DateTime.now(),
        recoveryScore: 88,
        primaryFactor: 'High parasympathetic readiness',
        restingHr: 48,
        baselineRestingHr: 50,
        daysOfData: 14,
        dayStrain: 13.0,
        targetStrain: 13.0,
        sleepHours: 8.0,
        baselineSleepHours: 8.0,
        todaySteps: 10000,
        habitCorrelations: const [],
        dailyInsights: const [],
        todayLoggedTags: const [],
      );

      final repo = MockHealthRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (_) => HealthSyncCubit(repository: repo),
              child: PulseScreen(
                summary: summary,
                onSyncTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Semantics nodes are present
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Daily Recovery Score',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Cardiovascular Load',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == "Tonight's Sleep Need",
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Energy Reserve',
        ),
        findsOneWidget,
      );
    });
  });

  group('Phase 6: Data Export & Offline Sovereignty Tests', () {
    test('DataManagementService exports valid JSON with FDA and offline metadata', () async {
      final service = DataManagementService(db: db);
      final jsonStr = await service.exportToJsonString();
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(parsed['app'], equals('Recova Athletic Body Intelligence'));
      expect(parsed['storageArchitecture'], contains('100% Offline Local SQLite'));
      expect(parsed['fdaNotice'], contains('General Wellness Device Policy (Jan 2026)'));
      expect(parsed['dailyMetrics'], isA<List>());
      expect(parsed['sleepSessions'], isA<List>());
    });

    test('DataManagementService wipeAllLocalData purges all tables cleanly', () async {
      final service = DataManagementService(db: db);
      final clearedTables = await service.wipeAllLocalData();
      expect(clearedTables, greaterThanOrEqualTo(5));
    });
  });
}
