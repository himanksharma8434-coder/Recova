// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_connection_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceConnectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $DeviceConnectionsTable get deviceConnections =>
      attachedDatabase.deviceConnections;
  DeviceConnectionDaoManager get managers => DeviceConnectionDaoManager(this);
}

class DeviceConnectionDaoManager {
  final _$DeviceConnectionDaoMixin _db;
  DeviceConnectionDaoManager(this._db);
  $$DeviceConnectionsTableTableManager get deviceConnections =>
      $$DeviceConnectionsTableTableManager(
        _db.attachedDatabase,
        _db.deviceConnections,
      );
}
