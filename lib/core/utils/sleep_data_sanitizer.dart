import 'dart:math';
import '../../data/database/app_database.dart';

/// Clean, deduplicated overnight sleep metrics.
class CleanNightSleep {
  final int deepMinutes;
  final int coreMinutes; // Light sleep
  final int remMinutes;
  final int awakeMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool hasStageData;
  final double totalHours;

  const CleanNightSleep({
    required this.deepMinutes,
    required this.coreMinutes,
    required this.remMinutes,
    required this.awakeMinutes,
    this.startTime,
    this.endTime,
    required this.hasStageData,
    required this.totalHours,
  });

  int get totalAsleepMinutes => deepMinutes + coreMinutes + remMinutes;
  int get totalTrackedMinutes => totalAsleepMinutes + awakeMinutes;
}

class SleepDataSanitizer {
  SleepDataSanitizer._();

  /// Merge overlapping or duplicate time intervals for the same sleep stage.
  /// This prevents double-counting when multiple apps report to Health Connect.
  static int calculateMergedMinutes(List<RawHealthRecord> records) {
    if (records.isEmpty) return 0;

    // Convert to sorted intervals
    final intervals = records
        .map((r) => (
              start: r.startTime,
              end: r.endTime.isAfter(r.startTime)
                  ? r.endTime
                  : r.startTime.add(Duration(minutes: max(1, r.value.round()))),
            ))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    int totalMinutes = 0;
    DateTime? currentStart;
    DateTime? currentEnd;

    for (final interval in intervals) {
      if (currentStart == null) {
        currentStart = interval.start;
        currentEnd = interval.end;
      } else if (interval.start.isBefore(currentEnd!) ||
          interval.start.isAtSameMomentAs(currentEnd)) {
        // Overlapping or adjacent interval — extend current span
        if (interval.end.isAfter(currentEnd)) {
          currentEnd = interval.end;
        }
      } else {
        // Gap reached — commit previous interval
        totalMinutes += currentEnd.difference(currentStart).inMinutes.abs();
        currentStart = interval.start;
        currentEnd = interval.end;
      }
    }

    if (currentStart != null && currentEnd != null) {
      totalMinutes += currentEnd.difference(currentStart).inMinutes.abs();
    }

    return totalMinutes;
  }

  /// Extracts clean, deduplicated sleep stages for a specific overnight sleep.
  /// Filters out duplicate records across multiple sync sources (e.g. Nothing + Google Fit).
  static CleanNightSleep sanitizeOvernightStages({
    required List<RawHealthRecord> stageRecords,
    RawHealthRecord? sessionRecord,
    double? fallbackHours,
  }) {
    if (stageRecords.isEmpty && sessionRecord == null) {
      final h = fallbackHours ?? 6.0;
      final totalM = (h * 60).round();
      final deep = (totalM * 0.222).round();
      final rem = (totalM * 0.236).round();
      final core = max(30, totalM - deep - rem);
      return CleanNightSleep(
        deepMinutes: deep,
        coreMinutes: core,
        remMinutes: rem,
        awakeMinutes: 18,
        hasStageData: false,
        totalHours: h,
      );
    }

    // 1. Group records by source
    final bySource = <String, List<RawHealthRecord>>{};
    for (final r in stageRecords) {
      bySource.putIfAbsent(r.sourceId, () => []).add(r);
    }

    // Pick preferred wearable source if multiple exist to avoid double-counting
    List<RawHealthRecord> activeStageRecords = stageRecords;
    if (bySource.length > 1) {
      String? bestSource;
      for (final src in bySource.keys) {
        final lower = src.toLowerCase();
        if (lower.contains('nothing') ||
            lower.contains('cmf') ||
            lower.contains('watch') ||
            lower.contains('wearable') ||
            lower.contains('health')) {
          bestSource = src;
          break;
        }
      }
      bestSource ??= bySource.entries
          .reduce((a, b) => a.value.length >= b.value.length ? a : b)
          .key;
      activeStageRecords = bySource[bestSource] ?? stageRecords;
    }

    // 2. Calculate non-overlapping minutes per stage
    final deepRecs = activeStageRecords
        .where((r) => r.recordType == 'SLEEP_DEEP')
        .toList();
    final lightRecs = activeStageRecords
        .where((r) => r.recordType == 'SLEEP_LIGHT')
        .toList();
    final remRecs =
        activeStageRecords.where((r) => r.recordType == 'SLEEP_REM').toList();
    final awakeRecs = activeStageRecords
        .where((r) => r.recordType == 'SLEEP_AWAKE')
        .toList();

    int deep = calculateMergedMinutes(deepRecs);
    int core = calculateMergedMinutes(lightRecs);
    int rem = calculateMergedMinutes(remRecs);
    int awake = calculateMergedMinutes(awakeRecs);

    final hasStages = (deep + core + rem) > 0;

    // 3. Bound checking against session duration if available
    DateTime? minStart;
    DateTime? maxEnd;
    if (sessionRecord != null) {
      minStart = sessionRecord.startTime;
      maxEnd = sessionRecord.endTime;
    } else if (activeStageRecords.isNotEmpty) {
      minStart = activeStageRecords
          .map((r) => r.startTime)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      maxEnd = activeStageRecords
          .map((r) => r.endTime)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    int totalAsleep = deep + core + rem;
    if (!hasStages && sessionRecord != null) {
      // No stages, only session record
      final sessionM =
          sessionRecord.endTime.difference(sessionRecord.startTime).inMinutes.abs();
      totalAsleep = sessionM > 0 ? sessionM : sessionRecord.value.round();
      // Bound to realistic human range (15m to 12h)
      totalAsleep = totalAsleep.clamp(15, 720);
      deep = (totalAsleep * 0.222).round();
      rem = (totalAsleep * 0.236).round();
      core = max(0, totalAsleep - deep - rem);
      awake = min(18, (totalAsleep * 0.05).round());
    } else if (hasStages && minStart != null && maxEnd != null) {
      // Check that total stage minutes don't exceed the physical elapsed night duration
      final elapsedM = maxEnd.difference(minStart).inMinutes.abs();
      if (elapsedM > 0 && (totalAsleep + awake) > elapsedM) {
        final scale = elapsedM / (totalAsleep + awake);
        deep = (deep * scale).round();
        core = (core * scale).round();
        rem = (rem * scale).round();
        awake = (awake * scale).round();
        totalAsleep = deep + core + rem;
      }
    }

    // Clamp sleep to maximum 12 hours for a single night
    if (totalAsleep > 720) {
      final scale = 720.0 / totalAsleep;
      deep = (deep * scale).round();
      core = (core * scale).round();
      rem = (rem * scale).round();
      awake = (awake * scale).round();
      totalAsleep = deep + core + rem;
    }

    final double totalHours = totalAsleep / 60.0;

    return CleanNightSleep(
      deepMinutes: deep,
      coreMinutes: core,
      remMinutes: rem,
      awakeMinutes: awake,
      startTime: minStart,
      endTime: maxEnd,
      hasStageData: hasStages,
      totalHours: totalHours,
    );
  }

  /// Extracts and classifies distributed sleep sessions (night sleep and naps) across a 24-hour cycle.
  static CleanDistributedSleep extractDistributedSessions({
    required List<RawHealthRecord> stageRecords,
    required List<RawHealthRecord> sessionRecords,
    double? fallbackHours,
  }) {
    if (stageRecords.isEmpty && sessionRecords.isEmpty) {
      final fallback = sanitizeOvernightStages(
        stageRecords: [],
        sessionRecord: null,
        fallbackHours: fallbackHours,
      );
      return CleanDistributedSleep(
        totalHours: fallback.totalHours,
        totalMinutes: fallback.totalAsleepMinutes,
        nightHours: fallback.totalHours,
        napHours: 0.0,
        sessions: [
          CleanDistributedSession(
            title: 'Night Sleep',
            sessionType: 'NIGHT_SLEEP',
            startTime: fallback.startTime ?? DateTime.now().subtract(const Duration(hours: 8)),
            endTime: fallback.endTime ?? DateTime.now(),
            durationHours: fallback.totalHours,
            durationMinutes: fallback.totalAsleepMinutes,
            sleepData: fallback,
            isMainSleep: true,
          ),
        ],
        mainSleep: fallback,
      );
    }

    final rawSessions = <({DateTime start, DateTime end, RawHealthRecord? record})>[];

    if (sessionRecords.isNotEmpty) {
      final sorted = List<RawHealthRecord>.from(sessionRecords)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      DateTime? curStart;
      DateTime? curEnd;
      RawHealthRecord? curRec;

      for (final s in sorted) {
        final sEnd = s.endTime.isAfter(s.startTime)
            ? s.endTime
            : s.startTime.add(Duration(minutes: max(1, s.value.round())));

        if (curStart == null) {
          curStart = s.startTime;
          curEnd = sEnd;
          curRec = s;
        } else if (s.startTime.difference(curEnd!).inMinutes <= 35) {
          // Merge closely adjacent session segments
          if (sEnd.isAfter(curEnd)) curEnd = sEnd;
        } else {
          rawSessions.add((start: curStart, end: curEnd, record: curRec));
          curStart = s.startTime;
          curEnd = sEnd;
          curRec = s;
        }
      }
      if (curStart != null && curEnd != null) {
        rawSessions.add((start: curStart, end: curEnd, record: curRec));
      }
    } else {
      // Group contiguous stage records into distinct sessions
      final sortedStages = List<RawHealthRecord>.from(stageRecords)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      DateTime? curStart;
      DateTime? curEnd;

      for (final st in sortedStages) {
        final stEnd = st.endTime.isAfter(st.startTime)
            ? st.endTime
            : st.startTime.add(Duration(minutes: max(1, st.value.round())));

        if (curStart == null) {
          curStart = st.startTime;
          curEnd = stEnd;
        } else if (st.startTime.difference(curEnd!).inMinutes <= 45) {
          if (stEnd.isAfter(curEnd)) curEnd = stEnd;
        } else {
          rawSessions.add((start: curStart, end: curEnd, record: null));
          curStart = st.startTime;
          curEnd = stEnd;
        }
      }
      if (curStart != null && curEnd != null) {
        rawSessions.add((start: curStart, end: curEnd, record: null));
      }
    }

    // Minimum duration (in minutes) to consider a sleep session real.
    // Sessions shorter than this are discarded as sensor noise / phantom detections.
    const int minNapMinutes = 20;

    // Process each session with its overlapping stage records
    final analyzedSessions = <CleanDistributedSession>[];

    for (final raw in rawSessions) {
      final sessionStages = stageRecords
          .where((r) =>
              r.startTime.isBefore(raw.end.add(const Duration(minutes: 15))) &&
              r.endTime.isAfter(raw.start.subtract(const Duration(minutes: 15))))
          .toList();

      final clean = sanitizeOvernightStages(
        stageRecords: sessionStages,
        sessionRecord: raw.record,
        fallbackHours: raw.end.difference(raw.start).inMinutes / 60.0,
      );

      final durationM = clean.totalAsleepMinutes > 0
          ? clean.totalAsleepMinutes
          : raw.end.difference(raw.start).inMinutes.abs();
      final durationH = durationM / 60.0;

      analyzedSessions.add(CleanDistributedSession(
        title: 'Sleep Session',
        sessionType: 'NIGHT_SLEEP',
        startTime: raw.start,
        endTime: raw.end,
        durationHours: durationH,
        durationMinutes: durationM,
        sleepData: clean,
      ));
    }

    if (analyzedSessions.isEmpty) {
      final fallback = sanitizeOvernightStages(
        stageRecords: stageRecords,
        sessionRecord: sessionRecords.isNotEmpty ? sessionRecords.last : null,
        fallbackHours: fallbackHours,
      );
      return CleanDistributedSleep(
        totalHours: fallback.totalHours,
        totalMinutes: fallback.totalAsleepMinutes,
        nightHours: fallback.totalHours,
        napHours: 0.0,
        sessions: [
          CleanDistributedSession(
            title: 'Night Sleep',
            sessionType: 'NIGHT_SLEEP',
            startTime: fallback.startTime ?? DateTime.now(),
            endTime: fallback.endTime ?? DateTime.now(),
            durationHours: fallback.totalHours,
            durationMinutes: fallback.totalAsleepMinutes,
            sleepData: fallback,
            isMainSleep: true,
          ),
        ],
        mainSleep: fallback,
      );
    }

    // Identify main sleep session (longest duration or primary nocturnal session)
    int mainIndex = 0;
    double maxDur = -1.0;
    for (int i = 0; i < analyzedSessions.length; i++) {
      final s = analyzedSessions[i];
      // Nocturnal bonus for selection
      final isNocturnal = s.startTime.hour >= 20 || s.startTime.hour <= 5;
      final effectiveScore = s.durationHours + (isNocturnal ? 2.0 : 0.0);
      if (effectiveScore > maxDur) {
        maxDur = effectiveScore;
        mainIndex = i;
      }
    }

    final classified = <CleanDistributedSession>[];
    double nightH = 0.0;
    double napH = 0.0;

    for (int i = 0; i < analyzedSessions.length; i++) {
      final s = analyzedSessions[i];
      final isMain = i == mainIndex;

      // Skip phantom / spurious non-main sessions that are too short to be real naps.
      // Main sleep is always kept regardless of duration.
      if (!isMain && s.durationMinutes < minNapMinutes) {
        continue;
      }

      String title;
      String type;

      if (isMain) {
        title = 'Night Sleep';
        type = 'NIGHT_SLEEP';
        nightH += s.durationHours;
      } else {
        final startH = s.startTime.hour;
        if (s.durationHours >= 3.5 || startH >= 21 || startH < 5) {
          title = 'Night Sleep';
          type = 'NIGHT_SLEEP';
          nightH += s.durationHours;
        } else if (startH >= 17 && startH < 21) {
          title = 'Evening Nap';
          type = 'EVENING_NAP';
          napH += s.durationHours;
        } else if (startH >= 12 && startH < 17) {
          title = 'Afternoon Nap';
          type = 'AFTERNOON_NAP';
          napH += s.durationHours;
        } else {
          title = 'Morning Nap';
          type = 'MORNING_NAP';
          napH += s.durationHours;
        }
      }

      classified.add(CleanDistributedSession(
        title: title,
        sessionType: type,
        startTime: s.startTime,
        endTime: s.endTime,
        durationHours: s.durationHours,
        durationMinutes: s.durationMinutes,
        sleepData: s.sleepData,
        isMainSleep: isMain,
      ));
    }

    final totalH = nightH + napH;
    final totalM = (totalH * 60).round();

    // Find the main session in the classified list (index may differ from
    // analyzedSessions after phantom nap filtering).
    final mainSession = classified.firstWhere(
      (s) => s.isMainSleep,
      orElse: () => classified.first,
    );

    return CleanDistributedSleep(
      totalHours: totalH,
      totalMinutes: totalM,
      nightHours: nightH,
      napHours: napH,
      sessions: classified,
      mainSleep: mainSession.sleepData,
    );
  }
}

/// An individual clean distributed sleep session.
class CleanDistributedSession {
  final String title;
  final String sessionType;
  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;
  final int durationMinutes;
  final CleanNightSleep sleepData;
  final bool isMainSleep;

  const CleanDistributedSession({
    required this.title,
    required this.sessionType,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.durationMinutes,
    required this.sleepData,
    this.isMainSleep = false,
  });
}

/// Container for total daily sleep across distributed sessions.
class CleanDistributedSleep {
  final double totalHours;
  final int totalMinutes;
  final double nightHours;
  final double napHours;
  final List<CleanDistributedSession> sessions;
  final CleanNightSleep mainSleep;

  const CleanDistributedSleep({
    required this.totalHours,
    required this.totalMinutes,
    required this.nightHours,
    required this.napHours,
    required this.sessions,
    required this.mainSleep,
  });
}
