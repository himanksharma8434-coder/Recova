import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/health_source_repository.dart';
import 'presentation/cubits/health_permission/health_permission_cubit.dart';
import 'presentation/cubits/health_permission/health_permission_state.dart';
import 'presentation/cubits/health_sync/health_sync_cubit.dart';
import 'presentation/cubits/dashboard/dashboard_cubit.dart';
import 'presentation/screens/permission_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'services/background_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure GetIt dependency injection
  await configureDependencies();

  // Initialize Workmanager for background sync
  await Workmanager().initialize(callbackDispatcher);

  runApp(const RecovaApp());
}

class RecovaApp extends StatelessWidget {
  const RecovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = sl<HealthSourceRepository>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HealthSourceRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<HealthPermissionCubit>()..checkPermissions(),
          ),
          BlocProvider(
            create: (_) => sl<HealthSyncCubit>(),
          ),
          BlocProvider(
            create: (_) => sl<DashboardCubit>(),
          ),
        ],
        child: MaterialApp(
          title: 'Recova - Athletic Recovery Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            overscroll: false,
          ),
          home: BlocBuilder<HealthPermissionCubit, HealthPermissionState>(
            builder: (context, state) {
              if (state is HealthPermissionGranted) {
                return const MainShellScreen();
              }
              return const PermissionScreen();
            },
          ),
        ),
      ),
    );
  }
}
