// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_dao.dart';

// ignore_for_file: type=lint
mixin _$InsightDaoMixin on DatabaseAccessor<AppDatabase> {
  $InsightsTable get insights => attachedDatabase.insights;
  InsightDaoManager get managers => InsightDaoManager(this);
}

class InsightDaoManager {
  final _$InsightDaoMixin _db;
  InsightDaoManager(this._db);
  $$InsightsTableTableManager get insights =>
      $$InsightsTableTableManager(_db.attachedDatabase, _db.insights);
}
