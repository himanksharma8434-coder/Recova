import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/database/app_database.dart';
import '../data/datasources/health_platform_datasource.dart';
import '../data/repositories/health_repository_impl.dart';
import 'home_widget_service.dart';

/// Unique task name for the periodic health sync.
const String healthSyncTaskName = 'com.recova.healthSync';

/// Top-level callback for workmanager background execution.
/// Runs in a separate isolate — no access to the main app's UI or state.
@pragma('vm:entry-point')
void callbackDispatcher() {
  // Ensure framework services and binary messengers are initialized in the background isolate
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == healthSyncTaskName ||
          taskName == Workmanager.iOSBackgroundTask) {
        // Initialize dependencies in the background isolate
        final db = AppDatabase.instance;
        final platform = HealthPlatformDatasource();
        await platform.configure();

        final repository = HealthRepositoryImpl(
          platform: platform,
          db: db,
        );

        // Check if we have permissions before attempting sync
        final hasPerms = await repository.hasPermissions();
        if (!hasPerms) {
          // Log and return success to avoid retry loops —
          // user needs to open the app to grant permissions.
          await db.syncDao.logSync(
            taskType: 'background',
            recordsRead: 0,
            recordsWritten: 0,
            success: false,
            errorMessage: 'Health permissions not granted',
          );
          return true;
        }

        // Avoid redundant background sync if a sync occurred recently (< 10 minutes)
        final lastGlobalSync = await db.syncDao.getLastSyncedAt('GLOBAL_SYNC');
        if (lastGlobalSync != null &&
            DateTime.now().difference(lastGlobalSync) < const Duration(minutes: 10)) {
          final summary = await repository.getLatestSummary();
          if (summary != null) {
            await HomeWidgetService.updateFromSummary(summary);
          }
          return true;
        }

        await repository.syncHealthData(taskType: 'background');
        final summary = await repository.getLatestSummary();
        if (summary != null) {
          await HomeWidgetService.updateFromSummary(summary);
        }
      }
      return true;
    } catch (e, st) {
      try {
        final db = AppDatabase.instance;
        await db.syncDao.logSync(
          taskType: 'background',
          recordsRead: 0,
          recordsWritten: 0,
          success: false,
          errorMessage: 'Background sync error: $e\n$st',
        );
      } catch (_) {}
      return false;
    }
  });
}

/// Register the periodic background sync task.
/// Runs every 30 minutes in the background.
Future<void> registerPeriodicSync() async {
  try {
    await Workmanager().registerPeriodicTask(
      healthSyncTaskName,
      healthSyncTaskName,
      frequency: const Duration(minutes: 30),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  } catch (_) {
    // Gracefully ignore on platforms/test environments where Workmanager is unmocked
  }
}

/// Cancel the periodic background sync task.
Future<void> cancelPeriodicSync() async {
  try {
    await Workmanager().cancelByUniqueName(healthSyncTaskName);
  } catch (_) {}
}

/// Helper to get the most recent global sync timestamp.
Future<DateTime?> getLastSyncTime() async {
  try {
    final db = AppDatabase.instance;
    return await db.syncDao.getLastSyncedAt('GLOBAL_SYNC');
  } catch (_) {
    return null;
  }
}

/// Formats a sync DateTime into human-friendly relative duration (e.g. "Just now", "4m ago").
String formatRelativeSyncTime(DateTime? time) {
  if (time == null) return 'Awaiting initial sync';
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 45) {
    return 'Just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  } else {
    return '${diff.inDays}d ago';
  }
}

