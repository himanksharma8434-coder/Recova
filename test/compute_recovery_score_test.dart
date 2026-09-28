import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/domain/usecases/compute_recovery_score.dart';

void main() {
  const computeRecoveryScore = ComputeRecoveryScore();

  group('ComputeRecoveryScore Multi-Pillar Algorithm', () {
    test('all metrics at optimal baseline → score 85–100%', () {
      final result = computeRecoveryScore(
        todayHrv: 65, // above 55 baseline
        hrvBaseline: 55,
        todayRhr: 58,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480, // 8 hours
        sleepBaseline7d: 480,
        deepSleepMinutes: 100,
        remSleepMinutes: 110,
        todaySpo2: 98,
        spo2Baseline7d: 97,
        todayRespiratoryRate: 14.0,
        respiratoryRateBaseline: 14.0,
      );
      expect(result.score, greaterThanOrEqualTo(85));
      expect(result.hrvComponent, greaterThanOrEqualTo(80));
      expect(result.rhrComponent, closeTo(100, 1));
      expect(result.sleepComponent, closeTo(100, 1));
      expect(result.spo2Component, closeTo(100, 1));
      expect(result.respiratoryComponent, closeTo(100, 1));
      expect(result.primaryFactor, contains('Great recovery'));
    });

    test('HRV elevated 25%+ above baseline → HRV component = 100', () {
      final result = computeRecoveryScore(
        todayHrv: 70, // ~27% above 55
        hrvBaseline: 55,
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480,
        sleepBaseline7d: 480,
      );
      expect(result.hrvComponent, closeTo(100, 1));
      expect(result.score, greaterThanOrEqualTo(90));
    });

    test('HRV suppressed below baseline → HRV drops, primary factor flagged', () {
      final result = computeRecoveryScore(
        todayHrv: 35, // ~36% below 55
        hrvBaseline: 55,
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480,
        sleepBaseline7d: 480,
      );
      expect(result.hrvComponent, lessThanOrEqualTo(10));
      expect(result.primaryFactor, contains('HRV'));
    });

    test('RHR 10% above baseline → RHR score drops to 50', () {
      final result = computeRecoveryScore(
        todayRhr: 66, // 10% above 60
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480,
        sleepBaseline7d: 480,
        todaySpo2: 97,
        spo2Baseline7d: 97,
      );
      expect(result.rhrComponent, closeTo(50, 1));
      expect(result.sleepComponent, closeTo(100, 1));
      expect(result.spo2Component, closeTo(100, 1));
    });

    test('RHR 20%+ above baseline → RHR component = 0', () {
      final result = computeRecoveryScore(
        todayRhr: 72, // 20% above 60
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480,
        sleepBaseline7d: 480,
        todaySpo2: 97,
        spo2Baseline7d: 97,
      );
      expect(result.rhrComponent, closeTo(0, 1));
      expect(result.primaryFactor, contains('heart rate'));
    });

    test('poor sleep duration → sleep component drops smoothly', () {
      final result = computeRecoveryScore(
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 240, // 4 hours out of 8h (ratio 0.5)
        sleepBaseline7d: 480,
      );
      expect(result.sleepComponent, closeTo(30, 2));
      expect(result.primaryFactor, contains('Sleep'));
    });

    test('high restorative sleep (Deep + REM >= 40%) provides quality bonus', () {
      final withoutBonus = computeRecoveryScore(
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 360, // 6 hours
        sleepBaseline7d: 480,
      );

      final withBonus = computeRecoveryScore(
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 360, // 6 hours
        sleepBaseline7d: 480,
        deepSleepMinutes: 90, // 90/360 = 25%
        remSleepMinutes: 90, // 90/360 = 25% -> 50% restorative
      );

      expect(withBonus.sleepComponent, greaterThan(withoutBonus.sleepComponent));
    });

    test('respiratory rate deviation drops respiratory component', () {
      final result = computeRecoveryScore(
        todayRespiratoryRate: 16.5, // 2.5 rpm above 14.0 baseline
        respiratoryRateBaseline: 14.0,
      );
      expect(result.respiratoryComponent, closeTo(0, 1));
    });

    test('SpO2 dip penalizes score proportionally', () {
      final result = computeRecoveryScore(
        todaySpo2: 94, // 3% drop from 97
        spo2Baseline7d: 97,
      );
      expect(result.spo2Component, closeTo(40, 1));
    });

    test('handles missing sensors with dynamic re-weighting', () {
      // Only HRV and RHR present
      final result = computeRecoveryScore(
        todayHrv: 65,
        hrvBaseline: 55,
        todayRhr: 60,
        rhrBaseline7d: 60,
      );
      // Both are high -> final score should be high
      expect(result.score, greaterThanOrEqualTo(85));
      expect(result.rhrComponent, closeTo(100, 1));
    });

    test('handles all data missing → neutral score (50)', () {
      final result = computeRecoveryScore();
      expect(result.score, closeTo(50, 1));
      expect(result.primaryFactor, contains('Insufficient'));
    });

    test('RHR below baseline → score = 100 (clamped)', () {
      final result = computeRecoveryScore(
        todayRhr: 55, // below baseline of 60
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 480,
        sleepBaseline7d: 480,
      );
      expect(result.rhrComponent, closeTo(100, 1));
    });

    test('5 hours sleep (300 min) with optimal HRV/RHR cannot produce 98% recovery', () {
      final result = computeRecoveryScore(
        todayHrv: 70, // optimal (+27%)
        hrvBaseline: 55,
        todayRhr: 50, // optimal (below 60)
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 300, // 5 hours
        sleepBaseline7d: 480,
        todaySpo2: 99,
        spo2Baseline7d: 97,
        todayRespiratoryRate: 14.0,
        respiratoryRateBaseline: 14.0,
      );
      // Recovery cannot be green (>=67%) or 98% on only 5 hours of sleep
      expect(result.score, lessThan(67));
      expect(result.score, closeTo(56, 1));
      expect(result.primaryFactor, contains('Sleep deficit'));
    });

    test('sleep baseline floor prevents 5h sleep from evaluating as 100% sleep performance', () {
      final result = computeRecoveryScore(
        todayHrv: 55,
        hrvBaseline: 55,
        todayRhr: 60,
        rhrBaseline7d: 60,
        lastNightSleepMinutes: 300, // 5 hours
        sleepBaseline7d: 300, // artificial 5h baseline from recent short nights
      );
      // Sleep component must evaluate against physiological floor (>=420m / 7h), not 300m
      expect(result.sleepComponent, lessThan(60));
      expect(result.score, lessThan(67));
    });
  });
}
