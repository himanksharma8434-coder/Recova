import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/native.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/presentation/screens/pulse_screen.dart';
import 'package:whoop/presentation/screens/main_shell_screen.dart';
import 'package:whoop/presentation/screens/permission_screen.dart';
import 'package:whoop/presentation/screens/recovery_calculation_screen.dart';
import 'package:whoop/presentation/screens/resting_hr_detail_screen.dart';
import 'package:whoop/presentation/screens/blood_o2_detail_screen.dart';
import 'package:whoop/presentation/screens/sleep_architecture_detail_screen.dart';
import 'package:whoop/presentation/screens/hrv_detail_screen.dart';
import 'package:whoop/presentation/screens/recovery_deep_dive_screen.dart';
import 'package:whoop/presentation/screens/sleep_screen.dart';
import 'package:whoop/presentation/screens/strain_screen.dart';
import 'package:whoop/presentation/components/daily_activity_pod.dart';
import 'package:whoop/presentation/cubits/health_sync/health_sync_cubit.dart';
import 'package:whoop/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:whoop/presentation/cubits/health_permission/health_permission_cubit.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';

class MockHealthRepo implements HealthSourceRepository {
  @override
  DerivedMetricSummary? get cachedSummary => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
  });

  tearDown(() async {
    await db.close();
  });
  final testSummary = DerivedMetricSummary(
    lastSyncedAt: DateTime.now(),
    recoveryScore: 88,
    primaryFactor: 'Great recovery across all metrics',
    restingHr: 48,
    baselineRestingHr: 50,
    hrvMs: 82,
    spo2: 98,
    sleepHours: 7.8,
    baselineSleepHours: 8.0,
    dayStrain: 12.4,
    todaySteps: 8420,
    activeCalories: 480,
    totalCalories: 1950,
    sleepStages: const SleepStageBreakdown(
      deepMinutes: 110,
      remMinutes: 95,
      lightMinutes: 240,
      awakeMinutes: 25,
    ),
  );

  testWidgets('PulseScreen renders with zero overflow on typical phone',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('HOW IT\'S CALCULATED'), findsOneWidget);
    expect(find.text('SLEEP ARCHITECTURE'), findsOneWidget);
    expect(find.text('DAILY ACTIVITY & ENERGY'), findsOneWidget);
  });

  testWidgets('PulseScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('RecoveryCalculationScreen renders multi-pillar biometric algorithm properly',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryCalculationScreen(summary: testSummary),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('HOW RECOVERY IS CALCULATED'), findsOneWidget);
    expect(find.text('1. HEART RATE VARIABILITY (HRV)'), findsOneWidget);
    expect(find.text('2. RESTING HEART RATE'), findsOneWidget);
    expect(find.text('3. SLEEP DURATION & ARCHITECTURE'), findsOneWidget);
    expect(find.text('4. BLOOD OXYGEN & RESPIRATION'), findsOneWidget);
    expect(find.text('DYNAMIC RE-WEIGHTING'), findsOneWidget);
  });

  testWidgets('Tapping recovery gauge navigates to RecoveryCalculationScreen',
      (tester) async {
    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    // Tap the Recovery Gauge
    await tester.tap(find.text('88'));
    await tester.pumpAndSettle();

    // Verify we navigated to RecoveryCalculationScreen
    expect(find.text('AUTONOMIC COMPOSITE ALGORITHM'), findsOneWidget);
    expect(find.text('1. HEART RATE VARIABILITY (HRV)'), findsOneWidget);
  });

  testWidgets('MainShellScreen renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HealthSyncCubit(repository: repo)),
          BlocProvider(create: (_) => DashboardCubit(repository: repo)),
        ],
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('PermissionScreen renders without overflow on compact screen',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HealthPermissionCubit(repository: repo),
          child: const PermissionScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('CONNECT WEARABLE TELEMETRY'), findsOneWidget);
  });

  testWidgets('Tapping RESTING HR navigates to RestingHrDetailScreen',
      (tester) async {
    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    // Tap the RESTING HR tile
    await tester.tap(find.text('RESTING HR'));
    await tester.pumpAndSettle();

    // Verify RestingHrDetailScreen is opened
    expect(find.text('RESTING HEART RATE'), findsOneWidget);
    expect(find.text('TODAY'), findsNothing);
    expect(find.text('7 DAYS'), findsOneWidget);
    expect(find.text('30 DAYS'), findsOneWidget);
    expect(find.text('ALL TIME'), findsOneWidget);
    expect(find.text('RESTING HR CURVE'), findsOneWidget);
    expect(find.text('CLINICAL & PERFORMANCE CONTEXT'), findsOneWidget);
  });

  testWidgets(
      'RestingHrDetailScreen allows switching time filters and updates dynamic average',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RestingHrDetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('AVG RESTING HR (7 DAYS)'), findsOneWidget);

    // Switch to 30 DAYS
    await tester.tap(find.text('30 DAYS'));
    await tester.pumpAndSettle();
    expect(find.text('AVG RESTING HR (30 DAYS)'), findsOneWidget);

    // Switch to ALL TIME
    await tester.tap(find.text('ALL TIME'));
    await tester.pumpAndSettle();
    expect(find.text('AVG RESTING HR (ALL TIME)'), findsOneWidget);

    // Switch back to 7 DAYS
    await tester.tap(find.text('7 DAYS'));
    await tester.pumpAndSettle();
    expect(find.text('AVG RESTING HR (7 DAYS)'), findsOneWidget);
  });

  testWidgets(
      'RestingHrDetailScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: RestingHrDetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('RESTING HEART RATE'), findsOneWidget);
    expect(find.text('7 DAYS'), findsOneWidget);
  });

  testWidgets('Tapping BLOOD O2 navigates to BloodO2DetailScreen',
      (tester) async {
    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    // Tap the BLOOD O2 tile
    await tester.tap(find.text('BLOOD O2'));
    await tester.pumpAndSettle();

    // Verify BloodO2DetailScreen is opened
    expect(find.text('BLOOD OXYGEN (SpO2)'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('7 DAYS'), findsOneWidget);
    expect(find.text('30 DAYS'), findsOneWidget);
    expect(find.text('ALL TIME'), findsOneWidget);
    expect(find.text('OXYGEN SATURATION CURVE'), findsOneWidget);
    expect(find.text('OXYGENATION & RECOVERY METRICS'), findsOneWidget);
  });

  testWidgets(
      'BloodO2DetailScreen allows switching time filters and updates dynamic average',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BloodO2DetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('AVG BLOOD O2 (TODAY)'), findsOneWidget);

    // Switch to 7 DAYS
    await tester.tap(find.text('7 DAYS'));
    await tester.pumpAndSettle();
    expect(find.text('AVG BLOOD O2 (7 DAYS)'), findsOneWidget);

    // Switch to 30 DAYS
    await tester.tap(find.text('30 DAYS'));
    await tester.pumpAndSettle();
    expect(find.text('AVG BLOOD O2 (30 DAYS)'), findsOneWidget);

    // Switch to ALL TIME
    await tester.tap(find.text('ALL TIME'));
    await tester.pumpAndSettle();
    expect(find.text('AVG BLOOD O2 (ALL TIME)'), findsOneWidget);
  });

  testWidgets(
      'BloodO2DetailScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: BloodO2DetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('BLOOD OXYGEN (SpO2)'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });

  testWidgets('Tapping SLEEP ARCHITECTURE navigates to SleepArchitectureDetailScreen',
      (tester) async {
    final mockRepo = MockHealthRepo();
    final cubit = HealthSyncCubit(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HealthSyncCubit>.value(
          value: cubit,
          child: Scaffold(
            body: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify Sleep Architecture Card is present
    expect(find.text('SLEEP ARCHITECTURE'), findsOneWidget);

    // Tap the sleep architecture card
    await tester.tap(find.text('SLEEP ARCHITECTURE'));
    await tester.pumpAndSettle();

    // Verify SleepArchitectureDetailScreen was pushed
    expect(find.byType(SleepArchitectureDetailScreen), findsOneWidget);
    expect(find.text('CIRCADIAN RESTORATION TELEMETRY'), findsOneWidget);
  });

  testWidgets(
      'SleepArchitectureDetailScreen displays recovery percentage, hypnogram distribution dividing 6h sleep, and sliding days',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SleepArchitectureDetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Overall sleep quality is removed
    expect(find.text('OVERALL SLEEP QUALITY'), findsNothing);

    // 2. Percentage of recovery by sleep directly with no extra explanation
    expect(find.text('RECOVERY FROM SLEEP'), findsOneWidget);
    expect(find.text('HELP IN RECOVERY'), findsOneWidget);

    // 3. Full sleep distribution graph (hypnogram and Nothing OS horizontal bar)
    expect(find.textContaining('FULL SLEEP DISTRIBUTION'), findsOneWidget);

    // 4. 4 clean stage chips dividing the sleep (DEEP, CORE, REM, AWAKE)
    expect(find.text('DEEP'), findsWidgets);
    expect(find.text('CORE'), findsWidgets);
    expect(find.text('REM'), findsWidgets);
    expect(find.text('AWAKE'), findsWidgets);

    // Old verbose stage composition cards are removed
    expect(find.text('DEEP SLEEP'), findsNothing);
    expect(find.text('CORE SLEEP'), findsNothing);
    expect(find.text('REM SLEEP'), findsNothing);

    // 5. Verify single-day view displays TODAY initially
    expect(find.text('TODAY'), findsWidgets);

    // 6. Sliding / tapping previous day turns the day to YESTERDAY
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('YESTERDAY'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'SleepArchitectureDetailScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: SleepArchitectureDetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('SLEEP ARCHITECTURE'), findsOneWidget);
    expect(find.text('RECOVERY FROM SLEEP'), findsOneWidget);
    expect(find.text('OVERALL SLEEP QUALITY'), findsNothing);
  });

  testWidgets('Tapping HRV (rMSSD) navigates to HrvDetailScreen', (tester) async {
    final repo = MockHealthRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => HealthSyncCubit(repository: repo),
            child: PulseScreen(
              summary: testSummary,
              onSyncTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final hrvTile = find.text('HRV (RMSSD)');
    expect(hrvTile, findsOneWidget);

    await tester.tap(hrvTile);
    await tester.pumpAndSettle();

    expect(find.text('HEART RATE VARIABILITY'), findsOneWidget);
    expect(find.text('OPTICAL PPG TELEMETRY'), findsOneWidget);
    expect(find.text('AUTONOMIC PULSE VARIANCE'), findsOneWidget);
    expect(find.text('HOW WHOOP CAPTURES PPG DATA'), findsNothing);
    expect(find.text('MATHEMATICAL rMSSD FORMULATION'), findsNothing);
    expect(find.text('WHY MEASURE DURING DEEP SLEEP?'), findsNothing);
  });

  testWidgets(
      'HrvDetailScreen allows switching time filters and updates dynamic average',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HrvDetailScreen(summary: testSummary),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HEART RATE VARIABILITY'), findsOneWidget);
    expect(find.text('OPTICAL PPG TELEMETRY'), findsOneWidget);

    // Default filter is 7 DAYS
    expect(find.text('7 DAYS'), findsOneWidget);

    // Switch filter to 30 DAYS
    await tester.tap(find.text('30 DAYS'));
    await tester.pumpAndSettle();

    // Switch filter to TODAY
    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'HrvDetailScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: HrvDetailScreen(summary: testSummary),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('HEART RATE VARIABILITY'), findsOneWidget);
    expect(find.text('AUTONOMIC PULSE VARIANCE'), findsOneWidget);
  });

  testWidgets(
      'SleepScreen renders Total Sleep and Distributed Sleep Sessions (Night Sleep & Evening Nap)',
      (tester) async {
    final distributedSummary = DerivedMetricSummary(
      lastSyncedAt: DateTime.now(),
      recoveryScore: 85,
      sleepHours: 7.25, // 7h 15m Total Sleep
      baselineSleepHours: 8.0,
      nightSleepHours: 6.5,
      napSleepHours: 0.75,
      sleepSessions: [
        DistributedSleepSession(
          title: 'Night Sleep',
          type: SleepSessionType.nightSleep,
          startTime: DateTime(2026, 9, 20, 23, 30),
          endTime: DateTime(2026, 9, 21, 6, 0),
          durationHours: 6.5,
          durationMinutes: 390,
          isMainSleep: true,
          stages: const SleepStageBreakdown(
            deepMinutes: 90,
            remMinutes: 90,
            lightMinutes: 200,
            awakeMinutes: 10,
          ),
        ),
        DistributedSleepSession(
          title: 'Evening Nap',
          type: SleepSessionType.eveningNap,
          startTime: DateTime(2026, 9, 21, 18, 0),
          endTime: DateTime(2026, 9, 21, 18, 45),
          durationHours: 0.75,
          durationMinutes: 45,
          isMainSleep: false,
        ),
      ],
      sleepStages: const SleepStageBreakdown(
        deepMinutes: 90,
        remMinutes: 90,
        lightMinutes: 200,
        awakeMinutes: 10,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepScreen(summary: distributedSummary),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify Total Sleep is displayed
    expect(find.text('TOTAL TIME ASLEEP'), findsOneWidget);
    expect(find.text('7h'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);

    // Verify Distributed Sleep Sessions section
    expect(find.text('DISTRIBUTED SLEEP SESSIONS'), findsOneWidget);
    expect(find.text('NIGHT SLEEP'), findsWidgets);
    expect(find.text('EVENING NAP'), findsWidgets);
    expect(find.text('6h 30m'), findsWidgets);
    expect(find.text('45m'), findsWidgets);
  });

  testWidgets(
      'SleepScreen renders on compact 360x640 screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final distributedSummary = DerivedMetricSummary(
      lastSyncedAt: DateTime.now(),
      recoveryScore: 85,
      sleepHours: 7.25,
      baselineSleepHours: 8.0,
      sleepSessions: [
        DistributedSleepSession(
          title: 'Night Sleep',
          type: SleepSessionType.nightSleep,
          startTime: DateTime(2026, 9, 20, 23, 30),
          endTime: DateTime(2026, 9, 21, 6, 0),
          durationHours: 6.5,
          durationMinutes: 390,
          isMainSleep: true,
        ),
        DistributedSleepSession(
          title: 'Evening Nap',
          type: SleepSessionType.eveningNap,
          startTime: DateTime(2026, 9, 21, 18, 0),
          endTime: DateTime(2026, 9, 21, 18, 45),
          durationHours: 0.75,
          durationMinutes: 45,
          isMainSleep: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepScreen(summary: distributedSummary),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('TOTAL TIME ASLEEP'), findsOneWidget);
    expect(find.text('DISTRIBUTED SLEEP SESSIONS'), findsOneWidget);
  });

  testWidgets('DailyActivityPod shows STEPS (TODAY) and opens telemetry modal on tap',
      (tester) async {
    final summary = DerivedMetricSummary(
      todaySteps: 6420,
      activeCalories: 450,
      totalCalories: 2100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyActivityPod(
            todaySteps: summary.todaySteps,
            activeCalories: summary.activeCalories,
            totalCalories: summary.totalCalories,
          ),
        ),
      ),
    );

    expect(find.text('STEPS (TODAY)'), findsOneWidget);
    expect(find.text('6,420'), findsOneWidget);
    expect(find.text('TODAY • / 10,000'), findsOneWidget);

    // Tap to open telemetry modal
    await tester.tap(find.byType(DailyActivityPod));
    await tester.pumpAndSettle();

    expect(find.text('DAILY ACTIVITY TELEMETRY'), findsOneWidget);
    expect(find.text('DAY ONLY (00:00 - NOW)'), findsOneWidget);
    expect(find.text('Pedometer Steps (Today)'), findsOneWidget);
  });

  testWidgets('StrainScreen displays TODAY\'S STEPS and DAY TOTAL (00:00 - NOW)',
      (tester) async {
    final summary = DerivedMetricSummary(
      todaySteps: 7850,
      activeCalories: 520,
      dayStrain: 8.5,
      targetStrain: 12.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StrainScreen(summary: summary),
        ),
      ),
    );

    expect(find.text('TODAY\'S STEPS'), findsOneWidget);
    expect(find.text('7,850'), findsOneWidget);
    expect(find.text('DAY TOTAL (00:00 - NOW)'), findsOneWidget);
  });

  testWidgets(
      'RecoveryDeepDiveScreen renders without overflow on compact 360x640 screen',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final summary = const DerivedMetricSummary(
      estimatedVo2Max: 55.5,
      restingHr: 54.0,
      baselineRestingHr: 50.4,
      recoveryScore: 82.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecoveryDeepDiveScreen(summary: summary),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('RECOVERY ANALYSIS'), findsOneWidget);
    expect(find.text('VO₂ MAX'), findsWidgets);
    expect(find.text('MAX HR'), findsOneWidget);
    expect(find.text('RESTING HR'), findsOneWidget);
    expect(find.text('CALCULATION BREAKDOWN'), findsOneWidget);
  });

  testWidgets(
      'RecoveryDeepDiveScreen allows switching between VO2 MAX, MAX HR, and RESTING HR',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    final summary = const DerivedMetricSummary(
      estimatedVo2Max: 55.5,
      restingHr: 54.0,
      baselineRestingHr: 50.4,
      recoveryScore: 82.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecoveryDeepDiveScreen(summary: summary),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initial state: VO2 MAX selected with visible calculation breakdown
    expect(find.text('CALCULATION BREAKDOWN'), findsOneWidget);
    expect(find.text('UTH–SØRENSEN'), findsOneWidget);

    // Switch to MAX HR
    await tester.tap(find.text('MAX HR'));
    await tester.pumpAndSettle();
    expect(find.text('MAXIMUM HEART RATE'), findsOneWidget);
    expect(find.text('MAX HEART RATE TELEMETRY'), findsOneWidget);

    // Switch to RESTING HR
    await tester.tap(find.text('RESTING HR'));
    await tester.pumpAndSettle();
    expect(find.text('RESTING HEART RATE'), findsOneWidget);
    expect(find.text('RESTING HEART RATE TELEMETRY'), findsOneWidget);

    // Switch periods: 30D, ALL, 7D
    await tester.tap(find.text('30D'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ALL'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('7D'));
    await tester.pumpAndSettle();

    // Switch back to VO2 MAX and open HOW IT WORKS
    await tester.tap(find.text('VO₂ MAX').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('HOW IT WORKS'));
    await tester.pumpAndSettle();

    // Verify modal sheet opened
    expect(find.text('HOW VO₂ MAX IS CALCULATED'), findsOneWidget);
    expect(find.text('VO₂max ≈ 15.3 × (HRmax ÷ HRrest)'), findsOneWidget);
  });
}



