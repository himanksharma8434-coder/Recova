// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RawHealthRecordsTable extends RawHealthRecords
    with TableInfo<$RawHealthRecordsTable, RawHealthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RawHealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueSecondaryMeta = const VerificationMeta(
    'valueSecondary',
  );
  @override
  late final GeneratedColumn<double> valueSecondary = GeneratedColumn<double>(
    'value_secondary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityFlagMeta = const VerificationMeta(
    'qualityFlag',
  );
  @override
  late final GeneratedColumn<String> qualityFlag = GeneratedColumn<String>(
    'quality_flag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordType,
    value,
    valueSecondary,
    unit,
    startTime,
    endTime,
    sourceId,
    qualityFlag,
    timeZoneOffsetMinutes,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'raw_health_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawHealthRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('value_secondary')) {
      context.handle(
        _valueSecondaryMeta,
        valueSecondary.isAcceptableOrUnknown(
          data['value_secondary']!,
          _valueSecondaryMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('quality_flag')) {
      context.handle(
        _qualityFlagMeta,
        qualityFlag.isAcceptableOrUnknown(
          data['quality_flag']!,
          _qualityFlagMeta,
        ),
      );
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recordType, sourceId, startTime},
  ];
  @override
  RawHealthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawHealthRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      valueSecondary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_secondary'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      qualityFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_flag'],
      ),
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $RawHealthRecordsTable createAlias(String alias) {
    return $RawHealthRecordsTable(attachedDatabase, alias);
  }
}

class RawHealthRecord extends DataClass implements Insertable<RawHealthRecord> {
  final int id;
  final String recordType;
  final double value;
  final double? valueSecondary;
  final String unit;
  final DateTime startTime;
  final DateTime endTime;
  final String sourceId;
  final String? qualityFlag;
  final int? timeZoneOffsetMinutes;
  final DateTime syncedAt;
  const RawHealthRecord({
    required this.id,
    required this.recordType,
    required this.value,
    this.valueSecondary,
    required this.unit,
    required this.startTime,
    required this.endTime,
    required this.sourceId,
    this.qualityFlag,
    this.timeZoneOffsetMinutes,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_type'] = Variable<String>(recordType);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || valueSecondary != null) {
      map['value_secondary'] = Variable<double>(valueSecondary);
    }
    map['unit'] = Variable<String>(unit);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || qualityFlag != null) {
      map['quality_flag'] = Variable<String>(qualityFlag);
    }
    if (!nullToAbsent || timeZoneOffsetMinutes != null) {
      map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  RawHealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return RawHealthRecordsCompanion(
      id: Value(id),
      recordType: Value(recordType),
      value: Value(value),
      valueSecondary: valueSecondary == null && nullToAbsent
          ? const Value.absent()
          : Value(valueSecondary),
      unit: Value(unit),
      startTime: Value(startTime),
      endTime: Value(endTime),
      sourceId: Value(sourceId),
      qualityFlag: qualityFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityFlag),
      timeZoneOffsetMinutes: timeZoneOffsetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZoneOffsetMinutes),
      syncedAt: Value(syncedAt),
    );
  }

  factory RawHealthRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawHealthRecord(
      id: serializer.fromJson<int>(json['id']),
      recordType: serializer.fromJson<String>(json['recordType']),
      value: serializer.fromJson<double>(json['value']),
      valueSecondary: serializer.fromJson<double?>(json['valueSecondary']),
      unit: serializer.fromJson<String>(json['unit']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      qualityFlag: serializer.fromJson<String?>(json['qualityFlag']),
      timeZoneOffsetMinutes: serializer.fromJson<int?>(
        json['timeZoneOffsetMinutes'],
      ),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordType': serializer.toJson<String>(recordType),
      'value': serializer.toJson<double>(value),
      'valueSecondary': serializer.toJson<double?>(valueSecondary),
      'unit': serializer.toJson<String>(unit),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'sourceId': serializer.toJson<String>(sourceId),
      'qualityFlag': serializer.toJson<String?>(qualityFlag),
      'timeZoneOffsetMinutes': serializer.toJson<int?>(timeZoneOffsetMinutes),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  RawHealthRecord copyWith({
    int? id,
    String? recordType,
    double? value,
    Value<double?> valueSecondary = const Value.absent(),
    String? unit,
    DateTime? startTime,
    DateTime? endTime,
    String? sourceId,
    Value<String?> qualityFlag = const Value.absent(),
    Value<int?> timeZoneOffsetMinutes = const Value.absent(),
    DateTime? syncedAt,
  }) => RawHealthRecord(
    id: id ?? this.id,
    recordType: recordType ?? this.recordType,
    value: value ?? this.value,
    valueSecondary: valueSecondary.present
        ? valueSecondary.value
        : this.valueSecondary,
    unit: unit ?? this.unit,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    sourceId: sourceId ?? this.sourceId,
    qualityFlag: qualityFlag.present ? qualityFlag.value : this.qualityFlag,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes.present
        ? timeZoneOffsetMinutes.value
        : this.timeZoneOffsetMinutes,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  RawHealthRecord copyWithCompanion(RawHealthRecordsCompanion data) {
    return RawHealthRecord(
      id: data.id.present ? data.id.value : this.id,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      value: data.value.present ? data.value.value : this.value,
      valueSecondary: data.valueSecondary.present
          ? data.valueSecondary.value
          : this.valueSecondary,
      unit: data.unit.present ? data.unit.value : this.unit,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      qualityFlag: data.qualityFlag.present
          ? data.qualityFlag.value
          : this.qualityFlag,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawHealthRecord(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('value: $value, ')
          ..write('valueSecondary: $valueSecondary, ')
          ..write('unit: $unit, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('sourceId: $sourceId, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordType,
    value,
    valueSecondary,
    unit,
    startTime,
    endTime,
    sourceId,
    qualityFlag,
    timeZoneOffsetMinutes,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawHealthRecord &&
          other.id == this.id &&
          other.recordType == this.recordType &&
          other.value == this.value &&
          other.valueSecondary == this.valueSecondary &&
          other.unit == this.unit &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.sourceId == this.sourceId &&
          other.qualityFlag == this.qualityFlag &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.syncedAt == this.syncedAt);
}

class RawHealthRecordsCompanion extends UpdateCompanion<RawHealthRecord> {
  final Value<int> id;
  final Value<String> recordType;
  final Value<double> value;
  final Value<double?> valueSecondary;
  final Value<String> unit;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String> sourceId;
  final Value<String?> qualityFlag;
  final Value<int?> timeZoneOffsetMinutes;
  final Value<DateTime> syncedAt;
  const RawHealthRecordsCompanion({
    this.id = const Value.absent(),
    this.recordType = const Value.absent(),
    this.value = const Value.absent(),
    this.valueSecondary = const Value.absent(),
    this.unit = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.qualityFlag = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  RawHealthRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String recordType,
    required double value,
    this.valueSecondary = const Value.absent(),
    required String unit,
    required DateTime startTime,
    required DateTime endTime,
    required String sourceId,
    this.qualityFlag = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    required DateTime syncedAt,
  }) : recordType = Value(recordType),
       value = Value(value),
       unit = Value(unit),
       startTime = Value(startTime),
       endTime = Value(endTime),
       sourceId = Value(sourceId),
       syncedAt = Value(syncedAt);
  static Insertable<RawHealthRecord> custom({
    Expression<int>? id,
    Expression<String>? recordType,
    Expression<double>? value,
    Expression<double>? valueSecondary,
    Expression<String>? unit,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? sourceId,
    Expression<String>? qualityFlag,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordType != null) 'record_type': recordType,
      if (value != null) 'value': value,
      if (valueSecondary != null) 'value_secondary': valueSecondary,
      if (unit != null) 'unit': unit,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (sourceId != null) 'source_id': sourceId,
      if (qualityFlag != null) 'quality_flag': qualityFlag,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  RawHealthRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? recordType,
    Value<double>? value,
    Value<double?>? valueSecondary,
    Value<String>? unit,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<String>? sourceId,
    Value<String?>? qualityFlag,
    Value<int?>? timeZoneOffsetMinutes,
    Value<DateTime>? syncedAt,
  }) {
    return RawHealthRecordsCompanion(
      id: id ?? this.id,
      recordType: recordType ?? this.recordType,
      value: value ?? this.value,
      valueSecondary: valueSecondary ?? this.valueSecondary,
      unit: unit ?? this.unit,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sourceId: sourceId ?? this.sourceId,
      qualityFlag: qualityFlag ?? this.qualityFlag,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (valueSecondary.present) {
      map['value_secondary'] = Variable<double>(valueSecondary.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (qualityFlag.present) {
      map['quality_flag'] = Variable<String>(qualityFlag.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RawHealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('value: $value, ')
          ..write('valueSecondary: $valueSecondary, ')
          ..write('unit: $unit, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('sourceId: $sourceId, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyBaselinesTable extends DailyBaselines
    with TableInfo<$DailyBaselinesTable, DailyBaseline> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyBaselinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restingHrBaseline7dMeta =
      const VerificationMeta('restingHrBaseline7d');
  @override
  late final GeneratedColumn<double> restingHrBaseline7d =
      GeneratedColumn<double>(
        'resting_hr_baseline7d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _restingHrBaseline30dMeta =
      const VerificationMeta('restingHrBaseline30d');
  @override
  late final GeneratedColumn<double> restingHrBaseline30d =
      GeneratedColumn<double>(
        'resting_hr_baseline30d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sleepDurationBaseline7dMeta =
      const VerificationMeta('sleepDurationBaseline7d');
  @override
  late final GeneratedColumn<double> sleepDurationBaseline7d =
      GeneratedColumn<double>(
        'sleep_duration_baseline7d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _spo2Baseline7dMeta = const VerificationMeta(
    'spo2Baseline7d',
  );
  @override
  late final GeneratedColumn<double> spo2Baseline7d = GeneratedColumn<double>(
    'spo2_baseline7d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    restingHrBaseline7d,
    restingHrBaseline30d,
    sleepDurationBaseline7d,
    spo2Baseline7d,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_baselines';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyBaseline> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('resting_hr_baseline7d')) {
      context.handle(
        _restingHrBaseline7dMeta,
        restingHrBaseline7d.isAcceptableOrUnknown(
          data['resting_hr_baseline7d']!,
          _restingHrBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('resting_hr_baseline30d')) {
      context.handle(
        _restingHrBaseline30dMeta,
        restingHrBaseline30d.isAcceptableOrUnknown(
          data['resting_hr_baseline30d']!,
          _restingHrBaseline30dMeta,
        ),
      );
    }
    if (data.containsKey('sleep_duration_baseline7d')) {
      context.handle(
        _sleepDurationBaseline7dMeta,
        sleepDurationBaseline7d.isAcceptableOrUnknown(
          data['sleep_duration_baseline7d']!,
          _sleepDurationBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('spo2_baseline7d')) {
      context.handle(
        _spo2Baseline7dMeta,
        spo2Baseline7d.isAcceptableOrUnknown(
          data['spo2_baseline7d']!,
          _spo2Baseline7dMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date},
  ];
  @override
  DailyBaseline map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyBaseline(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      restingHrBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_hr_baseline7d'],
      ),
      restingHrBaseline30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_hr_baseline30d'],
      ),
      sleepDurationBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_duration_baseline7d'],
      ),
      spo2Baseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2_baseline7d'],
      ),
    );
  }

  @override
  $DailyBaselinesTable createAlias(String alias) {
    return $DailyBaselinesTable(attachedDatabase, alias);
  }
}

class DailyBaseline extends DataClass implements Insertable<DailyBaseline> {
  final int id;
  final DateTime date;
  final double? restingHrBaseline7d;
  final double? restingHrBaseline30d;
  final double? sleepDurationBaseline7d;
  final double? spo2Baseline7d;
  const DailyBaseline({
    required this.id,
    required this.date,
    this.restingHrBaseline7d,
    this.restingHrBaseline30d,
    this.sleepDurationBaseline7d,
    this.spo2Baseline7d,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || restingHrBaseline7d != null) {
      map['resting_hr_baseline7d'] = Variable<double>(restingHrBaseline7d);
    }
    if (!nullToAbsent || restingHrBaseline30d != null) {
      map['resting_hr_baseline30d'] = Variable<double>(restingHrBaseline30d);
    }
    if (!nullToAbsent || sleepDurationBaseline7d != null) {
      map['sleep_duration_baseline7d'] = Variable<double>(
        sleepDurationBaseline7d,
      );
    }
    if (!nullToAbsent || spo2Baseline7d != null) {
      map['spo2_baseline7d'] = Variable<double>(spo2Baseline7d);
    }
    return map;
  }

  DailyBaselinesCompanion toCompanion(bool nullToAbsent) {
    return DailyBaselinesCompanion(
      id: Value(id),
      date: Value(date),
      restingHrBaseline7d: restingHrBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHrBaseline7d),
      restingHrBaseline30d: restingHrBaseline30d == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHrBaseline30d),
      sleepDurationBaseline7d: sleepDurationBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepDurationBaseline7d),
      spo2Baseline7d: spo2Baseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(spo2Baseline7d),
    );
  }

  factory DailyBaseline.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyBaseline(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      restingHrBaseline7d: serializer.fromJson<double?>(
        json['restingHrBaseline7d'],
      ),
      restingHrBaseline30d: serializer.fromJson<double?>(
        json['restingHrBaseline30d'],
      ),
      sleepDurationBaseline7d: serializer.fromJson<double?>(
        json['sleepDurationBaseline7d'],
      ),
      spo2Baseline7d: serializer.fromJson<double?>(json['spo2Baseline7d']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'restingHrBaseline7d': serializer.toJson<double?>(restingHrBaseline7d),
      'restingHrBaseline30d': serializer.toJson<double?>(restingHrBaseline30d),
      'sleepDurationBaseline7d': serializer.toJson<double?>(
        sleepDurationBaseline7d,
      ),
      'spo2Baseline7d': serializer.toJson<double?>(spo2Baseline7d),
    };
  }

  DailyBaseline copyWith({
    int? id,
    DateTime? date,
    Value<double?> restingHrBaseline7d = const Value.absent(),
    Value<double?> restingHrBaseline30d = const Value.absent(),
    Value<double?> sleepDurationBaseline7d = const Value.absent(),
    Value<double?> spo2Baseline7d = const Value.absent(),
  }) => DailyBaseline(
    id: id ?? this.id,
    date: date ?? this.date,
    restingHrBaseline7d: restingHrBaseline7d.present
        ? restingHrBaseline7d.value
        : this.restingHrBaseline7d,
    restingHrBaseline30d: restingHrBaseline30d.present
        ? restingHrBaseline30d.value
        : this.restingHrBaseline30d,
    sleepDurationBaseline7d: sleepDurationBaseline7d.present
        ? sleepDurationBaseline7d.value
        : this.sleepDurationBaseline7d,
    spo2Baseline7d: spo2Baseline7d.present
        ? spo2Baseline7d.value
        : this.spo2Baseline7d,
  );
  DailyBaseline copyWithCompanion(DailyBaselinesCompanion data) {
    return DailyBaseline(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      restingHrBaseline7d: data.restingHrBaseline7d.present
          ? data.restingHrBaseline7d.value
          : this.restingHrBaseline7d,
      restingHrBaseline30d: data.restingHrBaseline30d.present
          ? data.restingHrBaseline30d.value
          : this.restingHrBaseline30d,
      sleepDurationBaseline7d: data.sleepDurationBaseline7d.present
          ? data.sleepDurationBaseline7d.value
          : this.sleepDurationBaseline7d,
      spo2Baseline7d: data.spo2Baseline7d.present
          ? data.spo2Baseline7d.value
          : this.spo2Baseline7d,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyBaseline(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('restingHrBaseline7d: $restingHrBaseline7d, ')
          ..write('restingHrBaseline30d: $restingHrBaseline30d, ')
          ..write('sleepDurationBaseline7d: $sleepDurationBaseline7d, ')
          ..write('spo2Baseline7d: $spo2Baseline7d')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    restingHrBaseline7d,
    restingHrBaseline30d,
    sleepDurationBaseline7d,
    spo2Baseline7d,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBaseline &&
          other.id == this.id &&
          other.date == this.date &&
          other.restingHrBaseline7d == this.restingHrBaseline7d &&
          other.restingHrBaseline30d == this.restingHrBaseline30d &&
          other.sleepDurationBaseline7d == this.sleepDurationBaseline7d &&
          other.spo2Baseline7d == this.spo2Baseline7d);
}

class DailyBaselinesCompanion extends UpdateCompanion<DailyBaseline> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double?> restingHrBaseline7d;
  final Value<double?> restingHrBaseline30d;
  final Value<double?> sleepDurationBaseline7d;
  final Value<double?> spo2Baseline7d;
  const DailyBaselinesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.restingHrBaseline7d = const Value.absent(),
    this.restingHrBaseline30d = const Value.absent(),
    this.sleepDurationBaseline7d = const Value.absent(),
    this.spo2Baseline7d = const Value.absent(),
  });
  DailyBaselinesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.restingHrBaseline7d = const Value.absent(),
    this.restingHrBaseline30d = const Value.absent(),
    this.sleepDurationBaseline7d = const Value.absent(),
    this.spo2Baseline7d = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyBaseline> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? restingHrBaseline7d,
    Expression<double>? restingHrBaseline30d,
    Expression<double>? sleepDurationBaseline7d,
    Expression<double>? spo2Baseline7d,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (restingHrBaseline7d != null)
        'resting_hr_baseline7d': restingHrBaseline7d,
      if (restingHrBaseline30d != null)
        'resting_hr_baseline30d': restingHrBaseline30d,
      if (sleepDurationBaseline7d != null)
        'sleep_duration_baseline7d': sleepDurationBaseline7d,
      if (spo2Baseline7d != null) 'spo2_baseline7d': spo2Baseline7d,
    });
  }

  DailyBaselinesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double?>? restingHrBaseline7d,
    Value<double?>? restingHrBaseline30d,
    Value<double?>? sleepDurationBaseline7d,
    Value<double?>? spo2Baseline7d,
  }) {
    return DailyBaselinesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      restingHrBaseline7d: restingHrBaseline7d ?? this.restingHrBaseline7d,
      restingHrBaseline30d: restingHrBaseline30d ?? this.restingHrBaseline30d,
      sleepDurationBaseline7d:
          sleepDurationBaseline7d ?? this.sleepDurationBaseline7d,
      spo2Baseline7d: spo2Baseline7d ?? this.spo2Baseline7d,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (restingHrBaseline7d.present) {
      map['resting_hr_baseline7d'] = Variable<double>(
        restingHrBaseline7d.value,
      );
    }
    if (restingHrBaseline30d.present) {
      map['resting_hr_baseline30d'] = Variable<double>(
        restingHrBaseline30d.value,
      );
    }
    if (sleepDurationBaseline7d.present) {
      map['sleep_duration_baseline7d'] = Variable<double>(
        sleepDurationBaseline7d.value,
      );
    }
    if (spo2Baseline7d.present) {
      map['spo2_baseline7d'] = Variable<double>(spo2Baseline7d.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyBaselinesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('restingHrBaseline7d: $restingHrBaseline7d, ')
          ..write('restingHrBaseline30d: $restingHrBaseline30d, ')
          ..write('sleepDurationBaseline7d: $sleepDurationBaseline7d, ')
          ..write('spo2Baseline7d: $spo2Baseline7d')
          ..write(')'))
        .toString();
  }
}

class $DerivedMetricsTable extends DerivedMetrics
    with TableInfo<$DerivedMetricsTable, DerivedMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DerivedMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedVo2MaxMeta = const VerificationMeta(
    'estimatedVo2Max',
  );
  @override
  late final GeneratedColumn<double> estimatedVo2Max = GeneratedColumn<double>(
    'estimated_vo2_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoveryScoreMeta = const VerificationMeta(
    'recoveryScore',
  );
  @override
  late final GeneratedColumn<double> recoveryScore = GeneratedColumn<double>(
    'recovery_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoveryComponentRhrMeta =
      const VerificationMeta('recoveryComponentRhr');
  @override
  late final GeneratedColumn<double> recoveryComponentRhr =
      GeneratedColumn<double>(
        'recovery_component_rhr',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recoveryComponentSleepMeta =
      const VerificationMeta('recoveryComponentSleep');
  @override
  late final GeneratedColumn<double> recoveryComponentSleep =
      GeneratedColumn<double>(
        'recovery_component_sleep',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recoveryComponentSpo2Meta =
      const VerificationMeta('recoveryComponentSpo2');
  @override
  late final GeneratedColumn<double> recoveryComponentSpo2 =
      GeneratedColumn<double>(
        'recovery_component_spo2',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _primaryFactorMeta = const VerificationMeta(
    'primaryFactor',
  );
  @override
  late final GeneratedColumn<String> primaryFactor = GeneratedColumn<String>(
    'primary_factor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readinessConfidenceMeta =
      const VerificationMeta('readinessConfidence');
  @override
  late final GeneratedColumn<String> readinessConfidence =
      GeneratedColumn<String>(
        'readiness_confidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dataQualityMeta = const VerificationMeta(
    'dataQuality',
  );
  @override
  late final GeneratedColumn<String> dataQuality = GeneratedColumn<String>(
    'data_quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('2.0.0'),
  );
  static const VerificationMeta _dayLoadScoreMeta = const VerificationMeta(
    'dayLoadScore',
  );
  @override
  late final GeneratedColumn<double> dayLoadScore = GeneratedColumn<double>(
    'day_load_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepScoreMeta = const VerificationMeta(
    'sleepScore',
  );
  @override
  late final GeneratedColumn<double> sleepScore = GeneratedColumn<double>(
    'sleep_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyReserveMeta = const VerificationMeta(
    'energyReserve',
  );
  @override
  late final GeneratedColumn<double> energyReserve = GeneratedColumn<double>(
    'energy_reserve',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daytimeStressMeta = const VerificationMeta(
    'daytimeStress',
  );
  @override
  late final GeneratedColumn<double> daytimeStress = GeneratedColumn<double>(
    'daytime_stress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topDriversJsonMeta = const VerificationMeta(
    'topDriversJson',
  );
  @override
  late final GeneratedColumn<String> topDriversJson = GeneratedColumn<String>(
    'top_drivers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calculationBreakdownJsonMeta =
      const VerificationMeta('calculationBreakdownJson');
  @override
  late final GeneratedColumn<String> calculationBreakdownJson =
      GeneratedColumn<String>(
        'calculation_breakdown_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    estimatedVo2Max,
    recoveryScore,
    recoveryComponentRhr,
    recoveryComponentSleep,
    recoveryComponentSpo2,
    primaryFactor,
    readinessConfidence,
    dataQuality,
    algorithmVersion,
    dayLoadScore,
    sleepScore,
    energyReserve,
    daytimeStress,
    topDriversJson,
    calculationBreakdownJson,
    timeZoneOffsetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'derived_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DerivedMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('estimated_vo2_max')) {
      context.handle(
        _estimatedVo2MaxMeta,
        estimatedVo2Max.isAcceptableOrUnknown(
          data['estimated_vo2_max']!,
          _estimatedVo2MaxMeta,
        ),
      );
    }
    if (data.containsKey('recovery_score')) {
      context.handle(
        _recoveryScoreMeta,
        recoveryScore.isAcceptableOrUnknown(
          data['recovery_score']!,
          _recoveryScoreMeta,
        ),
      );
    }
    if (data.containsKey('recovery_component_rhr')) {
      context.handle(
        _recoveryComponentRhrMeta,
        recoveryComponentRhr.isAcceptableOrUnknown(
          data['recovery_component_rhr']!,
          _recoveryComponentRhrMeta,
        ),
      );
    }
    if (data.containsKey('recovery_component_sleep')) {
      context.handle(
        _recoveryComponentSleepMeta,
        recoveryComponentSleep.isAcceptableOrUnknown(
          data['recovery_component_sleep']!,
          _recoveryComponentSleepMeta,
        ),
      );
    }
    if (data.containsKey('recovery_component_spo2')) {
      context.handle(
        _recoveryComponentSpo2Meta,
        recoveryComponentSpo2.isAcceptableOrUnknown(
          data['recovery_component_spo2']!,
          _recoveryComponentSpo2Meta,
        ),
      );
    }
    if (data.containsKey('primary_factor')) {
      context.handle(
        _primaryFactorMeta,
        primaryFactor.isAcceptableOrUnknown(
          data['primary_factor']!,
          _primaryFactorMeta,
        ),
      );
    }
    if (data.containsKey('readiness_confidence')) {
      context.handle(
        _readinessConfidenceMeta,
        readinessConfidence.isAcceptableOrUnknown(
          data['readiness_confidence']!,
          _readinessConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('data_quality')) {
      context.handle(
        _dataQualityMeta,
        dataQuality.isAcceptableOrUnknown(
          data['data_quality']!,
          _dataQualityMeta,
        ),
      );
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    }
    if (data.containsKey('day_load_score')) {
      context.handle(
        _dayLoadScoreMeta,
        dayLoadScore.isAcceptableOrUnknown(
          data['day_load_score']!,
          _dayLoadScoreMeta,
        ),
      );
    }
    if (data.containsKey('sleep_score')) {
      context.handle(
        _sleepScoreMeta,
        sleepScore.isAcceptableOrUnknown(data['sleep_score']!, _sleepScoreMeta),
      );
    }
    if (data.containsKey('energy_reserve')) {
      context.handle(
        _energyReserveMeta,
        energyReserve.isAcceptableOrUnknown(
          data['energy_reserve']!,
          _energyReserveMeta,
        ),
      );
    }
    if (data.containsKey('daytime_stress')) {
      context.handle(
        _daytimeStressMeta,
        daytimeStress.isAcceptableOrUnknown(
          data['daytime_stress']!,
          _daytimeStressMeta,
        ),
      );
    }
    if (data.containsKey('top_drivers_json')) {
      context.handle(
        _topDriversJsonMeta,
        topDriversJson.isAcceptableOrUnknown(
          data['top_drivers_json']!,
          _topDriversJsonMeta,
        ),
      );
    }
    if (data.containsKey('calculation_breakdown_json')) {
      context.handle(
        _calculationBreakdownJsonMeta,
        calculationBreakdownJson.isAcceptableOrUnknown(
          data['calculation_breakdown_json']!,
          _calculationBreakdownJsonMeta,
        ),
      );
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date},
  ];
  @override
  DerivedMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DerivedMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      estimatedVo2Max: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_vo2_max'],
      ),
      recoveryScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_score'],
      ),
      recoveryComponentRhr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_component_rhr'],
      ),
      recoveryComponentSleep: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_component_sleep'],
      ),
      recoveryComponentSpo2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_component_spo2'],
      ),
      primaryFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_factor'],
      ),
      readinessConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}readiness_confidence'],
      ),
      dataQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_quality'],
      ),
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      dayLoadScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}day_load_score'],
      ),
      sleepScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_score'],
      ),
      energyReserve: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_reserve'],
      ),
      daytimeStress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daytime_stress'],
      ),
      topDriversJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_drivers_json'],
      ),
      calculationBreakdownJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_breakdown_json'],
      ),
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
    );
  }

  @override
  $DerivedMetricsTable createAlias(String alias) {
    return $DerivedMetricsTable(attachedDatabase, alias);
  }
}

class DerivedMetric extends DataClass implements Insertable<DerivedMetric> {
  final int id;
  final DateTime date;
  final double? estimatedVo2Max;
  final double? recoveryScore;
  final double? recoveryComponentRhr;
  final double? recoveryComponentSleep;
  final double? recoveryComponentSpo2;
  final String? primaryFactor;
  final String? readinessConfidence;
  final String? dataQuality;
  final String algorithmVersion;
  final double? dayLoadScore;
  final double? sleepScore;
  final double? energyReserve;
  final double? daytimeStress;
  final String? topDriversJson;
  final String? calculationBreakdownJson;
  final int timeZoneOffsetMinutes;
  const DerivedMetric({
    required this.id,
    required this.date,
    this.estimatedVo2Max,
    this.recoveryScore,
    this.recoveryComponentRhr,
    this.recoveryComponentSleep,
    this.recoveryComponentSpo2,
    this.primaryFactor,
    this.readinessConfidence,
    this.dataQuality,
    required this.algorithmVersion,
    this.dayLoadScore,
    this.sleepScore,
    this.energyReserve,
    this.daytimeStress,
    this.topDriversJson,
    this.calculationBreakdownJson,
    required this.timeZoneOffsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || estimatedVo2Max != null) {
      map['estimated_vo2_max'] = Variable<double>(estimatedVo2Max);
    }
    if (!nullToAbsent || recoveryScore != null) {
      map['recovery_score'] = Variable<double>(recoveryScore);
    }
    if (!nullToAbsent || recoveryComponentRhr != null) {
      map['recovery_component_rhr'] = Variable<double>(recoveryComponentRhr);
    }
    if (!nullToAbsent || recoveryComponentSleep != null) {
      map['recovery_component_sleep'] = Variable<double>(
        recoveryComponentSleep,
      );
    }
    if (!nullToAbsent || recoveryComponentSpo2 != null) {
      map['recovery_component_spo2'] = Variable<double>(recoveryComponentSpo2);
    }
    if (!nullToAbsent || primaryFactor != null) {
      map['primary_factor'] = Variable<String>(primaryFactor);
    }
    if (!nullToAbsent || readinessConfidence != null) {
      map['readiness_confidence'] = Variable<String>(readinessConfidence);
    }
    if (!nullToAbsent || dataQuality != null) {
      map['data_quality'] = Variable<String>(dataQuality);
    }
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    if (!nullToAbsent || dayLoadScore != null) {
      map['day_load_score'] = Variable<double>(dayLoadScore);
    }
    if (!nullToAbsent || sleepScore != null) {
      map['sleep_score'] = Variable<double>(sleepScore);
    }
    if (!nullToAbsent || energyReserve != null) {
      map['energy_reserve'] = Variable<double>(energyReserve);
    }
    if (!nullToAbsent || daytimeStress != null) {
      map['daytime_stress'] = Variable<double>(daytimeStress);
    }
    if (!nullToAbsent || topDriversJson != null) {
      map['top_drivers_json'] = Variable<String>(topDriversJson);
    }
    if (!nullToAbsent || calculationBreakdownJson != null) {
      map['calculation_breakdown_json'] = Variable<String>(
        calculationBreakdownJson,
      );
    }
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    return map;
  }

  DerivedMetricsCompanion toCompanion(bool nullToAbsent) {
    return DerivedMetricsCompanion(
      id: Value(id),
      date: Value(date),
      estimatedVo2Max: estimatedVo2Max == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedVo2Max),
      recoveryScore: recoveryScore == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryScore),
      recoveryComponentRhr: recoveryComponentRhr == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryComponentRhr),
      recoveryComponentSleep: recoveryComponentSleep == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryComponentSleep),
      recoveryComponentSpo2: recoveryComponentSpo2 == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryComponentSpo2),
      primaryFactor: primaryFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryFactor),
      readinessConfidence: readinessConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(readinessConfidence),
      dataQuality: dataQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(dataQuality),
      algorithmVersion: Value(algorithmVersion),
      dayLoadScore: dayLoadScore == null && nullToAbsent
          ? const Value.absent()
          : Value(dayLoadScore),
      sleepScore: sleepScore == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepScore),
      energyReserve: energyReserve == null && nullToAbsent
          ? const Value.absent()
          : Value(energyReserve),
      daytimeStress: daytimeStress == null && nullToAbsent
          ? const Value.absent()
          : Value(daytimeStress),
      topDriversJson: topDriversJson == null && nullToAbsent
          ? const Value.absent()
          : Value(topDriversJson),
      calculationBreakdownJson: calculationBreakdownJson == null && nullToAbsent
          ? const Value.absent()
          : Value(calculationBreakdownJson),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
    );
  }

  factory DerivedMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DerivedMetric(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      estimatedVo2Max: serializer.fromJson<double?>(json['estimatedVo2Max']),
      recoveryScore: serializer.fromJson<double?>(json['recoveryScore']),
      recoveryComponentRhr: serializer.fromJson<double?>(
        json['recoveryComponentRhr'],
      ),
      recoveryComponentSleep: serializer.fromJson<double?>(
        json['recoveryComponentSleep'],
      ),
      recoveryComponentSpo2: serializer.fromJson<double?>(
        json['recoveryComponentSpo2'],
      ),
      primaryFactor: serializer.fromJson<String?>(json['primaryFactor']),
      readinessConfidence: serializer.fromJson<String?>(
        json['readinessConfidence'],
      ),
      dataQuality: serializer.fromJson<String?>(json['dataQuality']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      dayLoadScore: serializer.fromJson<double?>(json['dayLoadScore']),
      sleepScore: serializer.fromJson<double?>(json['sleepScore']),
      energyReserve: serializer.fromJson<double?>(json['energyReserve']),
      daytimeStress: serializer.fromJson<double?>(json['daytimeStress']),
      topDriversJson: serializer.fromJson<String?>(json['topDriversJson']),
      calculationBreakdownJson: serializer.fromJson<String?>(
        json['calculationBreakdownJson'],
      ),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'estimatedVo2Max': serializer.toJson<double?>(estimatedVo2Max),
      'recoveryScore': serializer.toJson<double?>(recoveryScore),
      'recoveryComponentRhr': serializer.toJson<double?>(recoveryComponentRhr),
      'recoveryComponentSleep': serializer.toJson<double?>(
        recoveryComponentSleep,
      ),
      'recoveryComponentSpo2': serializer.toJson<double?>(
        recoveryComponentSpo2,
      ),
      'primaryFactor': serializer.toJson<String?>(primaryFactor),
      'readinessConfidence': serializer.toJson<String?>(readinessConfidence),
      'dataQuality': serializer.toJson<String?>(dataQuality),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'dayLoadScore': serializer.toJson<double?>(dayLoadScore),
      'sleepScore': serializer.toJson<double?>(sleepScore),
      'energyReserve': serializer.toJson<double?>(energyReserve),
      'daytimeStress': serializer.toJson<double?>(daytimeStress),
      'topDriversJson': serializer.toJson<String?>(topDriversJson),
      'calculationBreakdownJson': serializer.toJson<String?>(
        calculationBreakdownJson,
      ),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
    };
  }

  DerivedMetric copyWith({
    int? id,
    DateTime? date,
    Value<double?> estimatedVo2Max = const Value.absent(),
    Value<double?> recoveryScore = const Value.absent(),
    Value<double?> recoveryComponentRhr = const Value.absent(),
    Value<double?> recoveryComponentSleep = const Value.absent(),
    Value<double?> recoveryComponentSpo2 = const Value.absent(),
    Value<String?> primaryFactor = const Value.absent(),
    Value<String?> readinessConfidence = const Value.absent(),
    Value<String?> dataQuality = const Value.absent(),
    String? algorithmVersion,
    Value<double?> dayLoadScore = const Value.absent(),
    Value<double?> sleepScore = const Value.absent(),
    Value<double?> energyReserve = const Value.absent(),
    Value<double?> daytimeStress = const Value.absent(),
    Value<String?> topDriversJson = const Value.absent(),
    Value<String?> calculationBreakdownJson = const Value.absent(),
    int? timeZoneOffsetMinutes,
  }) => DerivedMetric(
    id: id ?? this.id,
    date: date ?? this.date,
    estimatedVo2Max: estimatedVo2Max.present
        ? estimatedVo2Max.value
        : this.estimatedVo2Max,
    recoveryScore: recoveryScore.present
        ? recoveryScore.value
        : this.recoveryScore,
    recoveryComponentRhr: recoveryComponentRhr.present
        ? recoveryComponentRhr.value
        : this.recoveryComponentRhr,
    recoveryComponentSleep: recoveryComponentSleep.present
        ? recoveryComponentSleep.value
        : this.recoveryComponentSleep,
    recoveryComponentSpo2: recoveryComponentSpo2.present
        ? recoveryComponentSpo2.value
        : this.recoveryComponentSpo2,
    primaryFactor: primaryFactor.present
        ? primaryFactor.value
        : this.primaryFactor,
    readinessConfidence: readinessConfidence.present
        ? readinessConfidence.value
        : this.readinessConfidence,
    dataQuality: dataQuality.present ? dataQuality.value : this.dataQuality,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    dayLoadScore: dayLoadScore.present ? dayLoadScore.value : this.dayLoadScore,
    sleepScore: sleepScore.present ? sleepScore.value : this.sleepScore,
    energyReserve: energyReserve.present
        ? energyReserve.value
        : this.energyReserve,
    daytimeStress: daytimeStress.present
        ? daytimeStress.value
        : this.daytimeStress,
    topDriversJson: topDriversJson.present
        ? topDriversJson.value
        : this.topDriversJson,
    calculationBreakdownJson: calculationBreakdownJson.present
        ? calculationBreakdownJson.value
        : this.calculationBreakdownJson,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
  );
  DerivedMetric copyWithCompanion(DerivedMetricsCompanion data) {
    return DerivedMetric(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      estimatedVo2Max: data.estimatedVo2Max.present
          ? data.estimatedVo2Max.value
          : this.estimatedVo2Max,
      recoveryScore: data.recoveryScore.present
          ? data.recoveryScore.value
          : this.recoveryScore,
      recoveryComponentRhr: data.recoveryComponentRhr.present
          ? data.recoveryComponentRhr.value
          : this.recoveryComponentRhr,
      recoveryComponentSleep: data.recoveryComponentSleep.present
          ? data.recoveryComponentSleep.value
          : this.recoveryComponentSleep,
      recoveryComponentSpo2: data.recoveryComponentSpo2.present
          ? data.recoveryComponentSpo2.value
          : this.recoveryComponentSpo2,
      primaryFactor: data.primaryFactor.present
          ? data.primaryFactor.value
          : this.primaryFactor,
      readinessConfidence: data.readinessConfidence.present
          ? data.readinessConfidence.value
          : this.readinessConfidence,
      dataQuality: data.dataQuality.present
          ? data.dataQuality.value
          : this.dataQuality,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      dayLoadScore: data.dayLoadScore.present
          ? data.dayLoadScore.value
          : this.dayLoadScore,
      sleepScore: data.sleepScore.present
          ? data.sleepScore.value
          : this.sleepScore,
      energyReserve: data.energyReserve.present
          ? data.energyReserve.value
          : this.energyReserve,
      daytimeStress: data.daytimeStress.present
          ? data.daytimeStress.value
          : this.daytimeStress,
      topDriversJson: data.topDriversJson.present
          ? data.topDriversJson.value
          : this.topDriversJson,
      calculationBreakdownJson: data.calculationBreakdownJson.present
          ? data.calculationBreakdownJson.value
          : this.calculationBreakdownJson,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetric(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('estimatedVo2Max: $estimatedVo2Max, ')
          ..write('recoveryScore: $recoveryScore, ')
          ..write('recoveryComponentRhr: $recoveryComponentRhr, ')
          ..write('recoveryComponentSleep: $recoveryComponentSleep, ')
          ..write('recoveryComponentSpo2: $recoveryComponentSpo2, ')
          ..write('primaryFactor: $primaryFactor, ')
          ..write('readinessConfidence: $readinessConfidence, ')
          ..write('dataQuality: $dataQuality, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dayLoadScore: $dayLoadScore, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('energyReserve: $energyReserve, ')
          ..write('daytimeStress: $daytimeStress, ')
          ..write('topDriversJson: $topDriversJson, ')
          ..write('calculationBreakdownJson: $calculationBreakdownJson, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    estimatedVo2Max,
    recoveryScore,
    recoveryComponentRhr,
    recoveryComponentSleep,
    recoveryComponentSpo2,
    primaryFactor,
    readinessConfidence,
    dataQuality,
    algorithmVersion,
    dayLoadScore,
    sleepScore,
    energyReserve,
    daytimeStress,
    topDriversJson,
    calculationBreakdownJson,
    timeZoneOffsetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DerivedMetric &&
          other.id == this.id &&
          other.date == this.date &&
          other.estimatedVo2Max == this.estimatedVo2Max &&
          other.recoveryScore == this.recoveryScore &&
          other.recoveryComponentRhr == this.recoveryComponentRhr &&
          other.recoveryComponentSleep == this.recoveryComponentSleep &&
          other.recoveryComponentSpo2 == this.recoveryComponentSpo2 &&
          other.primaryFactor == this.primaryFactor &&
          other.readinessConfidence == this.readinessConfidence &&
          other.dataQuality == this.dataQuality &&
          other.algorithmVersion == this.algorithmVersion &&
          other.dayLoadScore == this.dayLoadScore &&
          other.sleepScore == this.sleepScore &&
          other.energyReserve == this.energyReserve &&
          other.daytimeStress == this.daytimeStress &&
          other.topDriversJson == this.topDriversJson &&
          other.calculationBreakdownJson == this.calculationBreakdownJson &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes);
}

class DerivedMetricsCompanion extends UpdateCompanion<DerivedMetric> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double?> estimatedVo2Max;
  final Value<double?> recoveryScore;
  final Value<double?> recoveryComponentRhr;
  final Value<double?> recoveryComponentSleep;
  final Value<double?> recoveryComponentSpo2;
  final Value<String?> primaryFactor;
  final Value<String?> readinessConfidence;
  final Value<String?> dataQuality;
  final Value<String> algorithmVersion;
  final Value<double?> dayLoadScore;
  final Value<double?> sleepScore;
  final Value<double?> energyReserve;
  final Value<double?> daytimeStress;
  final Value<String?> topDriversJson;
  final Value<String?> calculationBreakdownJson;
  final Value<int> timeZoneOffsetMinutes;
  const DerivedMetricsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.estimatedVo2Max = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.recoveryComponentRhr = const Value.absent(),
    this.recoveryComponentSleep = const Value.absent(),
    this.recoveryComponentSpo2 = const Value.absent(),
    this.primaryFactor = const Value.absent(),
    this.readinessConfidence = const Value.absent(),
    this.dataQuality = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.dayLoadScore = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.energyReserve = const Value.absent(),
    this.daytimeStress = const Value.absent(),
    this.topDriversJson = const Value.absent(),
    this.calculationBreakdownJson = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
  });
  DerivedMetricsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.estimatedVo2Max = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.recoveryComponentRhr = const Value.absent(),
    this.recoveryComponentSleep = const Value.absent(),
    this.recoveryComponentSpo2 = const Value.absent(),
    this.primaryFactor = const Value.absent(),
    this.readinessConfidence = const Value.absent(),
    this.dataQuality = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.dayLoadScore = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.energyReserve = const Value.absent(),
    this.daytimeStress = const Value.absent(),
    this.topDriversJson = const Value.absent(),
    this.calculationBreakdownJson = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DerivedMetric> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? estimatedVo2Max,
    Expression<double>? recoveryScore,
    Expression<double>? recoveryComponentRhr,
    Expression<double>? recoveryComponentSleep,
    Expression<double>? recoveryComponentSpo2,
    Expression<String>? primaryFactor,
    Expression<String>? readinessConfidence,
    Expression<String>? dataQuality,
    Expression<String>? algorithmVersion,
    Expression<double>? dayLoadScore,
    Expression<double>? sleepScore,
    Expression<double>? energyReserve,
    Expression<double>? daytimeStress,
    Expression<String>? topDriversJson,
    Expression<String>? calculationBreakdownJson,
    Expression<int>? timeZoneOffsetMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (estimatedVo2Max != null) 'estimated_vo2_max': estimatedVo2Max,
      if (recoveryScore != null) 'recovery_score': recoveryScore,
      if (recoveryComponentRhr != null)
        'recovery_component_rhr': recoveryComponentRhr,
      if (recoveryComponentSleep != null)
        'recovery_component_sleep': recoveryComponentSleep,
      if (recoveryComponentSpo2 != null)
        'recovery_component_spo2': recoveryComponentSpo2,
      if (primaryFactor != null) 'primary_factor': primaryFactor,
      if (readinessConfidence != null)
        'readiness_confidence': readinessConfidence,
      if (dataQuality != null) 'data_quality': dataQuality,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (dayLoadScore != null) 'day_load_score': dayLoadScore,
      if (sleepScore != null) 'sleep_score': sleepScore,
      if (energyReserve != null) 'energy_reserve': energyReserve,
      if (daytimeStress != null) 'daytime_stress': daytimeStress,
      if (topDriversJson != null) 'top_drivers_json': topDriversJson,
      if (calculationBreakdownJson != null)
        'calculation_breakdown_json': calculationBreakdownJson,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
    });
  }

  DerivedMetricsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double?>? estimatedVo2Max,
    Value<double?>? recoveryScore,
    Value<double?>? recoveryComponentRhr,
    Value<double?>? recoveryComponentSleep,
    Value<double?>? recoveryComponentSpo2,
    Value<String?>? primaryFactor,
    Value<String?>? readinessConfidence,
    Value<String?>? dataQuality,
    Value<String>? algorithmVersion,
    Value<double?>? dayLoadScore,
    Value<double?>? sleepScore,
    Value<double?>? energyReserve,
    Value<double?>? daytimeStress,
    Value<String?>? topDriversJson,
    Value<String?>? calculationBreakdownJson,
    Value<int>? timeZoneOffsetMinutes,
  }) {
    return DerivedMetricsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      estimatedVo2Max: estimatedVo2Max ?? this.estimatedVo2Max,
      recoveryScore: recoveryScore ?? this.recoveryScore,
      recoveryComponentRhr: recoveryComponentRhr ?? this.recoveryComponentRhr,
      recoveryComponentSleep:
          recoveryComponentSleep ?? this.recoveryComponentSleep,
      recoveryComponentSpo2:
          recoveryComponentSpo2 ?? this.recoveryComponentSpo2,
      primaryFactor: primaryFactor ?? this.primaryFactor,
      readinessConfidence: readinessConfidence ?? this.readinessConfidence,
      dataQuality: dataQuality ?? this.dataQuality,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      dayLoadScore: dayLoadScore ?? this.dayLoadScore,
      sleepScore: sleepScore ?? this.sleepScore,
      energyReserve: energyReserve ?? this.energyReserve,
      daytimeStress: daytimeStress ?? this.daytimeStress,
      topDriversJson: topDriversJson ?? this.topDriversJson,
      calculationBreakdownJson:
          calculationBreakdownJson ?? this.calculationBreakdownJson,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (estimatedVo2Max.present) {
      map['estimated_vo2_max'] = Variable<double>(estimatedVo2Max.value);
    }
    if (recoveryScore.present) {
      map['recovery_score'] = Variable<double>(recoveryScore.value);
    }
    if (recoveryComponentRhr.present) {
      map['recovery_component_rhr'] = Variable<double>(
        recoveryComponentRhr.value,
      );
    }
    if (recoveryComponentSleep.present) {
      map['recovery_component_sleep'] = Variable<double>(
        recoveryComponentSleep.value,
      );
    }
    if (recoveryComponentSpo2.present) {
      map['recovery_component_spo2'] = Variable<double>(
        recoveryComponentSpo2.value,
      );
    }
    if (primaryFactor.present) {
      map['primary_factor'] = Variable<String>(primaryFactor.value);
    }
    if (readinessConfidence.present) {
      map['readiness_confidence'] = Variable<String>(readinessConfidence.value);
    }
    if (dataQuality.present) {
      map['data_quality'] = Variable<String>(dataQuality.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (dayLoadScore.present) {
      map['day_load_score'] = Variable<double>(dayLoadScore.value);
    }
    if (sleepScore.present) {
      map['sleep_score'] = Variable<double>(sleepScore.value);
    }
    if (energyReserve.present) {
      map['energy_reserve'] = Variable<double>(energyReserve.value);
    }
    if (daytimeStress.present) {
      map['daytime_stress'] = Variable<double>(daytimeStress.value);
    }
    if (topDriversJson.present) {
      map['top_drivers_json'] = Variable<String>(topDriversJson.value);
    }
    if (calculationBreakdownJson.present) {
      map['calculation_breakdown_json'] = Variable<String>(
        calculationBreakdownJson.value,
      );
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetricsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('estimatedVo2Max: $estimatedVo2Max, ')
          ..write('recoveryScore: $recoveryScore, ')
          ..write('recoveryComponentRhr: $recoveryComponentRhr, ')
          ..write('recoveryComponentSleep: $recoveryComponentSleep, ')
          ..write('recoveryComponentSpo2: $recoveryComponentSpo2, ')
          ..write('primaryFactor: $primaryFactor, ')
          ..write('readinessConfidence: $readinessConfidence, ')
          ..write('dataQuality: $dataQuality, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dayLoadScore: $dayLoadScore, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('energyReserve: $energyReserve, ')
          ..write('daytimeStress: $daytimeStress, ')
          ..write('topDriversJson: $topDriversJson, ')
          ..write('calculationBreakdownJson: $calculationBreakdownJson, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recordType, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recordType},
  ];
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final int id;
  final String recordType;
  final DateTime lastSyncedAt;
  const SyncMetadataData({
    required this.id,
    required this.recordType,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_type'] = Variable<String>(recordType);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      recordType: Value(recordType),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      recordType: serializer.fromJson<String>(json['recordType']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordType': serializer.toJson<String>(recordType),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncMetadataData copyWith({
    int? id,
    String? recordType,
    DateTime? lastSyncedAt,
  }) => SyncMetadataData(
    id: id ?? this.id,
    recordType: recordType ?? this.recordType,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recordType, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.recordType == this.recordType &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<int> id;
  final Value<String> recordType;
  final Value<DateTime> lastSyncedAt;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.recordType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String recordType,
    required DateTime lastSyncedAt,
  }) : recordType = Value(recordType),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncMetadataData> custom({
    Expression<int>? id,
    Expression<String>? recordType,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordType != null) 'record_type': recordType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? recordType,
    Value<DateTime>? lastSyncedAt,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      recordType: recordType ?? this.recordType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs with TableInfo<$SyncLogsTable, SyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordsReadMeta = const VerificationMeta(
    'recordsRead',
  );
  @override
  late final GeneratedColumn<int> recordsRead = GeneratedColumn<int>(
    'records_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordsWrittenMeta = const VerificationMeta(
    'recordsWritten',
  );
  @override
  late final GeneratedColumn<int> recordsWritten = GeneratedColumn<int>(
    'records_written',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    taskType,
    recordsRead,
    recordsWritten,
    success,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('records_read')) {
      context.handle(
        _recordsReadMeta,
        recordsRead.isAcceptableOrUnknown(
          data['records_read']!,
          _recordsReadMeta,
        ),
      );
    }
    if (data.containsKey('records_written')) {
      context.handle(
        _recordsWrittenMeta,
        recordsWritten.isAcceptableOrUnknown(
          data['records_written']!,
          _recordsWrittenMeta,
        ),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      recordsRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_read'],
      )!,
      recordsWritten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_written'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLog extends DataClass implements Insertable<SyncLog> {
  final int id;
  final DateTime timestamp;
  final String taskType;
  final int recordsRead;
  final int recordsWritten;
  final bool success;
  final String? errorMessage;
  const SyncLog({
    required this.id,
    required this.timestamp,
    required this.taskType,
    required this.recordsRead,
    required this.recordsWritten,
    required this.success,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['task_type'] = Variable<String>(taskType);
    map['records_read'] = Variable<int>(recordsRead);
    map['records_written'] = Variable<int>(recordsWritten);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      taskType: Value(taskType),
      recordsRead: Value(recordsRead),
      recordsWritten: Value(recordsWritten),
      success: Value(success),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLog(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      taskType: serializer.fromJson<String>(json['taskType']),
      recordsRead: serializer.fromJson<int>(json['recordsRead']),
      recordsWritten: serializer.fromJson<int>(json['recordsWritten']),
      success: serializer.fromJson<bool>(json['success']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'taskType': serializer.toJson<String>(taskType),
      'recordsRead': serializer.toJson<int>(recordsRead),
      'recordsWritten': serializer.toJson<int>(recordsWritten),
      'success': serializer.toJson<bool>(success),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncLog copyWith({
    int? id,
    DateTime? timestamp,
    String? taskType,
    int? recordsRead,
    int? recordsWritten,
    bool? success,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncLog(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    taskType: taskType ?? this.taskType,
    recordsRead: recordsRead ?? this.recordsRead,
    recordsWritten: recordsWritten ?? this.recordsWritten,
    success: success ?? this.success,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncLog copyWithCompanion(SyncLogsCompanion data) {
    return SyncLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      recordsRead: data.recordsRead.present
          ? data.recordsRead.value
          : this.recordsRead,
      recordsWritten: data.recordsWritten.present
          ? data.recordsWritten.value
          : this.recordsWritten,
      success: data.success.present ? data.success.value : this.success,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('taskType: $taskType, ')
          ..write('recordsRead: $recordsRead, ')
          ..write('recordsWritten: $recordsWritten, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    taskType,
    recordsRead,
    recordsWritten,
    success,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.taskType == this.taskType &&
          other.recordsRead == this.recordsRead &&
          other.recordsWritten == this.recordsWritten &&
          other.success == this.success &&
          other.errorMessage == this.errorMessage);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLog> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String> taskType;
  final Value<int> recordsRead;
  final Value<int> recordsWritten;
  final Value<bool> success;
  final Value<String?> errorMessage;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.taskType = const Value.absent(),
    this.recordsRead = const Value.absent(),
    this.recordsWritten = const Value.absent(),
    this.success = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required String taskType,
    this.recordsRead = const Value.absent(),
    this.recordsWritten = const Value.absent(),
    this.success = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : timestamp = Value(timestamp),
       taskType = Value(taskType);
  static Insertable<SyncLog> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? taskType,
    Expression<int>? recordsRead,
    Expression<int>? recordsWritten,
    Expression<bool>? success,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (taskType != null) 'task_type': taskType,
      if (recordsRead != null) 'records_read': recordsRead,
      if (recordsWritten != null) 'records_written': recordsWritten,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<String>? taskType,
    Value<int>? recordsRead,
    Value<int>? recordsWritten,
    Value<bool>? success,
    Value<String?>? errorMessage,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      taskType: taskType ?? this.taskType,
      recordsRead: recordsRead ?? this.recordsRead,
      recordsWritten: recordsWritten ?? this.recordsWritten,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (recordsRead.present) {
      map['records_read'] = Variable<int>(recordsRead.value);
    }
    if (recordsWritten.present) {
      map['records_written'] = Variable<int>(recordsWritten.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('taskType: $taskType, ')
          ..write('recordsRead: $recordsRead, ')
          ..write('recordsWritten: $recordsWritten, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta(
    'bodyFatPct',
  );
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    measuredAt,
    weightKg,
    bodyFatPct,
    source,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(
        _bodyFatPctMeta,
        bodyFatPct.isAcceptableOrUnknown(
          data['body_fat_pct']!,
          _bodyFatPctMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      bodyFatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_pct'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final int id;
  final String userId;
  final DateTime measuredAt;
  final double weightKg;
  final double? bodyFatPct;
  final String source;
  final bool synced;
  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.measuredAt,
    required this.weightKg,
    this.bodyFatPct,
    required this.source,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    map['source'] = Variable<String>(source);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      userId: Value(userId),
      measuredAt: Value(measuredAt),
      weightKg: Value(weightKg),
      bodyFatPct: bodyFatPct == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPct),
      source: Value(source),
      synced: Value(synced),
    );
  }

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      source: serializer.fromJson<String>(json['source']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'source': serializer.toJson<String>(source),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  BodyMeasurement copyWith({
    int? id,
    String? userId,
    DateTime? measuredAt,
    double? weightKg,
    Value<double?> bodyFatPct = const Value.absent(),
    String? source,
    bool? synced,
  }) => BodyMeasurement(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    measuredAt: measuredAt ?? this.measuredAt,
    weightKg: weightKg ?? this.weightKg,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    source: source ?? this.source,
    synced: synced ?? this.synced,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bodyFatPct: data.bodyFatPct.present
          ? data.bodyFatPct.value
          : this.bodyFatPct,
      source: data.source.present ? data.source.value : this.source,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('source: $source, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, measuredAt, weightKg, bodyFatPct, source, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.measuredAt == this.measuredAt &&
          other.weightKg == this.weightKg &&
          other.bodyFatPct == this.bodyFatPct &&
          other.source == this.source &&
          other.synced == this.synced);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> measuredAt;
  final Value<double> weightKg;
  final Value<double?> bodyFatPct;
  final Value<String> source;
  final Value<bool> synced;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.source = const Value.absent(),
    this.synced = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime measuredAt,
    required double weightKg,
    this.bodyFatPct = const Value.absent(),
    this.source = const Value.absent(),
    this.synced = const Value.absent(),
  }) : measuredAt = Value(measuredAt),
       weightKg = Value(weightKg);
  static Insertable<BodyMeasurement> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? measuredAt,
    Expression<double>? weightKg,
    Expression<double>? bodyFatPct,
    Expression<String>? source,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (source != null) 'source': source,
      if (synced != null) 'synced': synced,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? measuredAt,
    Value<double>? weightKg,
    Value<double?>? bodyFatPct,
    Value<String>? source,
    Value<bool>? synced,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      source: source ?? this.source,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('source: $source, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $BodyAgeSnapshotsTable extends BodyAgeSnapshots
    with TableInfo<$BodyAgeSnapshotsTable, BodyAgeSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyAgeSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyAgeMeta = const VerificationMeta(
    'bodyAge',
  );
  @override
  late final GeneratedColumn<double> bodyAge = GeneratedColumn<double>(
    'body_age',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chronologicalAgeMeta = const VerificationMeta(
    'chronologicalAge',
  );
  @override
  late final GeneratedColumn<int> chronologicalAge = GeneratedColumn<int>(
    'chronological_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorAgesJsonMeta = const VerificationMeta(
    'factorAgesJson',
  );
  @override
  late final GeneratedColumn<String> factorAgesJson = GeneratedColumn<String>(
    'factor_ages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    calculatedAt,
    bodyAge,
    chronologicalAge,
    factorAgesJson,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_age_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyAgeSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    if (data.containsKey('body_age')) {
      context.handle(
        _bodyAgeMeta,
        bodyAge.isAcceptableOrUnknown(data['body_age']!, _bodyAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyAgeMeta);
    }
    if (data.containsKey('chronological_age')) {
      context.handle(
        _chronologicalAgeMeta,
        chronologicalAge.isAcceptableOrUnknown(
          data['chronological_age']!,
          _chronologicalAgeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chronologicalAgeMeta);
    }
    if (data.containsKey('factor_ages_json')) {
      context.handle(
        _factorAgesJsonMeta,
        factorAgesJson.isAcceptableOrUnknown(
          data['factor_ages_json']!,
          _factorAgesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factorAgesJsonMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyAgeSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyAgeSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
      bodyAge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_age'],
      )!,
      chronologicalAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chronological_age'],
      )!,
      factorAgesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factor_ages_json'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BodyAgeSnapshotsTable createAlias(String alias) {
    return $BodyAgeSnapshotsTable(attachedDatabase, alias);
  }
}

class BodyAgeSnapshot extends DataClass implements Insertable<BodyAgeSnapshot> {
  final int id;
  final String userId;
  final DateTime calculatedAt;
  final double bodyAge;
  final int chronologicalAge;
  final String factorAgesJson;
  final bool synced;
  const BodyAgeSnapshot({
    required this.id,
    required this.userId,
    required this.calculatedAt,
    required this.bodyAge,
    required this.chronologicalAge,
    required this.factorAgesJson,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    map['body_age'] = Variable<double>(bodyAge);
    map['chronological_age'] = Variable<int>(chronologicalAge);
    map['factor_ages_json'] = Variable<String>(factorAgesJson);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BodyAgeSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BodyAgeSnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      calculatedAt: Value(calculatedAt),
      bodyAge: Value(bodyAge),
      chronologicalAge: Value(chronologicalAge),
      factorAgesJson: Value(factorAgesJson),
      synced: Value(synced),
    );
  }

  factory BodyAgeSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyAgeSnapshot(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
      bodyAge: serializer.fromJson<double>(json['bodyAge']),
      chronologicalAge: serializer.fromJson<int>(json['chronologicalAge']),
      factorAgesJson: serializer.fromJson<String>(json['factorAgesJson']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
      'bodyAge': serializer.toJson<double>(bodyAge),
      'chronologicalAge': serializer.toJson<int>(chronologicalAge),
      'factorAgesJson': serializer.toJson<String>(factorAgesJson),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  BodyAgeSnapshot copyWith({
    int? id,
    String? userId,
    DateTime? calculatedAt,
    double? bodyAge,
    int? chronologicalAge,
    String? factorAgesJson,
    bool? synced,
  }) => BodyAgeSnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    calculatedAt: calculatedAt ?? this.calculatedAt,
    bodyAge: bodyAge ?? this.bodyAge,
    chronologicalAge: chronologicalAge ?? this.chronologicalAge,
    factorAgesJson: factorAgesJson ?? this.factorAgesJson,
    synced: synced ?? this.synced,
  );
  BodyAgeSnapshot copyWithCompanion(BodyAgeSnapshotsCompanion data) {
    return BodyAgeSnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
      bodyAge: data.bodyAge.present ? data.bodyAge.value : this.bodyAge,
      chronologicalAge: data.chronologicalAge.present
          ? data.chronologicalAge.value
          : this.chronologicalAge,
      factorAgesJson: data.factorAgesJson.present
          ? data.factorAgesJson.value
          : this.factorAgesJson,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyAgeSnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('bodyAge: $bodyAge, ')
          ..write('chronologicalAge: $chronologicalAge, ')
          ..write('factorAgesJson: $factorAgesJson, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    calculatedAt,
    bodyAge,
    chronologicalAge,
    factorAgesJson,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyAgeSnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.calculatedAt == this.calculatedAt &&
          other.bodyAge == this.bodyAge &&
          other.chronologicalAge == this.chronologicalAge &&
          other.factorAgesJson == this.factorAgesJson &&
          other.synced == this.synced);
}

class BodyAgeSnapshotsCompanion extends UpdateCompanion<BodyAgeSnapshot> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> calculatedAt;
  final Value<double> bodyAge;
  final Value<int> chronologicalAge;
  final Value<String> factorAgesJson;
  final Value<bool> synced;
  const BodyAgeSnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.bodyAge = const Value.absent(),
    this.chronologicalAge = const Value.absent(),
    this.factorAgesJson = const Value.absent(),
    this.synced = const Value.absent(),
  });
  BodyAgeSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime calculatedAt,
    required double bodyAge,
    required int chronologicalAge,
    required String factorAgesJson,
    this.synced = const Value.absent(),
  }) : calculatedAt = Value(calculatedAt),
       bodyAge = Value(bodyAge),
       chronologicalAge = Value(chronologicalAge),
       factorAgesJson = Value(factorAgesJson);
  static Insertable<BodyAgeSnapshot> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? calculatedAt,
    Expression<double>? bodyAge,
    Expression<int>? chronologicalAge,
    Expression<String>? factorAgesJson,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (bodyAge != null) 'body_age': bodyAge,
      if (chronologicalAge != null) 'chronological_age': chronologicalAge,
      if (factorAgesJson != null) 'factor_ages_json': factorAgesJson,
      if (synced != null) 'synced': synced,
    });
  }

  BodyAgeSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? calculatedAt,
    Value<double>? bodyAge,
    Value<int>? chronologicalAge,
    Value<String>? factorAgesJson,
    Value<bool>? synced,
  }) {
    return BodyAgeSnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      bodyAge: bodyAge ?? this.bodyAge,
      chronologicalAge: chronologicalAge ?? this.chronologicalAge,
      factorAgesJson: factorAgesJson ?? this.factorAgesJson,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (bodyAge.present) {
      map['body_age'] = Variable<double>(bodyAge.value);
    }
    if (chronologicalAge.present) {
      map['chronological_age'] = Variable<int>(chronologicalAge.value);
    }
    if (factorAgesJson.present) {
      map['factor_ages_json'] = Variable<String>(factorAgesJson.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyAgeSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('bodyAge: $bodyAge, ')
          ..write('chronologicalAge: $chronologicalAge, ')
          ..write('factorAgesJson: $factorAgesJson, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta(
    'bodyFatPct',
  );
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<double> maxHr = GeneratedColumn<double>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restingHrBaselineMeta = const VerificationMeta(
    'restingHrBaseline',
  );
  @override
  late final GeneratedColumn<double> restingHrBaseline =
      GeneratedColumn<double>(
        'resting_hr_baseline',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sleepNeedBaselineMinutesMeta =
      const VerificationMeta('sleepNeedBaselineMinutes');
  @override
  late final GeneratedColumn<int> sleepNeedBaselineMinutes =
      GeneratedColumn<int>(
        'sleep_need_baseline_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(480),
      );
  static const VerificationMeta _targetStrainMeta = const VerificationMeta(
    'targetStrain',
  );
  @override
  late final GeneratedColumn<double> targetStrain = GeneratedColumn<double>(
    'target_strain',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    age,
    sex,
    heightCm,
    weightKg,
    bodyFatPct,
    maxHr,
    restingHrBaseline,
    sleepNeedBaselineMinutes,
    targetStrain,
    units,
    timeZone,
    timeZoneOffsetMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(
        _bodyFatPctMeta,
        bodyFatPct.isAcceptableOrUnknown(
          data['body_fat_pct']!,
          _bodyFatPctMeta,
        ),
      );
    }
    if (data.containsKey('max_hr')) {
      context.handle(
        _maxHrMeta,
        maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta),
      );
    }
    if (data.containsKey('resting_hr_baseline')) {
      context.handle(
        _restingHrBaselineMeta,
        restingHrBaseline.isAcceptableOrUnknown(
          data['resting_hr_baseline']!,
          _restingHrBaselineMeta,
        ),
      );
    }
    if (data.containsKey('sleep_need_baseline_minutes')) {
      context.handle(
        _sleepNeedBaselineMinutesMeta,
        sleepNeedBaselineMinutes.isAcceptableOrUnknown(
          data['sleep_need_baseline_minutes']!,
          _sleepNeedBaselineMinutesMeta,
        ),
      );
    }
    if (data.containsKey('target_strain')) {
      context.handle(
        _targetStrainMeta,
        targetStrain.isAcceptableOrUnknown(
          data['target_strain']!,
          _targetStrainMeta,
        ),
      );
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId},
  ];
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      bodyFatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_pct'],
      ),
      maxHr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_hr'],
      ),
      restingHrBaseline: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_hr_baseline'],
      ),
      sleepNeedBaselineMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_need_baseline_minutes'],
      )!,
      targetStrain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_strain'],
      ),
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}units'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String userId;
  final int? age;
  final String? sex;
  final double? heightCm;
  final double? weightKg;
  final double? bodyFatPct;
  final double? maxHr;
  final double? restingHrBaseline;
  final int sleepNeedBaselineMinutes;
  final double? targetStrain;
  final String units;
  final String timeZone;
  final int timeZoneOffsetMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.userId,
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.bodyFatPct,
    this.maxHr,
    this.restingHrBaseline,
    required this.sleepNeedBaselineMinutes,
    this.targetStrain,
    required this.units,
    required this.timeZone,
    required this.timeZoneOffsetMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<double>(maxHr);
    }
    if (!nullToAbsent || restingHrBaseline != null) {
      map['resting_hr_baseline'] = Variable<double>(restingHrBaseline);
    }
    map['sleep_need_baseline_minutes'] = Variable<int>(
      sleepNeedBaselineMinutes,
    );
    if (!nullToAbsent || targetStrain != null) {
      map['target_strain'] = Variable<double>(targetStrain);
    }
    map['units'] = Variable<String>(units);
    map['time_zone'] = Variable<String>(timeZone);
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      bodyFatPct: bodyFatPct == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPct),
      maxHr: maxHr == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHr),
      restingHrBaseline: restingHrBaseline == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHrBaseline),
      sleepNeedBaselineMinutes: Value(sleepNeedBaselineMinutes),
      targetStrain: targetStrain == null && nullToAbsent
          ? const Value.absent()
          : Value(targetStrain),
      units: Value(units),
      timeZone: Value(timeZone),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      age: serializer.fromJson<int?>(json['age']),
      sex: serializer.fromJson<String?>(json['sex']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      maxHr: serializer.fromJson<double?>(json['maxHr']),
      restingHrBaseline: serializer.fromJson<double?>(
        json['restingHrBaseline'],
      ),
      sleepNeedBaselineMinutes: serializer.fromJson<int>(
        json['sleepNeedBaselineMinutes'],
      ),
      targetStrain: serializer.fromJson<double?>(json['targetStrain']),
      units: serializer.fromJson<String>(json['units']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'age': serializer.toJson<int?>(age),
      'sex': serializer.toJson<String?>(sex),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'maxHr': serializer.toJson<double?>(maxHr),
      'restingHrBaseline': serializer.toJson<double?>(restingHrBaseline),
      'sleepNeedBaselineMinutes': serializer.toJson<int>(
        sleepNeedBaselineMinutes,
      ),
      'targetStrain': serializer.toJson<double?>(targetStrain),
      'units': serializer.toJson<String>(units),
      'timeZone': serializer.toJson<String>(timeZone),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? userId,
    Value<int?> age = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> bodyFatPct = const Value.absent(),
    Value<double?> maxHr = const Value.absent(),
    Value<double?> restingHrBaseline = const Value.absent(),
    int? sleepNeedBaselineMinutes,
    Value<double?> targetStrain = const Value.absent(),
    String? units,
    String? timeZone,
    int? timeZoneOffsetMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    age: age.present ? age.value : this.age,
    sex: sex.present ? sex.value : this.sex,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    restingHrBaseline: restingHrBaseline.present
        ? restingHrBaseline.value
        : this.restingHrBaseline,
    sleepNeedBaselineMinutes:
        sleepNeedBaselineMinutes ?? this.sleepNeedBaselineMinutes,
    targetStrain: targetStrain.present ? targetStrain.value : this.targetStrain,
    units: units ?? this.units,
    timeZone: timeZone ?? this.timeZone,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      age: data.age.present ? data.age.value : this.age,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bodyFatPct: data.bodyFatPct.present
          ? data.bodyFatPct.value
          : this.bodyFatPct,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      restingHrBaseline: data.restingHrBaseline.present
          ? data.restingHrBaseline.value
          : this.restingHrBaseline,
      sleepNeedBaselineMinutes: data.sleepNeedBaselineMinutes.present
          ? data.sleepNeedBaselineMinutes.value
          : this.sleepNeedBaselineMinutes,
      targetStrain: data.targetStrain.present
          ? data.targetStrain.value
          : this.targetStrain,
      units: data.units.present ? data.units.value : this.units,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('maxHr: $maxHr, ')
          ..write('restingHrBaseline: $restingHrBaseline, ')
          ..write('sleepNeedBaselineMinutes: $sleepNeedBaselineMinutes, ')
          ..write('targetStrain: $targetStrain, ')
          ..write('units: $units, ')
          ..write('timeZone: $timeZone, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    age,
    sex,
    heightCm,
    weightKg,
    bodyFatPct,
    maxHr,
    restingHrBaseline,
    sleepNeedBaselineMinutes,
    targetStrain,
    units,
    timeZone,
    timeZoneOffsetMinutes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.age == this.age &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.bodyFatPct == this.bodyFatPct &&
          other.maxHr == this.maxHr &&
          other.restingHrBaseline == this.restingHrBaseline &&
          other.sleepNeedBaselineMinutes == this.sleepNeedBaselineMinutes &&
          other.targetStrain == this.targetStrain &&
          other.units == this.units &&
          other.timeZone == this.timeZone &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int?> age;
  final Value<String?> sex;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<double?> bodyFatPct;
  final Value<double?> maxHr;
  final Value<double?> restingHrBaseline;
  final Value<int> sleepNeedBaselineMinutes;
  final Value<double?> targetStrain;
  final Value<String> units;
  final Value<String> timeZone;
  final Value<int> timeZoneOffsetMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.restingHrBaseline = const Value.absent(),
    this.sleepNeedBaselineMinutes = const Value.absent(),
    this.targetStrain = const Value.absent(),
    this.units = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.restingHrBaseline = const Value.absent(),
    this.sleepNeedBaselineMinutes = const Value.absent(),
    this.targetStrain = const Value.absent(),
    this.units = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? age,
    Expression<String>? sex,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? bodyFatPct,
    Expression<double>? maxHr,
    Expression<double>? restingHrBaseline,
    Expression<int>? sleepNeedBaselineMinutes,
    Expression<double>? targetStrain,
    Expression<String>? units,
    Expression<String>? timeZone,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (maxHr != null) 'max_hr': maxHr,
      if (restingHrBaseline != null) 'resting_hr_baseline': restingHrBaseline,
      if (sleepNeedBaselineMinutes != null)
        'sleep_need_baseline_minutes': sleepNeedBaselineMinutes,
      if (targetStrain != null) 'target_strain': targetStrain,
      if (units != null) 'units': units,
      if (timeZone != null) 'time_zone': timeZone,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int?>? age,
    Value<String?>? sex,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<double?>? bodyFatPct,
    Value<double?>? maxHr,
    Value<double?>? restingHrBaseline,
    Value<int>? sleepNeedBaselineMinutes,
    Value<double?>? targetStrain,
    Value<String>? units,
    Value<String>? timeZone,
    Value<int>? timeZoneOffsetMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      maxHr: maxHr ?? this.maxHr,
      restingHrBaseline: restingHrBaseline ?? this.restingHrBaseline,
      sleepNeedBaselineMinutes:
          sleepNeedBaselineMinutes ?? this.sleepNeedBaselineMinutes,
      targetStrain: targetStrain ?? this.targetStrain,
      units: units ?? this.units,
      timeZone: timeZone ?? this.timeZone,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<double>(maxHr.value);
    }
    if (restingHrBaseline.present) {
      map['resting_hr_baseline'] = Variable<double>(restingHrBaseline.value);
    }
    if (sleepNeedBaselineMinutes.present) {
      map['sleep_need_baseline_minutes'] = Variable<int>(
        sleepNeedBaselineMinutes.value,
      );
    }
    if (targetStrain.present) {
      map['target_strain'] = Variable<double>(targetStrain.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('maxHr: $maxHr, ')
          ..write('restingHrBaseline: $restingHrBaseline, ')
          ..write('sleepNeedBaselineMinutes: $sleepNeedBaselineMinutes, ')
          ..write('targetStrain: $targetStrain, ')
          ..write('units: $units, ')
          ..write('timeZone: $timeZone, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SleepSessionsTable extends SleepSessions
    with TableInfo<$SleepSessionsTable, SleepSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asleepMinutesMeta = const VerificationMeta(
    'asleepMinutes',
  );
  @override
  late final GeneratedColumn<int> asleepMinutes = GeneratedColumn<int>(
    'asleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deepMinutesMeta = const VerificationMeta(
    'deepMinutes',
  );
  @override
  late final GeneratedColumn<int> deepMinutes = GeneratedColumn<int>(
    'deep_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lightMinutesMeta = const VerificationMeta(
    'lightMinutes',
  );
  @override
  late final GeneratedColumn<int> lightMinutes = GeneratedColumn<int>(
    'light_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remMinutesMeta = const VerificationMeta(
    'remMinutes',
  );
  @override
  late final GeneratedColumn<int> remMinutes = GeneratedColumn<int>(
    'rem_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awakeMinutesMeta = const VerificationMeta(
    'awakeMinutes',
  );
  @override
  late final GeneratedColumn<int> awakeMinutes = GeneratedColumn<int>(
    'awake_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _efficiencyMeta = const VerificationMeta(
    'efficiency',
  );
  @override
  late final GeneratedColumn<double> efficiency = GeneratedColumn<double>(
    'efficiency',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _disturbancesCountMeta = const VerificationMeta(
    'disturbancesCount',
  );
  @override
  late final GeneratedColumn<int> disturbancesCount = GeneratedColumn<int>(
    'disturbances_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<double> respiratoryRate = GeneratedColumn<double>(
    'respiratory_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restingHeartRateMeta = const VerificationMeta(
    'restingHeartRate',
  );
  @override
  late final GeneratedColumn<double> restingHeartRate = GeneratedColumn<double>(
    'resting_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvRmssdMeta = const VerificationMeta(
    'hrvRmssd',
  );
  @override
  late final GeneratedColumn<double> hrvRmssd = GeneratedColumn<double>(
    'hrv_rmssd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spo2AverageMeta = const VerificationMeta(
    'spo2Average',
  );
  @override
  late final GeneratedColumn<double> spo2Average = GeneratedColumn<double>(
    'spo2_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spo2MinMeta = const VerificationMeta(
    'spo2Min',
  );
  @override
  late final GeneratedColumn<double> spo2Min = GeneratedColumn<double>(
    'spo2_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skinTempDeviationMeta = const VerificationMeta(
    'skinTempDeviation',
  );
  @override
  late final GeneratedColumn<double> skinTempDeviation =
      GeneratedColumn<double>(
        'skin_temp_deviation',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isNapMeta = const VerificationMeta('isNap');
  @override
  late final GeneratedColumn<bool> isNap = GeneratedColumn<bool>(
    'is_nap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_nap" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceDeviceMeta = const VerificationMeta(
    'sourceDevice',
  );
  @override
  late final GeneratedColumn<String> sourceDevice = GeneratedColumn<String>(
    'source_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calculationMethodMeta = const VerificationMeta(
    'calculationMethod',
  );
  @override
  late final GeneratedColumn<String> calculationMethod =
      GeneratedColumn<String>(
        'calculation_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('sensor'),
      );
  static const VerificationMeta _qualityFlagMeta = const VerificationMeta(
    'qualityFlag',
  );
  @override
  late final GeneratedColumn<String> qualityFlag = GeneratedColumn<String>(
    'quality_flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('good'),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    startTime,
    endTime,
    timeZoneOffsetMinutes,
    durationMinutes,
    asleepMinutes,
    deepMinutes,
    lightMinutes,
    remMinutes,
    awakeMinutes,
    efficiency,
    disturbancesCount,
    respiratoryRate,
    restingHeartRate,
    hrvRmssd,
    spo2Average,
    spo2Min,
    skinTempDeviation,
    isNap,
    sourceDevice,
    calculationMethod,
    qualityFlag,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('asleep_minutes')) {
      context.handle(
        _asleepMinutesMeta,
        asleepMinutes.isAcceptableOrUnknown(
          data['asleep_minutes']!,
          _asleepMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_asleepMinutesMeta);
    }
    if (data.containsKey('deep_minutes')) {
      context.handle(
        _deepMinutesMeta,
        deepMinutes.isAcceptableOrUnknown(
          data['deep_minutes']!,
          _deepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('light_minutes')) {
      context.handle(
        _lightMinutesMeta,
        lightMinutes.isAcceptableOrUnknown(
          data['light_minutes']!,
          _lightMinutesMeta,
        ),
      );
    }
    if (data.containsKey('rem_minutes')) {
      context.handle(
        _remMinutesMeta,
        remMinutes.isAcceptableOrUnknown(data['rem_minutes']!, _remMinutesMeta),
      );
    }
    if (data.containsKey('awake_minutes')) {
      context.handle(
        _awakeMinutesMeta,
        awakeMinutes.isAcceptableOrUnknown(
          data['awake_minutes']!,
          _awakeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('efficiency')) {
      context.handle(
        _efficiencyMeta,
        efficiency.isAcceptableOrUnknown(data['efficiency']!, _efficiencyMeta),
      );
    }
    if (data.containsKey('disturbances_count')) {
      context.handle(
        _disturbancesCountMeta,
        disturbancesCount.isAcceptableOrUnknown(
          data['disturbances_count']!,
          _disturbancesCountMeta,
        ),
      );
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('resting_heart_rate')) {
      context.handle(
        _restingHeartRateMeta,
        restingHeartRate.isAcceptableOrUnknown(
          data['resting_heart_rate']!,
          _restingHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('hrv_rmssd')) {
      context.handle(
        _hrvRmssdMeta,
        hrvRmssd.isAcceptableOrUnknown(data['hrv_rmssd']!, _hrvRmssdMeta),
      );
    }
    if (data.containsKey('spo2_average')) {
      context.handle(
        _spo2AverageMeta,
        spo2Average.isAcceptableOrUnknown(
          data['spo2_average']!,
          _spo2AverageMeta,
        ),
      );
    }
    if (data.containsKey('spo2_min')) {
      context.handle(
        _spo2MinMeta,
        spo2Min.isAcceptableOrUnknown(data['spo2_min']!, _spo2MinMeta),
      );
    }
    if (data.containsKey('skin_temp_deviation')) {
      context.handle(
        _skinTempDeviationMeta,
        skinTempDeviation.isAcceptableOrUnknown(
          data['skin_temp_deviation']!,
          _skinTempDeviationMeta,
        ),
      );
    }
    if (data.containsKey('is_nap')) {
      context.handle(
        _isNapMeta,
        isNap.isAcceptableOrUnknown(data['is_nap']!, _isNapMeta),
      );
    }
    if (data.containsKey('source_device')) {
      context.handle(
        _sourceDeviceMeta,
        sourceDevice.isAcceptableOrUnknown(
          data['source_device']!,
          _sourceDeviceMeta,
        ),
      );
    }
    if (data.containsKey('calculation_method')) {
      context.handle(
        _calculationMethodMeta,
        calculationMethod.isAcceptableOrUnknown(
          data['calculation_method']!,
          _calculationMethodMeta,
        ),
      );
    }
    if (data.containsKey('quality_flag')) {
      context.handle(
        _qualityFlagMeta,
        qualityFlag.isAcceptableOrUnknown(
          data['quality_flag']!,
          _qualityFlagMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, startTime},
  ];
  @override
  SleepSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      asleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asleep_minutes'],
      )!,
      deepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deep_minutes'],
      ),
      lightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}light_minutes'],
      ),
      remMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rem_minutes'],
      ),
      awakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awake_minutes'],
      ),
      efficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}efficiency'],
      ),
      disturbancesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disturbances_count'],
      ),
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate'],
      ),
      restingHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_heart_rate'],
      ),
      hrvRmssd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_rmssd'],
      ),
      spo2Average: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2_average'],
      ),
      spo2Min: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2_min'],
      ),
      skinTempDeviation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}skin_temp_deviation'],
      ),
      isNap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_nap'],
      )!,
      sourceDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device'],
      ),
      calculationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_method'],
      )!,
      qualityFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_flag'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SleepSessionsTable createAlias(String alias) {
    return $SleepSessionsTable(attachedDatabase, alias);
  }
}

class SleepSession extends DataClass implements Insertable<SleepSession> {
  final int id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int timeZoneOffsetMinutes;
  final int durationMinutes;
  final int asleepMinutes;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? remMinutes;
  final int? awakeMinutes;
  final double? efficiency;
  final int? disturbancesCount;
  final double? respiratoryRate;
  final double? restingHeartRate;
  final double? hrvRmssd;
  final double? spo2Average;
  final double? spo2Min;
  final double? skinTempDeviation;
  final bool isNap;
  final String? sourceDevice;
  final String calculationMethod;
  final String qualityFlag;
  final DateTime syncedAt;
  const SleepSession({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.timeZoneOffsetMinutes,
    required this.durationMinutes,
    required this.asleepMinutes,
    this.deepMinutes,
    this.lightMinutes,
    this.remMinutes,
    this.awakeMinutes,
    this.efficiency,
    this.disturbancesCount,
    this.respiratoryRate,
    this.restingHeartRate,
    this.hrvRmssd,
    this.spo2Average,
    this.spo2Min,
    this.skinTempDeviation,
    required this.isNap,
    this.sourceDevice,
    required this.calculationMethod,
    required this.qualityFlag,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['asleep_minutes'] = Variable<int>(asleepMinutes);
    if (!nullToAbsent || deepMinutes != null) {
      map['deep_minutes'] = Variable<int>(deepMinutes);
    }
    if (!nullToAbsent || lightMinutes != null) {
      map['light_minutes'] = Variable<int>(lightMinutes);
    }
    if (!nullToAbsent || remMinutes != null) {
      map['rem_minutes'] = Variable<int>(remMinutes);
    }
    if (!nullToAbsent || awakeMinutes != null) {
      map['awake_minutes'] = Variable<int>(awakeMinutes);
    }
    if (!nullToAbsent || efficiency != null) {
      map['efficiency'] = Variable<double>(efficiency);
    }
    if (!nullToAbsent || disturbancesCount != null) {
      map['disturbances_count'] = Variable<int>(disturbancesCount);
    }
    if (!nullToAbsent || respiratoryRate != null) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate);
    }
    if (!nullToAbsent || restingHeartRate != null) {
      map['resting_heart_rate'] = Variable<double>(restingHeartRate);
    }
    if (!nullToAbsent || hrvRmssd != null) {
      map['hrv_rmssd'] = Variable<double>(hrvRmssd);
    }
    if (!nullToAbsent || spo2Average != null) {
      map['spo2_average'] = Variable<double>(spo2Average);
    }
    if (!nullToAbsent || spo2Min != null) {
      map['spo2_min'] = Variable<double>(spo2Min);
    }
    if (!nullToAbsent || skinTempDeviation != null) {
      map['skin_temp_deviation'] = Variable<double>(skinTempDeviation);
    }
    map['is_nap'] = Variable<bool>(isNap);
    if (!nullToAbsent || sourceDevice != null) {
      map['source_device'] = Variable<String>(sourceDevice);
    }
    map['calculation_method'] = Variable<String>(calculationMethod);
    map['quality_flag'] = Variable<String>(qualityFlag);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SleepSessionsCompanion toCompanion(bool nullToAbsent) {
    return SleepSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
      durationMinutes: Value(durationMinutes),
      asleepMinutes: Value(asleepMinutes),
      deepMinutes: deepMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(deepMinutes),
      lightMinutes: lightMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(lightMinutes),
      remMinutes: remMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(remMinutes),
      awakeMinutes: awakeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(awakeMinutes),
      efficiency: efficiency == null && nullToAbsent
          ? const Value.absent()
          : Value(efficiency),
      disturbancesCount: disturbancesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(disturbancesCount),
      respiratoryRate: respiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRate),
      restingHeartRate: restingHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHeartRate),
      hrvRmssd: hrvRmssd == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvRmssd),
      spo2Average: spo2Average == null && nullToAbsent
          ? const Value.absent()
          : Value(spo2Average),
      spo2Min: spo2Min == null && nullToAbsent
          ? const Value.absent()
          : Value(spo2Min),
      skinTempDeviation: skinTempDeviation == null && nullToAbsent
          ? const Value.absent()
          : Value(skinTempDeviation),
      isNap: Value(isNap),
      sourceDevice: sourceDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDevice),
      calculationMethod: Value(calculationMethod),
      qualityFlag: Value(qualityFlag),
      syncedAt: Value(syncedAt),
    );
  }

  factory SleepSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepSession(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      asleepMinutes: serializer.fromJson<int>(json['asleepMinutes']),
      deepMinutes: serializer.fromJson<int?>(json['deepMinutes']),
      lightMinutes: serializer.fromJson<int?>(json['lightMinutes']),
      remMinutes: serializer.fromJson<int?>(json['remMinutes']),
      awakeMinutes: serializer.fromJson<int?>(json['awakeMinutes']),
      efficiency: serializer.fromJson<double?>(json['efficiency']),
      disturbancesCount: serializer.fromJson<int?>(json['disturbancesCount']),
      respiratoryRate: serializer.fromJson<double?>(json['respiratoryRate']),
      restingHeartRate: serializer.fromJson<double?>(json['restingHeartRate']),
      hrvRmssd: serializer.fromJson<double?>(json['hrvRmssd']),
      spo2Average: serializer.fromJson<double?>(json['spo2Average']),
      spo2Min: serializer.fromJson<double?>(json['spo2Min']),
      skinTempDeviation: serializer.fromJson<double?>(
        json['skinTempDeviation'],
      ),
      isNap: serializer.fromJson<bool>(json['isNap']),
      sourceDevice: serializer.fromJson<String?>(json['sourceDevice']),
      calculationMethod: serializer.fromJson<String>(json['calculationMethod']),
      qualityFlag: serializer.fromJson<String>(json['qualityFlag']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'asleepMinutes': serializer.toJson<int>(asleepMinutes),
      'deepMinutes': serializer.toJson<int?>(deepMinutes),
      'lightMinutes': serializer.toJson<int?>(lightMinutes),
      'remMinutes': serializer.toJson<int?>(remMinutes),
      'awakeMinutes': serializer.toJson<int?>(awakeMinutes),
      'efficiency': serializer.toJson<double?>(efficiency),
      'disturbancesCount': serializer.toJson<int?>(disturbancesCount),
      'respiratoryRate': serializer.toJson<double?>(respiratoryRate),
      'restingHeartRate': serializer.toJson<double?>(restingHeartRate),
      'hrvRmssd': serializer.toJson<double?>(hrvRmssd),
      'spo2Average': serializer.toJson<double?>(spo2Average),
      'spo2Min': serializer.toJson<double?>(spo2Min),
      'skinTempDeviation': serializer.toJson<double?>(skinTempDeviation),
      'isNap': serializer.toJson<bool>(isNap),
      'sourceDevice': serializer.toJson<String?>(sourceDevice),
      'calculationMethod': serializer.toJson<String>(calculationMethod),
      'qualityFlag': serializer.toJson<String>(qualityFlag),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  SleepSession copyWith({
    int? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? timeZoneOffsetMinutes,
    int? durationMinutes,
    int? asleepMinutes,
    Value<int?> deepMinutes = const Value.absent(),
    Value<int?> lightMinutes = const Value.absent(),
    Value<int?> remMinutes = const Value.absent(),
    Value<int?> awakeMinutes = const Value.absent(),
    Value<double?> efficiency = const Value.absent(),
    Value<int?> disturbancesCount = const Value.absent(),
    Value<double?> respiratoryRate = const Value.absent(),
    Value<double?> restingHeartRate = const Value.absent(),
    Value<double?> hrvRmssd = const Value.absent(),
    Value<double?> spo2Average = const Value.absent(),
    Value<double?> spo2Min = const Value.absent(),
    Value<double?> skinTempDeviation = const Value.absent(),
    bool? isNap,
    Value<String?> sourceDevice = const Value.absent(),
    String? calculationMethod,
    String? qualityFlag,
    DateTime? syncedAt,
  }) => SleepSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    asleepMinutes: asleepMinutes ?? this.asleepMinutes,
    deepMinutes: deepMinutes.present ? deepMinutes.value : this.deepMinutes,
    lightMinutes: lightMinutes.present ? lightMinutes.value : this.lightMinutes,
    remMinutes: remMinutes.present ? remMinutes.value : this.remMinutes,
    awakeMinutes: awakeMinutes.present ? awakeMinutes.value : this.awakeMinutes,
    efficiency: efficiency.present ? efficiency.value : this.efficiency,
    disturbancesCount: disturbancesCount.present
        ? disturbancesCount.value
        : this.disturbancesCount,
    respiratoryRate: respiratoryRate.present
        ? respiratoryRate.value
        : this.respiratoryRate,
    restingHeartRate: restingHeartRate.present
        ? restingHeartRate.value
        : this.restingHeartRate,
    hrvRmssd: hrvRmssd.present ? hrvRmssd.value : this.hrvRmssd,
    spo2Average: spo2Average.present ? spo2Average.value : this.spo2Average,
    spo2Min: spo2Min.present ? spo2Min.value : this.spo2Min,
    skinTempDeviation: skinTempDeviation.present
        ? skinTempDeviation.value
        : this.skinTempDeviation,
    isNap: isNap ?? this.isNap,
    sourceDevice: sourceDevice.present ? sourceDevice.value : this.sourceDevice,
    calculationMethod: calculationMethod ?? this.calculationMethod,
    qualityFlag: qualityFlag ?? this.qualityFlag,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  SleepSession copyWithCompanion(SleepSessionsCompanion data) {
    return SleepSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      asleepMinutes: data.asleepMinutes.present
          ? data.asleepMinutes.value
          : this.asleepMinutes,
      deepMinutes: data.deepMinutes.present
          ? data.deepMinutes.value
          : this.deepMinutes,
      lightMinutes: data.lightMinutes.present
          ? data.lightMinutes.value
          : this.lightMinutes,
      remMinutes: data.remMinutes.present
          ? data.remMinutes.value
          : this.remMinutes,
      awakeMinutes: data.awakeMinutes.present
          ? data.awakeMinutes.value
          : this.awakeMinutes,
      efficiency: data.efficiency.present
          ? data.efficiency.value
          : this.efficiency,
      disturbancesCount: data.disturbancesCount.present
          ? data.disturbancesCount.value
          : this.disturbancesCount,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      restingHeartRate: data.restingHeartRate.present
          ? data.restingHeartRate.value
          : this.restingHeartRate,
      hrvRmssd: data.hrvRmssd.present ? data.hrvRmssd.value : this.hrvRmssd,
      spo2Average: data.spo2Average.present
          ? data.spo2Average.value
          : this.spo2Average,
      spo2Min: data.spo2Min.present ? data.spo2Min.value : this.spo2Min,
      skinTempDeviation: data.skinTempDeviation.present
          ? data.skinTempDeviation.value
          : this.skinTempDeviation,
      isNap: data.isNap.present ? data.isNap.value : this.isNap,
      sourceDevice: data.sourceDevice.present
          ? data.sourceDevice.value
          : this.sourceDevice,
      calculationMethod: data.calculationMethod.present
          ? data.calculationMethod.value
          : this.calculationMethod,
      qualityFlag: data.qualityFlag.present
          ? data.qualityFlag.value
          : this.qualityFlag,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('asleepMinutes: $asleepMinutes, ')
          ..write('deepMinutes: $deepMinutes, ')
          ..write('lightMinutes: $lightMinutes, ')
          ..write('remMinutes: $remMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('efficiency: $efficiency, ')
          ..write('disturbancesCount: $disturbancesCount, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('spo2Average: $spo2Average, ')
          ..write('spo2Min: $spo2Min, ')
          ..write('skinTempDeviation: $skinTempDeviation, ')
          ..write('isNap: $isNap, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('calculationMethod: $calculationMethod, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    startTime,
    endTime,
    timeZoneOffsetMinutes,
    durationMinutes,
    asleepMinutes,
    deepMinutes,
    lightMinutes,
    remMinutes,
    awakeMinutes,
    efficiency,
    disturbancesCount,
    respiratoryRate,
    restingHeartRate,
    hrvRmssd,
    spo2Average,
    spo2Min,
    skinTempDeviation,
    isNap,
    sourceDevice,
    calculationMethod,
    qualityFlag,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.durationMinutes == this.durationMinutes &&
          other.asleepMinutes == this.asleepMinutes &&
          other.deepMinutes == this.deepMinutes &&
          other.lightMinutes == this.lightMinutes &&
          other.remMinutes == this.remMinutes &&
          other.awakeMinutes == this.awakeMinutes &&
          other.efficiency == this.efficiency &&
          other.disturbancesCount == this.disturbancesCount &&
          other.respiratoryRate == this.respiratoryRate &&
          other.restingHeartRate == this.restingHeartRate &&
          other.hrvRmssd == this.hrvRmssd &&
          other.spo2Average == this.spo2Average &&
          other.spo2Min == this.spo2Min &&
          other.skinTempDeviation == this.skinTempDeviation &&
          other.isNap == this.isNap &&
          other.sourceDevice == this.sourceDevice &&
          other.calculationMethod == this.calculationMethod &&
          other.qualityFlag == this.qualityFlag &&
          other.syncedAt == this.syncedAt);
}

class SleepSessionsCompanion extends UpdateCompanion<SleepSession> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> timeZoneOffsetMinutes;
  final Value<int> durationMinutes;
  final Value<int> asleepMinutes;
  final Value<int?> deepMinutes;
  final Value<int?> lightMinutes;
  final Value<int?> remMinutes;
  final Value<int?> awakeMinutes;
  final Value<double?> efficiency;
  final Value<int?> disturbancesCount;
  final Value<double?> respiratoryRate;
  final Value<double?> restingHeartRate;
  final Value<double?> hrvRmssd;
  final Value<double?> spo2Average;
  final Value<double?> spo2Min;
  final Value<double?> skinTempDeviation;
  final Value<bool> isNap;
  final Value<String?> sourceDevice;
  final Value<String> calculationMethod;
  final Value<String> qualityFlag;
  final Value<DateTime> syncedAt;
  const SleepSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.asleepMinutes = const Value.absent(),
    this.deepMinutes = const Value.absent(),
    this.lightMinutes = const Value.absent(),
    this.remMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.efficiency = const Value.absent(),
    this.disturbancesCount = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.hrvRmssd = const Value.absent(),
    this.spo2Average = const Value.absent(),
    this.spo2Min = const Value.absent(),
    this.skinTempDeviation = const Value.absent(),
    this.isNap = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.calculationMethod = const Value.absent(),
    this.qualityFlag = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SleepSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime startTime,
    required DateTime endTime,
    this.timeZoneOffsetMinutes = const Value.absent(),
    required int durationMinutes,
    required int asleepMinutes,
    this.deepMinutes = const Value.absent(),
    this.lightMinutes = const Value.absent(),
    this.remMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.efficiency = const Value.absent(),
    this.disturbancesCount = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.hrvRmssd = const Value.absent(),
    this.spo2Average = const Value.absent(),
    this.spo2Min = const Value.absent(),
    this.skinTempDeviation = const Value.absent(),
    this.isNap = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.calculationMethod = const Value.absent(),
    this.qualityFlag = const Value.absent(),
    required DateTime syncedAt,
  }) : startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes),
       asleepMinutes = Value(asleepMinutes),
       syncedAt = Value(syncedAt);
  static Insertable<SleepSession> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<int>? durationMinutes,
    Expression<int>? asleepMinutes,
    Expression<int>? deepMinutes,
    Expression<int>? lightMinutes,
    Expression<int>? remMinutes,
    Expression<int>? awakeMinutes,
    Expression<double>? efficiency,
    Expression<int>? disturbancesCount,
    Expression<double>? respiratoryRate,
    Expression<double>? restingHeartRate,
    Expression<double>? hrvRmssd,
    Expression<double>? spo2Average,
    Expression<double>? spo2Min,
    Expression<double>? skinTempDeviation,
    Expression<bool>? isNap,
    Expression<String>? sourceDevice,
    Expression<String>? calculationMethod,
    Expression<String>? qualityFlag,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (asleepMinutes != null) 'asleep_minutes': asleepMinutes,
      if (deepMinutes != null) 'deep_minutes': deepMinutes,
      if (lightMinutes != null) 'light_minutes': lightMinutes,
      if (remMinutes != null) 'rem_minutes': remMinutes,
      if (awakeMinutes != null) 'awake_minutes': awakeMinutes,
      if (efficiency != null) 'efficiency': efficiency,
      if (disturbancesCount != null) 'disturbances_count': disturbancesCount,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (restingHeartRate != null) 'resting_heart_rate': restingHeartRate,
      if (hrvRmssd != null) 'hrv_rmssd': hrvRmssd,
      if (spo2Average != null) 'spo2_average': spo2Average,
      if (spo2Min != null) 'spo2_min': spo2Min,
      if (skinTempDeviation != null) 'skin_temp_deviation': skinTempDeviation,
      if (isNap != null) 'is_nap': isNap,
      if (sourceDevice != null) 'source_device': sourceDevice,
      if (calculationMethod != null) 'calculation_method': calculationMethod,
      if (qualityFlag != null) 'quality_flag': qualityFlag,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SleepSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<int>? timeZoneOffsetMinutes,
    Value<int>? durationMinutes,
    Value<int>? asleepMinutes,
    Value<int?>? deepMinutes,
    Value<int?>? lightMinutes,
    Value<int?>? remMinutes,
    Value<int?>? awakeMinutes,
    Value<double?>? efficiency,
    Value<int?>? disturbancesCount,
    Value<double?>? respiratoryRate,
    Value<double?>? restingHeartRate,
    Value<double?>? hrvRmssd,
    Value<double?>? spo2Average,
    Value<double?>? spo2Min,
    Value<double?>? skinTempDeviation,
    Value<bool>? isNap,
    Value<String?>? sourceDevice,
    Value<String>? calculationMethod,
    Value<String>? qualityFlag,
    Value<DateTime>? syncedAt,
  }) {
    return SleepSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      asleepMinutes: asleepMinutes ?? this.asleepMinutes,
      deepMinutes: deepMinutes ?? this.deepMinutes,
      lightMinutes: lightMinutes ?? this.lightMinutes,
      remMinutes: remMinutes ?? this.remMinutes,
      awakeMinutes: awakeMinutes ?? this.awakeMinutes,
      efficiency: efficiency ?? this.efficiency,
      disturbancesCount: disturbancesCount ?? this.disturbancesCount,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      spo2Average: spo2Average ?? this.spo2Average,
      spo2Min: spo2Min ?? this.spo2Min,
      skinTempDeviation: skinTempDeviation ?? this.skinTempDeviation,
      isNap: isNap ?? this.isNap,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      qualityFlag: qualityFlag ?? this.qualityFlag,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (asleepMinutes.present) {
      map['asleep_minutes'] = Variable<int>(asleepMinutes.value);
    }
    if (deepMinutes.present) {
      map['deep_minutes'] = Variable<int>(deepMinutes.value);
    }
    if (lightMinutes.present) {
      map['light_minutes'] = Variable<int>(lightMinutes.value);
    }
    if (remMinutes.present) {
      map['rem_minutes'] = Variable<int>(remMinutes.value);
    }
    if (awakeMinutes.present) {
      map['awake_minutes'] = Variable<int>(awakeMinutes.value);
    }
    if (efficiency.present) {
      map['efficiency'] = Variable<double>(efficiency.value);
    }
    if (disturbancesCount.present) {
      map['disturbances_count'] = Variable<int>(disturbancesCount.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate.value);
    }
    if (restingHeartRate.present) {
      map['resting_heart_rate'] = Variable<double>(restingHeartRate.value);
    }
    if (hrvRmssd.present) {
      map['hrv_rmssd'] = Variable<double>(hrvRmssd.value);
    }
    if (spo2Average.present) {
      map['spo2_average'] = Variable<double>(spo2Average.value);
    }
    if (spo2Min.present) {
      map['spo2_min'] = Variable<double>(spo2Min.value);
    }
    if (skinTempDeviation.present) {
      map['skin_temp_deviation'] = Variable<double>(skinTempDeviation.value);
    }
    if (isNap.present) {
      map['is_nap'] = Variable<bool>(isNap.value);
    }
    if (sourceDevice.present) {
      map['source_device'] = Variable<String>(sourceDevice.value);
    }
    if (calculationMethod.present) {
      map['calculation_method'] = Variable<String>(calculationMethod.value);
    }
    if (qualityFlag.present) {
      map['quality_flag'] = Variable<String>(qualityFlag.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('asleepMinutes: $asleepMinutes, ')
          ..write('deepMinutes: $deepMinutes, ')
          ..write('lightMinutes: $lightMinutes, ')
          ..write('remMinutes: $remMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('efficiency: $efficiency, ')
          ..write('disturbancesCount: $disturbancesCount, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('spo2Average: $spo2Average, ')
          ..write('spo2Min: $spo2Min, ')
          ..write('skinTempDeviation: $skinTempDeviation, ')
          ..write('isNap: $isNap, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('calculationMethod: $calculationMethod, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _sportMeta = const VerificationMeta('sport');
  @override
  late final GeneratedColumn<String> sport = GeneratedColumn<String>(
    'sport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<double> avgHeartRate = GeneratedColumn<double>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<double> maxHeartRate = GeneratedColumn<double>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
    'calories_burned',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _zone1MinutesMeta = const VerificationMeta(
    'zone1Minutes',
  );
  @override
  late final GeneratedColumn<int> zone1Minutes = GeneratedColumn<int>(
    'zone1_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zone2MinutesMeta = const VerificationMeta(
    'zone2Minutes',
  );
  @override
  late final GeneratedColumn<int> zone2Minutes = GeneratedColumn<int>(
    'zone2_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zone3MinutesMeta = const VerificationMeta(
    'zone3Minutes',
  );
  @override
  late final GeneratedColumn<int> zone3Minutes = GeneratedColumn<int>(
    'zone3_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zone4MinutesMeta = const VerificationMeta(
    'zone4Minutes',
  );
  @override
  late final GeneratedColumn<int> zone4Minutes = GeneratedColumn<int>(
    'zone4_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zone5MinutesMeta = const VerificationMeta(
    'zone5Minutes',
  );
  @override
  late final GeneratedColumn<int> zone5Minutes = GeneratedColumn<int>(
    'zone5_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _strainScoreMeta = const VerificationMeta(
    'strainScore',
  );
  @override
  late final GeneratedColumn<double> strainScore = GeneratedColumn<double>(
    'strain_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _recoveryCostMeta = const VerificationMeta(
    'recoveryCost',
  );
  @override
  late final GeneratedColumn<double> recoveryCost = GeneratedColumn<double>(
    'recovery_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sourceDeviceMeta = const VerificationMeta(
    'sourceDevice',
  );
  @override
  late final GeneratedColumn<String> sourceDevice = GeneratedColumn<String>(
    'source_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityFlagMeta = const VerificationMeta(
    'qualityFlag',
  );
  @override
  late final GeneratedColumn<String> qualityFlag = GeneratedColumn<String>(
    'quality_flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('good'),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    sport,
    title,
    startTime,
    endTime,
    timeZoneOffsetMinutes,
    durationMinutes,
    avgHeartRate,
    maxHeartRate,
    caloriesBurned,
    distanceMeters,
    elevationGainMeters,
    zone1Minutes,
    zone2Minutes,
    zone3Minutes,
    zone4Minutes,
    zone5Minutes,
    strainScore,
    recoveryCost,
    sourceDevice,
    qualityFlag,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('sport')) {
      context.handle(
        _sportMeta,
        sport.isAcceptableOrUnknown(data['sport']!, _sportMeta),
      );
    } else if (isInserting) {
      context.missing(_sportMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('zone1_minutes')) {
      context.handle(
        _zone1MinutesMeta,
        zone1Minutes.isAcceptableOrUnknown(
          data['zone1_minutes']!,
          _zone1MinutesMeta,
        ),
      );
    }
    if (data.containsKey('zone2_minutes')) {
      context.handle(
        _zone2MinutesMeta,
        zone2Minutes.isAcceptableOrUnknown(
          data['zone2_minutes']!,
          _zone2MinutesMeta,
        ),
      );
    }
    if (data.containsKey('zone3_minutes')) {
      context.handle(
        _zone3MinutesMeta,
        zone3Minutes.isAcceptableOrUnknown(
          data['zone3_minutes']!,
          _zone3MinutesMeta,
        ),
      );
    }
    if (data.containsKey('zone4_minutes')) {
      context.handle(
        _zone4MinutesMeta,
        zone4Minutes.isAcceptableOrUnknown(
          data['zone4_minutes']!,
          _zone4MinutesMeta,
        ),
      );
    }
    if (data.containsKey('zone5_minutes')) {
      context.handle(
        _zone5MinutesMeta,
        zone5Minutes.isAcceptableOrUnknown(
          data['zone5_minutes']!,
          _zone5MinutesMeta,
        ),
      );
    }
    if (data.containsKey('strain_score')) {
      context.handle(
        _strainScoreMeta,
        strainScore.isAcceptableOrUnknown(
          data['strain_score']!,
          _strainScoreMeta,
        ),
      );
    }
    if (data.containsKey('recovery_cost')) {
      context.handle(
        _recoveryCostMeta,
        recoveryCost.isAcceptableOrUnknown(
          data['recovery_cost']!,
          _recoveryCostMeta,
        ),
      );
    }
    if (data.containsKey('source_device')) {
      context.handle(
        _sourceDeviceMeta,
        sourceDevice.isAcceptableOrUnknown(
          data['source_device']!,
          _sourceDeviceMeta,
        ),
      );
    }
    if (data.containsKey('quality_flag')) {
      context.handle(
        _qualityFlagMeta,
        qualityFlag.isAcceptableOrUnknown(
          data['quality_flag']!,
          _qualityFlagMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, startTime},
  ];
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      sport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_heart_rate'],
      ),
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_burned'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      ),
      zone1Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone1_minutes'],
      )!,
      zone2Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone2_minutes'],
      )!,
      zone3Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone3_minutes'],
      )!,
      zone4Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone4_minutes'],
      )!,
      zone5Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone5_minutes'],
      )!,
      strainScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strain_score'],
      )!,
      recoveryCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_cost'],
      )!,
      sourceDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device'],
      ),
      qualityFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_flag'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;
  final String userId;
  final String sport;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int timeZoneOffsetMinutes;
  final int durationMinutes;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? caloriesBurned;
  final double? distanceMeters;
  final double? elevationGainMeters;
  final int zone1Minutes;
  final int zone2Minutes;
  final int zone3Minutes;
  final int zone4Minutes;
  final int zone5Minutes;
  final double strainScore;
  final double recoveryCost;
  final String? sourceDevice;
  final String qualityFlag;
  final DateTime syncedAt;
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.sport,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.timeZoneOffsetMinutes,
    required this.durationMinutes,
    this.avgHeartRate,
    this.maxHeartRate,
    this.caloriesBurned,
    this.distanceMeters,
    this.elevationGainMeters,
    required this.zone1Minutes,
    required this.zone2Minutes,
    required this.zone3Minutes,
    required this.zone4Minutes,
    required this.zone5Minutes,
    required this.strainScore,
    required this.recoveryCost,
    this.sourceDevice,
    required this.qualityFlag,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['sport'] = Variable<String>(sport);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<double>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<double>(maxHeartRate);
    }
    if (!nullToAbsent || caloriesBurned != null) {
      map['calories_burned'] = Variable<double>(caloriesBurned);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || elevationGainMeters != null) {
      map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    }
    map['zone1_minutes'] = Variable<int>(zone1Minutes);
    map['zone2_minutes'] = Variable<int>(zone2Minutes);
    map['zone3_minutes'] = Variable<int>(zone3Minutes);
    map['zone4_minutes'] = Variable<int>(zone4Minutes);
    map['zone5_minutes'] = Variable<int>(zone5Minutes);
    map['strain_score'] = Variable<double>(strainScore);
    map['recovery_cost'] = Variable<double>(recoveryCost);
    if (!nullToAbsent || sourceDevice != null) {
      map['source_device'] = Variable<String>(sourceDevice);
    }
    map['quality_flag'] = Variable<String>(qualityFlag);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      sport: Value(sport),
      title: Value(title),
      startTime: Value(startTime),
      endTime: Value(endTime),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
      durationMinutes: Value(durationMinutes),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      caloriesBurned: caloriesBurned == null && nullToAbsent
          ? const Value.absent()
          : Value(caloriesBurned),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      elevationGainMeters: elevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainMeters),
      zone1Minutes: Value(zone1Minutes),
      zone2Minutes: Value(zone2Minutes),
      zone3Minutes: Value(zone3Minutes),
      zone4Minutes: Value(zone4Minutes),
      zone5Minutes: Value(zone5Minutes),
      strainScore: Value(strainScore),
      recoveryCost: Value(recoveryCost),
      sourceDevice: sourceDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDevice),
      qualityFlag: Value(qualityFlag),
      syncedAt: Value(syncedAt),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sport: serializer.fromJson<String>(json['sport']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      avgHeartRate: serializer.fromJson<double?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<double?>(json['maxHeartRate']),
      caloriesBurned: serializer.fromJson<double?>(json['caloriesBurned']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      elevationGainMeters: serializer.fromJson<double?>(
        json['elevationGainMeters'],
      ),
      zone1Minutes: serializer.fromJson<int>(json['zone1Minutes']),
      zone2Minutes: serializer.fromJson<int>(json['zone2Minutes']),
      zone3Minutes: serializer.fromJson<int>(json['zone3Minutes']),
      zone4Minutes: serializer.fromJson<int>(json['zone4Minutes']),
      zone5Minutes: serializer.fromJson<int>(json['zone5Minutes']),
      strainScore: serializer.fromJson<double>(json['strainScore']),
      recoveryCost: serializer.fromJson<double>(json['recoveryCost']),
      sourceDevice: serializer.fromJson<String?>(json['sourceDevice']),
      qualityFlag: serializer.fromJson<String>(json['qualityFlag']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'sport': serializer.toJson<String>(sport),
      'title': serializer.toJson<String>(title),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'avgHeartRate': serializer.toJson<double?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<double?>(maxHeartRate),
      'caloriesBurned': serializer.toJson<double?>(caloriesBurned),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'elevationGainMeters': serializer.toJson<double?>(elevationGainMeters),
      'zone1Minutes': serializer.toJson<int>(zone1Minutes),
      'zone2Minutes': serializer.toJson<int>(zone2Minutes),
      'zone3Minutes': serializer.toJson<int>(zone3Minutes),
      'zone4Minutes': serializer.toJson<int>(zone4Minutes),
      'zone5Minutes': serializer.toJson<int>(zone5Minutes),
      'strainScore': serializer.toJson<double>(strainScore),
      'recoveryCost': serializer.toJson<double>(recoveryCost),
      'sourceDevice': serializer.toJson<String?>(sourceDevice),
      'qualityFlag': serializer.toJson<String>(qualityFlag),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  WorkoutSession copyWith({
    int? id,
    String? userId,
    String? sport,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? timeZoneOffsetMinutes,
    int? durationMinutes,
    Value<double?> avgHeartRate = const Value.absent(),
    Value<double?> maxHeartRate = const Value.absent(),
    Value<double?> caloriesBurned = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<double?> elevationGainMeters = const Value.absent(),
    int? zone1Minutes,
    int? zone2Minutes,
    int? zone3Minutes,
    int? zone4Minutes,
    int? zone5Minutes,
    double? strainScore,
    double? recoveryCost,
    Value<String?> sourceDevice = const Value.absent(),
    String? qualityFlag,
    DateTime? syncedAt,
  }) => WorkoutSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sport: sport ?? this.sport,
    title: title ?? this.title,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    caloriesBurned: caloriesBurned.present
        ? caloriesBurned.value
        : this.caloriesBurned,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    elevationGainMeters: elevationGainMeters.present
        ? elevationGainMeters.value
        : this.elevationGainMeters,
    zone1Minutes: zone1Minutes ?? this.zone1Minutes,
    zone2Minutes: zone2Minutes ?? this.zone2Minutes,
    zone3Minutes: zone3Minutes ?? this.zone3Minutes,
    zone4Minutes: zone4Minutes ?? this.zone4Minutes,
    zone5Minutes: zone5Minutes ?? this.zone5Minutes,
    strainScore: strainScore ?? this.strainScore,
    recoveryCost: recoveryCost ?? this.recoveryCost,
    sourceDevice: sourceDevice.present ? sourceDevice.value : this.sourceDevice,
    qualityFlag: qualityFlag ?? this.qualityFlag,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sport: data.sport.present ? data.sport.value : this.sport,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      zone1Minutes: data.zone1Minutes.present
          ? data.zone1Minutes.value
          : this.zone1Minutes,
      zone2Minutes: data.zone2Minutes.present
          ? data.zone2Minutes.value
          : this.zone2Minutes,
      zone3Minutes: data.zone3Minutes.present
          ? data.zone3Minutes.value
          : this.zone3Minutes,
      zone4Minutes: data.zone4Minutes.present
          ? data.zone4Minutes.value
          : this.zone4Minutes,
      zone5Minutes: data.zone5Minutes.present
          ? data.zone5Minutes.value
          : this.zone5Minutes,
      strainScore: data.strainScore.present
          ? data.strainScore.value
          : this.strainScore,
      recoveryCost: data.recoveryCost.present
          ? data.recoveryCost.value
          : this.recoveryCost,
      sourceDevice: data.sourceDevice.present
          ? data.sourceDevice.value
          : this.sourceDevice,
      qualityFlag: data.qualityFlag.present
          ? data.qualityFlag.value
          : this.qualityFlag,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sport: $sport, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('zone1Minutes: $zone1Minutes, ')
          ..write('zone2Minutes: $zone2Minutes, ')
          ..write('zone3Minutes: $zone3Minutes, ')
          ..write('zone4Minutes: $zone4Minutes, ')
          ..write('zone5Minutes: $zone5Minutes, ')
          ..write('strainScore: $strainScore, ')
          ..write('recoveryCost: $recoveryCost, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    sport,
    title,
    startTime,
    endTime,
    timeZoneOffsetMinutes,
    durationMinutes,
    avgHeartRate,
    maxHeartRate,
    caloriesBurned,
    distanceMeters,
    elevationGainMeters,
    zone1Minutes,
    zone2Minutes,
    zone3Minutes,
    zone4Minutes,
    zone5Minutes,
    strainScore,
    recoveryCost,
    sourceDevice,
    qualityFlag,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sport == this.sport &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.durationMinutes == this.durationMinutes &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.caloriesBurned == this.caloriesBurned &&
          other.distanceMeters == this.distanceMeters &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.zone1Minutes == this.zone1Minutes &&
          other.zone2Minutes == this.zone2Minutes &&
          other.zone3Minutes == this.zone3Minutes &&
          other.zone4Minutes == this.zone4Minutes &&
          other.zone5Minutes == this.zone5Minutes &&
          other.strainScore == this.strainScore &&
          other.recoveryCost == this.recoveryCost &&
          other.sourceDevice == this.sourceDevice &&
          other.qualityFlag == this.qualityFlag &&
          other.syncedAt == this.syncedAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> sport;
  final Value<String> title;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> timeZoneOffsetMinutes;
  final Value<int> durationMinutes;
  final Value<double?> avgHeartRate;
  final Value<double?> maxHeartRate;
  final Value<double?> caloriesBurned;
  final Value<double?> distanceMeters;
  final Value<double?> elevationGainMeters;
  final Value<int> zone1Minutes;
  final Value<int> zone2Minutes;
  final Value<int> zone3Minutes;
  final Value<int> zone4Minutes;
  final Value<int> zone5Minutes;
  final Value<double> strainScore;
  final Value<double> recoveryCost;
  final Value<String?> sourceDevice;
  final Value<String> qualityFlag;
  final Value<DateTime> syncedAt;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sport = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.zone1Minutes = const Value.absent(),
    this.zone2Minutes = const Value.absent(),
    this.zone3Minutes = const Value.absent(),
    this.zone4Minutes = const Value.absent(),
    this.zone5Minutes = const Value.absent(),
    this.strainScore = const Value.absent(),
    this.recoveryCost = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.qualityFlag = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String sport,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    this.timeZoneOffsetMinutes = const Value.absent(),
    required int durationMinutes,
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.zone1Minutes = const Value.absent(),
    this.zone2Minutes = const Value.absent(),
    this.zone3Minutes = const Value.absent(),
    this.zone4Minutes = const Value.absent(),
    this.zone5Minutes = const Value.absent(),
    this.strainScore = const Value.absent(),
    this.recoveryCost = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.qualityFlag = const Value.absent(),
    required DateTime syncedAt,
  }) : sport = Value(sport),
       title = Value(title),
       startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes),
       syncedAt = Value(syncedAt);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? sport,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<int>? durationMinutes,
    Expression<double>? avgHeartRate,
    Expression<double>? maxHeartRate,
    Expression<double>? caloriesBurned,
    Expression<double>? distanceMeters,
    Expression<double>? elevationGainMeters,
    Expression<int>? zone1Minutes,
    Expression<int>? zone2Minutes,
    Expression<int>? zone3Minutes,
    Expression<int>? zone4Minutes,
    Expression<int>? zone5Minutes,
    Expression<double>? strainScore,
    Expression<double>? recoveryCost,
    Expression<String>? sourceDevice,
    Expression<String>? qualityFlag,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sport != null) 'sport': sport,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (zone1Minutes != null) 'zone1_minutes': zone1Minutes,
      if (zone2Minutes != null) 'zone2_minutes': zone2Minutes,
      if (zone3Minutes != null) 'zone3_minutes': zone3Minutes,
      if (zone4Minutes != null) 'zone4_minutes': zone4Minutes,
      if (zone5Minutes != null) 'zone5_minutes': zone5Minutes,
      if (strainScore != null) 'strain_score': strainScore,
      if (recoveryCost != null) 'recovery_cost': recoveryCost,
      if (sourceDevice != null) 'source_device': sourceDevice,
      if (qualityFlag != null) 'quality_flag': qualityFlag,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? sport,
    Value<String>? title,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<int>? timeZoneOffsetMinutes,
    Value<int>? durationMinutes,
    Value<double?>? avgHeartRate,
    Value<double?>? maxHeartRate,
    Value<double?>? caloriesBurned,
    Value<double?>? distanceMeters,
    Value<double?>? elevationGainMeters,
    Value<int>? zone1Minutes,
    Value<int>? zone2Minutes,
    Value<int>? zone3Minutes,
    Value<int>? zone4Minutes,
    Value<int>? zone5Minutes,
    Value<double>? strainScore,
    Value<double>? recoveryCost,
    Value<String?>? sourceDevice,
    Value<String>? qualityFlag,
    Value<DateTime>? syncedAt,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sport: sport ?? this.sport,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      zone1Minutes: zone1Minutes ?? this.zone1Minutes,
      zone2Minutes: zone2Minutes ?? this.zone2Minutes,
      zone3Minutes: zone3Minutes ?? this.zone3Minutes,
      zone4Minutes: zone4Minutes ?? this.zone4Minutes,
      zone5Minutes: zone5Minutes ?? this.zone5Minutes,
      strainScore: strainScore ?? this.strainScore,
      recoveryCost: recoveryCost ?? this.recoveryCost,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      qualityFlag: qualityFlag ?? this.qualityFlag,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sport.present) {
      map['sport'] = Variable<String>(sport.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<double>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<double>(maxHeartRate.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (zone1Minutes.present) {
      map['zone1_minutes'] = Variable<int>(zone1Minutes.value);
    }
    if (zone2Minutes.present) {
      map['zone2_minutes'] = Variable<int>(zone2Minutes.value);
    }
    if (zone3Minutes.present) {
      map['zone3_minutes'] = Variable<int>(zone3Minutes.value);
    }
    if (zone4Minutes.present) {
      map['zone4_minutes'] = Variable<int>(zone4Minutes.value);
    }
    if (zone5Minutes.present) {
      map['zone5_minutes'] = Variable<int>(zone5Minutes.value);
    }
    if (strainScore.present) {
      map['strain_score'] = Variable<double>(strainScore.value);
    }
    if (recoveryCost.present) {
      map['recovery_cost'] = Variable<double>(recoveryCost.value);
    }
    if (sourceDevice.present) {
      map['source_device'] = Variable<String>(sourceDevice.value);
    }
    if (qualityFlag.present) {
      map['quality_flag'] = Variable<String>(qualityFlag.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sport: $sport, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('zone1Minutes: $zone1Minutes, ')
          ..write('zone2Minutes: $zone2Minutes, ')
          ..write('zone3Minutes: $zone3Minutes, ')
          ..write('zone4Minutes: $zone4Minutes, ')
          ..write('zone5Minutes: $zone5Minutes, ')
          ..write('strainScore: $strainScore, ')
          ..write('recoveryCost: $recoveryCost, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('qualityFlag: $qualityFlag, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $BaselineSnapshotsTable extends BaselineSnapshots
    with TableInfo<$BaselineSnapshotsTable, BaselineSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaselineSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hrvBaseline7dMeta = const VerificationMeta(
    'hrvBaseline7d',
  );
  @override
  late final GeneratedColumn<double> hrvBaseline7d = GeneratedColumn<double>(
    'hrv_baseline7d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvBaseline60dMeanMeta =
      const VerificationMeta('hrvBaseline60dMean');
  @override
  late final GeneratedColumn<double> hrvBaseline60dMean =
      GeneratedColumn<double>(
        'hrv_baseline60d_mean',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hrvBaseline60dSdMeta = const VerificationMeta(
    'hrvBaseline60dSd',
  );
  @override
  late final GeneratedColumn<double> hrvBaseline60dSd = GeneratedColumn<double>(
    'hrv_baseline60d_sd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvCv7dMeta = const VerificationMeta(
    'hrvCv7d',
  );
  @override
  late final GeneratedColumn<double> hrvCv7d = GeneratedColumn<double>(
    'hrv_cv7d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawHrvBaseline7dMsMeta =
      const VerificationMeta('rawHrvBaseline7dMs');
  @override
  late final GeneratedColumn<double> rawHrvBaseline7dMs =
      GeneratedColumn<double>(
        'raw_hrv_baseline7d_ms',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rhrBaseline7dMeta = const VerificationMeta(
    'rhrBaseline7d',
  );
  @override
  late final GeneratedColumn<double> rhrBaseline7d = GeneratedColumn<double>(
    'rhr_baseline7d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rhrBaseline30dMeta = const VerificationMeta(
    'rhrBaseline30d',
  );
  @override
  late final GeneratedColumn<double> rhrBaseline30d = GeneratedColumn<double>(
    'rhr_baseline30d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rhrBaseline60dMeanMeta =
      const VerificationMeta('rhrBaseline60dMean');
  @override
  late final GeneratedColumn<double> rhrBaseline60dMean =
      GeneratedColumn<double>(
        'rhr_baseline60d_mean',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rhrBaseline60dSdMeta = const VerificationMeta(
    'rhrBaseline60dSd',
  );
  @override
  late final GeneratedColumn<double> rhrBaseline60dSd = GeneratedColumn<double>(
    'rhr_baseline60d_sd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepDurationBaseline7dMeta =
      const VerificationMeta('sleepDurationBaseline7d');
  @override
  late final GeneratedColumn<double> sleepDurationBaseline7d =
      GeneratedColumn<double>(
        'sleep_duration_baseline7d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sleepDurationBaseline60dMeta =
      const VerificationMeta('sleepDurationBaseline60d');
  @override
  late final GeneratedColumn<double> sleepDurationBaseline60d =
      GeneratedColumn<double>(
        'sleep_duration_baseline60d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _respiratoryRateBaseline7dMeta =
      const VerificationMeta('respiratoryRateBaseline7d');
  @override
  late final GeneratedColumn<double> respiratoryRateBaseline7d =
      GeneratedColumn<double>(
        'respiratory_rate_baseline7d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _respiratoryRateBaseline60dMeta =
      const VerificationMeta('respiratoryRateBaseline60d');
  @override
  late final GeneratedColumn<double> respiratoryRateBaseline60d =
      GeneratedColumn<double>(
        'respiratory_rate_baseline60d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _spo2Baseline7dMeta = const VerificationMeta(
    'spo2Baseline7d',
  );
  @override
  late final GeneratedColumn<double> spo2Baseline7d = GeneratedColumn<double>(
    'spo2_baseline7d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skinTempBaseline30dMeta =
      const VerificationMeta('skinTempBaseline30d');
  @override
  late final GeneratedColumn<double> skinTempBaseline30d =
      GeneratedColumn<double>(
        'skin_temp_baseline30d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalRecordedNightsMeta =
      const VerificationMeta('totalRecordedNights');
  @override
  late final GeneratedColumn<int> totalRecordedNights = GeneratedColumn<int>(
    'total_recorded_nights',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    timeZoneOffsetMinutes,
    hrvBaseline7d,
    hrvBaseline60dMean,
    hrvBaseline60dSd,
    hrvCv7d,
    rawHrvBaseline7dMs,
    rhrBaseline7d,
    rhrBaseline30d,
    rhrBaseline60dMean,
    rhrBaseline60dSd,
    sleepDurationBaseline7d,
    sleepDurationBaseline60d,
    respiratoryRateBaseline7d,
    respiratoryRateBaseline60d,
    spo2Baseline7d,
    skinTempBaseline30d,
    totalRecordedNights,
    calculatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'baseline_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaselineSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('hrv_baseline7d')) {
      context.handle(
        _hrvBaseline7dMeta,
        hrvBaseline7d.isAcceptableOrUnknown(
          data['hrv_baseline7d']!,
          _hrvBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('hrv_baseline60d_mean')) {
      context.handle(
        _hrvBaseline60dMeanMeta,
        hrvBaseline60dMean.isAcceptableOrUnknown(
          data['hrv_baseline60d_mean']!,
          _hrvBaseline60dMeanMeta,
        ),
      );
    }
    if (data.containsKey('hrv_baseline60d_sd')) {
      context.handle(
        _hrvBaseline60dSdMeta,
        hrvBaseline60dSd.isAcceptableOrUnknown(
          data['hrv_baseline60d_sd']!,
          _hrvBaseline60dSdMeta,
        ),
      );
    }
    if (data.containsKey('hrv_cv7d')) {
      context.handle(
        _hrvCv7dMeta,
        hrvCv7d.isAcceptableOrUnknown(data['hrv_cv7d']!, _hrvCv7dMeta),
      );
    }
    if (data.containsKey('raw_hrv_baseline7d_ms')) {
      context.handle(
        _rawHrvBaseline7dMsMeta,
        rawHrvBaseline7dMs.isAcceptableOrUnknown(
          data['raw_hrv_baseline7d_ms']!,
          _rawHrvBaseline7dMsMeta,
        ),
      );
    }
    if (data.containsKey('rhr_baseline7d')) {
      context.handle(
        _rhrBaseline7dMeta,
        rhrBaseline7d.isAcceptableOrUnknown(
          data['rhr_baseline7d']!,
          _rhrBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('rhr_baseline30d')) {
      context.handle(
        _rhrBaseline30dMeta,
        rhrBaseline30d.isAcceptableOrUnknown(
          data['rhr_baseline30d']!,
          _rhrBaseline30dMeta,
        ),
      );
    }
    if (data.containsKey('rhr_baseline60d_mean')) {
      context.handle(
        _rhrBaseline60dMeanMeta,
        rhrBaseline60dMean.isAcceptableOrUnknown(
          data['rhr_baseline60d_mean']!,
          _rhrBaseline60dMeanMeta,
        ),
      );
    }
    if (data.containsKey('rhr_baseline60d_sd')) {
      context.handle(
        _rhrBaseline60dSdMeta,
        rhrBaseline60dSd.isAcceptableOrUnknown(
          data['rhr_baseline60d_sd']!,
          _rhrBaseline60dSdMeta,
        ),
      );
    }
    if (data.containsKey('sleep_duration_baseline7d')) {
      context.handle(
        _sleepDurationBaseline7dMeta,
        sleepDurationBaseline7d.isAcceptableOrUnknown(
          data['sleep_duration_baseline7d']!,
          _sleepDurationBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('sleep_duration_baseline60d')) {
      context.handle(
        _sleepDurationBaseline60dMeta,
        sleepDurationBaseline60d.isAcceptableOrUnknown(
          data['sleep_duration_baseline60d']!,
          _sleepDurationBaseline60dMeta,
        ),
      );
    }
    if (data.containsKey('respiratory_rate_baseline7d')) {
      context.handle(
        _respiratoryRateBaseline7dMeta,
        respiratoryRateBaseline7d.isAcceptableOrUnknown(
          data['respiratory_rate_baseline7d']!,
          _respiratoryRateBaseline7dMeta,
        ),
      );
    }
    if (data.containsKey('respiratory_rate_baseline60d')) {
      context.handle(
        _respiratoryRateBaseline60dMeta,
        respiratoryRateBaseline60d.isAcceptableOrUnknown(
          data['respiratory_rate_baseline60d']!,
          _respiratoryRateBaseline60dMeta,
        ),
      );
    }
    if (data.containsKey('spo2_baseline7d')) {
      context.handle(
        _spo2Baseline7dMeta,
        spo2Baseline7d.isAcceptableOrUnknown(
          data['spo2_baseline7d']!,
          _spo2Baseline7dMeta,
        ),
      );
    }
    if (data.containsKey('skin_temp_baseline30d')) {
      context.handle(
        _skinTempBaseline30dMeta,
        skinTempBaseline30d.isAcceptableOrUnknown(
          data['skin_temp_baseline30d']!,
          _skinTempBaseline30dMeta,
        ),
      );
    }
    if (data.containsKey('total_recorded_nights')) {
      context.handle(
        _totalRecordedNightsMeta,
        totalRecordedNights.isAcceptableOrUnknown(
          data['total_recorded_nights']!,
          _totalRecordedNightsMeta,
        ),
      );
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date},
  ];
  @override
  BaselineSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaselineSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
      hrvBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_baseline7d'],
      ),
      hrvBaseline60dMean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_baseline60d_mean'],
      ),
      hrvBaseline60dSd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_baseline60d_sd'],
      ),
      hrvCv7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_cv7d'],
      ),
      rawHrvBaseline7dMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_hrv_baseline7d_ms'],
      ),
      rhrBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rhr_baseline7d'],
      ),
      rhrBaseline30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rhr_baseline30d'],
      ),
      rhrBaseline60dMean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rhr_baseline60d_mean'],
      ),
      rhrBaseline60dSd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rhr_baseline60d_sd'],
      ),
      sleepDurationBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_duration_baseline7d'],
      ),
      sleepDurationBaseline60d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_duration_baseline60d'],
      ),
      respiratoryRateBaseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate_baseline7d'],
      ),
      respiratoryRateBaseline60d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate_baseline60d'],
      ),
      spo2Baseline7d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2_baseline7d'],
      ),
      skinTempBaseline30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}skin_temp_baseline30d'],
      ),
      totalRecordedNights: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_recorded_nights'],
      )!,
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
    );
  }

  @override
  $BaselineSnapshotsTable createAlias(String alias) {
    return $BaselineSnapshotsTable(attachedDatabase, alias);
  }
}

class BaselineSnapshot extends DataClass
    implements Insertable<BaselineSnapshot> {
  final int id;
  final DateTime date;
  final int timeZoneOffsetMinutes;
  final double? hrvBaseline7d;
  final double? hrvBaseline60dMean;
  final double? hrvBaseline60dSd;
  final double? hrvCv7d;
  final double? rawHrvBaseline7dMs;
  final double? rhrBaseline7d;
  final double? rhrBaseline30d;
  final double? rhrBaseline60dMean;
  final double? rhrBaseline60dSd;
  final double? sleepDurationBaseline7d;
  final double? sleepDurationBaseline60d;
  final double? respiratoryRateBaseline7d;
  final double? respiratoryRateBaseline60d;
  final double? spo2Baseline7d;
  final double? skinTempBaseline30d;
  final int totalRecordedNights;
  final DateTime calculatedAt;
  const BaselineSnapshot({
    required this.id,
    required this.date,
    required this.timeZoneOffsetMinutes,
    this.hrvBaseline7d,
    this.hrvBaseline60dMean,
    this.hrvBaseline60dSd,
    this.hrvCv7d,
    this.rawHrvBaseline7dMs,
    this.rhrBaseline7d,
    this.rhrBaseline30d,
    this.rhrBaseline60dMean,
    this.rhrBaseline60dSd,
    this.sleepDurationBaseline7d,
    this.sleepDurationBaseline60d,
    this.respiratoryRateBaseline7d,
    this.respiratoryRateBaseline60d,
    this.spo2Baseline7d,
    this.skinTempBaseline30d,
    required this.totalRecordedNights,
    required this.calculatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    if (!nullToAbsent || hrvBaseline7d != null) {
      map['hrv_baseline7d'] = Variable<double>(hrvBaseline7d);
    }
    if (!nullToAbsent || hrvBaseline60dMean != null) {
      map['hrv_baseline60d_mean'] = Variable<double>(hrvBaseline60dMean);
    }
    if (!nullToAbsent || hrvBaseline60dSd != null) {
      map['hrv_baseline60d_sd'] = Variable<double>(hrvBaseline60dSd);
    }
    if (!nullToAbsent || hrvCv7d != null) {
      map['hrv_cv7d'] = Variable<double>(hrvCv7d);
    }
    if (!nullToAbsent || rawHrvBaseline7dMs != null) {
      map['raw_hrv_baseline7d_ms'] = Variable<double>(rawHrvBaseline7dMs);
    }
    if (!nullToAbsent || rhrBaseline7d != null) {
      map['rhr_baseline7d'] = Variable<double>(rhrBaseline7d);
    }
    if (!nullToAbsent || rhrBaseline30d != null) {
      map['rhr_baseline30d'] = Variable<double>(rhrBaseline30d);
    }
    if (!nullToAbsent || rhrBaseline60dMean != null) {
      map['rhr_baseline60d_mean'] = Variable<double>(rhrBaseline60dMean);
    }
    if (!nullToAbsent || rhrBaseline60dSd != null) {
      map['rhr_baseline60d_sd'] = Variable<double>(rhrBaseline60dSd);
    }
    if (!nullToAbsent || sleepDurationBaseline7d != null) {
      map['sleep_duration_baseline7d'] = Variable<double>(
        sleepDurationBaseline7d,
      );
    }
    if (!nullToAbsent || sleepDurationBaseline60d != null) {
      map['sleep_duration_baseline60d'] = Variable<double>(
        sleepDurationBaseline60d,
      );
    }
    if (!nullToAbsent || respiratoryRateBaseline7d != null) {
      map['respiratory_rate_baseline7d'] = Variable<double>(
        respiratoryRateBaseline7d,
      );
    }
    if (!nullToAbsent || respiratoryRateBaseline60d != null) {
      map['respiratory_rate_baseline60d'] = Variable<double>(
        respiratoryRateBaseline60d,
      );
    }
    if (!nullToAbsent || spo2Baseline7d != null) {
      map['spo2_baseline7d'] = Variable<double>(spo2Baseline7d);
    }
    if (!nullToAbsent || skinTempBaseline30d != null) {
      map['skin_temp_baseline30d'] = Variable<double>(skinTempBaseline30d);
    }
    map['total_recorded_nights'] = Variable<int>(totalRecordedNights);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    return map;
  }

  BaselineSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BaselineSnapshotsCompanion(
      id: Value(id),
      date: Value(date),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
      hrvBaseline7d: hrvBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvBaseline7d),
      hrvBaseline60dMean: hrvBaseline60dMean == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvBaseline60dMean),
      hrvBaseline60dSd: hrvBaseline60dSd == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvBaseline60dSd),
      hrvCv7d: hrvCv7d == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvCv7d),
      rawHrvBaseline7dMs: rawHrvBaseline7dMs == null && nullToAbsent
          ? const Value.absent()
          : Value(rawHrvBaseline7dMs),
      rhrBaseline7d: rhrBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(rhrBaseline7d),
      rhrBaseline30d: rhrBaseline30d == null && nullToAbsent
          ? const Value.absent()
          : Value(rhrBaseline30d),
      rhrBaseline60dMean: rhrBaseline60dMean == null && nullToAbsent
          ? const Value.absent()
          : Value(rhrBaseline60dMean),
      rhrBaseline60dSd: rhrBaseline60dSd == null && nullToAbsent
          ? const Value.absent()
          : Value(rhrBaseline60dSd),
      sleepDurationBaseline7d: sleepDurationBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepDurationBaseline7d),
      sleepDurationBaseline60d: sleepDurationBaseline60d == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepDurationBaseline60d),
      respiratoryRateBaseline7d:
          respiratoryRateBaseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRateBaseline7d),
      respiratoryRateBaseline60d:
          respiratoryRateBaseline60d == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRateBaseline60d),
      spo2Baseline7d: spo2Baseline7d == null && nullToAbsent
          ? const Value.absent()
          : Value(spo2Baseline7d),
      skinTempBaseline30d: skinTempBaseline30d == null && nullToAbsent
          ? const Value.absent()
          : Value(skinTempBaseline30d),
      totalRecordedNights: Value(totalRecordedNights),
      calculatedAt: Value(calculatedAt),
    );
  }

  factory BaselineSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaselineSnapshot(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
      hrvBaseline7d: serializer.fromJson<double?>(json['hrvBaseline7d']),
      hrvBaseline60dMean: serializer.fromJson<double?>(
        json['hrvBaseline60dMean'],
      ),
      hrvBaseline60dSd: serializer.fromJson<double?>(json['hrvBaseline60dSd']),
      hrvCv7d: serializer.fromJson<double?>(json['hrvCv7d']),
      rawHrvBaseline7dMs: serializer.fromJson<double?>(
        json['rawHrvBaseline7dMs'],
      ),
      rhrBaseline7d: serializer.fromJson<double?>(json['rhrBaseline7d']),
      rhrBaseline30d: serializer.fromJson<double?>(json['rhrBaseline30d']),
      rhrBaseline60dMean: serializer.fromJson<double?>(
        json['rhrBaseline60dMean'],
      ),
      rhrBaseline60dSd: serializer.fromJson<double?>(json['rhrBaseline60dSd']),
      sleepDurationBaseline7d: serializer.fromJson<double?>(
        json['sleepDurationBaseline7d'],
      ),
      sleepDurationBaseline60d: serializer.fromJson<double?>(
        json['sleepDurationBaseline60d'],
      ),
      respiratoryRateBaseline7d: serializer.fromJson<double?>(
        json['respiratoryRateBaseline7d'],
      ),
      respiratoryRateBaseline60d: serializer.fromJson<double?>(
        json['respiratoryRateBaseline60d'],
      ),
      spo2Baseline7d: serializer.fromJson<double?>(json['spo2Baseline7d']),
      skinTempBaseline30d: serializer.fromJson<double?>(
        json['skinTempBaseline30d'],
      ),
      totalRecordedNights: serializer.fromJson<int>(
        json['totalRecordedNights'],
      ),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
      'hrvBaseline7d': serializer.toJson<double?>(hrvBaseline7d),
      'hrvBaseline60dMean': serializer.toJson<double?>(hrvBaseline60dMean),
      'hrvBaseline60dSd': serializer.toJson<double?>(hrvBaseline60dSd),
      'hrvCv7d': serializer.toJson<double?>(hrvCv7d),
      'rawHrvBaseline7dMs': serializer.toJson<double?>(rawHrvBaseline7dMs),
      'rhrBaseline7d': serializer.toJson<double?>(rhrBaseline7d),
      'rhrBaseline30d': serializer.toJson<double?>(rhrBaseline30d),
      'rhrBaseline60dMean': serializer.toJson<double?>(rhrBaseline60dMean),
      'rhrBaseline60dSd': serializer.toJson<double?>(rhrBaseline60dSd),
      'sleepDurationBaseline7d': serializer.toJson<double?>(
        sleepDurationBaseline7d,
      ),
      'sleepDurationBaseline60d': serializer.toJson<double?>(
        sleepDurationBaseline60d,
      ),
      'respiratoryRateBaseline7d': serializer.toJson<double?>(
        respiratoryRateBaseline7d,
      ),
      'respiratoryRateBaseline60d': serializer.toJson<double?>(
        respiratoryRateBaseline60d,
      ),
      'spo2Baseline7d': serializer.toJson<double?>(spo2Baseline7d),
      'skinTempBaseline30d': serializer.toJson<double?>(skinTempBaseline30d),
      'totalRecordedNights': serializer.toJson<int>(totalRecordedNights),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
    };
  }

  BaselineSnapshot copyWith({
    int? id,
    DateTime? date,
    int? timeZoneOffsetMinutes,
    Value<double?> hrvBaseline7d = const Value.absent(),
    Value<double?> hrvBaseline60dMean = const Value.absent(),
    Value<double?> hrvBaseline60dSd = const Value.absent(),
    Value<double?> hrvCv7d = const Value.absent(),
    Value<double?> rawHrvBaseline7dMs = const Value.absent(),
    Value<double?> rhrBaseline7d = const Value.absent(),
    Value<double?> rhrBaseline30d = const Value.absent(),
    Value<double?> rhrBaseline60dMean = const Value.absent(),
    Value<double?> rhrBaseline60dSd = const Value.absent(),
    Value<double?> sleepDurationBaseline7d = const Value.absent(),
    Value<double?> sleepDurationBaseline60d = const Value.absent(),
    Value<double?> respiratoryRateBaseline7d = const Value.absent(),
    Value<double?> respiratoryRateBaseline60d = const Value.absent(),
    Value<double?> spo2Baseline7d = const Value.absent(),
    Value<double?> skinTempBaseline30d = const Value.absent(),
    int? totalRecordedNights,
    DateTime? calculatedAt,
  }) => BaselineSnapshot(
    id: id ?? this.id,
    date: date ?? this.date,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    hrvBaseline7d: hrvBaseline7d.present
        ? hrvBaseline7d.value
        : this.hrvBaseline7d,
    hrvBaseline60dMean: hrvBaseline60dMean.present
        ? hrvBaseline60dMean.value
        : this.hrvBaseline60dMean,
    hrvBaseline60dSd: hrvBaseline60dSd.present
        ? hrvBaseline60dSd.value
        : this.hrvBaseline60dSd,
    hrvCv7d: hrvCv7d.present ? hrvCv7d.value : this.hrvCv7d,
    rawHrvBaseline7dMs: rawHrvBaseline7dMs.present
        ? rawHrvBaseline7dMs.value
        : this.rawHrvBaseline7dMs,
    rhrBaseline7d: rhrBaseline7d.present
        ? rhrBaseline7d.value
        : this.rhrBaseline7d,
    rhrBaseline30d: rhrBaseline30d.present
        ? rhrBaseline30d.value
        : this.rhrBaseline30d,
    rhrBaseline60dMean: rhrBaseline60dMean.present
        ? rhrBaseline60dMean.value
        : this.rhrBaseline60dMean,
    rhrBaseline60dSd: rhrBaseline60dSd.present
        ? rhrBaseline60dSd.value
        : this.rhrBaseline60dSd,
    sleepDurationBaseline7d: sleepDurationBaseline7d.present
        ? sleepDurationBaseline7d.value
        : this.sleepDurationBaseline7d,
    sleepDurationBaseline60d: sleepDurationBaseline60d.present
        ? sleepDurationBaseline60d.value
        : this.sleepDurationBaseline60d,
    respiratoryRateBaseline7d: respiratoryRateBaseline7d.present
        ? respiratoryRateBaseline7d.value
        : this.respiratoryRateBaseline7d,
    respiratoryRateBaseline60d: respiratoryRateBaseline60d.present
        ? respiratoryRateBaseline60d.value
        : this.respiratoryRateBaseline60d,
    spo2Baseline7d: spo2Baseline7d.present
        ? spo2Baseline7d.value
        : this.spo2Baseline7d,
    skinTempBaseline30d: skinTempBaseline30d.present
        ? skinTempBaseline30d.value
        : this.skinTempBaseline30d,
    totalRecordedNights: totalRecordedNights ?? this.totalRecordedNights,
    calculatedAt: calculatedAt ?? this.calculatedAt,
  );
  BaselineSnapshot copyWithCompanion(BaselineSnapshotsCompanion data) {
    return BaselineSnapshot(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      hrvBaseline7d: data.hrvBaseline7d.present
          ? data.hrvBaseline7d.value
          : this.hrvBaseline7d,
      hrvBaseline60dMean: data.hrvBaseline60dMean.present
          ? data.hrvBaseline60dMean.value
          : this.hrvBaseline60dMean,
      hrvBaseline60dSd: data.hrvBaseline60dSd.present
          ? data.hrvBaseline60dSd.value
          : this.hrvBaseline60dSd,
      hrvCv7d: data.hrvCv7d.present ? data.hrvCv7d.value : this.hrvCv7d,
      rawHrvBaseline7dMs: data.rawHrvBaseline7dMs.present
          ? data.rawHrvBaseline7dMs.value
          : this.rawHrvBaseline7dMs,
      rhrBaseline7d: data.rhrBaseline7d.present
          ? data.rhrBaseline7d.value
          : this.rhrBaseline7d,
      rhrBaseline30d: data.rhrBaseline30d.present
          ? data.rhrBaseline30d.value
          : this.rhrBaseline30d,
      rhrBaseline60dMean: data.rhrBaseline60dMean.present
          ? data.rhrBaseline60dMean.value
          : this.rhrBaseline60dMean,
      rhrBaseline60dSd: data.rhrBaseline60dSd.present
          ? data.rhrBaseline60dSd.value
          : this.rhrBaseline60dSd,
      sleepDurationBaseline7d: data.sleepDurationBaseline7d.present
          ? data.sleepDurationBaseline7d.value
          : this.sleepDurationBaseline7d,
      sleepDurationBaseline60d: data.sleepDurationBaseline60d.present
          ? data.sleepDurationBaseline60d.value
          : this.sleepDurationBaseline60d,
      respiratoryRateBaseline7d: data.respiratoryRateBaseline7d.present
          ? data.respiratoryRateBaseline7d.value
          : this.respiratoryRateBaseline7d,
      respiratoryRateBaseline60d: data.respiratoryRateBaseline60d.present
          ? data.respiratoryRateBaseline60d.value
          : this.respiratoryRateBaseline60d,
      spo2Baseline7d: data.spo2Baseline7d.present
          ? data.spo2Baseline7d.value
          : this.spo2Baseline7d,
      skinTempBaseline30d: data.skinTempBaseline30d.present
          ? data.skinTempBaseline30d.value
          : this.skinTempBaseline30d,
      totalRecordedNights: data.totalRecordedNights.present
          ? data.totalRecordedNights.value
          : this.totalRecordedNights,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaselineSnapshot(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('hrvBaseline7d: $hrvBaseline7d, ')
          ..write('hrvBaseline60dMean: $hrvBaseline60dMean, ')
          ..write('hrvBaseline60dSd: $hrvBaseline60dSd, ')
          ..write('hrvCv7d: $hrvCv7d, ')
          ..write('rawHrvBaseline7dMs: $rawHrvBaseline7dMs, ')
          ..write('rhrBaseline7d: $rhrBaseline7d, ')
          ..write('rhrBaseline30d: $rhrBaseline30d, ')
          ..write('rhrBaseline60dMean: $rhrBaseline60dMean, ')
          ..write('rhrBaseline60dSd: $rhrBaseline60dSd, ')
          ..write('sleepDurationBaseline7d: $sleepDurationBaseline7d, ')
          ..write('sleepDurationBaseline60d: $sleepDurationBaseline60d, ')
          ..write('respiratoryRateBaseline7d: $respiratoryRateBaseline7d, ')
          ..write('respiratoryRateBaseline60d: $respiratoryRateBaseline60d, ')
          ..write('spo2Baseline7d: $spo2Baseline7d, ')
          ..write('skinTempBaseline30d: $skinTempBaseline30d, ')
          ..write('totalRecordedNights: $totalRecordedNights, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    timeZoneOffsetMinutes,
    hrvBaseline7d,
    hrvBaseline60dMean,
    hrvBaseline60dSd,
    hrvCv7d,
    rawHrvBaseline7dMs,
    rhrBaseline7d,
    rhrBaseline30d,
    rhrBaseline60dMean,
    rhrBaseline60dSd,
    sleepDurationBaseline7d,
    sleepDurationBaseline60d,
    respiratoryRateBaseline7d,
    respiratoryRateBaseline60d,
    spo2Baseline7d,
    skinTempBaseline30d,
    totalRecordedNights,
    calculatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaselineSnapshot &&
          other.id == this.id &&
          other.date == this.date &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.hrvBaseline7d == this.hrvBaseline7d &&
          other.hrvBaseline60dMean == this.hrvBaseline60dMean &&
          other.hrvBaseline60dSd == this.hrvBaseline60dSd &&
          other.hrvCv7d == this.hrvCv7d &&
          other.rawHrvBaseline7dMs == this.rawHrvBaseline7dMs &&
          other.rhrBaseline7d == this.rhrBaseline7d &&
          other.rhrBaseline30d == this.rhrBaseline30d &&
          other.rhrBaseline60dMean == this.rhrBaseline60dMean &&
          other.rhrBaseline60dSd == this.rhrBaseline60dSd &&
          other.sleepDurationBaseline7d == this.sleepDurationBaseline7d &&
          other.sleepDurationBaseline60d == this.sleepDurationBaseline60d &&
          other.respiratoryRateBaseline7d == this.respiratoryRateBaseline7d &&
          other.respiratoryRateBaseline60d == this.respiratoryRateBaseline60d &&
          other.spo2Baseline7d == this.spo2Baseline7d &&
          other.skinTempBaseline30d == this.skinTempBaseline30d &&
          other.totalRecordedNights == this.totalRecordedNights &&
          other.calculatedAt == this.calculatedAt);
}

class BaselineSnapshotsCompanion extends UpdateCompanion<BaselineSnapshot> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> timeZoneOffsetMinutes;
  final Value<double?> hrvBaseline7d;
  final Value<double?> hrvBaseline60dMean;
  final Value<double?> hrvBaseline60dSd;
  final Value<double?> hrvCv7d;
  final Value<double?> rawHrvBaseline7dMs;
  final Value<double?> rhrBaseline7d;
  final Value<double?> rhrBaseline30d;
  final Value<double?> rhrBaseline60dMean;
  final Value<double?> rhrBaseline60dSd;
  final Value<double?> sleepDurationBaseline7d;
  final Value<double?> sleepDurationBaseline60d;
  final Value<double?> respiratoryRateBaseline7d;
  final Value<double?> respiratoryRateBaseline60d;
  final Value<double?> spo2Baseline7d;
  final Value<double?> skinTempBaseline30d;
  final Value<int> totalRecordedNights;
  final Value<DateTime> calculatedAt;
  const BaselineSnapshotsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.hrvBaseline7d = const Value.absent(),
    this.hrvBaseline60dMean = const Value.absent(),
    this.hrvBaseline60dSd = const Value.absent(),
    this.hrvCv7d = const Value.absent(),
    this.rawHrvBaseline7dMs = const Value.absent(),
    this.rhrBaseline7d = const Value.absent(),
    this.rhrBaseline30d = const Value.absent(),
    this.rhrBaseline60dMean = const Value.absent(),
    this.rhrBaseline60dSd = const Value.absent(),
    this.sleepDurationBaseline7d = const Value.absent(),
    this.sleepDurationBaseline60d = const Value.absent(),
    this.respiratoryRateBaseline7d = const Value.absent(),
    this.respiratoryRateBaseline60d = const Value.absent(),
    this.spo2Baseline7d = const Value.absent(),
    this.skinTempBaseline30d = const Value.absent(),
    this.totalRecordedNights = const Value.absent(),
    this.calculatedAt = const Value.absent(),
  });
  BaselineSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.hrvBaseline7d = const Value.absent(),
    this.hrvBaseline60dMean = const Value.absent(),
    this.hrvBaseline60dSd = const Value.absent(),
    this.hrvCv7d = const Value.absent(),
    this.rawHrvBaseline7dMs = const Value.absent(),
    this.rhrBaseline7d = const Value.absent(),
    this.rhrBaseline30d = const Value.absent(),
    this.rhrBaseline60dMean = const Value.absent(),
    this.rhrBaseline60dSd = const Value.absent(),
    this.sleepDurationBaseline7d = const Value.absent(),
    this.sleepDurationBaseline60d = const Value.absent(),
    this.respiratoryRateBaseline7d = const Value.absent(),
    this.respiratoryRateBaseline60d = const Value.absent(),
    this.spo2Baseline7d = const Value.absent(),
    this.skinTempBaseline30d = const Value.absent(),
    this.totalRecordedNights = const Value.absent(),
    required DateTime calculatedAt,
  }) : date = Value(date),
       calculatedAt = Value(calculatedAt);
  static Insertable<BaselineSnapshot> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<double>? hrvBaseline7d,
    Expression<double>? hrvBaseline60dMean,
    Expression<double>? hrvBaseline60dSd,
    Expression<double>? hrvCv7d,
    Expression<double>? rawHrvBaseline7dMs,
    Expression<double>? rhrBaseline7d,
    Expression<double>? rhrBaseline30d,
    Expression<double>? rhrBaseline60dMean,
    Expression<double>? rhrBaseline60dSd,
    Expression<double>? sleepDurationBaseline7d,
    Expression<double>? sleepDurationBaseline60d,
    Expression<double>? respiratoryRateBaseline7d,
    Expression<double>? respiratoryRateBaseline60d,
    Expression<double>? spo2Baseline7d,
    Expression<double>? skinTempBaseline30d,
    Expression<int>? totalRecordedNights,
    Expression<DateTime>? calculatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (hrvBaseline7d != null) 'hrv_baseline7d': hrvBaseline7d,
      if (hrvBaseline60dMean != null)
        'hrv_baseline60d_mean': hrvBaseline60dMean,
      if (hrvBaseline60dSd != null) 'hrv_baseline60d_sd': hrvBaseline60dSd,
      if (hrvCv7d != null) 'hrv_cv7d': hrvCv7d,
      if (rawHrvBaseline7dMs != null)
        'raw_hrv_baseline7d_ms': rawHrvBaseline7dMs,
      if (rhrBaseline7d != null) 'rhr_baseline7d': rhrBaseline7d,
      if (rhrBaseline30d != null) 'rhr_baseline30d': rhrBaseline30d,
      if (rhrBaseline60dMean != null)
        'rhr_baseline60d_mean': rhrBaseline60dMean,
      if (rhrBaseline60dSd != null) 'rhr_baseline60d_sd': rhrBaseline60dSd,
      if (sleepDurationBaseline7d != null)
        'sleep_duration_baseline7d': sleepDurationBaseline7d,
      if (sleepDurationBaseline60d != null)
        'sleep_duration_baseline60d': sleepDurationBaseline60d,
      if (respiratoryRateBaseline7d != null)
        'respiratory_rate_baseline7d': respiratoryRateBaseline7d,
      if (respiratoryRateBaseline60d != null)
        'respiratory_rate_baseline60d': respiratoryRateBaseline60d,
      if (spo2Baseline7d != null) 'spo2_baseline7d': spo2Baseline7d,
      if (skinTempBaseline30d != null)
        'skin_temp_baseline30d': skinTempBaseline30d,
      if (totalRecordedNights != null)
        'total_recorded_nights': totalRecordedNights,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
    });
  }

  BaselineSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? timeZoneOffsetMinutes,
    Value<double?>? hrvBaseline7d,
    Value<double?>? hrvBaseline60dMean,
    Value<double?>? hrvBaseline60dSd,
    Value<double?>? hrvCv7d,
    Value<double?>? rawHrvBaseline7dMs,
    Value<double?>? rhrBaseline7d,
    Value<double?>? rhrBaseline30d,
    Value<double?>? rhrBaseline60dMean,
    Value<double?>? rhrBaseline60dSd,
    Value<double?>? sleepDurationBaseline7d,
    Value<double?>? sleepDurationBaseline60d,
    Value<double?>? respiratoryRateBaseline7d,
    Value<double?>? respiratoryRateBaseline60d,
    Value<double?>? spo2Baseline7d,
    Value<double?>? skinTempBaseline30d,
    Value<int>? totalRecordedNights,
    Value<DateTime>? calculatedAt,
  }) {
    return BaselineSnapshotsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      hrvBaseline7d: hrvBaseline7d ?? this.hrvBaseline7d,
      hrvBaseline60dMean: hrvBaseline60dMean ?? this.hrvBaseline60dMean,
      hrvBaseline60dSd: hrvBaseline60dSd ?? this.hrvBaseline60dSd,
      hrvCv7d: hrvCv7d ?? this.hrvCv7d,
      rawHrvBaseline7dMs: rawHrvBaseline7dMs ?? this.rawHrvBaseline7dMs,
      rhrBaseline7d: rhrBaseline7d ?? this.rhrBaseline7d,
      rhrBaseline30d: rhrBaseline30d ?? this.rhrBaseline30d,
      rhrBaseline60dMean: rhrBaseline60dMean ?? this.rhrBaseline60dMean,
      rhrBaseline60dSd: rhrBaseline60dSd ?? this.rhrBaseline60dSd,
      sleepDurationBaseline7d:
          sleepDurationBaseline7d ?? this.sleepDurationBaseline7d,
      sleepDurationBaseline60d:
          sleepDurationBaseline60d ?? this.sleepDurationBaseline60d,
      respiratoryRateBaseline7d:
          respiratoryRateBaseline7d ?? this.respiratoryRateBaseline7d,
      respiratoryRateBaseline60d:
          respiratoryRateBaseline60d ?? this.respiratoryRateBaseline60d,
      spo2Baseline7d: spo2Baseline7d ?? this.spo2Baseline7d,
      skinTempBaseline30d: skinTempBaseline30d ?? this.skinTempBaseline30d,
      totalRecordedNights: totalRecordedNights ?? this.totalRecordedNights,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (hrvBaseline7d.present) {
      map['hrv_baseline7d'] = Variable<double>(hrvBaseline7d.value);
    }
    if (hrvBaseline60dMean.present) {
      map['hrv_baseline60d_mean'] = Variable<double>(hrvBaseline60dMean.value);
    }
    if (hrvBaseline60dSd.present) {
      map['hrv_baseline60d_sd'] = Variable<double>(hrvBaseline60dSd.value);
    }
    if (hrvCv7d.present) {
      map['hrv_cv7d'] = Variable<double>(hrvCv7d.value);
    }
    if (rawHrvBaseline7dMs.present) {
      map['raw_hrv_baseline7d_ms'] = Variable<double>(rawHrvBaseline7dMs.value);
    }
    if (rhrBaseline7d.present) {
      map['rhr_baseline7d'] = Variable<double>(rhrBaseline7d.value);
    }
    if (rhrBaseline30d.present) {
      map['rhr_baseline30d'] = Variable<double>(rhrBaseline30d.value);
    }
    if (rhrBaseline60dMean.present) {
      map['rhr_baseline60d_mean'] = Variable<double>(rhrBaseline60dMean.value);
    }
    if (rhrBaseline60dSd.present) {
      map['rhr_baseline60d_sd'] = Variable<double>(rhrBaseline60dSd.value);
    }
    if (sleepDurationBaseline7d.present) {
      map['sleep_duration_baseline7d'] = Variable<double>(
        sleepDurationBaseline7d.value,
      );
    }
    if (sleepDurationBaseline60d.present) {
      map['sleep_duration_baseline60d'] = Variable<double>(
        sleepDurationBaseline60d.value,
      );
    }
    if (respiratoryRateBaseline7d.present) {
      map['respiratory_rate_baseline7d'] = Variable<double>(
        respiratoryRateBaseline7d.value,
      );
    }
    if (respiratoryRateBaseline60d.present) {
      map['respiratory_rate_baseline60d'] = Variable<double>(
        respiratoryRateBaseline60d.value,
      );
    }
    if (spo2Baseline7d.present) {
      map['spo2_baseline7d'] = Variable<double>(spo2Baseline7d.value);
    }
    if (skinTempBaseline30d.present) {
      map['skin_temp_baseline30d'] = Variable<double>(
        skinTempBaseline30d.value,
      );
    }
    if (totalRecordedNights.present) {
      map['total_recorded_nights'] = Variable<int>(totalRecordedNights.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaselineSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('hrvBaseline7d: $hrvBaseline7d, ')
          ..write('hrvBaseline60dMean: $hrvBaseline60dMean, ')
          ..write('hrvBaseline60dSd: $hrvBaseline60dSd, ')
          ..write('hrvCv7d: $hrvCv7d, ')
          ..write('rawHrvBaseline7dMs: $rawHrvBaseline7dMs, ')
          ..write('rhrBaseline7d: $rhrBaseline7d, ')
          ..write('rhrBaseline30d: $rhrBaseline30d, ')
          ..write('rhrBaseline60dMean: $rhrBaseline60dMean, ')
          ..write('rhrBaseline60dSd: $rhrBaseline60dSd, ')
          ..write('sleepDurationBaseline7d: $sleepDurationBaseline7d, ')
          ..write('sleepDurationBaseline60d: $sleepDurationBaseline60d, ')
          ..write('respiratoryRateBaseline7d: $respiratoryRateBaseline7d, ')
          ..write('respiratoryRateBaseline60d: $respiratoryRateBaseline60d, ')
          ..write('spo2Baseline7d: $spo2Baseline7d, ')
          ..write('skinTempBaseline30d: $skinTempBaseline30d, ')
          ..write('totalRecordedNights: $totalRecordedNights, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneOffsetMinutesMeta =
      const VerificationMeta('timeZoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timeZoneOffsetMinutes = GeneratedColumn<int>(
    'time_zone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    timestamp,
    timeZoneOffsetMinutes,
    tag,
    value,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('time_zone_offset_minutes')) {
      context.handle(
        _timeZoneOffsetMinutesMeta,
        timeZoneOffsetMinutes.isAcceptableOrUnknown(
          data['time_zone_offset_minutes']!,
          _timeZoneOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      timeZoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_zone_offset_minutes'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;
  final String userId;
  final DateTime date;
  final DateTime timestamp;
  final int timeZoneOffsetMinutes;
  final String tag;
  final String? value;
  final String? notes;
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.timestamp,
    required this.timeZoneOffsetMinutes,
    required this.tag,
    this.value,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['time_zone_offset_minutes'] = Variable<int>(timeZoneOffsetMinutes);
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      timestamp: Value(timestamp),
      timeZoneOffsetMinutes: Value(timeZoneOffsetMinutes),
      tag: Value(tag),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      timeZoneOffsetMinutes: serializer.fromJson<int>(
        json['timeZoneOffsetMinutes'],
      ),
      tag: serializer.fromJson<String>(json['tag']),
      value: serializer.fromJson<String?>(json['value']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'timeZoneOffsetMinutes': serializer.toJson<int>(timeZoneOffsetMinutes),
      'tag': serializer.toJson<String>(tag),
      'value': serializer.toJson<String?>(value),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  JournalEntry copyWith({
    int? id,
    String? userId,
    DateTime? date,
    DateTime? timestamp,
    int? timeZoneOffsetMinutes,
    String? tag,
    Value<String?> value = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => JournalEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    timestamp: timestamp ?? this.timestamp,
    timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
    tag: tag ?? this.tag,
    value: value.present ? value.value : this.value,
    notes: notes.present ? notes.value : this.notes,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      timeZoneOffsetMinutes: data.timeZoneOffsetMinutes.present
          ? data.timeZoneOffsetMinutes.value
          : this.timeZoneOffsetMinutes,
      tag: data.tag.present ? data.tag.value : this.tag,
      value: data.value.present ? data.value.value : this.value,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('timestamp: $timestamp, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('tag: $tag, ')
          ..write('value: $value, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    timestamp,
    timeZoneOffsetMinutes,
    tag,
    value,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.timestamp == this.timestamp &&
          other.timeZoneOffsetMinutes == this.timeZoneOffsetMinutes &&
          other.tag == this.tag &&
          other.value == this.value &&
          other.notes == this.notes);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<DateTime> timestamp;
  final Value<int> timeZoneOffsetMinutes;
  final Value<String> tag;
  final Value<String?> value;
  final Value<String?> notes;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timeZoneOffsetMinutes = const Value.absent(),
    this.tag = const Value.absent(),
    this.value = const Value.absent(),
    this.notes = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime date,
    required DateTime timestamp,
    this.timeZoneOffsetMinutes = const Value.absent(),
    required String tag,
    this.value = const Value.absent(),
    this.notes = const Value.absent(),
  }) : date = Value(date),
       timestamp = Value(timestamp),
       tag = Value(tag);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<DateTime>? timestamp,
    Expression<int>? timeZoneOffsetMinutes,
    Expression<String>? tag,
    Expression<String>? value,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (timestamp != null) 'timestamp': timestamp,
      if (timeZoneOffsetMinutes != null)
        'time_zone_offset_minutes': timeZoneOffsetMinutes,
      if (tag != null) 'tag': tag,
      if (value != null) 'value': value,
      if (notes != null) 'notes': notes,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<DateTime>? timestamp,
    Value<int>? timeZoneOffsetMinutes,
    Value<String>? tag,
    Value<String?>? value,
    Value<String?>? notes,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      timeZoneOffsetMinutes:
          timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      tag: tag ?? this.tag,
      value: value ?? this.value,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (timeZoneOffsetMinutes.present) {
      map['time_zone_offset_minutes'] = Variable<int>(
        timeZoneOffsetMinutes.value,
      );
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('timestamp: $timestamp, ')
          ..write('timeZoneOffsetMinutes: $timeZoneOffsetMinutes, ')
          ..write('tag: $tag, ')
          ..write('value: $value, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $InsightsTable extends Insights with TableInfo<$InsightsTable, Insight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionableNudgeMeta = const VerificationMeta(
    'actionableNudge',
  );
  @override
  late final GeneratedColumn<String> actionableNudge = GeneratedColumn<String>(
    'actionable_nudge',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metricReferencesJsonMeta =
      const VerificationMeta('metricReferencesJson');
  @override
  late final GeneratedColumn<String> metricReferencesJson =
      GeneratedColumn<String>(
        'metric_references_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    date,
    category,
    title,
    summary,
    actionableNudge,
    metricReferencesJson,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Insight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('actionable_nudge')) {
      context.handle(
        _actionableNudgeMeta,
        actionableNudge.isAcceptableOrUnknown(
          data['actionable_nudge']!,
          _actionableNudgeMeta,
        ),
      );
    }
    if (data.containsKey('metric_references_json')) {
      context.handle(
        _metricReferencesJsonMeta,
        metricReferencesJson.isAcceptableOrUnknown(
          data['metric_references_json']!,
          _metricReferencesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metricReferencesJsonMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Insight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Insight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      actionableNudge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actionable_nudge'],
      ),
      metricReferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_references_json'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $InsightsTable createAlias(String alias) {
    return $InsightsTable(attachedDatabase, alias);
  }
}

class Insight extends DataClass implements Insertable<Insight> {
  final int id;
  final DateTime createdAt;
  final DateTime date;
  final String category;
  final String title;
  final String summary;
  final String? actionableNudge;
  final String metricReferencesJson;
  final bool isRead;
  const Insight({
    required this.id,
    required this.createdAt,
    required this.date,
    required this.category,
    required this.title,
    required this.summary,
    this.actionableNudge,
    required this.metricReferencesJson,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || actionableNudge != null) {
      map['actionable_nudge'] = Variable<String>(actionableNudge);
    }
    map['metric_references_json'] = Variable<String>(metricReferencesJson);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  InsightsCompanion toCompanion(bool nullToAbsent) {
    return InsightsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      date: Value(date),
      category: Value(category),
      title: Value(title),
      summary: Value(summary),
      actionableNudge: actionableNudge == null && nullToAbsent
          ? const Value.absent()
          : Value(actionableNudge),
      metricReferencesJson: Value(metricReferencesJson),
      isRead: Value(isRead),
    );
  }

  factory Insight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Insight(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      actionableNudge: serializer.fromJson<String?>(json['actionableNudge']),
      metricReferencesJson: serializer.fromJson<String>(
        json['metricReferencesJson'],
      ),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'actionableNudge': serializer.toJson<String?>(actionableNudge),
      'metricReferencesJson': serializer.toJson<String>(metricReferencesJson),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  Insight copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? date,
    String? category,
    String? title,
    String? summary,
    Value<String?> actionableNudge = const Value.absent(),
    String? metricReferencesJson,
    bool? isRead,
  }) => Insight(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    date: date ?? this.date,
    category: category ?? this.category,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    actionableNudge: actionableNudge.present
        ? actionableNudge.value
        : this.actionableNudge,
    metricReferencesJson: metricReferencesJson ?? this.metricReferencesJson,
    isRead: isRead ?? this.isRead,
  );
  Insight copyWithCompanion(InsightsCompanion data) {
    return Insight(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      actionableNudge: data.actionableNudge.present
          ? data.actionableNudge.value
          : this.actionableNudge,
      metricReferencesJson: data.metricReferencesJson.present
          ? data.metricReferencesJson.value
          : this.metricReferencesJson,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Insight(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('actionableNudge: $actionableNudge, ')
          ..write('metricReferencesJson: $metricReferencesJson, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    date,
    category,
    title,
    summary,
    actionableNudge,
    metricReferencesJson,
    isRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insight &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.date == this.date &&
          other.category == this.category &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.actionableNudge == this.actionableNudge &&
          other.metricReferencesJson == this.metricReferencesJson &&
          other.isRead == this.isRead);
}

class InsightsCompanion extends UpdateCompanion<Insight> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<String> title;
  final Value<String> summary;
  final Value<String?> actionableNudge;
  final Value<String> metricReferencesJson;
  final Value<bool> isRead;
  const InsightsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.actionableNudge = const Value.absent(),
    this.metricReferencesJson = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  InsightsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime date,
    required String category,
    required String title,
    required String summary,
    this.actionableNudge = const Value.absent(),
    required String metricReferencesJson,
    this.isRead = const Value.absent(),
  }) : createdAt = Value(createdAt),
       date = Value(date),
       category = Value(category),
       title = Value(title),
       summary = Value(summary),
       metricReferencesJson = Value(metricReferencesJson);
  static Insertable<Insight> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? actionableNudge,
    Expression<String>? metricReferencesJson,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (actionableNudge != null) 'actionable_nudge': actionableNudge,
      if (metricReferencesJson != null)
        'metric_references_json': metricReferencesJson,
      if (isRead != null) 'is_read': isRead,
    });
  }

  InsightsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? date,
    Value<String>? category,
    Value<String>? title,
    Value<String>? summary,
    Value<String?>? actionableNudge,
    Value<String>? metricReferencesJson,
    Value<bool>? isRead,
  }) {
    return InsightsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      category: category ?? this.category,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      actionableNudge: actionableNudge ?? this.actionableNudge,
      metricReferencesJson: metricReferencesJson ?? this.metricReferencesJson,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (actionableNudge.present) {
      map['actionable_nudge'] = Variable<String>(actionableNudge.value);
    }
    if (metricReferencesJson.present) {
      map['metric_references_json'] = Variable<String>(
        metricReferencesJson.value,
      );
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('actionableNudge: $actionableNudge, ')
          ..write('metricReferencesJson: $metricReferencesJson, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

class $DeviceConnectionsTable extends DeviceConnections
    with TableInfo<$DeviceConnectionsTable, DeviceConnection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncTimeMeta = const VerificationMeta(
    'lastSyncTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncTime = GeneratedColumn<DateTime>(
    'last_sync_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
    'battery_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    name,
    platform,
    lastSyncTime,
    batteryLevel,
    isActive,
    priority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceConnection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
        _lastSyncTimeMeta,
        lastSyncTime.isAcceptableOrUnknown(
          data['last_sync_time']!,
          _lastSyncTimeMeta,
        ),
      );
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId},
  ];
  @override
  DeviceConnection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceConnection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      lastSyncTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_time'],
      ),
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_level'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
    );
  }

  @override
  $DeviceConnectionsTable createAlias(String alias) {
    return $DeviceConnectionsTable(attachedDatabase, alias);
  }
}

class DeviceConnection extends DataClass
    implements Insertable<DeviceConnection> {
  final int id;
  final String deviceId;
  final String name;
  final String platform;
  final DateTime? lastSyncTime;
  final int? batteryLevel;
  final bool isActive;
  final int priority;
  const DeviceConnection({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.platform,
    this.lastSyncTime,
    this.batteryLevel,
    required this.isActive,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || lastSyncTime != null) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime);
    }
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<int>(batteryLevel);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  DeviceConnectionsCompanion toCompanion(bool nullToAbsent) {
    return DeviceConnectionsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      name: Value(name),
      platform: Value(platform),
      lastSyncTime: lastSyncTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncTime),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      isActive: Value(isActive),
      priority: Value(priority),
    );
  }

  factory DeviceConnection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceConnection(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      lastSyncTime: serializer.fromJson<DateTime?>(json['lastSyncTime']),
      batteryLevel: serializer.fromJson<int?>(json['batteryLevel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'lastSyncTime': serializer.toJson<DateTime?>(lastSyncTime),
      'batteryLevel': serializer.toJson<int?>(batteryLevel),
      'isActive': serializer.toJson<bool>(isActive),
      'priority': serializer.toJson<int>(priority),
    };
  }

  DeviceConnection copyWith({
    int? id,
    String? deviceId,
    String? name,
    String? platform,
    Value<DateTime?> lastSyncTime = const Value.absent(),
    Value<int?> batteryLevel = const Value.absent(),
    bool? isActive,
    int? priority,
  }) => DeviceConnection(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    lastSyncTime: lastSyncTime.present ? lastSyncTime.value : this.lastSyncTime,
    batteryLevel: batteryLevel.present ? batteryLevel.value : this.batteryLevel,
    isActive: isActive ?? this.isActive,
    priority: priority ?? this.priority,
  );
  DeviceConnection copyWithCompanion(DeviceConnectionsCompanion data) {
    return DeviceConnection(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceConnection(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('isActive: $isActive, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    name,
    platform,
    lastSyncTime,
    batteryLevel,
    isActive,
    priority,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceConnection &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.lastSyncTime == this.lastSyncTime &&
          other.batteryLevel == this.batteryLevel &&
          other.isActive == this.isActive &&
          other.priority == this.priority);
}

class DeviceConnectionsCompanion extends UpdateCompanion<DeviceConnection> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String> platform;
  final Value<DateTime?> lastSyncTime;
  final Value<int?> batteryLevel;
  final Value<bool> isActive;
  final Value<int> priority;
  const DeviceConnectionsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.priority = const Value.absent(),
  });
  DeviceConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String name,
    required String platform,
    this.lastSyncTime = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.priority = const Value.absent(),
  }) : deviceId = Value(deviceId),
       name = Value(name),
       platform = Value(platform);
  static Insertable<DeviceConnection> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<DateTime>? lastSyncTime,
    Expression<int>? batteryLevel,
    Expression<bool>? isActive,
    Expression<int>? priority,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (isActive != null) 'is_active': isActive,
      if (priority != null) 'priority': priority,
    });
  }

  DeviceConnectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? name,
    Value<String>? platform,
    Value<DateTime?>? lastSyncTime,
    Value<int?>? batteryLevel,
    Value<bool>? isActive,
    Value<int>? priority,
  }) {
    return DeviceConnectionsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('isActive: $isActive, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RawHealthRecordsTable rawHealthRecords = $RawHealthRecordsTable(
    this,
  );
  late final $DailyBaselinesTable dailyBaselines = $DailyBaselinesTable(this);
  late final $DerivedMetricsTable derivedMetrics = $DerivedMetricsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $BodyAgeSnapshotsTable bodyAgeSnapshots = $BodyAgeSnapshotsTable(
    this,
  );
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SleepSessionsTable sleepSessions = $SleepSessionsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $BaselineSnapshotsTable baselineSnapshots =
      $BaselineSnapshotsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $InsightsTable insights = $InsightsTable(this);
  late final $DeviceConnectionsTable deviceConnections =
      $DeviceConnectionsTable(this);
  late final HealthRecordDao healthRecordDao = HealthRecordDao(
    this as AppDatabase,
  );
  late final BaselineDao baselineDao = BaselineDao(this as AppDatabase);
  late final DerivedMetricDao derivedMetricDao = DerivedMetricDao(
    this as AppDatabase,
  );
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final BodyMeasurementDao bodyMeasurementDao = BodyMeasurementDao(
    this as AppDatabase,
  );
  late final BodyAgeSnapshotDao bodyAgeSnapshotDao = BodyAgeSnapshotDao(
    this as AppDatabase,
  );
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final SleepSessionDao sleepSessionDao = SleepSessionDao(
    this as AppDatabase,
  );
  late final WorkoutSessionDao workoutSessionDao = WorkoutSessionDao(
    this as AppDatabase,
  );
  late final BaselineSnapshotDao baselineSnapshotDao = BaselineSnapshotDao(
    this as AppDatabase,
  );
  late final JournalDao journalDao = JournalDao(this as AppDatabase);
  late final InsightDao insightDao = InsightDao(this as AppDatabase);
  late final DeviceConnectionDao deviceConnectionDao = DeviceConnectionDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rawHealthRecords,
    dailyBaselines,
    derivedMetrics,
    syncMetadata,
    syncLogs,
    bodyMeasurements,
    bodyAgeSnapshots,
    userProfiles,
    sleepSessions,
    workoutSessions,
    baselineSnapshots,
    journalEntries,
    insights,
    deviceConnections,
  ];
}

typedef $$RawHealthRecordsTableCreateCompanionBuilder =
    RawHealthRecordsCompanion Function({
      Value<int> id,
      required String recordType,
      required double value,
      Value<double?> valueSecondary,
      required String unit,
      required DateTime startTime,
      required DateTime endTime,
      required String sourceId,
      Value<String?> qualityFlag,
      Value<int?> timeZoneOffsetMinutes,
      required DateTime syncedAt,
    });
typedef $$RawHealthRecordsTableUpdateCompanionBuilder =
    RawHealthRecordsCompanion Function({
      Value<int> id,
      Value<String> recordType,
      Value<double> value,
      Value<double?> valueSecondary,
      Value<String> unit,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<String> sourceId,
      Value<String?> qualityFlag,
      Value<int?> timeZoneOffsetMinutes,
      Value<DateTime> syncedAt,
    });

class $$RawHealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RawHealthRecordsTable> {
  $$RawHealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RawHealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RawHealthRecordsTable> {
  $$RawHealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RawHealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RawHealthRecordsTable> {
  $$RawHealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$RawHealthRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RawHealthRecordsTable,
          RawHealthRecord,
          $$RawHealthRecordsTableFilterComposer,
          $$RawHealthRecordsTableOrderingComposer,
          $$RawHealthRecordsTableAnnotationComposer,
          $$RawHealthRecordsTableCreateCompanionBuilder,
          $$RawHealthRecordsTableUpdateCompanionBuilder,
          (
            RawHealthRecord,
            BaseReferences<
              _$AppDatabase,
              $RawHealthRecordsTable,
              RawHealthRecord
            >,
          ),
          RawHealthRecord,
          PrefetchHooks Function()
        > {
  $$RawHealthRecordsTableTableManager(
    _$AppDatabase db,
    $RawHealthRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RawHealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RawHealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RawHealthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<double?> valueSecondary = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> qualityFlag = const Value.absent(),
                Value<int?> timeZoneOffsetMinutes = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => RawHealthRecordsCompanion(
                id: id,
                recordType: recordType,
                value: value,
                valueSecondary: valueSecondary,
                unit: unit,
                startTime: startTime,
                endTime: endTime,
                sourceId: sourceId,
                qualityFlag: qualityFlag,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordType,
                required double value,
                Value<double?> valueSecondary = const Value.absent(),
                required String unit,
                required DateTime startTime,
                required DateTime endTime,
                required String sourceId,
                Value<String?> qualityFlag = const Value.absent(),
                Value<int?> timeZoneOffsetMinutes = const Value.absent(),
                required DateTime syncedAt,
              }) => RawHealthRecordsCompanion.insert(
                id: id,
                recordType: recordType,
                value: value,
                valueSecondary: valueSecondary,
                unit: unit,
                startTime: startTime,
                endTime: endTime,
                sourceId: sourceId,
                qualityFlag: qualityFlag,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RawHealthRecordsTable, RawHealthRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RawHealthRecordsTable,
                    RawHealthRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RawHealthRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RawHealthRecordsTable,
      RawHealthRecord,
      $$RawHealthRecordsTableFilterComposer,
      $$RawHealthRecordsTableOrderingComposer,
      $$RawHealthRecordsTableAnnotationComposer,
      $$RawHealthRecordsTableCreateCompanionBuilder,
      $$RawHealthRecordsTableUpdateCompanionBuilder,
      (
        RawHealthRecord,
        BaseReferences<_$AppDatabase, $RawHealthRecordsTable, RawHealthRecord>,
      ),
      RawHealthRecord,
      PrefetchHooks Function()
    >;
typedef $$DailyBaselinesTableCreateCompanionBuilder =
    DailyBaselinesCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<double?> restingHrBaseline7d,
      Value<double?> restingHrBaseline30d,
      Value<double?> sleepDurationBaseline7d,
      Value<double?> spo2Baseline7d,
    });
typedef $$DailyBaselinesTableUpdateCompanionBuilder =
    DailyBaselinesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double?> restingHrBaseline7d,
      Value<double?> restingHrBaseline30d,
      Value<double?> sleepDurationBaseline7d,
      Value<double?> spo2Baseline7d,
    });

class $$DailyBaselinesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyBaselinesTable> {
  $$DailyBaselinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHrBaseline7d => $composableBuilder(
    column: $table.restingHrBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHrBaseline30d => $composableBuilder(
    column: $table.restingHrBaseline30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyBaselinesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyBaselinesTable> {
  $$DailyBaselinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHrBaseline7d => $composableBuilder(
    column: $table.restingHrBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHrBaseline30d => $composableBuilder(
    column: $table.restingHrBaseline30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyBaselinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyBaselinesTable> {
  $$DailyBaselinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get restingHrBaseline7d => $composableBuilder(
    column: $table.restingHrBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get restingHrBaseline30d => $composableBuilder(
    column: $table.restingHrBaseline30d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => column,
  );
}

class $$DailyBaselinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyBaselinesTable,
          DailyBaseline,
          $$DailyBaselinesTableFilterComposer,
          $$DailyBaselinesTableOrderingComposer,
          $$DailyBaselinesTableAnnotationComposer,
          $$DailyBaselinesTableCreateCompanionBuilder,
          $$DailyBaselinesTableUpdateCompanionBuilder,
          (
            DailyBaseline,
            BaseReferences<_$AppDatabase, $DailyBaselinesTable, DailyBaseline>,
          ),
          DailyBaseline,
          PrefetchHooks Function()
        > {
  $$DailyBaselinesTableTableManager(
    _$AppDatabase db,
    $DailyBaselinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyBaselinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyBaselinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyBaselinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> restingHrBaseline7d = const Value.absent(),
                Value<double?> restingHrBaseline30d = const Value.absent(),
                Value<double?> sleepDurationBaseline7d = const Value.absent(),
                Value<double?> spo2Baseline7d = const Value.absent(),
              }) => DailyBaselinesCompanion(
                id: id,
                date: date,
                restingHrBaseline7d: restingHrBaseline7d,
                restingHrBaseline30d: restingHrBaseline30d,
                sleepDurationBaseline7d: sleepDurationBaseline7d,
                spo2Baseline7d: spo2Baseline7d,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<double?> restingHrBaseline7d = const Value.absent(),
                Value<double?> restingHrBaseline30d = const Value.absent(),
                Value<double?> sleepDurationBaseline7d = const Value.absent(),
                Value<double?> spo2Baseline7d = const Value.absent(),
              }) => DailyBaselinesCompanion.insert(
                id: id,
                date: date,
                restingHrBaseline7d: restingHrBaseline7d,
                restingHrBaseline30d: restingHrBaseline30d,
                sleepDurationBaseline7d: sleepDurationBaseline7d,
                spo2Baseline7d: spo2Baseline7d,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyBaselinesTable, DailyBaseline>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyBaselinesTable,
                    DailyBaseline
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyBaselinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyBaselinesTable,
      DailyBaseline,
      $$DailyBaselinesTableFilterComposer,
      $$DailyBaselinesTableOrderingComposer,
      $$DailyBaselinesTableAnnotationComposer,
      $$DailyBaselinesTableCreateCompanionBuilder,
      $$DailyBaselinesTableUpdateCompanionBuilder,
      (
        DailyBaseline,
        BaseReferences<_$AppDatabase, $DailyBaselinesTable, DailyBaseline>,
      ),
      DailyBaseline,
      PrefetchHooks Function()
    >;
typedef $$DerivedMetricsTableCreateCompanionBuilder =
    DerivedMetricsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<double?> estimatedVo2Max,
      Value<double?> recoveryScore,
      Value<double?> recoveryComponentRhr,
      Value<double?> recoveryComponentSleep,
      Value<double?> recoveryComponentSpo2,
      Value<String?> primaryFactor,
      Value<String?> readinessConfidence,
      Value<String?> dataQuality,
      Value<String> algorithmVersion,
      Value<double?> dayLoadScore,
      Value<double?> sleepScore,
      Value<double?> energyReserve,
      Value<double?> daytimeStress,
      Value<String?> topDriversJson,
      Value<String?> calculationBreakdownJson,
      Value<int> timeZoneOffsetMinutes,
    });
typedef $$DerivedMetricsTableUpdateCompanionBuilder =
    DerivedMetricsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double?> estimatedVo2Max,
      Value<double?> recoveryScore,
      Value<double?> recoveryComponentRhr,
      Value<double?> recoveryComponentSleep,
      Value<double?> recoveryComponentSpo2,
      Value<String?> primaryFactor,
      Value<String?> readinessConfidence,
      Value<String?> dataQuality,
      Value<String> algorithmVersion,
      Value<double?> dayLoadScore,
      Value<double?> sleepScore,
      Value<double?> energyReserve,
      Value<double?> daytimeStress,
      Value<String?> topDriversJson,
      Value<String?> calculationBreakdownJson,
      Value<int> timeZoneOffsetMinutes,
    });

class $$DerivedMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedVo2Max => $composableBuilder(
    column: $table.estimatedVo2Max,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryComponentRhr => $composableBuilder(
    column: $table.recoveryComponentRhr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryComponentSleep => $composableBuilder(
    column: $table.recoveryComponentSleep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryComponentSpo2 => $composableBuilder(
    column: $table.recoveryComponentSpo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryFactor => $composableBuilder(
    column: $table.primaryFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readinessConfidence => $composableBuilder(
    column: $table.readinessConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataQuality => $composableBuilder(
    column: $table.dataQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dayLoadScore => $composableBuilder(
    column: $table.dayLoadScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyReserve => $composableBuilder(
    column: $table.energyReserve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get daytimeStress => $composableBuilder(
    column: $table.daytimeStress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topDriversJson => $composableBuilder(
    column: $table.topDriversJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationBreakdownJson => $composableBuilder(
    column: $table.calculationBreakdownJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DerivedMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedVo2Max => $composableBuilder(
    column: $table.estimatedVo2Max,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryComponentRhr => $composableBuilder(
    column: $table.recoveryComponentRhr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryComponentSleep => $composableBuilder(
    column: $table.recoveryComponentSleep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryComponentSpo2 => $composableBuilder(
    column: $table.recoveryComponentSpo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryFactor => $composableBuilder(
    column: $table.primaryFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readinessConfidence => $composableBuilder(
    column: $table.readinessConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataQuality => $composableBuilder(
    column: $table.dataQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dayLoadScore => $composableBuilder(
    column: $table.dayLoadScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyReserve => $composableBuilder(
    column: $table.energyReserve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get daytimeStress => $composableBuilder(
    column: $table.daytimeStress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topDriversJson => $composableBuilder(
    column: $table.topDriversJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationBreakdownJson => $composableBuilder(
    column: $table.calculationBreakdownJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DerivedMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get estimatedVo2Max => $composableBuilder(
    column: $table.estimatedVo2Max,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryScore => $composableBuilder(
    column: $table.recoveryScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryComponentRhr => $composableBuilder(
    column: $table.recoveryComponentRhr,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryComponentSleep => $composableBuilder(
    column: $table.recoveryComponentSleep,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryComponentSpo2 => $composableBuilder(
    column: $table.recoveryComponentSpo2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryFactor => $composableBuilder(
    column: $table.primaryFactor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readinessConfidence => $composableBuilder(
    column: $table.readinessConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataQuality => $composableBuilder(
    column: $table.dataQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dayLoadScore => $composableBuilder(
    column: $table.dayLoadScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energyReserve => $composableBuilder(
    column: $table.energyReserve,
    builder: (column) => column,
  );

  GeneratedColumn<double> get daytimeStress => $composableBuilder(
    column: $table.daytimeStress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topDriversJson => $composableBuilder(
    column: $table.topDriversJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculationBreakdownJson => $composableBuilder(
    column: $table.calculationBreakdownJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );
}

class $$DerivedMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DerivedMetricsTable,
          DerivedMetric,
          $$DerivedMetricsTableFilterComposer,
          $$DerivedMetricsTableOrderingComposer,
          $$DerivedMetricsTableAnnotationComposer,
          $$DerivedMetricsTableCreateCompanionBuilder,
          $$DerivedMetricsTableUpdateCompanionBuilder,
          (
            DerivedMetric,
            BaseReferences<_$AppDatabase, $DerivedMetricsTable, DerivedMetric>,
          ),
          DerivedMetric,
          PrefetchHooks Function()
        > {
  $$DerivedMetricsTableTableManager(
    _$AppDatabase db,
    $DerivedMetricsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DerivedMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DerivedMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DerivedMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> estimatedVo2Max = const Value.absent(),
                Value<double?> recoveryScore = const Value.absent(),
                Value<double?> recoveryComponentRhr = const Value.absent(),
                Value<double?> recoveryComponentSleep = const Value.absent(),
                Value<double?> recoveryComponentSpo2 = const Value.absent(),
                Value<String?> primaryFactor = const Value.absent(),
                Value<String?> readinessConfidence = const Value.absent(),
                Value<String?> dataQuality = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<double?> dayLoadScore = const Value.absent(),
                Value<double?> sleepScore = const Value.absent(),
                Value<double?> energyReserve = const Value.absent(),
                Value<double?> daytimeStress = const Value.absent(),
                Value<String?> topDriversJson = const Value.absent(),
                Value<String?> calculationBreakdownJson = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
              }) => DerivedMetricsCompanion(
                id: id,
                date: date,
                estimatedVo2Max: estimatedVo2Max,
                recoveryScore: recoveryScore,
                recoveryComponentRhr: recoveryComponentRhr,
                recoveryComponentSleep: recoveryComponentSleep,
                recoveryComponentSpo2: recoveryComponentSpo2,
                primaryFactor: primaryFactor,
                readinessConfidence: readinessConfidence,
                dataQuality: dataQuality,
                algorithmVersion: algorithmVersion,
                dayLoadScore: dayLoadScore,
                sleepScore: sleepScore,
                energyReserve: energyReserve,
                daytimeStress: daytimeStress,
                topDriversJson: topDriversJson,
                calculationBreakdownJson: calculationBreakdownJson,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<double?> estimatedVo2Max = const Value.absent(),
                Value<double?> recoveryScore = const Value.absent(),
                Value<double?> recoveryComponentRhr = const Value.absent(),
                Value<double?> recoveryComponentSleep = const Value.absent(),
                Value<double?> recoveryComponentSpo2 = const Value.absent(),
                Value<String?> primaryFactor = const Value.absent(),
                Value<String?> readinessConfidence = const Value.absent(),
                Value<String?> dataQuality = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<double?> dayLoadScore = const Value.absent(),
                Value<double?> sleepScore = const Value.absent(),
                Value<double?> energyReserve = const Value.absent(),
                Value<double?> daytimeStress = const Value.absent(),
                Value<String?> topDriversJson = const Value.absent(),
                Value<String?> calculationBreakdownJson = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
              }) => DerivedMetricsCompanion.insert(
                id: id,
                date: date,
                estimatedVo2Max: estimatedVo2Max,
                recoveryScore: recoveryScore,
                recoveryComponentRhr: recoveryComponentRhr,
                recoveryComponentSleep: recoveryComponentSleep,
                recoveryComponentSpo2: recoveryComponentSpo2,
                primaryFactor: primaryFactor,
                readinessConfidence: readinessConfidence,
                dataQuality: dataQuality,
                algorithmVersion: algorithmVersion,
                dayLoadScore: dayLoadScore,
                sleepScore: sleepScore,
                energyReserve: energyReserve,
                daytimeStress: daytimeStress,
                topDriversJson: topDriversJson,
                calculationBreakdownJson: calculationBreakdownJson,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DerivedMetricsTable, DerivedMetric>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DerivedMetricsTable,
                    DerivedMetric
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DerivedMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DerivedMetricsTable,
      DerivedMetric,
      $$DerivedMetricsTableFilterComposer,
      $$DerivedMetricsTableOrderingComposer,
      $$DerivedMetricsTableAnnotationComposer,
      $$DerivedMetricsTableCreateCompanionBuilder,
      $$DerivedMetricsTableUpdateCompanionBuilder,
      (
        DerivedMetric,
        BaseReferences<_$AppDatabase, $DerivedMetricsTable, DerivedMetric>,
      ),
      DerivedMetric,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      required String recordType,
      required DateTime lastSyncedAt,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<String> recordType,
      Value<DateTime> lastSyncedAt,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                recordType: recordType,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordType,
                required DateTime lastSyncedAt,
              }) => SyncMetadataCompanion.insert(
                id: id,
                recordType: recordType,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTable, SyncMetadataData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMetadataTable,
                    SyncMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$SyncLogsTableCreateCompanionBuilder = SyncLogsCompanion Function({
  Value<int> id,
  required DateTime timestamp,
  required String taskType,
  Value<int> recordsRead,
  Value<int> recordsWritten,
  Value<bool> success,
  Value<String?> errorMessage,
});
typedef $$SyncLogsTableUpdateCompanionBuilder = SyncLogsCompanion Function({
  Value<int> id,
  Value<DateTime> timestamp,
  Value<String> taskType,
  Value<int> recordsRead,
  Value<int> recordsWritten,
  Value<bool> success,
  Value<String?> errorMessage,
});

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsRead => $composableBuilder(
    column: $table.recordsRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsWritten => $composableBuilder(
    column: $table.recordsWritten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsRead => $composableBuilder(
    column: $table.recordsRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsWritten => $composableBuilder(
    column: $table.recordsWritten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<int> get recordsRead => $composableBuilder(
    column: $table.recordsRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordsWritten => $composableBuilder(
    column: $table.recordsWritten,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          SyncLog,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
          SyncLog,
          PrefetchHooks Function()
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<int> recordsRead = const Value.absent(),
                Value<int> recordsWritten = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                timestamp: timestamp,
                taskType: taskType,
                recordsRead: recordsRead,
                recordsWritten: recordsWritten,
                success: success,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required String taskType,
                Value<int> recordsRead = const Value.absent(),
                Value<int> recordsWritten = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                taskType: taskType,
                recordsRead: recordsRead,
                recordsWritten: recordsWritten,
                success: success,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncLogsTable, SyncLog>(table),
                  BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      SyncLog,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
      SyncLog,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<int> id,
      Value<String> userId,
      required DateTime measuredAt,
      required double weightKg,
      Value<double?> bodyFatPct,
      Value<String> source,
      Value<bool> synced,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> measuredAt,
      Value<double> weightKg,
      Value<double?> bodyFatPct,
      Value<String> source,
      Value<bool> synced,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurement,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurement
            >,
          ),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                userId: userId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                source: source,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required DateTime measuredAt,
                required double weightKg,
                Value<double?> bodyFatPct = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                userId: userId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                source: source,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyMeasurementsTable,
                    BodyMeasurement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurement,
        BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>,
      ),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$BodyAgeSnapshotsTableCreateCompanionBuilder =
    BodyAgeSnapshotsCompanion Function({
      Value<int> id,
      Value<String> userId,
      required DateTime calculatedAt,
      required double bodyAge,
      required int chronologicalAge,
      required String factorAgesJson,
      Value<bool> synced,
    });
typedef $$BodyAgeSnapshotsTableUpdateCompanionBuilder =
    BodyAgeSnapshotsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> calculatedAt,
      Value<double> bodyAge,
      Value<int> chronologicalAge,
      Value<String> factorAgesJson,
      Value<bool> synced,
    });

class $$BodyAgeSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyAgeSnapshotsTable> {
  $$BodyAgeSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyAge => $composableBuilder(
    column: $table.bodyAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chronologicalAge => $composableBuilder(
    column: $table.chronologicalAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factorAgesJson => $composableBuilder(
    column: $table.factorAgesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyAgeSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyAgeSnapshotsTable> {
  $$BodyAgeSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyAge => $composableBuilder(
    column: $table.bodyAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chronologicalAge => $composableBuilder(
    column: $table.chronologicalAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factorAgesJson => $composableBuilder(
    column: $table.factorAgesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyAgeSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyAgeSnapshotsTable> {
  $$BodyAgeSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bodyAge =>
      $composableBuilder(column: $table.bodyAge, builder: (column) => column);

  GeneratedColumn<int> get chronologicalAge => $composableBuilder(
    column: $table.chronologicalAge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get factorAgesJson => $composableBuilder(
    column: $table.factorAgesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BodyAgeSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyAgeSnapshotsTable,
          BodyAgeSnapshot,
          $$BodyAgeSnapshotsTableFilterComposer,
          $$BodyAgeSnapshotsTableOrderingComposer,
          $$BodyAgeSnapshotsTableAnnotationComposer,
          $$BodyAgeSnapshotsTableCreateCompanionBuilder,
          $$BodyAgeSnapshotsTableUpdateCompanionBuilder,
          (
            BodyAgeSnapshot,
            BaseReferences<
              _$AppDatabase,
              $BodyAgeSnapshotsTable,
              BodyAgeSnapshot
            >,
          ),
          BodyAgeSnapshot,
          PrefetchHooks Function()
        > {
  $$BodyAgeSnapshotsTableTableManager(
    _$AppDatabase db,
    $BodyAgeSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyAgeSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyAgeSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyAgeSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
                Value<double> bodyAge = const Value.absent(),
                Value<int> chronologicalAge = const Value.absent(),
                Value<String> factorAgesJson = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BodyAgeSnapshotsCompanion(
                id: id,
                userId: userId,
                calculatedAt: calculatedAt,
                bodyAge: bodyAge,
                chronologicalAge: chronologicalAge,
                factorAgesJson: factorAgesJson,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required DateTime calculatedAt,
                required double bodyAge,
                required int chronologicalAge,
                required String factorAgesJson,
                Value<bool> synced = const Value.absent(),
              }) => BodyAgeSnapshotsCompanion.insert(
                id: id,
                userId: userId,
                calculatedAt: calculatedAt,
                bodyAge: bodyAge,
                chronologicalAge: chronologicalAge,
                factorAgesJson: factorAgesJson,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyAgeSnapshotsTable, BodyAgeSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyAgeSnapshotsTable,
                    BodyAgeSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyAgeSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyAgeSnapshotsTable,
      BodyAgeSnapshot,
      $$BodyAgeSnapshotsTableFilterComposer,
      $$BodyAgeSnapshotsTableOrderingComposer,
      $$BodyAgeSnapshotsTableAnnotationComposer,
      $$BodyAgeSnapshotsTableCreateCompanionBuilder,
      $$BodyAgeSnapshotsTableUpdateCompanionBuilder,
      (
        BodyAgeSnapshot,
        BaseReferences<_$AppDatabase, $BodyAgeSnapshotsTable, BodyAgeSnapshot>,
      ),
      BodyAgeSnapshot,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int?> age,
      Value<String?> sex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<double?> bodyFatPct,
      Value<double?> maxHr,
      Value<double?> restingHrBaseline,
      Value<int> sleepNeedBaselineMinutes,
      Value<double?> targetStrain,
      Value<String> units,
      Value<String> timeZone,
      Value<int> timeZoneOffsetMinutes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int?> age,
      Value<String?> sex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<double?> bodyFatPct,
      Value<double?> maxHr,
      Value<double?> restingHrBaseline,
      Value<int> sleepNeedBaselineMinutes,
      Value<double?> targetStrain,
      Value<String> units,
      Value<String> timeZone,
      Value<int> timeZoneOffsetMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHrBaseline => $composableBuilder(
    column: $table.restingHrBaseline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepNeedBaselineMinutes => $composableBuilder(
    column: $table.sleepNeedBaselineMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetStrain => $composableBuilder(
    column: $table.targetStrain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHrBaseline => $composableBuilder(
    column: $table.restingHrBaseline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepNeedBaselineMinutes => $composableBuilder(
    column: $table.sleepNeedBaselineMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetStrain => $composableBuilder(
    column: $table.targetStrain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxHr =>
      $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<double> get restingHrBaseline => $composableBuilder(
    column: $table.restingHrBaseline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepNeedBaselineMinutes => $composableBuilder(
    column: $table.sleepNeedBaselineMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetStrain => $composableBuilder(
    column: $table.targetStrain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> maxHr = const Value.absent(),
                Value<double?> restingHrBaseline = const Value.absent(),
                Value<int> sleepNeedBaselineMinutes = const Value.absent(),
                Value<double?> targetStrain = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                userId: userId,
                age: age,
                sex: sex,
                heightCm: heightCm,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                maxHr: maxHr,
                restingHrBaseline: restingHrBaseline,
                sleepNeedBaselineMinutes: sleepNeedBaselineMinutes,
                targetStrain: targetStrain,
                units: units,
                timeZone: timeZone,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> maxHr = const Value.absent(),
                Value<double?> restingHrBaseline = const Value.absent(),
                Value<int> sleepNeedBaselineMinutes = const Value.absent(),
                Value<double?> targetStrain = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                userId: userId,
                age: age,
                sex: sex,
                heightCm: heightCm,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                maxHr: maxHr,
                restingHrBaseline: restingHrBaseline,
                sleepNeedBaselineMinutes: sleepNeedBaselineMinutes,
                targetStrain: targetStrain,
                units: units,
                timeZone: timeZone,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SleepSessionsTableCreateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      required DateTime startTime,
      required DateTime endTime,
      Value<int> timeZoneOffsetMinutes,
      required int durationMinutes,
      required int asleepMinutes,
      Value<int?> deepMinutes,
      Value<int?> lightMinutes,
      Value<int?> remMinutes,
      Value<int?> awakeMinutes,
      Value<double?> efficiency,
      Value<int?> disturbancesCount,
      Value<double?> respiratoryRate,
      Value<double?> restingHeartRate,
      Value<double?> hrvRmssd,
      Value<double?> spo2Average,
      Value<double?> spo2Min,
      Value<double?> skinTempDeviation,
      Value<bool> isNap,
      Value<String?> sourceDevice,
      Value<String> calculationMethod,
      Value<String> qualityFlag,
      required DateTime syncedAt,
    });
typedef $$SleepSessionsTableUpdateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<int> timeZoneOffsetMinutes,
      Value<int> durationMinutes,
      Value<int> asleepMinutes,
      Value<int?> deepMinutes,
      Value<int?> lightMinutes,
      Value<int?> remMinutes,
      Value<int?> awakeMinutes,
      Value<double?> efficiency,
      Value<int?> disturbancesCount,
      Value<double?> respiratoryRate,
      Value<double?> restingHeartRate,
      Value<double?> hrvRmssd,
      Value<double?> spo2Average,
      Value<double?> spo2Min,
      Value<double?> skinTempDeviation,
      Value<bool> isNap,
      Value<String?> sourceDevice,
      Value<String> calculationMethod,
      Value<String> qualityFlag,
      Value<DateTime> syncedAt,
    });

class $$SleepSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get asleepMinutes => $composableBuilder(
    column: $table.asleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get efficiency => $composableBuilder(
    column: $table.efficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disturbancesCount => $composableBuilder(
    column: $table.disturbancesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2Average => $composableBuilder(
    column: $table.spo2Average,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2Min => $composableBuilder(
    column: $table.spo2Min,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get skinTempDeviation => $composableBuilder(
    column: $table.skinTempDeviation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNap => $composableBuilder(
    column: $table.isNap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get asleepMinutes => $composableBuilder(
    column: $table.asleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get efficiency => $composableBuilder(
    column: $table.efficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disturbancesCount => $composableBuilder(
    column: $table.disturbancesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2Average => $composableBuilder(
    column: $table.spo2Average,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2Min => $composableBuilder(
    column: $table.spo2Min,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get skinTempDeviation => $composableBuilder(
    column: $table.skinTempDeviation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNap => $composableBuilder(
    column: $table.isNap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get asleepMinutes => $composableBuilder(
    column: $table.asleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get efficiency => $composableBuilder(
    column: $table.efficiency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get disturbancesCount => $composableBuilder(
    column: $table.disturbancesCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvRmssd =>
      $composableBuilder(column: $table.hrvRmssd, builder: (column) => column);

  GeneratedColumn<double> get spo2Average => $composableBuilder(
    column: $table.spo2Average,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spo2Min =>
      $composableBuilder(column: $table.spo2Min, builder: (column) => column);

  GeneratedColumn<double> get skinTempDeviation => $composableBuilder(
    column: $table.skinTempDeviation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNap =>
      $composableBuilder(column: $table.isNap, builder: (column) => column);

  GeneratedColumn<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SleepSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepSessionsTable,
          SleepSession,
          $$SleepSessionsTableFilterComposer,
          $$SleepSessionsTableOrderingComposer,
          $$SleepSessionsTableAnnotationComposer,
          $$SleepSessionsTableCreateCompanionBuilder,
          $$SleepSessionsTableUpdateCompanionBuilder,
          (
            SleepSession,
            BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSession>,
          ),
          SleepSession,
          PrefetchHooks Function()
        > {
  $$SleepSessionsTableTableManager(_$AppDatabase db, $SleepSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> asleepMinutes = const Value.absent(),
                Value<int?> deepMinutes = const Value.absent(),
                Value<int?> lightMinutes = const Value.absent(),
                Value<int?> remMinutes = const Value.absent(),
                Value<int?> awakeMinutes = const Value.absent(),
                Value<double?> efficiency = const Value.absent(),
                Value<int?> disturbancesCount = const Value.absent(),
                Value<double?> respiratoryRate = const Value.absent(),
                Value<double?> restingHeartRate = const Value.absent(),
                Value<double?> hrvRmssd = const Value.absent(),
                Value<double?> spo2Average = const Value.absent(),
                Value<double?> spo2Min = const Value.absent(),
                Value<double?> skinTempDeviation = const Value.absent(),
                Value<bool> isNap = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<String> calculationMethod = const Value.absent(),
                Value<String> qualityFlag = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SleepSessionsCompanion(
                id: id,
                userId: userId,
                startTime: startTime,
                endTime: endTime,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                durationMinutes: durationMinutes,
                asleepMinutes: asleepMinutes,
                deepMinutes: deepMinutes,
                lightMinutes: lightMinutes,
                remMinutes: remMinutes,
                awakeMinutes: awakeMinutes,
                efficiency: efficiency,
                disturbancesCount: disturbancesCount,
                respiratoryRate: respiratoryRate,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                spo2Average: spo2Average,
                spo2Min: spo2Min,
                skinTempDeviation: skinTempDeviation,
                isNap: isNap,
                sourceDevice: sourceDevice,
                calculationMethod: calculationMethod,
                qualityFlag: qualityFlag,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required DateTime startTime,
                required DateTime endTime,
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                required int durationMinutes,
                required int asleepMinutes,
                Value<int?> deepMinutes = const Value.absent(),
                Value<int?> lightMinutes = const Value.absent(),
                Value<int?> remMinutes = const Value.absent(),
                Value<int?> awakeMinutes = const Value.absent(),
                Value<double?> efficiency = const Value.absent(),
                Value<int?> disturbancesCount = const Value.absent(),
                Value<double?> respiratoryRate = const Value.absent(),
                Value<double?> restingHeartRate = const Value.absent(),
                Value<double?> hrvRmssd = const Value.absent(),
                Value<double?> spo2Average = const Value.absent(),
                Value<double?> spo2Min = const Value.absent(),
                Value<double?> skinTempDeviation = const Value.absent(),
                Value<bool> isNap = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<String> calculationMethod = const Value.absent(),
                Value<String> qualityFlag = const Value.absent(),
                required DateTime syncedAt,
              }) => SleepSessionsCompanion.insert(
                id: id,
                userId: userId,
                startTime: startTime,
                endTime: endTime,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                durationMinutes: durationMinutes,
                asleepMinutes: asleepMinutes,
                deepMinutes: deepMinutes,
                lightMinutes: lightMinutes,
                remMinutes: remMinutes,
                awakeMinutes: awakeMinutes,
                efficiency: efficiency,
                disturbancesCount: disturbancesCount,
                respiratoryRate: respiratoryRate,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                spo2Average: spo2Average,
                spo2Min: spo2Min,
                skinTempDeviation: skinTempDeviation,
                isNap: isNap,
                sourceDevice: sourceDevice,
                calculationMethod: calculationMethod,
                qualityFlag: qualityFlag,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepSessionsTable, SleepSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SleepSessionsTable,
                    SleepSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepSessionsTable,
      SleepSession,
      $$SleepSessionsTableFilterComposer,
      $$SleepSessionsTableOrderingComposer,
      $$SleepSessionsTableAnnotationComposer,
      $$SleepSessionsTableCreateCompanionBuilder,
      $$SleepSessionsTableUpdateCompanionBuilder,
      (
        SleepSession,
        BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSession>,
      ),
      SleepSession,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      required String sport,
      required String title,
      required DateTime startTime,
      required DateTime endTime,
      Value<int> timeZoneOffsetMinutes,
      required int durationMinutes,
      Value<double?> avgHeartRate,
      Value<double?> maxHeartRate,
      Value<double?> caloriesBurned,
      Value<double?> distanceMeters,
      Value<double?> elevationGainMeters,
      Value<int> zone1Minutes,
      Value<int> zone2Minutes,
      Value<int> zone3Minutes,
      Value<int> zone4Minutes,
      Value<int> zone5Minutes,
      Value<double> strainScore,
      Value<double> recoveryCost,
      Value<String?> sourceDevice,
      Value<String> qualityFlag,
      required DateTime syncedAt,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> sport,
      Value<String> title,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<int> timeZoneOffsetMinutes,
      Value<int> durationMinutes,
      Value<double?> avgHeartRate,
      Value<double?> maxHeartRate,
      Value<double?> caloriesBurned,
      Value<double?> distanceMeters,
      Value<double?> elevationGainMeters,
      Value<int> zone1Minutes,
      Value<int> zone2Minutes,
      Value<int> zone3Minutes,
      Value<int> zone4Minutes,
      Value<int> zone5Minutes,
      Value<double> strainScore,
      Value<double> recoveryCost,
      Value<String?> sourceDevice,
      Value<String> qualityFlag,
      Value<DateTime> syncedAt,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone1Minutes => $composableBuilder(
    column: $table.zone1Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone2Minutes => $composableBuilder(
    column: $table.zone2Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone3Minutes => $composableBuilder(
    column: $table.zone3Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone4Minutes => $composableBuilder(
    column: $table.zone4Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone5Minutes => $composableBuilder(
    column: $table.zone5Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strainScore => $composableBuilder(
    column: $table.strainScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryCost => $composableBuilder(
    column: $table.recoveryCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone1Minutes => $composableBuilder(
    column: $table.zone1Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone2Minutes => $composableBuilder(
    column: $table.zone2Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone3Minutes => $composableBuilder(
    column: $table.zone3Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone4Minutes => $composableBuilder(
    column: $table.zone4Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone5Minutes => $composableBuilder(
    column: $table.zone5Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strainScore => $composableBuilder(
    column: $table.strainScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryCost => $composableBuilder(
    column: $table.recoveryCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sport =>
      $composableBuilder(column: $table.sport, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone1Minutes => $composableBuilder(
    column: $table.zone1Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone2Minutes => $composableBuilder(
    column: $table.zone2Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone3Minutes => $composableBuilder(
    column: $table.zone3Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone4Minutes => $composableBuilder(
    column: $table.zone4Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone5Minutes => $composableBuilder(
    column: $table.zone5Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get strainScore => $composableBuilder(
    column: $table.strainScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryCost => $composableBuilder(
    column: $table.recoveryCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualityFlag => $composableBuilder(
    column: $table.qualityFlag,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSession
            >,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> sport = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<double?> avgHeartRate = const Value.absent(),
                Value<double?> maxHeartRate = const Value.absent(),
                Value<double?> caloriesBurned = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<int> zone1Minutes = const Value.absent(),
                Value<int> zone2Minutes = const Value.absent(),
                Value<int> zone3Minutes = const Value.absent(),
                Value<int> zone4Minutes = const Value.absent(),
                Value<int> zone5Minutes = const Value.absent(),
                Value<double> strainScore = const Value.absent(),
                Value<double> recoveryCost = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<String> qualityFlag = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                userId: userId,
                sport: sport,
                title: title,
                startTime: startTime,
                endTime: endTime,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                durationMinutes: durationMinutes,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                caloriesBurned: caloriesBurned,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                zone1Minutes: zone1Minutes,
                zone2Minutes: zone2Minutes,
                zone3Minutes: zone3Minutes,
                zone4Minutes: zone4Minutes,
                zone5Minutes: zone5Minutes,
                strainScore: strainScore,
                recoveryCost: recoveryCost,
                sourceDevice: sourceDevice,
                qualityFlag: qualityFlag,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required String sport,
                required String title,
                required DateTime startTime,
                required DateTime endTime,
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                required int durationMinutes,
                Value<double?> avgHeartRate = const Value.absent(),
                Value<double?> maxHeartRate = const Value.absent(),
                Value<double?> caloriesBurned = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<int> zone1Minutes = const Value.absent(),
                Value<int> zone2Minutes = const Value.absent(),
                Value<int> zone3Minutes = const Value.absent(),
                Value<int> zone4Minutes = const Value.absent(),
                Value<int> zone5Minutes = const Value.absent(),
                Value<double> strainScore = const Value.absent(),
                Value<double> recoveryCost = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<String> qualityFlag = const Value.absent(),
                required DateTime syncedAt,
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                userId: userId,
                sport: sport,
                title: title,
                startTime: startTime,
                endTime: endTime,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                durationMinutes: durationMinutes,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                caloriesBurned: caloriesBurned,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                zone1Minutes: zone1Minutes,
                zone2Minutes: zone2Minutes,
                zone3Minutes: zone3Minutes,
                zone4Minutes: zone4Minutes,
                zone5Minutes: zone5Minutes,
                strainScore: strainScore,
                recoveryCost: recoveryCost,
                sourceDevice: sourceDevice,
                qualityFlag: qualityFlag,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutSessionsTable,
                    WorkoutSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$BaselineSnapshotsTableCreateCompanionBuilder =
    BaselineSnapshotsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int> timeZoneOffsetMinutes,
      Value<double?> hrvBaseline7d,
      Value<double?> hrvBaseline60dMean,
      Value<double?> hrvBaseline60dSd,
      Value<double?> hrvCv7d,
      Value<double?> rawHrvBaseline7dMs,
      Value<double?> rhrBaseline7d,
      Value<double?> rhrBaseline30d,
      Value<double?> rhrBaseline60dMean,
      Value<double?> rhrBaseline60dSd,
      Value<double?> sleepDurationBaseline7d,
      Value<double?> sleepDurationBaseline60d,
      Value<double?> respiratoryRateBaseline7d,
      Value<double?> respiratoryRateBaseline60d,
      Value<double?> spo2Baseline7d,
      Value<double?> skinTempBaseline30d,
      Value<int> totalRecordedNights,
      required DateTime calculatedAt,
    });
typedef $$BaselineSnapshotsTableUpdateCompanionBuilder =
    BaselineSnapshotsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> timeZoneOffsetMinutes,
      Value<double?> hrvBaseline7d,
      Value<double?> hrvBaseline60dMean,
      Value<double?> hrvBaseline60dSd,
      Value<double?> hrvCv7d,
      Value<double?> rawHrvBaseline7dMs,
      Value<double?> rhrBaseline7d,
      Value<double?> rhrBaseline30d,
      Value<double?> rhrBaseline60dMean,
      Value<double?> rhrBaseline60dSd,
      Value<double?> sleepDurationBaseline7d,
      Value<double?> sleepDurationBaseline60d,
      Value<double?> respiratoryRateBaseline7d,
      Value<double?> respiratoryRateBaseline60d,
      Value<double?> spo2Baseline7d,
      Value<double?> skinTempBaseline30d,
      Value<int> totalRecordedNights,
      Value<DateTime> calculatedAt,
    });

class $$BaselineSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BaselineSnapshotsTable> {
  $$BaselineSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvBaseline7d => $composableBuilder(
    column: $table.hrvBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvBaseline60dMean => $composableBuilder(
    column: $table.hrvBaseline60dMean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvBaseline60dSd => $composableBuilder(
    column: $table.hrvBaseline60dSd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvCv7d => $composableBuilder(
    column: $table.hrvCv7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawHrvBaseline7dMs => $composableBuilder(
    column: $table.rawHrvBaseline7dMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rhrBaseline7d => $composableBuilder(
    column: $table.rhrBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rhrBaseline30d => $composableBuilder(
    column: $table.rhrBaseline30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rhrBaseline60dMean => $composableBuilder(
    column: $table.rhrBaseline60dMean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rhrBaseline60dSd => $composableBuilder(
    column: $table.rhrBaseline60dSd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepDurationBaseline60d => $composableBuilder(
    column: $table.sleepDurationBaseline60d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRateBaseline7d => $composableBuilder(
    column: $table.respiratoryRateBaseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRateBaseline60d => $composableBuilder(
    column: $table.respiratoryRateBaseline60d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get skinTempBaseline30d => $composableBuilder(
    column: $table.skinTempBaseline30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRecordedNights => $composableBuilder(
    column: $table.totalRecordedNights,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaselineSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BaselineSnapshotsTable> {
  $$BaselineSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvBaseline7d => $composableBuilder(
    column: $table.hrvBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvBaseline60dMean => $composableBuilder(
    column: $table.hrvBaseline60dMean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvBaseline60dSd => $composableBuilder(
    column: $table.hrvBaseline60dSd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvCv7d => $composableBuilder(
    column: $table.hrvCv7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawHrvBaseline7dMs => $composableBuilder(
    column: $table.rawHrvBaseline7dMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rhrBaseline7d => $composableBuilder(
    column: $table.rhrBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rhrBaseline30d => $composableBuilder(
    column: $table.rhrBaseline30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rhrBaseline60dMean => $composableBuilder(
    column: $table.rhrBaseline60dMean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rhrBaseline60dSd => $composableBuilder(
    column: $table.rhrBaseline60dSd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepDurationBaseline60d => $composableBuilder(
    column: $table.sleepDurationBaseline60d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRateBaseline7d => $composableBuilder(
    column: $table.respiratoryRateBaseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRateBaseline60d => $composableBuilder(
    column: $table.respiratoryRateBaseline60d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get skinTempBaseline30d => $composableBuilder(
    column: $table.skinTempBaseline30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRecordedNights => $composableBuilder(
    column: $table.totalRecordedNights,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaselineSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaselineSnapshotsTable> {
  $$BaselineSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvBaseline7d => $composableBuilder(
    column: $table.hrvBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvBaseline60dMean => $composableBuilder(
    column: $table.hrvBaseline60dMean,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvBaseline60dSd => $composableBuilder(
    column: $table.hrvBaseline60dSd,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvCv7d =>
      $composableBuilder(column: $table.hrvCv7d, builder: (column) => column);

  GeneratedColumn<double> get rawHrvBaseline7dMs => $composableBuilder(
    column: $table.rawHrvBaseline7dMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rhrBaseline7d => $composableBuilder(
    column: $table.rhrBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rhrBaseline30d => $composableBuilder(
    column: $table.rhrBaseline30d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rhrBaseline60dMean => $composableBuilder(
    column: $table.rhrBaseline60dMean,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rhrBaseline60dSd => $composableBuilder(
    column: $table.rhrBaseline60dSd,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepDurationBaseline7d => $composableBuilder(
    column: $table.sleepDurationBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepDurationBaseline60d => $composableBuilder(
    column: $table.sleepDurationBaseline60d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get respiratoryRateBaseline7d => $composableBuilder(
    column: $table.respiratoryRateBaseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get respiratoryRateBaseline60d => $composableBuilder(
    column: $table.respiratoryRateBaseline60d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spo2Baseline7d => $composableBuilder(
    column: $table.spo2Baseline7d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get skinTempBaseline30d => $composableBuilder(
    column: $table.skinTempBaseline30d,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRecordedNights => $composableBuilder(
    column: $table.totalRecordedNights,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );
}

class $$BaselineSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BaselineSnapshotsTable,
          BaselineSnapshot,
          $$BaselineSnapshotsTableFilterComposer,
          $$BaselineSnapshotsTableOrderingComposer,
          $$BaselineSnapshotsTableAnnotationComposer,
          $$BaselineSnapshotsTableCreateCompanionBuilder,
          $$BaselineSnapshotsTableUpdateCompanionBuilder,
          (
            BaselineSnapshot,
            BaseReferences<
              _$AppDatabase,
              $BaselineSnapshotsTable,
              BaselineSnapshot
            >,
          ),
          BaselineSnapshot,
          PrefetchHooks Function()
        > {
  $$BaselineSnapshotsTableTableManager(
    _$AppDatabase db,
    $BaselineSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaselineSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaselineSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaselineSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<double?> hrvBaseline7d = const Value.absent(),
                Value<double?> hrvBaseline60dMean = const Value.absent(),
                Value<double?> hrvBaseline60dSd = const Value.absent(),
                Value<double?> hrvCv7d = const Value.absent(),
                Value<double?> rawHrvBaseline7dMs = const Value.absent(),
                Value<double?> rhrBaseline7d = const Value.absent(),
                Value<double?> rhrBaseline30d = const Value.absent(),
                Value<double?> rhrBaseline60dMean = const Value.absent(),
                Value<double?> rhrBaseline60dSd = const Value.absent(),
                Value<double?> sleepDurationBaseline7d = const Value.absent(),
                Value<double?> sleepDurationBaseline60d = const Value.absent(),
                Value<double?> respiratoryRateBaseline7d = const Value.absent(),
                Value<double?> respiratoryRateBaseline60d =
                    const Value.absent(),
                Value<double?> spo2Baseline7d = const Value.absent(),
                Value<double?> skinTempBaseline30d = const Value.absent(),
                Value<int> totalRecordedNights = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
              }) => BaselineSnapshotsCompanion(
                id: id,
                date: date,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                hrvBaseline7d: hrvBaseline7d,
                hrvBaseline60dMean: hrvBaseline60dMean,
                hrvBaseline60dSd: hrvBaseline60dSd,
                hrvCv7d: hrvCv7d,
                rawHrvBaseline7dMs: rawHrvBaseline7dMs,
                rhrBaseline7d: rhrBaseline7d,
                rhrBaseline30d: rhrBaseline30d,
                rhrBaseline60dMean: rhrBaseline60dMean,
                rhrBaseline60dSd: rhrBaseline60dSd,
                sleepDurationBaseline7d: sleepDurationBaseline7d,
                sleepDurationBaseline60d: sleepDurationBaseline60d,
                respiratoryRateBaseline7d: respiratoryRateBaseline7d,
                respiratoryRateBaseline60d: respiratoryRateBaseline60d,
                spo2Baseline7d: spo2Baseline7d,
                skinTempBaseline30d: skinTempBaseline30d,
                totalRecordedNights: totalRecordedNights,
                calculatedAt: calculatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<double?> hrvBaseline7d = const Value.absent(),
                Value<double?> hrvBaseline60dMean = const Value.absent(),
                Value<double?> hrvBaseline60dSd = const Value.absent(),
                Value<double?> hrvCv7d = const Value.absent(),
                Value<double?> rawHrvBaseline7dMs = const Value.absent(),
                Value<double?> rhrBaseline7d = const Value.absent(),
                Value<double?> rhrBaseline30d = const Value.absent(),
                Value<double?> rhrBaseline60dMean = const Value.absent(),
                Value<double?> rhrBaseline60dSd = const Value.absent(),
                Value<double?> sleepDurationBaseline7d = const Value.absent(),
                Value<double?> sleepDurationBaseline60d = const Value.absent(),
                Value<double?> respiratoryRateBaseline7d = const Value.absent(),
                Value<double?> respiratoryRateBaseline60d =
                    const Value.absent(),
                Value<double?> spo2Baseline7d = const Value.absent(),
                Value<double?> skinTempBaseline30d = const Value.absent(),
                Value<int> totalRecordedNights = const Value.absent(),
                required DateTime calculatedAt,
              }) => BaselineSnapshotsCompanion.insert(
                id: id,
                date: date,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                hrvBaseline7d: hrvBaseline7d,
                hrvBaseline60dMean: hrvBaseline60dMean,
                hrvBaseline60dSd: hrvBaseline60dSd,
                hrvCv7d: hrvCv7d,
                rawHrvBaseline7dMs: rawHrvBaseline7dMs,
                rhrBaseline7d: rhrBaseline7d,
                rhrBaseline30d: rhrBaseline30d,
                rhrBaseline60dMean: rhrBaseline60dMean,
                rhrBaseline60dSd: rhrBaseline60dSd,
                sleepDurationBaseline7d: sleepDurationBaseline7d,
                sleepDurationBaseline60d: sleepDurationBaseline60d,
                respiratoryRateBaseline7d: respiratoryRateBaseline7d,
                respiratoryRateBaseline60d: respiratoryRateBaseline60d,
                spo2Baseline7d: spo2Baseline7d,
                skinTempBaseline30d: skinTempBaseline30d,
                totalRecordedNights: totalRecordedNights,
                calculatedAt: calculatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BaselineSnapshotsTable, BaselineSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BaselineSnapshotsTable,
                    BaselineSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaselineSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BaselineSnapshotsTable,
      BaselineSnapshot,
      $$BaselineSnapshotsTableFilterComposer,
      $$BaselineSnapshotsTableOrderingComposer,
      $$BaselineSnapshotsTableAnnotationComposer,
      $$BaselineSnapshotsTableCreateCompanionBuilder,
      $$BaselineSnapshotsTableUpdateCompanionBuilder,
      (
        BaselineSnapshot,
        BaseReferences<
          _$AppDatabase,
          $BaselineSnapshotsTable,
          BaselineSnapshot
        >,
      ),
      BaselineSnapshot,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      required DateTime date,
      required DateTime timestamp,
      Value<int> timeZoneOffsetMinutes,
      required String tag,
      Value<String?> value,
      Value<String?> notes,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<DateTime> timestamp,
      Value<int> timeZoneOffsetMinutes,
      Value<String> tag,
      Value<String?> value,
      Value<String?> notes,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get timeZoneOffsetMinutes => $composableBuilder(
    column: $table.timeZoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                userId: userId,
                date: date,
                timestamp: timestamp,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                tag: tag,
                value: value,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required DateTime date,
                required DateTime timestamp,
                Value<int> timeZoneOffsetMinutes = const Value.absent(),
                required String tag,
                Value<String?> value = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                timestamp: timestamp,
                timeZoneOffsetMinutes: timeZoneOffsetMinutes,
                tag: tag,
                value: value,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalEntriesTable, JournalEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalEntriesTable,
                    JournalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$InsightsTableCreateCompanionBuilder = InsightsCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime date,
  required String category,
  required String title,
  required String summary,
  Value<String?> actionableNudge,
  required String metricReferencesJson,
  Value<bool> isRead,
});
typedef $$InsightsTableUpdateCompanionBuilder = InsightsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> date,
  Value<String> category,
  Value<String> title,
  Value<String> summary,
  Value<String?> actionableNudge,
  Value<String> metricReferencesJson,
  Value<bool> isRead,
});

class $$InsightsTableFilterComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionableNudge => $composableBuilder(
    column: $table.actionableNudge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricReferencesJson => $composableBuilder(
    column: $table.metricReferencesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionableNudge => $composableBuilder(
    column: $table.actionableNudge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricReferencesJson => $composableBuilder(
    column: $table.metricReferencesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get actionableNudge => $composableBuilder(
    column: $table.actionableNudge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricReferencesJson => $composableBuilder(
    column: $table.metricReferencesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$InsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsightsTable,
          Insight,
          $$InsightsTableFilterComposer,
          $$InsightsTableOrderingComposer,
          $$InsightsTableAnnotationComposer,
          $$InsightsTableCreateCompanionBuilder,
          $$InsightsTableUpdateCompanionBuilder,
          (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
          Insight,
          PrefetchHooks Function()
        > {
  $$InsightsTableTableManager(_$AppDatabase db, $InsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> actionableNudge = const Value.absent(),
                Value<String> metricReferencesJson = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
              }) => InsightsCompanion(
                id: id,
                createdAt: createdAt,
                date: date,
                category: category,
                title: title,
                summary: summary,
                actionableNudge: actionableNudge,
                metricReferencesJson: metricReferencesJson,
                isRead: isRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime date,
                required String category,
                required String title,
                required String summary,
                Value<String?> actionableNudge = const Value.absent(),
                required String metricReferencesJson,
                Value<bool> isRead = const Value.absent(),
              }) => InsightsCompanion.insert(
                id: id,
                createdAt: createdAt,
                date: date,
                category: category,
                title: title,
                summary: summary,
                actionableNudge: actionableNudge,
                metricReferencesJson: metricReferencesJson,
                isRead: isRead,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InsightsTable, Insight>(table),
                  BaseReferences<_$AppDatabase, $InsightsTable, Insight>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsightsTable,
      Insight,
      $$InsightsTableFilterComposer,
      $$InsightsTableOrderingComposer,
      $$InsightsTableAnnotationComposer,
      $$InsightsTableCreateCompanionBuilder,
      $$InsightsTableUpdateCompanionBuilder,
      (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
      Insight,
      PrefetchHooks Function()
    >;
typedef $$DeviceConnectionsTableCreateCompanionBuilder =
    DeviceConnectionsCompanion Function({
      Value<int> id,
      required String deviceId,
      required String name,
      required String platform,
      Value<DateTime?> lastSyncTime,
      Value<int?> batteryLevel,
      Value<bool> isActive,
      Value<int> priority,
    });
typedef $$DeviceConnectionsTableUpdateCompanionBuilder =
    DeviceConnectionsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> name,
      Value<String> platform,
      Value<DateTime?> lastSyncTime,
      Value<int?> batteryLevel,
      Value<bool> isActive,
      Value<int> priority,
    });

class $$DeviceConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceConnectionsTable> {
  $$DeviceConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceConnectionsTable> {
  $$DeviceConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceConnectionsTable> {
  $$DeviceConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);
}

class $$DeviceConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceConnectionsTable,
          DeviceConnection,
          $$DeviceConnectionsTableFilterComposer,
          $$DeviceConnectionsTableOrderingComposer,
          $$DeviceConnectionsTableAnnotationComposer,
          $$DeviceConnectionsTableCreateCompanionBuilder,
          $$DeviceConnectionsTableUpdateCompanionBuilder,
          (
            DeviceConnection,
            BaseReferences<
              _$AppDatabase,
              $DeviceConnectionsTable,
              DeviceConnection
            >,
          ),
          DeviceConnection,
          PrefetchHooks Function()
        > {
  $$DeviceConnectionsTableTableManager(
    _$AppDatabase db,
    $DeviceConnectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceConnectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<DateTime?> lastSyncTime = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> priority = const Value.absent(),
              }) => DeviceConnectionsCompanion(
                id: id,
                deviceId: deviceId,
                name: name,
                platform: platform,
                lastSyncTime: lastSyncTime,
                batteryLevel: batteryLevel,
                isActive: isActive,
                priority: priority,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String name,
                required String platform,
                Value<DateTime?> lastSyncTime = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> priority = const Value.absent(),
              }) => DeviceConnectionsCompanion.insert(
                id: id,
                deviceId: deviceId,
                name: name,
                platform: platform,
                lastSyncTime: lastSyncTime,
                batteryLevel: batteryLevel,
                isActive: isActive,
                priority: priority,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceConnectionsTable, DeviceConnection>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceConnectionsTable,
                    DeviceConnection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceConnectionsTable,
      DeviceConnection,
      $$DeviceConnectionsTableFilterComposer,
      $$DeviceConnectionsTableOrderingComposer,
      $$DeviceConnectionsTableAnnotationComposer,
      $$DeviceConnectionsTableCreateCompanionBuilder,
      $$DeviceConnectionsTableUpdateCompanionBuilder,
      (
        DeviceConnection,
        BaseReferences<
          _$AppDatabase,
          $DeviceConnectionsTable,
          DeviceConnection
        >,
      ),
      DeviceConnection,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RawHealthRecordsTableTableManager get rawHealthRecords =>
      $$RawHealthRecordsTableTableManager(_db, _db.rawHealthRecords);
  $$DailyBaselinesTableTableManager get dailyBaselines =>
      $$DailyBaselinesTableTableManager(_db, _db.dailyBaselines);
  $$DerivedMetricsTableTableManager get derivedMetrics =>
      $$DerivedMetricsTableTableManager(_db, _db.derivedMetrics);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$BodyAgeSnapshotsTableTableManager get bodyAgeSnapshots =>
      $$BodyAgeSnapshotsTableTableManager(_db, _db.bodyAgeSnapshots);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SleepSessionsTableTableManager get sleepSessions =>
      $$SleepSessionsTableTableManager(_db, _db.sleepSessions);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$BaselineSnapshotsTableTableManager get baselineSnapshots =>
      $$BaselineSnapshotsTableTableManager(_db, _db.baselineSnapshots);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$InsightsTableTableManager get insights =>
      $$InsightsTableTableManager(_db, _db.insights);
  $$DeviceConnectionsTableTableManager get deviceConnections =>
      $$DeviceConnectionsTableTableManager(_db, _db.deviceConnections);
}
