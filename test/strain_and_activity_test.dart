import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/presentation/screens/strain_screen.dart';

void main() {
  group('Strain & Workout Activity Screen Tests', () {
    final now = DateTime.now();
    final sampleWorkoutsToday = [
      WorkoutSessionSummary(
        title: 'RUNNING',
        durationMinutes: 45,
        calories: 380,
        startTime: now.subtract(const Duration(hours: 4)),
      ),
      WorkoutSessionSummary(
        title: 'STRENGTH_TRAINING',
        durationMinutes: 60,
        calories: 320,
        startTime: now.subtract(const Duration(hours: 2)),
      ),
    ];

    final sampleWorkouts7d = [
      ...sampleWorkoutsToday,
      WorkoutSessionSummary(
        title: 'YOGA',
        durationMinutes: 30,
        calories: 110,
        startTime: now.subtract(const Duration(days: 2)),
      ),
      WorkoutSessionSummary(
        title: 'HIGH_INTENSITY_INTERVAL_TRAINING',
        durationMinutes: 25,
        calories: 260,
        startTime: now.subtract(const Duration(days: 3)),
      ),
      WorkoutSessionSummary(
        title: 'BASKETBALL',
        durationMinutes: 50,
        calories: 420,
        startTime: now.subtract(const Duration(days: 4)),
      ),
    ];

    final sampleSummary = DerivedMetricSummary(
      dayStrain: 12.8,
      targetStrain: 14.5,
      activeCalories: 700,
      totalCalories: 2450,
      todaySteps: 8420,
      workouts: sampleWorkoutsToday,
      workouts7d: sampleWorkouts7d,
      strainHistory7d: [
        HistoricalScorePoint(date: now.subtract(const Duration(days: 6)), score: 9.5),
        HistoricalScorePoint(date: now.subtract(const Duration(days: 5)), score: 14.2),
        HistoricalScorePoint(date: now.subtract(const Duration(days: 4)), score: 11.0),
        HistoricalScorePoint(date: now.subtract(const Duration(days: 3)), score: 13.5),
        HistoricalScorePoint(date: now.subtract(const Duration(days: 2)), score: 8.0),
        HistoricalScorePoint(date: now.subtract(const Duration(days: 1)), score: 15.1),
        HistoricalScorePoint(date: now, score: 12.8),
      ],
    );

    testWidgets('StrainScreen renders 5-second hero card and key telemetry pods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrainScreen(summary: sampleSummary),
          ),
        ),
      );

      // Header & Title
      expect(find.text('STRAIN & WORKOUTS'), findsOneWidget);
      expect(find.text('MODERATE LOAD'), findsOneWidget);

      // Hero Exertion Card
      expect(find.text('DAY STRAIN'), findsOneWidget);
      expect(find.text('12.8'), findsOneWidget);
      expect(find.text('/ 21.0'), findsWidgets);
      expect(find.text('TARGET: 14.5'), findsOneWidget);

      // 3 Bento Pods
      expect(find.text('ACTIVE ENERGY'), findsOneWidget);
      expect(find.text('700'), findsOneWidget);
      expect(find.text('TODAY\'S STEPS'), findsOneWidget);
      expect(find.text('8,420'), findsOneWidget);
      expect(find.text('DAY TOTAL (00:00 - NOW)'), findsOneWidget);
      expect(find.text('ACTIVE TIME'), findsOneWidget);

      // Today's Workouts List
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Strength Training'), findsOneWidget);
      expect(find.text('ALL ACTIVITIES'), findsOneWidget);
    });

    testWidgets('Toggling to PAST 7 DAYS displays 7-day distribution and weekly metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrainScreen(summary: sampleSummary),
          ),
        ),
      );

      // Tap PAST 7 DAYS tab
      await tester.tap(find.text('PAST 7 DAYS'));
      await tester.pumpAndSettle();

      expect(find.text('7-DAY AVERAGE STRAIN'), findsOneWidget);
      expect(find.text('DAILY EXERTION DISTRIBUTION'), findsOneWidget);
      expect(find.text('7-DAY ACTIVITIES'), findsOneWidget);
      expect(find.text('5 TOTAL'), findsOneWidget);

      // Workouts from 7 days should be listed
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Strength Training'), findsOneWidget);
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('High Intensity Interval Training'), findsOneWidget);
      expect(find.text('Basketball'), findsOneWidget);
    });

    testWidgets('Filtering by categories isolates matching activities', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrainScreen(summary: sampleSummary),
          ),
        ),
      );

      // Switch to 7 days
      await tester.tap(find.text('PAST 7 DAYS'));
      await tester.pumpAndSettle();

      // Tap STRENGTH category chip
      await tester.tap(find.byKey(const ValueKey('filter_chip_strength')));
      await tester.pumpAndSettle();

      // Only Strength Training should appear
      expect(find.text('Strength Training'), findsOneWidget);
      expect(find.text('Running'), findsNothing);
      expect(find.text('Yoga'), findsNothing);
      expect(find.text('1 Strength Sessions'), findsOneWidget);

      // Tap YOGA / RECOVERY category chip
      await tester.tap(find.byKey(const ValueKey('filter_chip_recovery')));
      await tester.pumpAndSettle();

      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('Strength Training'), findsNothing);
      expect(find.text('1 Recovery Sessions'), findsOneWidget);
    });

    testWidgets('Tapping ALL ACTIVITIES opens modal sheet with full activity breakdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrainScreen(summary: sampleSummary),
          ),
        ),
      );

      // Tap ALL ACTIVITIES
      await tester.tap(find.text('ALL ACTIVITIES'));
      await tester.pumpAndSettle();

      expect(find.text('ALL RECORDED ACTIVITIES'), findsOneWidget);
      expect(find.text('SESSIONS'), findsOneWidget);
      expect(find.text('TOTAL TIME'), findsOneWidget);
      expect(find.text('ACTIVE BURN'), findsOneWidget);
      expect(find.text('Search workouts (running, cycling, weights)...'), findsOneWidget);
    });

    test('ActivityCategoryHelper accurately classifies diverse wearable workout types', () {
      expect(ActivityCategoryHelper.resolve('RUNNING'), ActivityCategory.cardio);
      expect(ActivityCategoryHelper.resolve('OUTDOOR_CYCLING'), ActivityCategory.cardio);
      expect(ActivityCategoryHelper.resolve('SWIMMING_POOL'), ActivityCategory.cardio);
      expect(ActivityCategoryHelper.resolve('STRENGTH_TRAINING'), ActivityCategory.strength);
      expect(ActivityCategoryHelper.resolve('WEIGHTLIFTING'), ActivityCategory.strength);
      expect(ActivityCategoryHelper.resolve('HIGH_INTENSITY_INTERVAL_TRAINING'), ActivityCategory.hiit);
      expect(ActivityCategoryHelper.resolve('CIRCUIT_TRAINING'), ActivityCategory.hiit);
      expect(ActivityCategoryHelper.resolve('YOGA'), ActivityCategory.recovery);
      expect(ActivityCategoryHelper.resolve('PILATES'), ActivityCategory.recovery);
      expect(ActivityCategoryHelper.resolve('BASKETBALL'), ActivityCategory.sports);
      expect(ActivityCategoryHelper.resolve('SOCCER'), ActivityCategory.sports);
      expect(ActivityCategoryHelper.resolve('UNKNOWN_EXERCISE'), ActivityCategory.general);

      expect(ActivityCategoryHelper.formatTitle('OUTDOOR_RUNNING'), 'Outdoor Running');
      expect(ActivityCategoryHelper.formatTitle('WEIGHT_LIFTING'), 'Weight Lifting');
    });
  });
}
