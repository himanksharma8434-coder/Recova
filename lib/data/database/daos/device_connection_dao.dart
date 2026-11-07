import 'package:drift/drift.dart';

import '../tables/device_connections.dart';
import '../app_database.dart';

part 'device_connection_dao.g.dart';

@DriftAccessor(tables: [DeviceConnections])
class DeviceConnectionDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceConnectionDaoMixin {
  DeviceConnectionDao(super.db);

  /// Upsert a connected device or platform.
  Future<void> upsertDevice(DeviceConnectionsCompanion device) async {
    await into(deviceConnections).insert(
      device,
      onConflict: DoUpdate(
        (_) => device,
        target: [deviceConnections.deviceId],
      ),
    );
  }

  /// Get all registered devices.
  Future<List<DeviceConnection>> getAllDevices() {
    return (select(deviceConnections)
          ..orderBy([(d) => OrderingTerm.desc(d.priority)]))
        .get();
  }

  /// Watch active devices.
  Stream<List<DeviceConnection>> watchActiveDevices() {
    return (select(deviceConnections)
          ..where((d) => d.isActive.equals(true))
          ..orderBy([(d) => OrderingTerm.desc(d.priority)]))
        .watch();
  }
}

