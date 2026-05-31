// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('running'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('zh'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    durationMin,
    startAt,
    endAt,
    status,
    note,
    locale,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final int id;
  final String title;
  final int durationMin;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? note;
  final String locale;
  final DateTime createdAt;
  const Plan({
    required this.id,
    required this.title,
    required this.durationMin,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.note,
    required this.locale,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['duration_min'] = Variable<int>(durationMin);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      title: Value(title),
      durationMin: Value(durationMin),
      startAt: Value(startAt),
      endAt: Value(endAt),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      locale: Value(locale),
      createdAt: Value(createdAt),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'durationMin': serializer.toJson<int>(durationMin),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Plan copyWith({
    int? id,
    String? title,
    int? durationMin,
    DateTime? startAt,
    DateTime? endAt,
    String? status,
    Value<String?> note = const Value.absent(),
    String? locale,
    DateTime? createdAt,
  }) => Plan(
    id: id ?? this.id,
    title: title ?? this.title,
    durationMin: durationMin ?? this.durationMin,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
  );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('durationMin: $durationMin, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    durationMin,
    startAt,
    endAt,
    status,
    note,
    locale,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.title == this.title &&
          other.durationMin == this.durationMin &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.status == this.status &&
          other.note == this.note &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> durationMin;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<String> status;
  final Value<String?> note;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int durationMin,
    required DateTime startAt,
    required DateTime endAt,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.locale = const Value.absent(),
    required DateTime createdAt,
  }) : title = Value(title),
       durationMin = Value(durationMin),
       startAt = Value(startAt),
       endAt = Value(endAt),
       createdAt = Value(createdAt);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? durationMin,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (durationMin != null) 'duration_min': durationMin,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlansCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? durationMin,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<String>? status,
    Value<String?>? note,
    Value<String>? locale,
    Value<DateTime>? createdAt,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMin: durationMin ?? this.durationMin,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      note: note ?? this.note,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('durationMin: $durationMin, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PetConfigsTable extends PetConfigs
    with TableInfo<$PetConfigsTable, PetConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetConfigsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _schemaVerMeta = const VerificationMeta(
    'schemaVer',
  );
  @override
  late final GeneratedColumn<int> schemaVer = GeneratedColumn<int>(
    'schema_ver',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  List<GeneratedColumn> get $columns => [id, schemaVer, configJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pet_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PetConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_ver')) {
      context.handle(
        _schemaVerMeta,
        schemaVer.isAcceptableOrUnknown(data['schema_ver']!, _schemaVerMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
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
  PetConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PetConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      schemaVer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_ver'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PetConfigsTable createAlias(String alias) {
    return $PetConfigsTable(attachedDatabase, alias);
  }
}

class PetConfig extends DataClass implements Insertable<PetConfig> {
  final int id;
  final int schemaVer;
  final String configJson;
  final DateTime updatedAt;
  const PetConfig({
    required this.id,
    required this.schemaVer,
    required this.configJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_ver'] = Variable<int>(schemaVer);
    map['config_json'] = Variable<String>(configJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PetConfigsCompanion toCompanion(bool nullToAbsent) {
    return PetConfigsCompanion(
      id: Value(id),
      schemaVer: Value(schemaVer),
      configJson: Value(configJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory PetConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PetConfig(
      id: serializer.fromJson<int>(json['id']),
      schemaVer: serializer.fromJson<int>(json['schemaVer']),
      configJson: serializer.fromJson<String>(json['configJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVer': serializer.toJson<int>(schemaVer),
      'configJson': serializer.toJson<String>(configJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PetConfig copyWith({
    int? id,
    int? schemaVer,
    String? configJson,
    DateTime? updatedAt,
  }) => PetConfig(
    id: id ?? this.id,
    schemaVer: schemaVer ?? this.schemaVer,
    configJson: configJson ?? this.configJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PetConfig copyWithCompanion(PetConfigsCompanion data) {
    return PetConfig(
      id: data.id.present ? data.id.value : this.id,
      schemaVer: data.schemaVer.present ? data.schemaVer.value : this.schemaVer,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PetConfig(')
          ..write('id: $id, ')
          ..write('schemaVer: $schemaVer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schemaVer, configJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PetConfig &&
          other.id == this.id &&
          other.schemaVer == this.schemaVer &&
          other.configJson == this.configJson &&
          other.updatedAt == this.updatedAt);
}

class PetConfigsCompanion extends UpdateCompanion<PetConfig> {
  final Value<int> id;
  final Value<int> schemaVer;
  final Value<String> configJson;
  final Value<DateTime> updatedAt;
  const PetConfigsCompanion({
    this.id = const Value.absent(),
    this.schemaVer = const Value.absent(),
    this.configJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PetConfigsCompanion.insert({
    this.id = const Value.absent(),
    this.schemaVer = const Value.absent(),
    required String configJson,
    required DateTime updatedAt,
  }) : configJson = Value(configJson),
       updatedAt = Value(updatedAt);
  static Insertable<PetConfig> custom({
    Expression<int>? id,
    Expression<int>? schemaVer,
    Expression<String>? configJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVer != null) 'schema_ver': schemaVer,
      if (configJson != null) 'config_json': configJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PetConfigsCompanion copyWith({
    Value<int>? id,
    Value<int>? schemaVer,
    Value<String>? configJson,
    Value<DateTime>? updatedAt,
  }) {
    return PetConfigsCompanion(
      id: id ?? this.id,
      schemaVer: schemaVer ?? this.schemaVer,
      configJson: configJson ?? this.configJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVer.present) {
      map['schema_ver'] = Variable<int>(schemaVer.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetConfigsCompanion(')
          ..write('id: $id, ')
          ..write('schemaVer: $schemaVer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PetConfigsTable petConfigs = $PetConfigsTable(this);
  late final PlansDao plansDao = PlansDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [plans, petConfigs];
}

typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      required String title,
      required int durationMin,
      required DateTime startAt,
      required DateTime endAt,
      Value<String> status,
      Value<String?> note,
      Value<String> locale,
      required DateTime createdAt,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> durationMin,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<String> status,
      Value<String?> note,
      Value<String> locale,
      Value<DateTime> createdAt,
    });

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          Plan,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (Plan, BaseReferences<_$AppDatabase, $PlansTable, Plan>),
          Plan,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                title: title,
                durationMin: durationMin,
                startAt: startAt,
                endAt: endAt,
                status: status,
                note: note,
                locale: locale,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int durationMin,
                required DateTime startAt,
                required DateTime endAt,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> locale = const Value.absent(),
                required DateTime createdAt,
              }) => PlansCompanion.insert(
                id: id,
                title: title,
                durationMin: durationMin,
                startAt: startAt,
                endAt: endAt,
                status: status,
                note: note,
                locale: locale,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      Plan,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (Plan, BaseReferences<_$AppDatabase, $PlansTable, Plan>),
      Plan,
      PrefetchHooks Function()
    >;
typedef $$PetConfigsTableCreateCompanionBuilder =
    PetConfigsCompanion Function({
      Value<int> id,
      Value<int> schemaVer,
      required String configJson,
      required DateTime updatedAt,
    });
typedef $$PetConfigsTableUpdateCompanionBuilder =
    PetConfigsCompanion Function({
      Value<int> id,
      Value<int> schemaVer,
      Value<String> configJson,
      Value<DateTime> updatedAt,
    });

class $$PetConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $PetConfigsTable> {
  $$PetConfigsTableFilterComposer({
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

  ColumnFilters<int> get schemaVer => $composableBuilder(
    column: $table.schemaVer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PetConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $PetConfigsTable> {
  $$PetConfigsTableOrderingComposer({
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

  ColumnOrderings<int> get schemaVer => $composableBuilder(
    column: $table.schemaVer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetConfigsTable> {
  $$PetConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVer =>
      $composableBuilder(column: $table.schemaVer, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PetConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetConfigsTable,
          PetConfig,
          $$PetConfigsTableFilterComposer,
          $$PetConfigsTableOrderingComposer,
          $$PetConfigsTableAnnotationComposer,
          $$PetConfigsTableCreateCompanionBuilder,
          $$PetConfigsTableUpdateCompanionBuilder,
          (
            PetConfig,
            BaseReferences<_$AppDatabase, $PetConfigsTable, PetConfig>,
          ),
          PetConfig,
          PrefetchHooks Function()
        > {
  $$PetConfigsTableTableManager(_$AppDatabase db, $PetConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVer = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PetConfigsCompanion(
                id: id,
                schemaVer: schemaVer,
                configJson: configJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVer = const Value.absent(),
                required String configJson,
                required DateTime updatedAt,
              }) => PetConfigsCompanion.insert(
                id: id,
                schemaVer: schemaVer,
                configJson: configJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PetConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetConfigsTable,
      PetConfig,
      $$PetConfigsTableFilterComposer,
      $$PetConfigsTableOrderingComposer,
      $$PetConfigsTableAnnotationComposer,
      $$PetConfigsTableCreateCompanionBuilder,
      $$PetConfigsTableUpdateCompanionBuilder,
      (PetConfig, BaseReferences<_$AppDatabase, $PetConfigsTable, PetConfig>),
      PetConfig,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PetConfigsTableTableManager get petConfigs =>
      $$PetConfigsTableTableManager(_db, _db.petConfigs);
}

mixin _$PlansDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlansTable get plans => attachedDatabase.plans;
  PlansDaoManager get managers => PlansDaoManager(this);
}

class PlansDaoManager {
  final _$PlansDaoMixin _db;
  PlansDaoManager(this._db);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db.attachedDatabase, _db.plans);
}
