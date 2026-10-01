import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/health_source_repository.dart';
import '../../../services/background_sync_service.dart';
import 'health_permission_state.dart';

class HealthPermissionCubit extends Cubit<HealthPermissionState> {
  final HealthSourceRepository repository;

  HealthPermissionCubit({required this.repository})
      : super(const HealthPermissionInitial());

  /// Check if permissions are already granted.
  Future<void> checkPermissions() async {
    try {
      final hasPerms = await repository.hasPermissions();
      if (hasPerms) {
        final hasBg = await repository.hasBackgroundReadPermission();
        // Register periodic background sync (every 30 minutes)
        await registerPeriodicSync();
        emit(HealthPermissionGranted(backgroundReadGranted: hasBg));
      }
    } catch (_) {
      // Stay in initial state
    }
  }

  /// Request all required health permissions.
  Future<void> requestPermissions() async {
    emit(const HealthPermissionRequesting());
    try {
      final granted = await repository.requestPermissions();
      if (granted) {
        final hasBg = await repository.hasBackgroundReadPermission();
        // Register periodic background sync (every 30 minutes)
        await registerPeriodicSync();
        emit(HealthPermissionGranted(backgroundReadGranted: hasBg));
      } else {
        emit(const HealthPermissionDenied());
      }
    } catch (e) {
      emit(HealthPermissionDenied(message: e.toString()));
    }
  }
}
