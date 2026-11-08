import 'package:drift/drift.dart';

/// Tracks connected wearable sources, sensors, and status.
class DeviceConnections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()(); // Unique platform or hardware identifier
  TextColumn get name => text()(); // 'CMF Watch Pro', 'Apple Watch', 'Polar H10'
  TextColumn get platform =>
      text()(); // 'health_connect', 'healthkit', 'ble_strap', 'manual'
  DateTimeColumn get lastSyncTime => dateTime().nullable()();
  IntColumn get batteryLevel => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get priority =>
      integer().withDefault(const Constant(10))(); // Higher priority wins deduplication

  @override
  List<Set<Column>> get uniqueKeys => [
        {deviceId}
      ];
}

