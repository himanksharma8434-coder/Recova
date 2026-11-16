import 'dart:math' as math;

/// Pre-configured standard behavioral tags for habit logging.
class BehaviorTagDefinition {
  final String key;
  final String label;
  final String category; // 'recovery_suppressor', 'recovery_enhancer', 'lifestyle'
  final String iconName;

  const BehaviorTagDefinition({
    required this.key,
    required this.label,
    required this.category,
    required this.iconName,
  });

  static const List<BehaviorTagDefinition> defaults = [
    BehaviorTagDefinition(
      key: 'alcohol',
      label: 'Alcohol',
      category: 'recovery_suppressor',
      iconName: 'wine_bar',
    ),
    BehaviorTagDefinition(
      key: 'late_meal',
      label: 'Late Meal',
      category: 'recovery_suppressor',
      iconName: 'restaurant',
    ),
    BehaviorTagDefinition(
      key: 'caffeine_late',
      label: 'Late Caffeine',
      category: 'recovery_suppressor',
      iconName: 'coffee',
    ),
    BehaviorTagDefinition(
      key: 'high_stress',
      label: 'Acute Stress',
      category: 'recovery_suppressor',
      iconName: 'bolt',
    ),
    BehaviorTagDefinition(
      key: 'illness',
      label: 'Illness / Malaise',
      category: 'recovery_suppressor',
      iconName: 'coronavirus',
    ),
    BehaviorTagDefinition(
      key: 'screen_in_bed',
      label: 'Screen in Bed',
      category: 'recovery_suppressor',
      iconName: 'phone_android',
    ),
    BehaviorTagDefinition(
      key: 'travel',
      label: 'Travel / Jet Lag',
      category: 'lifestyle',
      iconName: 'flight',
    ),
    BehaviorTagDefinition(
      key: 'magnesium',
      label: 'Magnesium',
      category: 'recovery_enhancer',
      iconName: 'medication',
    ),
    BehaviorTagDefinition(
      key: 'cold_plunge',
      label: 'Cold Plunge',
      category: 'recovery_enhancer',
      iconName: 'ac_unit',
    ),
    BehaviorTagDefinition(
      key: 'sauna',
      label: 'Sauna Heat',
      category: 'recovery_enhancer',
      iconName: 'hot_tub',
    ),
    BehaviorTagDefinition(
      key: 'breathwork',
      label: 'Breathwork',
      category: 'recovery_enhancer',
      iconName: 'air',
    ),
  ];

  static BehaviorTagDefinition fromKey(String key) {
    return defaults.firstWhere(
      (d) => d.key == key,
      orElse: () => BehaviorTagDefinition(
        key: key,
        label: key.replaceAll('_', ' ').toUpperCase(),
        category: 'lifestyle',
        iconName: 'bookmark',
      ),
    );
  }
}

/// Statistical confidence level for habit-readiness correlations.
enum HabitConfidenceStatus {
  insufficientData('Collecting Data', 'Fewer than 5 occurrences logged'),
  emergingTrend('Emerging Trend', '5 to 9 occurrences logged'),
  grounded('Statistically Grounded', '10+ occurrences logged');

  final String label;
  final String description;
  const HabitConfidenceStatus(this.label, this.description);
}

/// Daily recovery and nocturnal biometric metrics.
class DayRecoveryRecord {
  final DateTime date;
  final double readinessScore; // 0 to 100
  final double? hrvRmssd; // ms
  final double? rhrNadir; // bpm
  final double? sleepScore; // 0 to 100

  const DayRecoveryRecord({
    required this.date,
    required this.readinessScore,
    this.hrvRmssd,
    this.rhrNadir,
    this.sleepScore,
  });
}

/// Association between a logged behavior tag and next-day physiological recovery.
class BehaviorCorrelation {
  final String tag;
  final String displayName;
  final String category;
  final int taggedDaysCount;
  final int untaggedDaysCount;
  final double? meanReadinessWithTag;
  final double? meanReadinessWithoutTag;
  final double? readinessDelta; // meanWith - meanWithout
  final double? readinessDeltaPercent; // (delta / meanWithout) * 100
  final double? rhrDeltaBpm;
  final double? hrvDeltaMs;
  final HabitConfidenceStatus status;
  final int minDaysRequired;
  final int daysNeededForGrounded;
  final String coachingInsight;
  final String disclaimer;

  const BehaviorCorrelation({
    required this.tag,
    required this.displayName,
    required this.category,
    required this.taggedDaysCount,
    required this.untaggedDaysCount,
    this.meanReadinessWithTag,
    this.meanReadinessWithoutTag,
    this.readinessDelta,
    this.readinessDeltaPercent,
    this.rhrDeltaBpm,
    this.hrvDeltaMs,
    required this.status,
    required this.minDaysRequired,
    required this.daysNeededForGrounded,
    required this.coachingInsight,
    this.disclaimer =
        'Correlation, not causation. Individual physiological responses vary.',
  });

  bool get hasReliableTrend => status != HabitConfidenceStatus.insufficientData;
}

/// Pure Dart science engine for analyzing habit correlations against next-day recovery.
class JournalEngine {
  static const int minEmergingDays = 5;
  static const int minGroundedDays = 10;

  const JournalEngine();

  /// Analyze the statistical impact of each behavior tag on next-day recovery.
  ///
  /// Pairing Logic:
  /// Tag logged on date `D` is paired with recovery evaluated on date `D + 1`.
  List<BehaviorCorrelation> computeCorrelations({
    required Map<DateTime, Set<String>> dailyTags,
    required List<DayRecoveryRecord> recoveryRecords,
  }) {
    if (dailyTags.isEmpty || recoveryRecords.isEmpty) return [];

    // Map daily tags by normalized calendar date (year-month-day)
    final normalizedTags = <DateTime, Set<String>>{};
    for (final entry in dailyTags.entries) {
      final key = DateTime(entry.key.year, entry.key.month, entry.key.day);
      normalizedTags[key] = entry.value;
    }

    // Collect all unique tags logged across history
    final allTags = <String>{};
    for (final tags in dailyTags.values) {
      allTags.addAll(tags);
    }

    final results = <BehaviorCorrelation>[];

    for (final tag in allTags) {
      final withTagRecoveries = <DayRecoveryRecord>[];
      final withoutTagRecoveries = <DayRecoveryRecord>[];

      // Walk through each recovery record (Day T) and check preceding day (Day T - 1)
      for (final recovery in recoveryRecords) {
        final recoveryDate =
            DateTime(recovery.date.year, recovery.date.month, recovery.date.day);
        final precedingDay = recoveryDate.subtract(const Duration(days: 1));

        final tagsPreceding = normalizedTags[precedingDay];
        if (tagsPreceding != null && tagsPreceding.contains(tag)) {
          withTagRecoveries.add(recovery);
        } else {
          withoutTagRecoveries.add(recovery);
        }
      }

      final countWith = withTagRecoveries.length;
      final countWithout = withoutTagRecoveries.length;
      final def = BehaviorTagDefinition.fromKey(tag);

      // Determine confidence status
      HabitConfidenceStatus status;
      if (countWith < minEmergingDays || countWithout < 3) {
        status = HabitConfidenceStatus.insufficientData;
      } else if (countWith < minGroundedDays) {
        status = HabitConfidenceStatus.emergingTrend;
      } else {
        status = HabitConfidenceStatus.grounded;
      }

      if (status == HabitConfidenceStatus.insufficientData) {
        results.add(BehaviorCorrelation(
          tag: tag,
          displayName: def.label,
          category: def.category,
          taggedDaysCount: countWith,
          untaggedDaysCount: countWithout,
          status: status,
          minDaysRequired: minEmergingDays,
          daysNeededForGrounded: math.max(0, minGroundedDays - countWith),
          coachingInsight:
              'Logged $countWith of $minEmergingDays days needed to compute habit impact.',
        ));
        continue;
      }

      // Calculate statistical means
      final meanWithReadiness =
          withTagRecoveries.map((r) => r.readinessScore).reduce((a, b) => a + b) /
              countWith;
      final meanWithoutReadiness = withoutTagRecoveries
              .map((r) => r.readinessScore)
              .reduce((a, b) => a + b) /
          countWithout;

      final deltaReadiness = meanWithReadiness - meanWithoutReadiness;
      final deltaPercent = meanWithoutReadiness > 0
          ? (deltaReadiness / meanWithoutReadiness) * 100.0
          : 0.0;

      // Nocturnal RHR delta
      final rhrWith = withTagRecoveries
          .where((r) => r.rhrNadir != null)
          .map((r) => r.rhrNadir!)
          .toList();
      final rhrWithout = withoutTagRecoveries
          .where((r) => r.rhrNadir != null)
          .map((r) => r.rhrNadir!)
          .toList();
      double? deltaRhr;
      if (rhrWith.isNotEmpty && rhrWithout.isNotEmpty) {
        final meanRhrWith = rhrWith.reduce((a, b) => a + b) / rhrWith.length;
        final meanRhrWithout =
            rhrWithout.reduce((a, b) => a + b) / rhrWithout.length;
        deltaRhr = meanRhrWith - meanRhrWithout;
      }

      // Nocturnal HRV delta
      final hrvWith = withTagRecoveries
          .where((r) => r.hrvRmssd != null)
          .map((r) => r.hrvRmssd!)
          .toList();
      final hrvWithout = withoutTagRecoveries
          .where((r) => r.hrvRmssd != null)
          .map((r) => r.hrvRmssd!)
          .toList();
      double? deltaHrv;
      if (hrvWith.isNotEmpty && hrvWithout.isNotEmpty) {
        final meanHrvWith = hrvWith.reduce((a, b) => a + b) / hrvWith.length;
        final meanHrvWithout =
            hrvWithout.reduce((a, b) => a + b) / hrvWithout.length;
        deltaHrv = meanHrvWith - meanHrvWithout;
      }

      // Coaching explanation
      final insight = _generateHabitInsight(
        tagDef: def,
        deltaPercent: deltaPercent,
        deltaRhr: deltaRhr,
        deltaHrv: deltaHrv,
        countWith: countWith,
        status: status,
      );

      results.add(BehaviorCorrelation(
        tag: tag,
        displayName: def.label,
        category: def.category,
        taggedDaysCount: countWith,
        untaggedDaysCount: countWithout,
        meanReadinessWithTag:
            double.parse(meanWithReadiness.toStringAsFixed(1)),
        meanReadinessWithoutTag:
            double.parse(meanWithoutReadiness.toStringAsFixed(1)),
        readinessDelta: double.parse(deltaReadiness.toStringAsFixed(1)),
        readinessDeltaPercent: double.parse(deltaPercent.toStringAsFixed(1)),
        rhrDeltaBpm: deltaRhr != null
            ? double.parse(deltaRhr.toStringAsFixed(1))
            : null,
        hrvDeltaMs: deltaHrv != null
            ? double.parse(deltaHrv.toStringAsFixed(1))
            : null,
        status: status,
        minDaysRequired: minEmergingDays,
        daysNeededForGrounded: math.max(0, minGroundedDays - countWith),
        coachingInsight: insight,
      ));
    }

    // Sort by largest absolute impact
    results.sort((a, b) {
      final aDelta = (a.readinessDeltaPercent ?? 0.0).abs();
      final bDelta = (b.readinessDeltaPercent ?? 0.0).abs();
      return bDelta.compareTo(aDelta);
    });

    return results;
  }

  String _generateHabitInsight({
    required BehaviorTagDefinition tagDef,
    required double deltaPercent,
    required double? deltaRhr,
    required double? deltaHrv,
    required int countWith,
    required HabitConfidenceStatus status,
  }) {
    final prefix = status == HabitConfidenceStatus.emergingTrend
        ? '[Emerging] '
        : '';
    final sign = deltaPercent >= 0 ? '+' : '';
    final formattedPercent = '$sign${deltaPercent.toStringAsFixed(1)}%';

    String vitalNote = '';
    if (deltaRhr != null && deltaRhr.abs() >= 1.5) {
      final rhrSign = deltaRhr > 0 ? '+' : '';
      vitalNote += ', RHR $rhrSign${deltaRhr.toStringAsFixed(1)} bpm';
    }
    if (deltaHrv != null && deltaHrv.abs() >= 2.0) {
      final hrvSign = deltaHrv > 0 ? '+' : '';
      vitalNote += ', HRV $hrvSign${deltaHrv.toStringAsFixed(1)} ms';
    }

    if (deltaPercent <= -5.0) {
      return '$prefix${tagDef.label} correlates with $formattedPercent lower next-day readiness$vitalNote ($countWith logged days).';
    } else if (deltaPercent >= 5.0) {
      return '$prefix${tagDef.label} correlates with $formattedPercent higher next-day readiness$vitalNote ($countWith logged days).';
    } else {
      return '$prefix${tagDef.label} shows neutral correlation with next-day readiness ($formattedPercent across $countWith logged days).';
    }
  }
}
