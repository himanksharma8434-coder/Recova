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

  /// Pushes the latest Recovery and Resting Heart Rate data into the OS widget data store
  /// and requests the OS to update all active home screen widgets.
  static Future<void> updateWidget({
    required double? recoveryScore,
    required double? restingHr,
    double? baselineRestingHr,
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

      final syncRelative = formatRelativeSyncTime(lastSyncedAt ?? DateTime.now());
      final formattedTime = 'Synced $syncRelative • Auto 30m';

      // Persist values in widget shared storage
      await HomeWidget.saveWidgetData<String>('recovery_score', recoveryText);
      await HomeWidget.saveWidgetData<String>('recovery_status', status);
      await HomeWidget.saveWidgetData<String>('resting_hr', rhrText);
      await HomeWidget.saveWidgetData<String>('rhr_delta', rhrDelta);
      await HomeWidget.saveWidgetData<String>('last_updated', formattedTime);

      // Trigger OS native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
        qualifiedAndroidName: qualifiedAndroidName,
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
      lastSyncedAt: summary.lastSyncedAt,
    );
  }
}
