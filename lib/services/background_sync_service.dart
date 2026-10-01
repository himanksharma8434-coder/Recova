import 'package:workmanager/workmanager.dart';

import '../data/database/app_database.dart';
import '../data/datasources/health_platform_datasource.dart';
import '../data/repositories/health_repository_impl.dart';

/// Unique task name for the periodic health sync.
const String healthSyncTaskName = 'com.recova.healthSync';

/// Top-level callback for workmanager background execution.
/// Runs in a separate isolate — no access to the main app's UI or state.
@pragma('vm:entry-point')
void callbackDispatcher() {
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

        // Avoid redundant background sync if a sync occurred recently (e.g. user had app open)
        final lastGlobalSync = await db.syncDao.getLastSyncedAt('GLOBAL_SYNC');
        if (lastGlobalSync != null &&
            DateTime.now().difference(lastGlobalSync) < const Duration(minutes: 5)) {
          return true;
        }

        await repository.syncHealthData(taskType: 'background');
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
/// Call this once after permissions are granted.
Future<void> registerPeriodicSync() async {
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
}

/// Cancel the periodic background sync task.
Future<void> cancelPeriodicSync() async {
  await Workmanager().cancelByUniqueName(healthSyncTaskName);
}
