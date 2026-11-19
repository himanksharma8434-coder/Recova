import 'dart:convert';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoop/data/database/app_database.dart';
import 'package:whoop/domain/body_engine/health_monitor_engine.dart';
import 'package:whoop/domain/repositories/health_source_repository.dart';
import 'package:whoop/domain/services/data_management_service.dart';
import 'package:whoop/presentation/components/health_monitor_pod.dart';
import 'package:whoop/presentation/screens/health_monitor_screen.dart';
import 'package:whoop/presentation/screens/methodology_sheet.dart';
import 'package:whoop/presentation/screens/trust_center_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 4: Health Monitor Science Engine Tests', () {
    const engine = HealthMonitorEngine();

    test('Scenario 1: Optimal 5-Vital Night (All in range)', () {
      final report = engine.evaluateReport(
        daysOfData: 45,
        todayHrvMs: 72.0,
        baselineHrvMs: 70.0,
        hrvStdDev: 8.0,
        todayRhrBpm: 48.0,
        baselineRhrBpm: 50.0,
        rhrStdDev: 3.0,
        todayRespiratoryRate: 14.2,
        baselineRespiratoryRate: 14.0,
        respStdDev: 0.8,
        todaySpo2: 98.0,
        baselineSpo2: 98.0,
        todaySkinTempDeviationCelsius: 0.12,
        baselineSkinTempDeviationCelsius: 0.0,
      );

      expect(report.overallStatus, OverallHealthStatus.allOptimal);
      expect(report.hasSystemicAnomaly, false);
      expect(report.inRangeCount, 5);
      expect(report.statusHeadline, 'ALL VITALS IN NORMAL RANGE');
      expect(report.statusSubhead, '5 OF 5 BIOMETRICS STABLE');

      final hrv = report.getVital(HealthVitalType.hrv)!;
      expect(hrv.status, VitalStatus.inRange);
      expect(hrv.provenance, VitalProvenance.sensorHardware);

      final temp = report.getVital(HealthVitalType.skinTemperature)!;
      expect(temp.status, VitalStatus.inRange);
      expect(temp.deviationString, '+0.12°C');
    });

    test('Scenario 2: Systemic Anomaly ("Something Is Off" Flag)', () {
      final report = engine.evaluateReport(
        daysOfData: 40,
        todayHrvMs: 44.0, // Suppressed (base 70, sd 8 -> range [64, 76])
        baselineHrvMs: 70.0,
        hrvStdDev: 8.0,
        todayRhrBpm: 58.0, // Elevated (base 50, sd 3 -> range [47.75, 52.25])
        baselineRhrBpm: 50.0,
        rhrStdDev: 3.0,
        todayRespiratoryRate: 16.5, // Elevated (base 14, sd 0.8 -> range [13.4, 14.6])
        baselineRespiratoryRate: 14.0,
        respStdDev: 0.8,
        todaySpo2: 97.0,
        baselineSpo2: 97.0,
        todaySkinTempDeviationCelsius: 0.85, // Elevated (> 0.5°C)
      );

      expect(report.overallStatus, OverallHealthStatus.systemicAnomaly);
      expect(report.hasSystemicAnomaly, true);
      expect(report.statusHeadline, '4 VITALS OUT OF NORMAL RANGE');
      expect(report.statusSubhead, 'SYSTEMIC DEVIATION DETECTED');
      // Guidance contains non-diagnostic explanation and medical consult disclaimer
      expect(report.nonDiagnosticGuidance, contains('Two or more overnight biometrics show significant deviation'));
      expect(report.nonDiagnosticGuidance, contains('consult a qualified healthcare professional'));

      final hrv = report.getVital(HealthVitalType.hrv)!;
      expect(hrv.status, VitalStatus.suppressed);

      final rhr = report.getVital(HealthVitalType.rhr)!;
      expect(rhr.status, VitalStatus.elevated);

      final temp = report.getVital(HealthVitalType.skinTemperature)!;
      expect(temp.status, VitalStatus.elevated);
    });

    test('Scenario 3: Calibrating Baseline (Day 3 of 7)', () {
      final report = engine.evaluateReport(
        daysOfData: 3,
        todayHrvMs: 65.0,
        todayRhrBpm: 54.0,
        todayRespiratoryRate: 15.0,
        todaySpo2: 98.0,
        todaySkinTempDeviationCelsius: 0.2,
      );

      expect(report.overallStatus, OverallHealthStatus.calibrating);
      expect(report.hasSystemicAnomaly, false);
      expect(report.statusHeadline, 'CALIBRATING HEALTH BASELINE');
      expect(report.statusSubhead, 'DAY 3 OF 7 REQUIRED');
      expect(report.nonDiagnosticGuidance, contains('Recova requires at least 7 nights of sleep wear'));

      final hrv = report.getVital(HealthVitalType.hrv)!;
      expect(hrv.status, VitalStatus.calibrating);
      expect(hrv.rangeLower, isNull);
      expect(hrv.rangeUpper, isNull);
    });

    test('Scenario 4: Missing Telemetry & Provenance Tagging', () {
      final report = engine.evaluateReport(
        daysOfData: 20,
        todayHrvMs: 58.0,
        isHrvEstimated: true, // Nocturnal PPG fallback
        todayRhrBpm: 52.0,
        todayRespiratoryRate: null, // Missing
        todaySpo2: null, // Missing
        todaySkinTempDeviationCelsius: null, // Missing
      );

      expect(report.overallStatus, OverallHealthStatus.allOptimal);

      final hrv = report.getVital(HealthVitalType.hrv)!;
      expect(hrv.provenance, VitalProvenance.estimated);

      final resp = report.getVital(HealthVitalType.respiratoryRate)!;
      expect(resp.status, VitalStatus.noData);
      expect(resp.provenance, VitalProvenance.unavailable);

      final temp = report.getVital(HealthVitalType.skinTemperature)!;
      expect(temp.status, VitalStatus.noData);
      expect(temp.provenance, VitalProvenance.unavailable);
    });
  });

  group('Phase 4: Data Management & Sovereignty Service Tests', () {
    test('JSON and CSV export generation produces compliant structured data', () async {
      final dataService = DataManagementService(db: db);

      // Insert dummy derived metric
      await db.derivedMetricDao.upsertMetric(DerivedMetricsCompanion.insert(
        date: DateTime(2026, 11, 7),
        estimatedVo2Max: const Value(52.5),
        recoveryScore: const Value(85.0),
        recoveryComponentRhr: const Value(48.0),
        recoveryComponentSleep: const Value(8.0),
        recoveryComponentSpo2: const Value(98.0),
        dayLoadScore: const Value(12.4),
        primaryFactor: const Value('Optimal autonomic recovery'),
      ));

      final jsonString = await dataService.exportToJsonString();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(decoded['app'], contains('Recova'));
      expect(decoded['storageArchitecture'], contains('100% Offline Local SQLite'));
      expect(decoded['fdaNotice'], contains('General Wellness Device Policy (Jan 2026)'));
      expect(decoded['dailyMetrics'], isNotEmpty);

      final metric = (decoded['dailyMetrics'] as List).first as Map<String, dynamic>;
      expect(metric['recoveryScore'], 85.0);
      expect(metric['dayLoadScore'], 12.4);

      final csvString = await dataService.exportToCsvString();
      expect(csvString, contains('Date,RecoveryScore,RestingHeartRate'));
      expect(csvString, contains('2026-11-07,85.0,48.0'));
    });

    test('Permanent wipe purges all local data tables and preferences', () async {
      final dataService = DataManagementService(db: db);

      // Seed data
      await db.derivedMetricDao.upsertMetric(DerivedMetricsCompanion.insert(
        date: DateTime(2026, 11, 7),
        recoveryScore: const Value(80.0),
      ));

      final countBefore = (await db.derivedMetricDao.getHistory(30)).length;
      expect(countBefore, 1);

      final wipedCount = await dataService.wipeAllLocalData();
      expect(wipedCount, 14);

      final countAfter = (await db.derivedMetricDao.getHistory(30)).length;
      expect(countAfter, 0);
    });
  });

  group('Phase 4: UI Screen & Compact Rendering Tests', () {
    testWidgets('HealthMonitorScreen renders 5 vitals without overflow on compact 360x640 screen', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final summary = DerivedMetricSummary(
        daysOfData: 45,
        hrvMs: 72.0,
        baselineHrv: 70.0,
        restingHr: 48.0,
        baselineRestingHr: 50.0,
        respiratoryRate: 14.2,
        baselineRespiratoryRate: 14.0,
        spo2: 98.0,
        baselineSpo2: 98.0,
        skinTempDeviation: 0.12,
        baselineSkinTemp: 0.0,
      );

      await tester.pumpWidget(MaterialApp(
        home: HealthMonitorScreen(summary: summary),
      ));
      await tester.pumpAndSettle();

      expect(find.text('HEALTH MONITOR'), findsOneWidget);
      expect(find.text('ALL VITALS IN RANGE'), findsOneWidget);
      expect(find.text('ALL VITALS IN NORMAL RANGE'), findsOneWidget);
      expect(find.text('HEART RATE VARIABILITY'), findsOneWidget);
      expect(find.text('RESTING HEART RATE'), findsOneWidget);

      final respVital = find.text('RESPIRATORY RATE');
      await tester.scrollUntilVisible(respVital, 200);
      expect(respVital, findsOneWidget);

      final spo2Vital = find.text('BLOOD OXYGEN');
      await tester.scrollUntilVisible(spo2Vital, 200);
      expect(spo2Vital, findsOneWidget);

      final tempVital = find.text('SKIN TEMPERATURE');
      await tester.scrollUntilVisible(tempVital, 200);
      expect(tempVital, findsOneWidget);

      final fdaBanner = find.text('FDA 2026 GENERAL WELLNESS SAFEGUARD');
      await tester.scrollUntilVisible(fdaBanner, 200);
      expect(fdaBanner, findsOneWidget);
    });

    testWidgets('HealthMonitorPod renders on PulseScreen and navigates to HealthMonitorScreen', (tester) async {
      final summary = DerivedMetricSummary(
        daysOfData: 45,
        hrvMs: 72.0,
        baselineHrv: 70.0,
        restingHr: 48.0,
        baselineRestingHr: 50.0,
        respiratoryRate: 14.2,
        baselineRespiratoryRate: 14.0,
        spo2: 98.0,
        baselineSpo2: 98.0,
        skinTempDeviation: 0.12,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HealthMonitorPod(summary: summary),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('HEALTH MONITOR'), findsOneWidget);
      expect(find.text('5/5 IN RANGE'), findsOneWidget);

      await tester.tap(find.byType(HealthMonitorPod));
      await tester.pumpAndSettle();

      expect(find.byType(HealthMonitorScreen), findsOneWidget);
    });

    testWidgets('TrustCenterScreen renders all compliance cards and opens methodology', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MaterialApp(
        home: TrustCenterScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TRUST & DATA PRIVACY'), findsOneWidget);
      expect(find.text('1. Local Offline Sovereignty'), findsOneWidget);
      expect(find.text('2. FDA 2026 General Wellness Compliance'), findsOneWidget);

      final card3 = find.text('3. Sensor Physics & Limitations');
      await tester.scrollUntilVisible(card3, 200);
      expect(card3, findsOneWidget);

      final card4 = find.text('4. Honest Data Provenance');
      await tester.scrollUntilVisible(card4, 200);
      expect(card4, findsOneWidget);

      final exportBtn = find.text('EXPORT ALL DATA (JSON & CSV)');
      await tester.scrollUntilVisible(exportBtn, 200);
      expect(exportBtn, findsOneWidget);

      final eraseBtn = find.text('PERMANENTLY ERASE ALL LOCAL DATA');
      await tester.scrollUntilVisible(eraseBtn, 200);
      expect(eraseBtn, findsOneWidget);

      // Open Methodology
      final methodBtn = find.textContaining('ALGORITHM VERSION');
      await tester.scrollUntilVisible(methodBtn, 200);
      await tester.pumpAndSettle();
      await tester.tap(methodBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MethodologySheet), findsOneWidget);
    });
  });
}
