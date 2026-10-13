// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement_dao.dart';

// ignore_for_file: type=lint
mixin _$BodyMeasurementDaoMixin on DatabaseAccessor<AppDatabase> {
  $BodyMeasurementsTable get bodyMeasurements =>
      attachedDatabase.bodyMeasurements;
  BodyMeasurementDaoManager get managers => BodyMeasurementDaoManager(this);
}

class BodyMeasurementDaoManager {
  final _$BodyMeasurementDaoMixin _db;
  BodyMeasurementDaoManager(this._db);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(
        _db.attachedDatabase,
        _db.bodyMeasurements,
      );
}
