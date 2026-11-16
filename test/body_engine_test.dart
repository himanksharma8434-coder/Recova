import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/core/config/engine_config.dart';
import 'package:whoop/domain/body_engine/body_engine.dart';

void main() {
  group('Engine Golden Fixtures Verification', () {
    test('JSON golden fixtures load and match static physiology math', () async {
      final file = File('test/fixtures/engine_golden_fixtures.json');
      expect(file.existsSync(), isTrue, reason: 'Golden fixtures file must exist');

      final jsonContent = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(jsonContent['version'], equals(EngineConfig.algorithmVersion));

      // 1. Verify TRIMP to Load scale fixtures
      final trimpFixtures = jsonContent['trimp_to_load_scale_fixtures'] as List<dynamic>;
      for (final fix in trimpFixtures) {
        final trimp = (fix['trimp'] as num).toDouble();
        final expected = (fix['expected_load_score'] as num).toDouble();
        final actual = LoadEngine.mapTrimpToLoadScale(trimp);
        expect(actual, closeTo(expected, 0.1),
            reason: 'TRIMP $trimp must map to $expected on 0-21 scale');
      }

      // 2. Verify Sigmoid conversion fixtures
      final sigmoidFixtures = jsonContent['readiness_sigmoid_fixtures'] as List<dynamic>;
      for (final fix in sigmoidFixtures) {
        final z = (fix['composite_z'] as num).toDouble();
        final expected = (fix['expected_score'] as num).toDouble();
        final actual = ReadinessEngine.zToScore(z);
        expect(actual, closeTo(expected, 0.5),
            reason: 'Composite Z $z must map to readiness score $expected');
      }

      // 3. Verify RR Cleaning fixture
      final rrFixtures = jsonContent['rr_cleaning_fixtures'] as List<dynamic>;
      for (final fix in rrFixtures) {
        final raw = (fix['raw_rr_ms'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
        final cleaned = HrvEngine.cleanRrIntervals(raw);
        expect(cleaned.length, equals(fix['expected_clean_count']));
        expect(cleaned, equals((fix['expected_cleaned_sample'] as List<dynamic>).map((e) => (e as num).toDouble()).toList()));
      }
    });
  });

  group('HrvEngine Tests', () {
    const engine = HrvEngine();

    test('cleanRrIntervals rejects extreme intervals (<300ms, >2000ms) and >20% successive jumps', () {
      final raw = [
        100.0, // too short
        800.0, // valid
        810.0, // valid (+1.25%)
        1200.0, // ectopic jump (+48% > 20% reject)
        820.0, // valid relative to 810 (+1.2%)
        2500.0, // too long
        815.0, // valid relative to 820
      ];

      final cleaned = HrvEngine.cleanRrIntervals(raw);
      expect(cleaned, equals([800.0, 810.0, 820.0, 815.0]));
    });

    test('computeRmssdFromRr calculates exact root mean square of successive differences', () {
      // Diffs: (820-800)=20 (sq:400), (810-820)=-10 (sq:100), (830-810)=20 (sq:400), (810-830)=-20 (sq:400)
      // Mean sq: (400+100+400+400)/4 = 325. sqrt(325) = ~18.03 ms
      final intervals = [800.0, 820.0, 810.0, 830.0, 810.0];
      final rmssd = HrvEngine.computeRmssdFromRr(intervals);
      expect(rmssd, isNotNull);
      expect(rmssd!, closeTo(18.03, 0.1));
    });

    test('estimateRmssdFromNocturnalHeartRates derives calibrated estimated RMSSD when only HR is available', () {
      final now = DateTime.now();
      final nocturnalSamples = [
        (timestamp: now.subtract(const Duration(minutes: 50)), bpm: 54.0),
        (timestamp: now.subtract(const Duration(minutes: 40)), bpm: 52.0),
        (timestamp: now.subtract(const Duration(minutes: 30)), bpm: 55.0),
        (timestamp: now.subtract(const Duration(minutes: 20)), bpm: 53.0),
        (timestamp: now.subtract(const Duration(minutes: 10)), bpm: 51.0),
        (timestamp: now, bpm: 52.0),
      ];

      final estimated = HrvEngine.estimateRmssdFromNocturnalHeartRates(nocturnalSamples);
      expect(estimated, isNotNull);
      expect(estimated!, greaterThan(15.0));
      expect(estimated, lessThan(150.0));
    });

    test('Returns calibrating trend when fewer than 4 nights exist', () {
      final result = engine.analyze(
        todayRmssdMs: 60.0,
        source: HrvSource.vendor,
        historicalNightlyRmssd60d: [58.0, 62.0],
      );

      expect(result.trendStatus, equals(HrvTrendStatus.calibrating));
      expect(result.explanation, contains('Collecting initial nocturnal baseline'));
    });

    test('Detects stable status when within personal normal range band (mean +- 0.75 SD)', () {
      final history60d = List.generate(40, (i) => 60.0 + (i % 5)); // 60 to 64
      final result = engine.analyze(
        todayRmssdMs: 62.0,
        source: HrvSource.vendor,
        historicalNightlyRmssd7d: [61.0, 62.0, 63.0, 62.0, 61.0, 62.0, 63.0],
        historicalNightlyRmssd60d: history60d,
      );

      expect(result.trendStatus, equals(HrvTrendStatus.stable));
      expect(result.normalRangeLowerBound, isNotNull);
      expect(result.normalRangeUpperBound, isNotNull);
      expect(result.lnRmssd, greaterThanOrEqualTo(result.normalRangeLowerBound!));
      expect(result.lnRmssd, lessThanOrEqualTo(result.normalRangeUpperBound!));
      expect(result.cv7d, isNotNull);
    });

    test('Detects acuteSuppression when today drops below normal band while 7-day remains normal', () {
      final history60d = List.generate(40, (i) => 65.0);
      final result = engine.analyze(
        todayRmssdMs: 30.0, // Acute drop
        source: HrvSource.vendor,
        historicalNightlyRmssd7d: [64.0, 65.0, 66.0, 64.0, 65.0, 65.0, 64.0],
        historicalNightlyRmssd60d: history60d,
      );

      expect(result.trendStatus, equals(HrvTrendStatus.acuteSuppression));
      expect(result.zScore, lessThan(-1.0));
    });

    test('Detects sustainedSuppression when 7-day rolling baseline drops below normal band', () {
      final history60d = List.generate(40, (i) => 70.0);
      final history7dSuppressed = [40.0, 42.0, 41.0, 39.0, 40.0, 41.0, 42.0];
      final result = engine.analyze(
        todayRmssdMs: 40.0,
        source: HrvSource.vendor,
        historicalNightlyRmssd7d: history7dSuppressed,
        historicalNightlyRmssd60d: history60d,
      );

      expect(result.trendStatus, equals(HrvTrendStatus.sustainedSuppression));
      expect(result.explanation, contains('7-day HRV baseline is suppressed'));
    });
  });

  group('RhrEngine Tests', () {
    const engine = RhrEngine();

    test('extractNadir extracts lowest sustained 5-minute average', () {
      final now = DateTime.now();
      final samples = <({DateTime timestamp, double bpm})>[];

      // 30 min of 65 bpm
      for (int i = 0; i < 30; i++) {
        samples.add((timestamp: now.subtract(Duration(minutes: 60 - i)), bpm: 65.0));
      }
      // 5 min dip to 48 bpm (sustained nadir)
      for (int i = 0; i < 5; i++) {
        samples.add((timestamp: now.subtract(Duration(minutes: 30 - i)), bpm: 48.0));
      }
      // 25 min of 60 bpm
      for (int i = 0; i < 25; i++) {
        samples.add((timestamp: now.subtract(Duration(minutes: 25 - i)), bpm: 60.0));
      }

      final nadir = RhrEngine.extractNadir(samples);
      expect(nadir, equals(48.0));
    });

    test('Inverted Z-score: lower RHR yields positive Z-score, higher RHR yields negative Z-score', () {
      final history60d = List.generate(40, (i) => 60.0);

      final lowerResult = engine.analyze(
        todayBpm: 52.0,
        historicalNightlyRhr7d: [60.0, 60.0, 60.0],
        historicalNightlyRhr60d: history60d,
      );
      expect(lowerResult.invertedZScore, greaterThan(0.0));
      expect(lowerResult.status, equals(RhrStatus.optimal));

      final higherResult = engine.analyze(
        todayBpm: 72.0,
        historicalNightlyRhr7d: [60.0, 60.0, 60.0],
        historicalNightlyRhr60d: history60d,
      );
      expect(higherResult.invertedZScore, lessThan(0.0));
      expect(higherResult.status, equals(RhrStatus.acuteElevation));
    });
  });

  group('SleepEngine Tests', () {
    const engine = SleepEngine();

    test('Dynamic sleep need adds strain addition, debt payback fraction, and subtracts naps', () {
      // Baseline 480m (8.0h)
      // Strain 16.0 -> (16.0 - 10.0) * 2.5 = 15.0 min addition
      // Debt 60m -> 20% payback = 12 min addition
      // Nap 30m -> 30 min credit
      // Target = 480 + 15 + 12 - 30 = 477 min
      final need = SleepEngine.calculateDynamicSleepNeed(
        baselineNeedMinutes: 480,
        daytimeStrain: 16.0,
        previousDebtMinutes: 60,
        napMinutesToday: 30,
      );

      expect(need.baselineMinutes, equals(480));
      expect(need.strainAdditionMinutes, equals(15));
      expect(need.debtAdditionMinutes, equals(12));
      expect(need.napCreditMinutes, equals(30));
      expect(need.targetSleepMinutes, equals(477));
    });

    test('Full hypnogram produces multi-pillar composite sleep score', () {
      final result = engine.analyze(
        asleepMinutes: 480, // 8h (100% sufficiency of 480)
        inBedMinutes: 520,  // 92.3% efficiency
        deepMinutes: 90,    // 18.75%
        remMinutes: 110,    // 22.9% -> restorative share = 41.6%
        lightMinutes: 280,
        awakeMinutes: 40,
        baselineNeedMinutes: 480,
      );

      expect(result.sleepScore, greaterThan(85.0));
      expect(result.restorativeEstimated, isFalse);
      expect(result.restorativeSharePercent, closeTo(41.6, 0.5));
    });

    test('Missing sleep stages activates transparent restorative estimation fallback', () {
      final result = engine.analyze(
        asleepMinutes: 420,
        inBedMinutes: 460,
        // stages omitted
        baselineNeedMinutes: 480,
      );

      expect(result.restorativeEstimated, isTrue);
      expect(result.deepMinutes, isNotNull);
      expect(result.remMinutes, isNotNull);
      expect(result.explanation, contains('sufficiency'));
    });
  });

  group('LoadEngine Tests', () {
    const engine = LoadEngine();

    test('calculateHrrIntensity computes accurate Karvonen percentages', () {
      // RHR 50, Max 200 -> Reserve = 150.
      // HR 125 -> (125-50)/150 = 75/150 = 0.50 (Zone 1)
      // HR 170 -> (170-50)/150 = 120/150 = 0.80 (Zone 4)
      final intensityZ1 = LoadEngine.calculateHrrIntensity(hr: 125.0, restingHr: 50.0, maxHr: 200.0);
      expect(intensityZ1, closeTo(0.50, 0.01));
      expect(LoadEngine.classifyZone(intensityZ1), equals(1));

      final intensityZ4 = LoadEngine.calculateHrrIntensity(hr: 170.0, restingHr: 50.0, maxHr: 200.0);
      expect(intensityZ4, closeTo(0.80, 0.01));
      expect(LoadEngine.classifyZone(intensityZ4), equals(4));
    });

    test('mapTrimpToLoadScale saturates smoothly on 0-21 scale', () {
      expect(LoadEngine.mapTrimpToLoadScale(0.0), equals(0.0));
      expect(LoadEngine.mapTrimpToLoadScale(18.0), closeTo(13.3, 0.1));
      expect(LoadEngine.mapTrimpToLoadScale(50.0), closeTo(19.7, 0.1));
      expect(LoadEngine.mapTrimpToLoadScale(200.0), closeTo(21.0, 0.1));
    });

    test('Calculates target load ranges based on morning readiness tier', () {
      // High readiness (85) -> Target 14.0 - 18.0
      final highResult = engine.analyze(
        hrSamples: const [],
        restingHr: 55.0,
        maxHr: 190.0,
        morningReadinessScore: 85.0,
        todaySteps: 5000,
      );
      expect(highResult.targetLoadLower, equals(14.0));
      expect(highResult.targetLoadUpper, equals(18.0));

      // Low readiness (25) -> Target 6.0 - 9.9
      final lowResult = engine.analyze(
        hrSamples: const [],
        restingHr: 55.0,
        maxHr: 190.0,
        morningReadinessScore: 25.0,
        todaySteps: 2000,
      );
      expect(lowResult.targetLoadLower, equals(EngineConfig.targetLoadLowBase));
      expect(lowResult.targetLoadUpper, closeTo(9.9, 0.1));
    });
  });

  group('ReadinessEngine Tests', () {
    const engine = ReadinessEngine();

    test('Days 1-3 baseline collection returns null score and calibrating confidence', () {
      final day1 = engine.compute(daysOfData: 1, hrvZ: 1.0, rhrInvertedZ: 1.0, sleepZ: 1.0);
      expect(day1.score, isNull);
      expect(day1.tier, equals(ReadinessTier.collecting));
      expect(day1.confidence, equals(ReadinessConfidence.calibrating));
      expect(day1.summary, contains('1/3 nights'));

      final day3 = engine.compute(daysOfData: 3, hrvZ: 1.0, rhrInvertedZ: 1.0, sleepZ: 1.0);
      expect(day3.score, isNull);
      expect(day3.tier, equals(ReadinessTier.collecting));
    });

    test('Days 4-13 provisional period returns score with calibrating badge', () {
      final day5 = engine.compute(daysOfData: 5, hrvZ: 0.5, rhrInvertedZ: 0.5, sleepZ: 0.5);
      expect(day5.score, isNotNull);
      expect(day5.confidence, equals(ReadinessConfidence.calibrating));
    });

    test('Day 14+ full score with all metrics has high confidence', () {
      final day15 = engine.compute(
        daysOfData: 15,
        hrvZ: 0.8,
        rhrInvertedZ: 0.4,
        sleepZ: 0.6,
        respiratoryInvertedZ: 0.2,
      );
      expect(day15.score, isNotNull);
      expect(day15.confidence, equals(ReadinessConfidence.high));
      expect(day15.topDrivers.length, greaterThanOrEqualTo(2));
    });

    test('Missing HRV reduces confidence and re-normalizes remaining weights without breaking', () {
      final missingHrv = engine.compute(
        daysOfData: 20,
        hrvZ: null, // Missing
        rhrInvertedZ: 1.0,
        sleepZ: 1.0,
      );
      expect(missingHrv.score, isNotNull);
      expect(missingHrv.confidence, equals(ReadinessConfidence.medium));
      expect(missingHrv.hrvSubScore, isNull);
      expect(missingHrv.rhrSubScore, isNotNull);
      expect(missingHrv.sleepSubScore, isNotNull);
    });

    test('Estimated HRV lowers confidence from high to medium even on day 20', () {
      final estResult = engine.compute(
        daysOfData: 20,
        hrvZ: 1.0,
        rhrInvertedZ: 1.0,
        sleepZ: 1.0,
        isHrvEstimated: true,
      );
      expect(estResult.confidence, equals(ReadinessConfidence.medium));
    });

    test('Sleep Deficit Governor caps peak readiness score if sleep < 6 hours (360m)', () {
      // With very high biometric z-scores, score would normally be > 85
      final result = engine.compute(
        daysOfData: 20,
        hrvZ: 2.5,
        rhrInvertedZ: 2.0,
        sleepZ: -1.5,
        lastNightSleepMinutes: 300, // 5 hours
      );

      expect(result.sleepGovernorApplied, isTrue);
      expect(result.score, lessThanOrEqualTo(66.0));
      expect(result.tier, isNot(equals(ReadinessTier.optimal)));
      expect(result.summary, contains('Sleep deficit (5.0h sleep) restricts physiological readiness'));
    });
  });

  group('StressEnergyEngine Tests', () {
    const engine = StressEnergyEngine();

    test('evaluateStress categorizes daytime stress into 4 bands and pauses during workouts', () {
      final calm = engine.evaluateStress(
        currentBpm: 55.0,
        restingHrBaseline: 55.0,
        shortWindowRmssd: 60.0,
        hrvBaseline: 60.0,
      );
      expect(calm.band, equals(StressBand.calm));
      expect(calm.score, lessThanOrEqualTo(25.0));

      final high = engine.evaluateStress(
        currentBpm: 85.0,
        restingHrBaseline: 55.0,
        shortWindowRmssd: 20.0,
        hrvBaseline: 60.0,
      );
      expect(high.band, equals(StressBand.high));
      expect(high.score, greaterThan(75.0));

      final workout = engine.evaluateStress(
        currentBpm: 150.0,
        restingHrBaseline: 55.0,
        isExercising: true,
      );
      expect(workout.score, equals(0.0));
      expect(workout.explanation, contains('workout in progress'));
    });

    test('Energy Reserve requires 10 days of wear to calibrate', () {
      final calibrating = engine.evaluateEnergyReserve(
        daysOfData: 5,
        morningReadinessScore: 80.0,
      );
      expect(calibrating.isCalibrating, isTrue);
      expect(calibrating.currentReserve, isNull);

      final active = engine.evaluateEnergyReserve(
        daysOfData: 14,
        morningReadinessScore: 80.0,
        dayStrain: 10.0, // Drains ~35 points
        restfulHoursToday: 2.0, // Charges ~3 points
      );
      expect(active.isCalibrating, isFalse);
      expect(active.currentReserve, isNotNull);
      expect(active.totalDrained, greaterThan(30.0));
      expect(active.totalCharged, greaterThan(2.0));
    });
  });

  group('TrainingReadinessEngine & ACWR Tests', () {
    const engine = TrainingReadinessEngine();

    test('calculateAcwr computes Acute:Chronic Workload Ratio', () {
      // Past 28 days of constant 10.0 load -> ACWR = 1.0
      final constantLoads = List.generate(28, (i) => 10.0);
      final acwrNormal = TrainingReadinessEngine.calculateAcwr(dailyLoadsPast28Days: constantLoads);
      expect(acwrNormal, equals(1.0));

      // Spike in acute load (first 7 days load = 20.0, preceding 21 days = 10.0)
      // Acute mean = 20.0, Chronic mean = (7*20 + 21*10)/28 = 350/28 = 12.5.
      // Ratio = 20.0 / 12.5 = 1.60 (Danger zone)
      final spikedLoads = [...List.generate(7, (i) => 20.0), ...List.generate(21, (i) => 10.0)];
      final acwrSpike = TrainingReadinessEngine.calculateAcwr(dailyLoadsPast28Days: spikedLoads);
      expect(acwrSpike, equals(1.60));
    });

    test('evaluate assigns Peak tier when readiness is high and ACWR is balanced', () {
      final constantLoads = List.generate(28, (i) => 10.0);
      final result = engine.evaluate(
        readinessScore: 88.0,
        dailyLoadsPast28Days: constantLoads,
        sleepSufficienciesPast3Days: [95.0, 92.0, 96.0],
      );
      expect(result.tier, equals(TrainingReadinessTier.peak));
      expect(result.headline, contains('Good Day to Push'));
    });

    test('High readiness downgraded if ACWR spikes above 1.4', () {
      final spikedLoads = [...List.generate(7, (i) => 20.0), ...List.generate(21, (i) => 10.0)];
      final result = engine.evaluate(
        readinessScore: 88.0,
        dailyLoadsPast28Days: spikedLoads,
      );
      expect(result.tier, isNot(equals(TrainingReadinessTier.peak)));
      expect(result.coachingAdvice, contains('workload has spiked'));
    });
  });

  group('Synthetic End-to-End Scenarios', () {
    const bodyEngine = BodyEngine();

    test('Scenario A: Prime Athletic Night (High HRV, Low RHR, 8h Sleep)', () {
      final output = bodyEngine.processDailyPipeline(
        daysOfData: 45,
        todayRmssdMs: 85.0, // High
        hrvSource: HrvSource.rrIntervals,
        hrvHistory7d: [80.0, 82.0, 84.0, 81.0, 83.0, 85.0, 82.0],
        hrvHistory60d: List.generate(45, (i) => 75.0),
        todayRhrBpm: 46.0, // Low resting nadir
        rhrHistory7d: [48.0, 47.0, 48.0, 46.0, 47.0, 48.0, 47.0],
        rhrHistory60d: List.generate(45, (i) => 50.0),
        lastNightAsleepMinutes: 510,
        inBedMinutes: 540,
        deepMinutes: 110,
        remMinutes: 120,
        lightMinutes: 280,
        awakeMinutes: 30,
        baselineNeedMinutes: 480,
        userMaxHr: 195.0,
        todaySteps: 8000,
      );

      expect(output.readiness.tier, equals(ReadinessTier.optimal));
      expect(output.readiness.score, greaterThanOrEqualTo(70.0));
      expect(output.readiness.confidence, equals(ReadinessConfidence.high));
      expect(output.readiness.topDrivers.first.direction, equals('positive'));
      expect(output.trainingReadiness.tier, anyOf([TrainingReadinessTier.high, TrainingReadinessTier.peak]));
      expect(output.load?.targetLoadLower, equals(14.0));
    });

    test('Scenario B: Acute Alcohol / Heavy Late Night (HRV Suppression, RHR +10 bpm, Poor Sleep)', () {
      final output = bodyEngine.processDailyPipeline(
        daysOfData: 45,
        todayRmssdMs: 25.0, // Severely suppressed
        hrvSource: HrvSource.vendor,
        hrvHistory7d: [70.0, 72.0, 71.0, 69.0, 70.0, 71.0, 72.0],
        hrvHistory60d: List.generate(45, (i) => 70.0),
        todayRhrBpm: 64.0, // Elevated +12 bpm
        rhrHistory7d: [52.0, 51.0, 53.0, 52.0, 51.0, 52.0, 52.0],
        rhrHistory60d: List.generate(45, (i) => 52.0),
        lastNightAsleepMinutes: 310, // Short fragmented sleep
        inBedMinutes: 420,
        deepMinutes: 20,
        remMinutes: 25,
        lightMinutes: 265,
        awakeMinutes: 110,
        baselineNeedMinutes: 480,
        userMaxHr: 190.0,
      );

      expect(output.hrv?.trendStatus, equals(HrvTrendStatus.acuteSuppression));
      expect(output.rhr?.status, equals(RhrStatus.acuteElevation));
      expect(output.readiness.tier, equals(ReadinessTier.low));
      expect(output.readiness.score, lessThan(35.0));
      expect(output.readiness.topDrivers.any((d) => d.direction == 'negative'), isTrue);
      expect(output.readiness.summary, contains('Recovery priority'));
      expect(output.trainingReadiness.headline, anyOf([contains('Rest Day'), contains('Easy')]));
      expect(output.load?.targetLoadUpper, closeTo(9.9, 0.1));
    });

    test('Scenario C: Sustained Overtraining Syndrome (Suppressed 7-day HRV, Elevated RHR)', () {
      final history60d = List.generate(45, (i) => 75.0);
      final suppressed7d = [42.0, 44.0, 41.0, 40.0, 43.0, 41.0, 42.0];

      final output = bodyEngine.processDailyPipeline(
        daysOfData: 45,
        todayRmssdMs: 40.0,
        hrvSource: HrvSource.vendor,
        hrvHistory7d: suppressed7d,
        hrvHistory60d: history60d,
        todayRhrBpm: 60.0,
        rhrHistory7d: [58.0, 59.0, 60.0, 59.0, 60.0, 59.0, 58.0],
        rhrHistory60d: List.generate(45, (i) => 50.0),
        lastNightAsleepMinutes: 420,
        baselineNeedMinutes: 480,
      );

      expect(output.hrv?.trendStatus, equals(HrvTrendStatus.sustainedSuppression));
      expect(output.rhr?.status, equals(RhrStatus.sustainedElevation));
      expect(output.readiness.tier, equals(ReadinessTier.low));
      expect(output.trainingReadiness.tier, anyOf([TrainingReadinessTier.veryLow, TrainingReadinessTier.low]));
    });

    test('Scenario D: Zero wearable HRV (PPG nocturnal pulse estimation fallback)', () {
      final now = DateTime.now();
      final nocturnalHr = List.generate(12, (i) => (
        timestamp: now.subtract(Duration(minutes: (12 - i) * 3)),
        bpm: 50.0 + (i % 3) * 2.0,
      ));

      final estimatedRmssd = HrvEngine.estimateRmssdFromNocturnalHeartRates(nocturnalHr);
      expect(estimatedRmssd, isNotNull);

      final output = bodyEngine.processDailyPipeline(
        daysOfData: 25,
        todayRmssdMs: estimatedRmssd,
        hrvSource: HrvSource.estimated, // Transparent provenance
        todayRhrBpm: 50.0,
        lastNightAsleepMinutes: 450,
      );

      expect(output.hrv?.source, equals(HrvSource.estimated));
      // Confidence should be capped at medium due to estimated HRV
      expect(output.readiness.confidence, equals(ReadinessConfidence.medium));
      expect(output.readiness.score, isNotNull);
    });
  });
}
