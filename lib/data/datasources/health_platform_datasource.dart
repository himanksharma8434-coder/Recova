import 'dart:io';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/health_types.dart';
import '../../domain/entities/health_record.dart';

/// Wraps the `health` package. This is the ONLY place in the codebase
/// that imports `package:health/health.dart` directly.
class HealthPlatformDatasource {
  Health? _health;

  Health get health => _health ??= Health();

  /// Configure the health plugin. Must be called before any other method.
  Future<void> configure() async {
    await health.configure();
  }

  /// Get the subset of requested types that are valid and supported on this platform.
  List<HealthDataType> getAvailableTypes() {
    return HealthTypes.platformRequestedTypes
        .where((type) => health.isDataTypeAvailable(type))
        .toList();
  }

  /// Get the subset of core types that are valid on this platform.
  List<HealthDataType> getAvailableCoreTypes() {
    return HealthTypes.coreTypes
        .where((type) => health.isDataTypeAvailable(type))
        .toList();
  }

  bool? _cachedPermissionsGranted;

  /// Request read authorization for all configured data types.
  Future<bool> requestPermissions() async {
    await configure();
    try {
      final available = getAvailableTypes();
      final perms = available.map((_) => HealthDataAccess.READ).toList();
      final granted = await health.requestAuthorization(
        available,
        permissions: perms,
      );
      if (granted == true) {
        _cachedPermissionsGranted = true;
        // Also request background read authorization on Android 14+ so background sync succeeds
        if (Platform.isAndroid) {
          try {
            await requestBackgroundReadPermission();
          } catch (_) {}
        }
        return true;
      }
    } catch (_) {
      try {
        final coreAvailable = getAvailableCoreTypes();
        final corePerms = coreAvailable.map((_) => HealthDataAccess.READ).toList();
        final coreGranted = await health.requestAuthorization(
          coreAvailable,
          permissions: corePerms,
        );
        if (coreGranted == true) {
          _cachedPermissionsGranted = true;
          if (Platform.isAndroid) {
            try {
              await requestBackgroundReadPermission();
            } catch (_) {}
          }
          return true;
        }
      } catch (_) {}
    }

    final has = await hasPermissions();
    if (has) {
      _cachedPermissionsGranted = true;
      if (Platform.isAndroid) {
        try {
          await requestBackgroundReadPermission();
        } catch (_) {}
      }
    }
    return has;
  }

  /// Check whether we have permission to read health data.
  Future<bool> hasPermissions() async {
    if (_cachedPermissionsGranted == true) return true;
    try {
      // 1. Check if core types are granted
      final coreAvailable = getAvailableCoreTypes();
      final corePerms = coreAvailable.map((_) => HealthDataAccess.READ).toList();
      final coreResult = await health.hasPermissions(
        coreAvailable,
        permissions: corePerms,
      );
      if (coreResult == true) {
        _cachedPermissionsGranted = true;
        return true;
      }

      // 2. Check individual key types supported on this platform
      final keyTypes = [
        HealthDataType.HEART_RATE,
        HealthDataType.STEPS,
        HealthDataType.RESTING_HEART_RATE,
        if (Platform.isAndroid) HealthDataType.SLEEP_SESSION else HealthDataType.SLEEP_ASLEEP,
      ];
      for (final type in keyTypes) {
        if (health.isDataTypeAvailable(type)) {
          final granted = await health.hasPermissions(
            [type],
            permissions: [HealthDataAccess.READ],
          );
          if (granted == true) {
            _cachedPermissionsGranted = true;
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  /// Check and request background-read permission (Android 14+ only).
  /// On iOS or older Android, returns false without error.
  Future<bool> requestBackgroundReadPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final isAvail = await health.isHealthDataInBackgroundAvailable();
      if (!isAvail) return false;

      final granted = await health.requestHealthDataInBackgroundAuthorization();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('backgroundReadGranted', granted);
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Check if background read was previously granted.
  Future<bool> hasBackgroundReadPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final isAuth = await health.isHealthDataInBackgroundAuthorized();
      if (isAuth) return true;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('backgroundReadGranted') ?? false;
  }

  /// Fetch health data from the platform store for a given time window.
  Future<List<HealthRecord>> fetchRecords({
    required DateTime startTime,
    required DateTime endTime,
    List<HealthDataType>? types,
  }) async {
    final candidateTypes = types ?? getAvailableTypes();
    final validTypes = candidateTypes
        .where((t) => health.isDataTypeAvailable(t))
        .toList();

    if (validTypes.isEmpty) return [];

    try {
      final dataPoints = await health.getHealthDataFromTypes(
        types: validTypes,
        startTime: startTime,
        endTime: endTime,
      );

      final unique = health.removeDuplicates(dataPoints);
      return unique.map(_toHealthRecord).toList();
    } catch (e) {
      // Fallback: fetch per-type so one restricted type does not fail the entire batch
      final List<HealthRecord> allRecords = [];
      for (final type in validTypes) {
        final records = await fetchRecordsForType(
          type: type,
          startTime: startTime,
          endTime: endTime,
        );
        allRecords.addAll(records);
      }
      return allRecords;
    }
  }

  /// Fetch health data for a single type safely without throwing.
  Future<List<HealthRecord>> fetchRecordsForType({
    required HealthDataType type,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!health.isDataTypeAvailable(type)) return [];

    try {
      final dataPoints = await health.getHealthDataFromTypes(
        types: [type],
        startTime: startTime,
        endTime: endTime,
      );

      final unique = health.removeDuplicates(dataPoints);
      return unique.map(_toHealthRecord).toList();
    } catch (_) {
      return [];
    }
  }

  /// Convert a platform HealthDataPoint to our domain entity.
  HealthRecord _toHealthRecord(HealthDataPoint point) {
    double value;
    double? valueSecondary;
    String unit = point.unit.name;

    // Extract numeric value based on the data point type
    final numValue = point.value;
    final isSleep = point.type == HealthDataType.SLEEP_SESSION ||
        point.type == HealthDataType.SLEEP_ASLEEP ||
        point.type == HealthDataType.SLEEP_AWAKE ||
        point.type == HealthDataType.SLEEP_DEEP ||
        point.type == HealthDataType.SLEEP_LIGHT ||
        point.type == HealthDataType.SLEEP_REM;

    if (isSleep) {
      // Sleep values are always elapsed duration in minutes from timestamps
      value = point.dateTo.difference(point.dateFrom).inMinutes.abs().toDouble();
    } else if (numValue is NumericHealthValue) {
      value = numValue.numericValue.toDouble();
    } else if (numValue is WorkoutHealthValue) {
      // For workouts: duration in minutes as primary value,
      // calories as secondary, and exercise type as unit
      value = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
      valueSecondary = numValue.totalEnergyBurned?.toDouble();
      unit = numValue.workoutActivityType.name;
    } else if (numValue is ElectrocardiogramHealthValue) {
      value = numValue.voltageValues.length.toDouble();
    } else {
      value = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
    }

    return HealthRecord(
      recordType: point.type.name,
      value: value,
      valueSecondary: valueSecondary,
      unit: unit,
      startTime: point.dateFrom,
      endTime: point.dateTo,
      sourceId: point.sourceName,
      syncedAt: DateTime.now(),
    );
  }

  /// Read total step count directly from the platform aggregate API
  /// (Health Connect aggregate / HealthKit statistics query).
  /// This automatically de-duplicates overlapping sources (e.g. phone + watch)
  /// and ensures only steps strictly within the requested interval (e.g. today only) are counted.
  Future<int?> getTotalStepsInInterval({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await health.getTotalStepsInInterval(startTime, endTime);
    } catch (_) {
      return null;
    }
  }

  DateTime? _cachedDateOfBirth;
  bool _hasCheckedDateOfBirth = false;

  /// Attempts to fetch the user's date of birth from the platform health store.
  /// Used for age-based HRmax fallback without asking the user manually.
  Future<DateTime?> fetchDateOfBirth() async {
    if (_hasCheckedDateOfBirth) return _cachedDateOfBirth;
    try {
      if (health.isDataTypeAvailable(HealthDataType.BIRTH_DATE)) {
        final records = await health.getHealthDataFromTypes(
          types: [HealthDataType.BIRTH_DATE],
          startTime: DateTime(1900),
          endTime: DateTime.now(),
        );
        if (records.isNotEmpty) {
          _cachedDateOfBirth = records.first.dateFrom;
        }
      }
    } catch (_) {
      // Platform doesn't support reading birth date directly
    }
    _hasCheckedDateOfBirth = true;
    return _cachedDateOfBirth;
  }
}

