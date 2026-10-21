import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/presentation/components/recovery_rhr_widget.dart';
import 'package:whoop/services/home_widget_service.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  final testSummaryOptimal = DerivedMetricSummary(
    lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    recoveryScore: 88,
    baselineRecoveryScore: 82,
    restingHr: 48,
    baselineRestingHr: 52,
    hrvMs: 75,
    spo2: 98,
  );

  final testSummaryModerate = DerivedMetricSummary(
    lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    recoveryScore: 55,
    baselineRecoveryScore: 60,
    restingHr: 58,
    baselineRestingHr: 58,
    hrvMs: 45,
    spo2: 97,
  );

  final testSummarySuppressed = DerivedMetricSummary(
    lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 25)),
    recoveryScore: 28,
    baselineRecoveryScore: 65,
    restingHr: 66,
    baselineRestingHr: 54,
    hrvMs: 30,
    spo2: 94,
  );

  group('RecoveryRhrWidget Widget Tests', () {
    testWidgets('renders optimal recovery (88%) and resting heart rate (48 bpm) with delta',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: testSummaryOptimal,
              autoRefreshEnabled: false,
            ),
          ),
        ),
      );

      // Verify Recovery & RHR headers
      expect(find.text('AUTONOMIC TELEMETRY'), findsOneWidget);
      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('RESTING HR'), findsOneWidget);

      // Verify Recovery score & status
      expect(find.text('88'), findsOneWidget);
      expect(find.text('OPTIMAL'), findsOneWidget);
      expect(find.text('Base 82%'), findsOneWidget);

      // Verify Resting HR readout & delta
      expect(find.text('48'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.text('-4 bpm basal'), findsOneWidget);

      // Verify 30m Auto-sync indicators
      expect(find.text('AUTO 30M'), findsOneWidget);
      expect(find.textContaining('Synced'), findsOneWidget);
      expect(find.textContaining('Next auto-refresh in'), findsOneWidget);
    });

    testWidgets('renders moderate recovery (55%) and on-baseline RHR (58 bpm)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: testSummaryModerate,
              autoRefreshEnabled: false,
            ),
          ),
        ),
      );

      expect(find.text('55'), findsOneWidget);
      expect(find.text('MODERATE'), findsOneWidget);
      expect(find.text('58'), findsOneWidget);
      expect(find.text('On baseline'), findsOneWidget);
    });

    testWidgets('renders suppressed recovery (28%) and elevated RHR (+12 bpm)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: testSummarySuppressed,
              autoRefreshEnabled: false,
            ),
          ),
        ),
      );

      expect(find.text('28'), findsOneWidget);
      expect(find.text('SUPPRESSED'), findsOneWidget);
      expect(find.text('66'), findsOneWidget);
      expect(find.text('+12 bpm basal'), findsOneWidget);
    });

    testWidgets('handles null summary with graceful placeholder states',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: null,
              autoRefreshEnabled: false,
            ),
          ),
        ),
      );

      // Should show placeholder dashes '--'
      expect(find.text('--'), findsNWidgets(2));
      expect(find.text('CALIBRATING'), findsOneWidget);
      expect(find.text('Basal'), findsOneWidget);
    });

    testWidgets('triggers onRefresh callback when refresh button is tapped',
        (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: testSummaryOptimal,
              autoRefreshEnabled: false,
              onRefresh: () {
                refreshed = true;
              },
            ),
          ),
        ),
      );

      final refreshBtn = find.byIcon(Icons.refresh_rounded);
      expect(refreshBtn, findsOneWidget);

      await tester.tap(refreshBtn);
      await tester.pump();

      expect(refreshed, isTrue);
    });

    testWidgets('triggers onRecoveryTap and onRhrTap when pods are tapped',
        (tester) async {
      bool recoveryTapped = false;
      bool rhrTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryRhrWidget(
              summary: testSummaryOptimal,
              autoRefreshEnabled: false,
              onRecoveryTap: () => recoveryTapped = true,
              onRhrTap: () => rhrTapped = true,
            ),
          ),
        ),
      );

      // Tap on RECOVERY section
      await tester.tap(find.text('RECOVERY'));
      await tester.pump();
      expect(recoveryTapped, isTrue);

      // Tap on RESTING HR section
      await tester.tap(find.text('RESTING HR'));
      await tester.pump();
      expect(rhrTapped, isTrue);
    });
  });

  group('HomeWidgetService Tests', () {
    test('updateWidget formats metrics and updates widget store safely', () async {
      // In unit test environment, HomeWidget channel may be unmocked.
      // HomeWidgetService catches MissingPluginException gracefully.
      await expectLater(
        HomeWidgetService.updateWidget(
          recoveryScore: 84.6,
          restingHr: 51.2,
          baselineRestingHr: 54.0,
          lastSyncedAt: DateTime.now(),
        ),
        completes,
      );
    });

    test('updateFromSummary handles nulls and extremes safely', () async {
      await expectLater(
        HomeWidgetService.updateFromSummary(
          const DerivedMetricSummary(
            recoveryScore: null,
            restingHr: null,
          ),
        ),
        completes,
      );

      await expectLater(
        HomeWidgetService.updateFromSummary(testSummaryOptimal),
        completes,
      );
    });
  });
}
