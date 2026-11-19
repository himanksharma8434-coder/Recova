import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/core/di/injection.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/body_engine/body_engine.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/presentation/components/explainable_insight_card.dart';
import 'package:whoop/presentation/components/journal_quick_tap_pod.dart';
import 'package:whoop/presentation/components/workout_logging_modal.dart';
import 'package:whoop/presentation/components/workout_session_card.dart';
import 'package:whoop/presentation/screens/journal_impact_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    await sl.reset();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await configureDependencies(database: db);
  });

  tearDown(() async {
    await db.close();
    await sl.reset();
  });

  group('Phase 5 UI Component Tests', () {
    testWidgets('ExplainableInsightCard renders metric citations and dismisses', (tester) async {
      final insight = EngineInsight(
        category: 'readiness',
        priority: InsightPriority.high,
        title: 'Acute Autonomic Suppression',
        summary: 'Your overnight HRV dipped below your normal band.',
        actionableNudge: 'Keep today\'s training load in the recovery zone.',
        metricReferences: const ['HRV: 31.0 ms', 'RHR Nadir: 66 bpm'],
        date: DateTime(2026, 11, 7),
      );

      bool wasDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ExplainableInsightCard(
                insight: insight,
                onDismiss: () => wasDismissed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('READINESS'), findsOneWidget);
      expect(find.text('Acute Autonomic Suppression'), findsOneWidget);
      expect(find.text('HRV: 31.0 ms'), findsOneWidget);
      expect(find.text('RHR Nadir: 66 bpm'), findsOneWidget);
      expect(find.text('Keep today\'s training load in the recovery zone.'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(wasDismissed, isTrue);
      expect(find.text('Acute Autonomic Suppression'), findsNothing);
    });

    testWidgets('JournalQuickTapPod renders tags and toggles behavior', (tester) async {
      const summary = DerivedMetricSummary(
        todayLoggedTags: ['alcohol'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: JournalQuickTapPod(summary: summary),
            ),
          ),
        ),
      );

      expect(find.text('DAILY BEHAVIORS'), findsOneWidget);
      expect(find.text('1 LOGGED'), findsOneWidget);
      expect(find.text('HABIT IMPACT'), findsOneWidget);
      expect(find.text('Alcohol'), findsOneWidget);
      expect(find.text('Late Meal'), findsOneWidget);

      // Tap 'Late Meal' to toggle it
      await tester.tap(find.text('Late Meal'));
      await tester.pumpAndSettle();

      // Verify in Drift SQLite
      final entries = await db.journalDao.getEntriesForDay(DateTime.now());
      expect(entries.any((e) => e.tag == 'late_meal'), isTrue);
    });

    testWidgets('JournalImpactScreen displays correlation disclaimer and cards', (tester) async {
      final correlations = [
        const BehaviorCorrelation(
          tag: 'alcohol',
          displayName: 'Alcohol',
          category: 'recovery_suppressor',
          taggedDaysCount: 8,
          untaggedDaysCount: 16,
          meanReadinessWithTag: 52.0,
          meanReadinessWithoutTag: 76.0,
          readinessDelta: -24.0,
          readinessDeltaPercent: -31.6,
          rhrDeltaBpm: 5.2,
          hrvDeltaMs: -14.0,
          status: HabitConfidenceStatus.emergingTrend,
          minDaysRequired: 5,
          daysNeededForGrounded: 2,
          coachingInsight:
              '[Emerging] Alcohol correlates with -31.6% lower next-day readiness, RHR +5.2 bpm, HRV -14.0 ms (8 logged days).',
        ),
      ];

      final summary = DerivedMetricSummary(
        habitCorrelations: correlations,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: JournalImpactScreen(summary: summary),
        ),
      );

      expect(find.text('HABIT IMPACT & HABITS'), findsOneWidget);
      expect(find.text('CORRELATION, NOT CAUSATION'), findsOneWidget);
      expect(find.text('Alcohol'), findsOneWidget);
      expect(find.text('-31.6% READINESS'), findsOneWidget);
      expect(find.text('RHR +5.2 bpm'), findsOneWidget);
      expect(find.text('HRV -14.0 ms'), findsOneWidget);
    });

    testWidgets('WorkoutLoggingModal renders preview and saves workout to Drift', (tester) async {
      bool workoutLogged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      WorkoutLoggingModal.show(
                        context,
                        onWorkoutLogged: () => workoutLogged = true,
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('LOG WORKOUT SESSION'), findsOneWidget);
      expect(find.text('ENGINE PHYSIOLOGY PREVIEW'), findsOneWidget);
      expect(find.text('EST. CALORIES'), findsOneWidget);
      expect(find.text('SAVE WORKOUT TO LOCAL DB'), findsOneWidget);

      // Tap Save Workout
      await tester.tap(find.text('SAVE WORKOUT TO LOCAL DB'));
      await tester.pumpAndSettle();

      expect(workoutLogged, isTrue);

      // Verify in Drift SQLite database
      final workouts = await db.workoutSessionDao.getRecentWorkouts();
      expect(workouts.isNotEmpty, isTrue);
      expect(workouts.first.sport, equals('running'));
      expect(workouts.first.strainScore, greaterThan(0.0));
      expect(workouts.first.recoveryCost, greaterThan(0.0));
    });

    testWidgets('WorkoutSessionCard renders workout summary with strain and recovery cost', (tester) async {
      final workout = WorkoutSessionSummary(
        title: 'Morning Interval Run',
        sport: 'running',
        durationMinutes: 45,
        calories: 420.0,
        startTime: DateTime(2026, 11, 7, 7, 0),
        avgHeartRate: 152.0,
        strain: 13.8,
        recoveryCostHours: 24.0,
        zones: const HeartRateZoneBreakdown(
          zone1Minutes: 5,
          zone2Minutes: 15,
          zone3Minutes: 15,
          zone4Minutes: 10,
          zone5Minutes: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: WorkoutSessionCard(workout: workout),
            ),
          ),
        ),
      );

      expect(find.text('Morning Interval Run'), findsOneWidget);
      expect(find.text('STRAIN 13.8'), findsOneWidget);
      expect(find.text('420 kcal'), findsOneWidget);
      expect(find.text('152 bpm avg'), findsOneWidget);
      expect(find.text('~24h recovery'), findsOneWidget);
    });

    testWidgets('Compact 360x640 layout test for Journal and Workout components has 0 overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final correlations = [
        const BehaviorCorrelation(
          tag: 'alcohol',
          displayName: 'Alcohol',
          category: 'recovery_suppressor',
          taggedDaysCount: 8,
          untaggedDaysCount: 16,
          readinessDeltaPercent: -22.5,
          status: HabitConfidenceStatus.emergingTrend,
          minDaysRequired: 5,
          daysNeededForGrounded: 2,
          coachingInsight: 'Alcohol correlates with -22.5% lower next-day readiness.',
        ),
      ];

      final summary = DerivedMetricSummary(
        habitCorrelations: correlations,
        todayLoggedTags: const ['alcohol'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: JournalImpactScreen(summary: summary),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
