import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/repositories/health_source_repository.dart';
import 'background_sync_service.dart';

/// Service managing OS Home Screen Widgets (Android AppWidget / iOS WidgetKit)
/// for Recovery and Resting Heart Rate telemetry.
class HomeWidgetService {
  HomeWidgetService._();

  static const String androidWidgetName = 'RecoveryRhrWidgetProvider';
  static const String iOSWidgetName = 'RecoveryRhrWidget';
  static const String qualifiedAndroidName =
      'com.recova.whoop.RecoveryRhrWidgetProvider';

  static const String recovery1x1AndroidWidgetName = 'Recovery1x1WidgetProvider';
  static const String qualifiedRecovery1x1AndroidName =
      'com.recova.whoop.Recovery1x1WidgetProvider';

  static const String vo2Rhr1x1AndroidWidgetName = 'Vo2Rhr1x1WidgetProvider';
  static const String qualifiedVo2Rhr1x1AndroidName =
      'com.recova.whoop.Vo2Rhr1x1WidgetProvider';

  /// Pushes the latest Recovery, Resting Heart Rate, and VO₂ Max data into the OS widget data store
  /// and requests the OS to update all active home screen widgets.
  static Future<void> updateWidget({
    required double? recoveryScore,
    required double? restingHr,
    double? baselineRestingHr,
    double? vo2Max,
    DateTime? lastSyncedAt,
  }) async {
    try {
      final recoveryInt = recoveryScore?.round();
      final recoveryText = recoveryInt != null ? '$recoveryInt%' : '--';

      String status = 'Awaiting Sync';
      if (recoveryInt != null) {
        if (recoveryInt >= 67) {
          status = 'Optimal Recovery';
        } else if (recoveryInt >= 34) {
          status = 'Moderate Recovery';
        } else {
          status = 'Suppressed Recovery';
        }
      }

      final rhrInt = restingHr?.round();
      final rhrText = rhrInt != null ? '$rhrInt bpm' : '--';

      String rhrDelta = 'Basal';
      if (restingHr != null && baselineRestingHr != null) {
        final diff = (restingHr - baselineRestingHr).round();
        if (diff > 0) {
          rhrDelta = '+$diff vs baseline';
        } else if (diff < 0) {
          rhrDelta = '$diff vs baseline';
        } else {
          rhrDelta = 'On baseline';
        }
      }

      final vo2Text = vo2Max != null ? vo2Max.toStringAsFixed(1) : '--';
      final syncRelative = formatRelativeSyncTime(lastSyncedAt ?? DateTime.now());
      final formattedTime = 'Synced $syncRelative • Auto 30m';

      // Persist values in widget shared storage
      await HomeWidget.saveWidgetData<String>('recovery_score', recoveryText);
      await HomeWidget.saveWidgetData<String>('recovery_status', status);
      await HomeWidget.saveWidgetData<String>('resting_hr', rhrText);
      await HomeWidget.saveWidgetData<String>('rhr_delta', rhrDelta);
      await HomeWidget.saveWidgetData<String>('vo2_max', vo2Text);
      await HomeWidget.saveWidgetData<String>('last_updated', formattedTime);

      // Trigger OS native widget refresh for all registered widget types
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
        qualifiedAndroidName: qualifiedAndroidName,
      );

      await HomeWidget.updateWidget(
        name: recovery1x1AndroidWidgetName,
        androidName: recovery1x1AndroidWidgetName,
        iOSName: 'Recovery1x1Widget',
        qualifiedAndroidName: qualifiedRecovery1x1AndroidName,
      );

      await HomeWidget.updateWidget(
        name: vo2Rhr1x1AndroidWidgetName,
        androidName: vo2Rhr1x1AndroidWidgetName,
        iOSName: 'Vo2Rhr1x1Widget',
        qualifiedAndroidName: qualifiedVo2Rhr1x1AndroidName,
      );
    } catch (e) {
      // Gracefully catch missing platform channels in test or unsupported environments
      debugPrint('HomeWidgetService updateWidget notice: $e');
    }
  }

  /// Convenience helper to update widget directly from a [DerivedMetricSummary].
  static Future<void> updateFromSummary(DerivedMetricSummary summary) async {
    await updateWidget(
      recoveryScore: summary.recoveryScore,
      restingHr: summary.restingHr,
      baselineRestingHr: summary.baselineRestingHr,
      vo2Max: summary.estimatedVo2Max,
      lastSyncedAt: summary.lastSyncedAt,
    );
  }
}
