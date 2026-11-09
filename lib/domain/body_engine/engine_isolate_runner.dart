import 'package:flutter/foundation.dart';
import 'body_engine.dart';

/// Serializable input payload for offloading physiological computation
/// to background isolates via [compute].
class EnginePipelineInput {
  final int daysOfData;
  final double? todayRmssdMs;
  final HrvSource hrvSource;
  final List<double>? hrvHistory7d;
  final List<double>? hrvHistory60d;
  final double? todayRhrBpm;
  final List<double>? rhrHistory7d;
  final List<double>? rhrHistory60d;
  final int? lastNightAsleepMinutes;
  final int? inBedMinutes;
  final int? deepMinutes;
  final int? remMinutes;
  final int? lightMinutes;
  final int? awakeMinutes;
  final int? baselineNeedMinutes;
  final int? previousDebtMinutes;
  final int? napMinutesToday;
  final List<DateTime>? recentBedTimes7d;
  final double? todayRespiratoryRate;
  final double? baselineRespiratoryRate;
  final double? todaySpo2;
  final double? baselineSpo2;
  final double? todaySkinTempDeviationCelsius;
  final double? baselineSkinTempDeviationCelsius;
  final double? userMaxHr;
  final int? todaySteps;
  final List<double>? dailyLoadsPast28Days;
  final List<double>? sleepSufficienciesPast3Days;
  final double? currentRestingBpm;
  final double? shortWindowRmssd;
  final double restfulHoursToday;

  const EnginePipelineInput({
    required this.daysOfData,
    this.todayRmssdMs,
    this.hrvSource = HrvSource.vendor,
    this.hrvHistory7d,
    this.hrvHistory60d,
    this.todayRhrBpm,
    this.rhrHistory7d,
    this.rhrHistory60d,
    this.lastNightAsleepMinutes,
    this.inBedMinutes,
    this.deepMinutes,
    this.remMinutes,
    this.lightMinutes,
    this.awakeMinutes,
    this.baselineNeedMinutes,
    this.previousDebtMinutes,
    this.napMinutesToday,
    this.recentBedTimes7d,
    this.todayRespiratoryRate,
    this.baselineRespiratoryRate,
    this.todaySpo2,
    this.baselineSpo2,
    this.todaySkinTempDeviationCelsius,
    this.baselineSkinTempDeviationCelsius,
    this.userMaxHr,
    this.todaySteps,
    this.dailyLoadsPast28Days,
    this.sleepSufficienciesPast3Days,
    this.currentRestingBpm,
    this.shortWindowRmssd,
    this.restfulHoursToday = 0.0,
  });
}

/// Standalone top-level isolate entry-point.
@pragma('vm:entry-point')
DailyEngineOutput runBodyEnginePipelineTopLevel(EnginePipelineInput input) {
  const engine = BodyEngine();
  return engine.processDailyPipeline(
    daysOfData: input.daysOfData,
    todayRmssdMs: input.todayRmssdMs,
    hrvSource: input.hrvSource,
    hrvHistory7d: input.hrvHistory7d,
    hrvHistory60d: input.hrvHistory60d,
    todayRhrBpm: input.todayRhrBpm,
    rhrHistory7d: input.rhrHistory7d,
    rhrHistory60d: input.rhrHistory60d,
    lastNightAsleepMinutes: input.lastNightAsleepMinutes,
    inBedMinutes: input.inBedMinutes,
    deepMinutes: input.deepMinutes,
    remMinutes: input.remMinutes,
    lightMinutes: input.lightMinutes,
    awakeMinutes: input.awakeMinutes,
    baselineNeedMinutes: input.baselineNeedMinutes,
    previousDebtMinutes: input.previousDebtMinutes,
    napMinutesToday: input.napMinutesToday,
    recentBedTimes7d: input.recentBedTimes7d,
    todayRespiratoryRate: input.todayRespiratoryRate,
    baselineRespiratoryRate: input.baselineRespiratoryRate,
    todaySpo2: input.todaySpo2,
    baselineSpo2: input.baselineSpo2,
    todaySkinTempDeviationCelsius: input.todaySkinTempDeviationCelsius,
    baselineSkinTempDeviationCelsius: input.baselineSkinTempDeviationCelsius,
    userMaxHr: input.userMaxHr,
    todaySteps: input.todaySteps,
    dailyLoadsPast28Days: input.dailyLoadsPast28Days,
    sleepSufficienciesPast3Days: input.sleepSufficienciesPast3Days,
    currentRestingBpm: input.currentRestingBpm,
    shortWindowRmssd: input.shortWindowRmssd,
    restfulHoursToday: input.restfulHoursToday,
  );
}

/// Utility for running heavy physiological math safely off the UI thread.
class EngineIsolateRunner {
  /// Computes [DailyEngineOutput] in a background isolate if possible,
  /// falling back gracefully to synchronous execution if isolates are unavailable.
  static Future<DailyEngineOutput> run(EnginePipelineInput input) async {
    try {
      return await compute(runBodyEnginePipelineTopLevel, input);
    } catch (_) {
      // Fallback for widget testing or environments without isolate support
      return runBodyEnginePipelineTopLevel(input);
    }
  }
}
