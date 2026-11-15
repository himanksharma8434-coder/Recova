import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/body_engine/body_engine.dart';

void main() {
  group('WorkoutEngine Science Tests', () {
    const engine = WorkoutEngine();

    test('Computes exact Karvonen zones and TRIMP from minute HR telemetry', () {
      // 30-min run: 5 mins warmup (115 bpm), 20 mins tempo (155 bpm), 5 mins interval (175 bpm)
      // RHR: 50 bpm, Max HR: 190 bpm -> HRR = 140 bpm
      // 115 bpm: (115-50)/140 = 0.46 (Zone 0/sub-active)
      // 155 bpm: (155-50)/140 = 0.75 (Zone 3, 70-80%)
      // 175 bpm: (175-50)/140 = 0.89 (Zone 4, 80-90%)
      final minuteHr = [
        ...List.filled(5, 115.0),
        ...List.filled(20, 155.0),
        ...List.filled(5, 175.0),
      ];

      final input = WorkoutInput(
        sport: 'running',
        title: 'Tempo Interval Run',
        startTime: DateTime(2026, 11, 7, 7, 0),
        durationMinutes: 30,
        avgHeartRate: 151.0,
        maxHeartRate: 178.0,
        restingHr: 50.0,
        maxHr: 190.0,
        minuteHrSamples: minuteHr,
        userWeightKg: 72.0,
        userAge: 28,
        isMale: true,
      );

      final result = engine.analyze(input);

      expect(result.isZoneEstimated, isFalse);
      expect(result.zones.zone3Minutes, equals(20));
      expect(result.zones.zone4Minutes, equals(5));
      expect(result.trimp, greaterThan(0));
      expect(result.strainScore, inInclusiveRange(5.0, 18.0));
      expect(result.recoveryCostHours, greaterThan(10.0));
      expect(result.calories, greaterThan(200.0));
      expect(result.coachingSummary, contains('Running'));
    });

    test('Estimates zones and flags isZoneEstimated when minute telemetry is absent', () {
      final input = WorkoutInput(
        sport: 'hiit',
        title: 'Morning Metcon',
        startTime: DateTime(2026, 11, 7, 8, 30),
        durationMinutes: 40,
        avgHeartRate: 162.0,
        maxHeartRate: 182.0,
        restingHr: 55.0,
        maxHr: 190.0,
      );

      final result = engine.analyze(input);

      expect(result.isZoneEstimated, isTrue);
      expect(result.zones.totalActiveMinutes, greaterThan(0));
      expect(result.strainScore, greaterThan(8.0));
      expect(result.recoveryCostHours, greaterThan(14.0));
    });

    test('Diminishing returns scaling: huge TRIMP never exceeds 21.0 scale ceiling', () {
      // 180 minutes of all-out Zone 5
      final extremeHr = List.filled(180, 188.0);
      final input = WorkoutInput(
        sport: 'cycling',
        title: 'Extreme Mountain Stage',
        startTime: DateTime(2026, 11, 7, 6, 0),
        durationMinutes: 180,
        avgHeartRate: 185.0,
        restingHr: 50.0,
        maxHr: 190.0,
        minuteHrSamples: extremeHr,
      );

      final result = engine.analyze(input);

      expect(result.strainScore, lessThanOrEqualTo(21.0));
      expect(result.strainScore, greaterThan(20.0));
      expect(result.recoveryCostHours, equals(48.0)); // Capped ceiling
      expect(result.recoveryCostLabel, contains('High (~48h)'));
    });
  });

  group('JournalEngine Habit Correlation Tests', () {
    const engine = JournalEngine();

    test('Returns insufficientData status when occurrences are below 5', () {
      final dailyTags = {
        DateTime(2026, 10, 1): {'alcohol'},
        DateTime(2026, 10, 5): {'alcohol'},
        DateTime(2026, 10, 10): {'alcohol'},
      };

      final recoveries = List.generate(15, (i) {
        return DayRecoveryRecord(
          date: DateTime(2026, 10, 1 + i),
          readinessScore: 70.0,
        );
      });

      final correlations = engine.computeCorrelations(
        dailyTags: dailyTags,
        recoveryRecords: recoveries,
      );

      expect(correlations.length, equals(1));
      final alcohol = correlations.first;
      expect(alcohol.tag, equals('alcohol'));
      expect(alcohol.status, equals(HabitConfidenceStatus.insufficientData));
      expect(alcohol.hasReliableTrend, isFalse);
      expect(alcohol.taggedDaysCount, equals(3));
      expect(alcohol.coachingInsight, contains('Logged 3 of 5 days needed'));
    });

    test('Emerging trend detected between 5 and 9 logged days', () {
      final dailyTags = <DateTime, Set<String>>{};
      // Log alcohol 6 times
      for (int i = 1; i <= 6; i++) {
        dailyTags[DateTime(2026, 10, i * 2)] = {'alcohol'};
      }

      final recoveries = List.generate(20, (i) {
        final d = DateTime(2026, 10, 1 + i);
        // Next-day after alcohol has depressed readiness (50% vs 75%)
        final isAfterAlcohol = [3, 5, 7, 9, 11, 13].contains(1 + i);
        return DayRecoveryRecord(
          date: d,
          readinessScore: isAfterAlcohol ? 52.0 : 76.0,
          hrvRmssd: isAfterAlcohol ? 32.0 : 54.0,
          rhrNadir: isAfterAlcohol ? 65.0 : 58.0,
        );
      });

      final correlations = engine.computeCorrelations(
        dailyTags: dailyTags,
        recoveryRecords: recoveries,
      );

      final alcohol = correlations.firstWhere((c) => c.tag == 'alcohol');
      expect(alcohol.status, equals(HabitConfidenceStatus.emergingTrend));
      expect(alcohol.hasReliableTrend, isTrue);
      expect(alcohol.taggedDaysCount, equals(6));
      expect(alcohol.readinessDeltaPercent, lessThan(-20.0));
      expect(alcohol.rhrDeltaBpm, greaterThan(5.0)); // RHR elevated
      expect(alcohol.hrvDeltaMs, lessThan(-15.0)); // HRV suppressed
      expect(alcohol.coachingInsight, contains('[Emerging] Alcohol correlates with'));
      expect(alcohol.disclaimer, contains('Correlation, not causation'));
    });

    test('Statistically grounded status at 10+ days with positive recovery habit', () {
      final dailyTags = <DateTime, Set<String>>{};
      // Log magnesium 12 times
      for (int i = 1; i <= 12; i++) {
        dailyTags[DateTime(2026, 9, i * 2)] = {'magnesium'};
      }

      final recoveries = List.generate(30, (i) {
        final d = DateTime(2026, 9, 1 + i);
        final isAfterMagnesium = List.generate(12, (k) => (k + 1) * 2 + 1).contains(1 + i);
        return DayRecoveryRecord(
          date: d,
          readinessScore: isAfterMagnesium ? 82.0 : 70.0,
          hrvRmssd: isAfterMagnesium ? 58.0 : 48.0,
        );
      });

      final correlations = engine.computeCorrelations(
        dailyTags: dailyTags,
        recoveryRecords: recoveries,
      );

      final mag = correlations.firstWhere((c) => c.tag == 'magnesium');
      expect(mag.status, equals(HabitConfidenceStatus.grounded));
      expect(mag.taggedDaysCount, equals(12));
      expect(mag.readinessDeltaPercent, greaterThan(10.0));
      expect(mag.coachingInsight, contains('Magnesium correlates with +'));
      expect(mag.coachingInsight, isNot(contains('[Emerging]')));
    });
  });

  group('InsightsEngine Rule Tests', () {
    const engine = InsightsEngine();

    test('Emits Autonomic Suppression alert when HRV dips below normal band', () {
      final output = DailyEngineOutput(
        readiness: const ReadinessResult(
          score: 38.0,
          tier: ReadinessTier.low,
          confidence: ReadinessConfidence.high,
          daysOfData: 30,
          topDrivers: [],
          summary: 'Suppressed',
        ),
        hrv: const HrvAnalysisResult(
          rmssdMs: 31.0,
          lnRmssd: 3.43,
          zScore: -1.9,
          baseline7d: 48.0,
          normalRangeMean60d: 52.0,
          normalRangeLowerBound: 44.0,
          normalRangeUpperBound: 60.0,
          cv7d: 0.18,
          trendStatus: HrvTrendStatus.acuteSuppression,
          source: HrvSource.vendor,
          explanation: 'Suppressed',
        ),
        rhr: const RhrAnalysisResult(
          todayBpm: 66.0,
          invertedZScore: -1.1,
          baseline7d: 58.0,
          normalRangeMean60d: 57.0,
          normalRangeLowerBound: 53.0,
          normalRangeUpperBound: 61.0,
          status: RhrStatus.acuteElevation,
          explanation: 'Elevated',
        ),
        sleep: const SleepAnalysisResult(
          totalAsleepMinutes: 440,
          totalInBedMinutes: 480,
          sleepNeedMinutes: 480,
          sleepPerformancePct: 91.0,
          sleepScore: 85.0,
          sleepEfficiencyPct: 91.0,
          accumulatedDebtMinutes: 0,
          stageProvenance: SleepStageProvenance.sensor,
          sleepZScore: 0.2,
          sufficiencySubScore: 85.0,
          efficiencySubScore: 91.0,
          restorativeSubScore: 80.0,
          consistencySubScore: 82.0,
          consistencyScore: 82.0,
          explanation: 'Normal sleep',
        ),
        load: const LoadAnalysisResult(
          dayLoadScore: 4.0,
          workoutLoadScore: 0.0,
          ambientLoadScore: 4.0,
          accumulatedTrimp: 4.0,
          zones: HeartRateZoneBreakdown(),
          targetLoadLower: 6.0,
          targetLoadUpper: 9.9,
          progressToTarget: 0.6,
          explanation: 'Keep it easy',
        ),
        trainingReadiness: const TrainingReadinessResult(
          tier: TrainingReadinessTier.low,
          headline: 'Rest',
          coachingAdvice: 'Autonomic suppression',
        ),
      );

      final insights = engine.generateInsights(
        todayOutput: output,
        date: DateTime(2026, 11, 7),
      );

      expect(insights.isNotEmpty, isTrue);
      final hrvInsight = insights.firstWhere((i) => i.category == 'readiness');
      expect(hrvInsight.title, equals('Acute Autonomic Suppression'));
      expect(hrvInsight.priority, equals(InsightPriority.high));
      expect(hrvInsight.metricReferences, anyElement(contains('HRV: 31.0 ms')));
      expect(hrvInsight.actionableNudge, contains('recovery zone'));
    });

    test('Emits ACWR spike insight when acute:chronic workload ratio exceeds 1.4', () {
      final output = DailyEngineOutput(
        readiness: const ReadinessResult(
          score: 72.0,
          tier: ReadinessTier.optimal,
          confidence: ReadinessConfidence.high,
          daysOfData: 30,
          topDrivers: [],
          summary: 'Good',
        ),
        sleep: const SleepAnalysisResult(
          totalAsleepMinutes: 460,
          totalInBedMinutes: 490,
          sleepNeedMinutes: 460,
          sleepPerformancePct: 100.0,
          sleepScore: 90.0,
          sleepEfficiencyPct: 93.0,
          accumulatedDebtMinutes: 0,
          stageProvenance: SleepStageProvenance.sensor,
          sleepZScore: 0.5,
          sufficiencySubScore: 90.0,
          efficiencySubScore: 93.0,
          restorativeSubScore: 88.0,
          consistencySubScore: 88.0,
          consistencyScore: 88.0,
          explanation: 'Good sleep',
        ),
        load: const LoadAnalysisResult(
          dayLoadScore: 16.5,
          workoutLoadScore: 14.0,
          ambientLoadScore: 2.5,
          accumulatedTrimp: 45.0,
          zones: HeartRateZoneBreakdown(),
          targetLoadLower: 14.0,
          targetLoadUpper: 18.0,
          progressToTarget: 1.0,
          explanation: 'Target met',
        ),
        trainingReadiness: const TrainingReadinessResult(
          tier: TrainingReadinessTier.high,
          headline: 'Train hard',
          coachingAdvice: 'Ready',
        ),
      );

      final insights = engine.generateInsights(
        todayOutput: output,
        date: DateTime(2026, 11, 7),
        acwr: 1.52, // High acute load spike
      );

      final acwrInsight = insights.firstWhere((i) => i.title.contains('Acute Workload Spike'));
      expect(acwrInsight.priority, equals(InsightPriority.high));
      expect(acwrInsight.metricReferences, anyElement(contains('ACWR: 1.52')));
      expect(acwrInsight.actionableNudge, contains('soft-tissue strain'));
    });

    test('Emits Habit insight when recent tag matches negative correlation', () {
      final output = DailyEngineOutput(
        readiness: const ReadinessResult(
          score: 55.0,
          tier: ReadinessTier.moderate,
          confidence: ReadinessConfidence.high,
          daysOfData: 30,
          topDrivers: [],
          summary: 'Moderate',
        ),
        sleep: const SleepAnalysisResult(
          totalAsleepMinutes: 420,
          totalInBedMinutes: 470,
          sleepNeedMinutes: 460,
          sleepPerformancePct: 91.0,
          sleepScore: 78.0,
          sleepEfficiencyPct: 89.0,
          accumulatedDebtMinutes: 40,
          stageProvenance: SleepStageProvenance.sensor,
          sleepZScore: -0.2,
          sufficiencySubScore: 78.0,
          efficiencySubScore: 89.0,
          restorativeSubScore: 80.0,
          consistencySubScore: 80.0,
          consistencyScore: 80.0,
          explanation: 'Moderate sleep',
        ),
        load: const LoadAnalysisResult(
          dayLoadScore: 8.0,
          workoutLoadScore: 0.0,
          ambientLoadScore: 8.0,
          accumulatedTrimp: 8.0,
          zones: HeartRateZoneBreakdown(),
          targetLoadLower: 10.0,
          targetLoadUpper: 13.9,
          progressToTarget: 0.8,
          explanation: 'Maintain',
        ),
        trainingReadiness: const TrainingReadinessResult(
          tier: TrainingReadinessTier.moderate,
          headline: 'Train moderate',
          coachingAdvice: 'Moderate',
        ),
      );

      final correlations = [
        const BehaviorCorrelation(
          tag: 'late_meal',
          displayName: 'Late Meal',
          category: 'recovery_suppressor',
          taggedDaysCount: 8,
          untaggedDaysCount: 14,
          readinessDeltaPercent: -13.5,
          status: HabitConfidenceStatus.emergingTrend,
          minDaysRequired: 5,
          daysNeededForGrounded: 2,
          coachingInsight:
              '[Emerging] Late Meal correlates with -13.5% lower next-day readiness (8 logged days).',
        ),
      ];

      final insights = engine.generateInsights(
        todayOutput: output,
        date: DateTime(2026, 11, 7),
        recentBehaviorTags: {'late_meal'},
        habitCorrelations: correlations,
      );

      final habitInsight = insights.firstWhere((i) => i.category == 'habit');
      expect(habitInsight.title, contains('Habit Impact: Late Meal'));
      expect(habitInsight.metricReferences, anyElement(contains('-13.5%')));
      expect(habitInsight.actionableNudge, contains('shift'));
    });
  });
}
