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
  const DerivedMetric({
    required this.id,
    required this.date,
    this.estimatedVo2Max,
    this.recoveryScore,
    this.recoveryComponentRhr,
    this.recoveryComponentSleep,
    this.recoveryComponentSpo2,
    this.primaryFactor,
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
          ..write('primaryFactor: $primaryFactor')
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
          other.primaryFactor == this.primaryFactor);
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
  const DerivedMetricsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.estimatedVo2Max = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.recoveryComponentRhr = const Value.absent(),
    this.recoveryComponentSleep = const Value.absent(),
    this.recoveryComponentSpo2 = const Value.absent(),
    this.primaryFactor = const Value.absent(),
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
          ..write('primaryFactor: $primaryFactor')
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
              }) => DerivedMetricsCompanion(
                id: id,
                date: date,
                estimatedVo2Max: estimatedVo2Max,
                recoveryScore: recoveryScore,
                recoveryComponentRhr: recoveryComponentRhr,
                recoveryComponentSleep: recoveryComponentSleep,
                recoveryComponentSpo2: recoveryComponentSpo2,
                primaryFactor: primaryFactor,
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
              }) => DerivedMetricsCompanion.insert(
                id: id,
                date: date,
                estimatedVo2Max: estimatedVo2Max,
                recoveryScore: recoveryScore,
                recoveryComponentRhr: recoveryComponentRhr,
                recoveryComponentSleep: recoveryComponentSleep,
                recoveryComponentSpo2: recoveryComponentSpo2,
                primaryFactor: primaryFactor,
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
}
