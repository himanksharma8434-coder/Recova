import 'package:get_it/get_it.dart';

import '../../data/database/app_database.dart';
import '../../data/database/daos/user_profile_dao.dart';
import '../../data/database/daos/sleep_session_dao.dart';
import '../../data/database/daos/workout_session_dao.dart';
import '../../data/database/daos/baseline_snapshot_dao.dart';
import '../../data/database/daos/journal_dao.dart';
import '../../data/database/daos/insight_dao.dart';
import '../../data/database/daos/device_connection_dao.dart';
import '../../data/database/daos/health_record_dao.dart';
import '../../data/database/daos/baseline_dao.dart';
import '../../data/database/daos/derived_metric_dao.dart';
import '../../data/database/daos/sync_dao.dart';
import '../../data/database/daos/body_measurement_dao.dart';
import '../../data/database/daos/body_age_snapshot_dao.dart';
import '../../data/datasources/health_platform_datasource.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../domain/usecases/compute_baselines.dart';
import '../../domain/usecases/compute_vo2max.dart';
import '../../domain/usecases/compute_recovery_score.dart';
import '../../domain/usecases/compute_body_age.dart';
import '../../features/body_age/data/repositories/body_age_repository_impl.dart';
import '../../features/body_age/data/repositories/body_measurement_repository_impl.dart';
import '../../features/body_age/domain/repositories/body_age_repository.dart';
import '../../features/body_age/domain/repositories/body_measurement_repository.dart';
import '../../presentation/cubits/dashboard/dashboard_cubit.dart';
import '../../presentation/cubits/health_sync/health_sync_cubit.dart';
import '../../presentation/cubits/health_permission/health_permission_cubit.dart';
import '../../presentation/cubits/body_age/body_age_cubit.dart';
import '../../features/body_age/presentation/cubits/body_age_checkin/body_age_checkin_cubit.dart';

final sl = GetIt.instance;

/// Central Dependency Injection configuration.
/// Call this before `runApp()` in `main.dart` or in test setups.
Future<void> configureDependencies({AppDatabase? database}) async {
  // Database singleton
  final db = database ?? AppDatabase.instance;
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerSingleton<AppDatabase>(db);
  }

  // DAOs
  if (!sl.isRegistered<UserProfileDao>()) {
    sl.registerLazySingleton<UserProfileDao>(() => db.userProfileDao);
    sl.registerLazySingleton<SleepSessionDao>(() => db.sleepSessionDao);
    sl.registerLazySingleton<WorkoutSessionDao>(() => db.workoutSessionDao);
    sl.registerLazySingleton<BaselineSnapshotDao>(() => db.baselineSnapshotDao);
    sl.registerLazySingleton<JournalDao>(() => db.journalDao);
    sl.registerLazySingleton<InsightDao>(() => db.insightDao);
    sl.registerLazySingleton<DeviceConnectionDao>(() => db.deviceConnectionDao);
    sl.registerLazySingleton<HealthRecordDao>(() => db.healthRecordDao);
    sl.registerLazySingleton<BaselineDao>(() => db.baselineDao);
    sl.registerLazySingleton<DerivedMetricDao>(() => db.derivedMetricDao);
    sl.registerLazySingleton<SyncDao>(() => db.syncDao);
    sl.registerLazySingleton<BodyMeasurementDao>(() => db.bodyMeasurementDao);
    sl.registerLazySingleton<BodyAgeSnapshotDao>(() => db.bodyAgeSnapshotDao);
  }

  // Platform Datasource
  if (!sl.isRegistered<HealthPlatformDatasource>()) {
    sl.registerLazySingleton<HealthPlatformDatasource>(
        () => HealthPlatformDatasource());
  }

  // Pure Use Cases
  if (!sl.isRegistered<ComputeBaselines>()) {
    sl.registerLazySingleton<ComputeBaselines>(() => const ComputeBaselines());
    sl.registerLazySingleton<ComputeVo2Max>(() => const ComputeVo2Max());
    sl.registerLazySingleton<ComputeRecoveryScore>(
        () => const ComputeRecoveryScore());
    sl.registerLazySingleton<ComputeBodyAge>(() => const ComputeBodyAge());
  }

  // Repositories
  if (!sl.isRegistered<HealthSourceRepository>()) {
    sl.registerLazySingleton<HealthSourceRepository>(() => HealthRepositoryImpl(
          platform: sl<HealthPlatformDatasource>(),
          db: sl<AppDatabase>(),
          computeBaselines: sl<ComputeBaselines>(),
          computeVo2Max: sl<ComputeVo2Max>(),
          computeRecoveryScore: sl<ComputeRecoveryScore>(),
          computeBodyAge: sl<ComputeBodyAge>(),
        ));
    sl.registerLazySingleton<BodyAgeRepository>(() => BodyAgeRepositoryImpl());
    sl.registerLazySingleton<BodyMeasurementRepository>(
        () => BodyMeasurementRepositoryImpl());
  }

  // Cubits (Factories for stateful lifecycles)
  if (!sl.isRegistered<DashboardCubit>()) {
    sl.registerFactory<DashboardCubit>(
        () => DashboardCubit(repository: sl<HealthSourceRepository>()));
    sl.registerFactory<HealthSyncCubit>(
        () => HealthSyncCubit(repository: sl<HealthSourceRepository>()));
    sl.registerFactory<HealthPermissionCubit>(
        () => HealthPermissionCubit(repository: sl<HealthSourceRepository>()));
    sl.registerFactory<BodyAgeCubit>(
        () => BodyAgeCubit(repository: sl<HealthSourceRepository>()));
    sl.registerFactory<BodyAgeCheckinCubit>(() => BodyAgeCheckinCubit(
          measurementRepo: sl<BodyMeasurementRepository>(),
          bodyAgeRepo: sl<BodyAgeRepository>(),
        ));
  }
}

