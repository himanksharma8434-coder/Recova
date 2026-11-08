import 'body_engine.dart';

/// Priority levels for daily explainable insights.
enum InsightPriority {
  high(3),
  medium(2),
  low(1);

  final int score;
  const InsightPriority(this.score);
}

/// A structured, explainable physiological insight grounded in concrete metrics.
class EngineInsight {
  final String category; // 'readiness', 'sleep', 'load', 'health', 'habit'
  final InsightPriority priority;
  final String title;
  final String summary;
  final String actionableNudge;
  final List<String> metricReferences;
  final DateTime date;

  const EngineInsight({
    required this.category,
    required this.priority,
    required this.title,
    required this.summary,
    required this.actionableNudge,
    required this.metricReferences,
    required this.date,
  });
}

/// Pure Dart rule-based engine that converts calculated physiology into
/// plain-language, transparent coaching insights with full metric attribution.
class InsightsEngine {
  const InsightsEngine();

  /// Generate explainable insights from today's computed engine output and history.
  List<EngineInsight> generateInsights({
    required DailyEngineOutput todayOutput,
    required DateTime date,
    double? acwr, // Acute:Chronic Workload Ratio (7d vs 28d)
    List<BehaviorCorrelation> habitCorrelations = const [],
    Set<String> recentBehaviorTags = const {},
  }) {
    final list = <EngineInsight>[];

    // Rule 1: Health Monitor Multi-Vital Anomaly ("Something is off")
    final hm = todayOutput.healthMonitor;
    if (hm != null && hm.hasSystemicAnomaly) {
      final deviating = hm.vitals.where((v) => v.isOut).toList();
      final deviatingNames =
          deviating.map((v) => v.type.shortName).join(', ');
      final citations = deviating.map((v) {
        final val = v.value?.toStringAsFixed(1) ?? 'N/A';
        final base = v.baseline?.toStringAsFixed(1) ?? 'N/A';
        return '${v.type.shortName}: $val ${v.type.unit} (baseline: $base)';
      }).toList();

      list.add(EngineInsight(
        category: 'health',
        priority: InsightPriority.high,
        title: 'Systemic Anomaly Detected',
        summary:
            'Two or more overnight vitals ($deviatingNames) deviated simultaneously from your normal range bands.',
        actionableNudge:
            'Prioritize passive recovery, extra hydration, and monitor how your body feels today.',
        metricReferences: citations,
        date: date,
      ));
    }

    // Rule 2: Autonomic Nervous System Suppression
    final hrv = todayOutput.hrv;
    if (hrv != null &&
        (hrv.trendStatus == HrvTrendStatus.acuteSuppression ||
            hrv.trendStatus == HrvTrendStatus.sustainedSuppression)) {
      final isSustained =
          hrv.trendStatus == HrvTrendStatus.sustainedSuppression;
      final citations = <String>[];
      citations.add('HRV: ${hrv.rmssdMs.toStringAsFixed(1)} ms');
      if (todayOutput.rhr?.todayBpm != null) {
        citations.add(
            'RHR Nadir: ${todayOutput.rhr!.todayBpm.toStringAsFixed(0)} bpm');
      }

      final targetLower = todayOutput.load?.targetLoadLower.toStringAsFixed(1) ?? '8.0';

      list.add(EngineInsight(
        category: 'readiness',
        priority: InsightPriority.high,
        title: isSustained
            ? 'Sustained Autonomic Fatigue'
            : 'Acute Autonomic Suppression',
        summary: isSustained
            ? 'Your 7-day rolling HRV baseline has dropped below your 60-day normal band. Parasympathetic recovery is depleted.'
            : 'Your overnight HRV dipped below your normal band, reflecting temporary sympathetic nervous system activation.',
        actionableNudge: isSustained
            ? 'Take an active rest day or restrict training to light mobility. Prevent cumulative overtraining.'
            : 'Keep today\'s training load in the recovery zone (under $targetLower strain).',
        metricReferences: citations,
        date: date,
      ));
    }

    // Rule 3: Restorative Sleep Deficit
    final sleep = todayOutput.sleep;
    if (sleep != null &&
        (sleep.accumulatedDebtMinutes >= 60 ||
            (sleep.totalAsleepMinutes < 360 && sleep.totalAsleepMinutes > 0))) {
      final deficitHours =
          (sleep.accumulatedDebtMinutes / 60.0).toStringAsFixed(1);
      final actualHours =
          (sleep.totalAsleepMinutes / 60.0).toStringAsFixed(1);
      final citations = [
        'Sleep Duration: ${actualHours}h',
        'Sleep Deficit: ${deficitHours}h',
        'Sleep Score: ${sleep.sleepScore.toStringAsFixed(0)}%',
      ];

      list.add(EngineInsight(
        category: 'sleep',
        priority: InsightPriority.medium,
        title: 'Sleep Deficit Governor Active',
        summary:
            'You accumulated $deficitHours hours of sleep debt. The safety governor capped readiness to protect motor control and focus.',
        actionableNudge:
            'Aim for a 20-minute restorative nap this afternoon or advance tonight\'s bedtime target.',
        metricReferences: citations,
        date: date,
      ));
    }

    // Rule 4: Acute Workload Spike (ACWR > 1.4)
    if (acwr != null && acwr >= 1.40) {
      final citations = [
        'ACWR: ${acwr.toStringAsFixed(2)}',
        if (todayOutput.load != null)
          'Day Strain: ${todayOutput.load!.dayLoadScore.toStringAsFixed(1)}',
        if (todayOutput.load != null)
          'Target Upper: ${todayOutput.load!.targetLoadUpper.toStringAsFixed(1)}',
      ];

      list.add(EngineInsight(
        category: 'load',
        priority: InsightPriority.high,
        title: 'High Acute Workload Spike',
        summary:
            'Your 7-day acute workload is ${acwr.toStringAsFixed(2)}x higher than your 28-day chronic baseline (Danger Zone: ACWR > 1.40).',
        actionableNudge:
            'High acute fatigue increases soft-tissue strain risk. Avoid maximal eccentric loading or sudden sprint volume.',
        metricReferences: citations,
        date: date,
      ));
    }

    // Rule 5: Peak Adaptation Window (Optimal Green Readiness)
    final score = todayOutput.readiness.score;
    if (score != null &&
        score >= 80.0 &&
        hrv != null &&
        hrv.trendStatus == HrvTrendStatus.stable) {
      final citations = [
        'Readiness: ${score.toStringAsFixed(0)}%',
        'HRV: ${hrv.rmssdMs.toStringAsFixed(1)} ms',
        if (todayOutput.rhr?.todayBpm != null)
          'RHR: ${todayOutput.rhr!.todayBpm.toStringAsFixed(0)} bpm',
      ];

      list.add(EngineInsight(
        category: 'readiness',
        priority: InsightPriority.medium,
        title: 'Peak Physiological Readiness',
        summary:
            'Parasympathetic tone and nocturnal vitals are in optimal alignment. Autonomic reserves are fully replenished.',
        actionableNudge:
            'Prime condition for high-intensity intervals, PR attempts, or demanding endurance volume.',
        metricReferences: citations,
        date: date,
      ));
    }

    // Rule 6: Behavioral Habit Correlation Trigger
    if (recentBehaviorTags.isNotEmpty && habitCorrelations.isNotEmpty) {
      for (final tag in recentBehaviorTags) {
        final correlation = habitCorrelations.firstWhere(
          (c) => c.tag == tag && c.hasReliableTrend,
          orElse: () => const BehaviorCorrelation(
            tag: '',
            displayName: '',
            category: '',
            taggedDaysCount: 0,
            untaggedDaysCount: 0,
            status: HabitConfidenceStatus.insufficientData,
            minDaysRequired: 5,
            daysNeededForGrounded: 5,
            coachingInsight: '',
          ),
        );

        if (correlation.tag.isNotEmpty &&
            correlation.readinessDeltaPercent != null &&
            correlation.readinessDeltaPercent!.abs() >= 5.0) {
          final isNegative = correlation.readinessDeltaPercent! < 0;
          final citations = [
            'Logged Tag: ${correlation.displayName}',
            'Next-Day Impact: ${correlation.readinessDeltaPercent!.toStringAsFixed(1)}%',
            'Sample Size: ${correlation.taggedDaysCount} days',
          ];

          list.add(EngineInsight(
            category: 'habit',
            priority: isNegative ? InsightPriority.high : InsightPriority.low,
            title: isNegative
                ? 'Habit Impact: ${correlation.displayName}'
                : 'Recovery Boost: ${correlation.displayName}',
            summary: correlation.coachingInsight,
            actionableNudge: isNegative
                ? 'Hydrate thoroughly and consider shifting this habit earlier to minimize sleep cycle disruption.'
                : 'Continue incorporating ${correlation.displayName.toLowerCase()} into your recovery routine.',
            metricReferences: citations,
            date: date,
          ));
          break; // Avoid flooding with multiple habit insights
        }
      }
    }

    // Sort by priority score descending
    list.sort((a, b) => b.priority.score.compareTo(a.priority.score));

    return list;
  }
}
