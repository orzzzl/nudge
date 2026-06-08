// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TodosTable extends Todos with TableInfo<$TodosTable, TodoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notStarted'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('p2'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    seq,
    title,
    status,
    priority,
    dueDate,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  TodoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
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
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class TodoRow extends DataClass implements Insertable<TodoRow> {
  final int id;
  final int seq;
  final String title;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TodoRow({
    required this.id,
    required this.seq,
    required this.title,
    required this.status,
    required this.priority,
    this.dueDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seq'] = Variable<int>(seq);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      seq: Value(seq),
      title: Value(title),
      status: Value(status),
      priority: Value(priority),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TodoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoRow(
      id: serializer.fromJson<int>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seq': serializer.toJson<int>(seq),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TodoRow copyWith({
    int? id,
    int? seq,
    String? title,
    String? status,
    String? priority,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TodoRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    title: title ?? this.title,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TodoRow copyWithCompanion(TodosCompanion data) {
    return TodoRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    title,
    status,
    priority,
    dueDate,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.title == this.title &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TodosCompanion extends UpdateCompanion<TodoRow> {
  final Value<int> id;
  final Value<int> seq;
  final Value<String> title;
  final Value<String> status;
  final Value<String> priority;
  final Value<DateTime?> dueDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TodosCompanion.insert({
    this.id = const Value.absent(),
    required int seq,
    required String title,
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : seq = Value(seq),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TodoRow> custom({
    Expression<int>? id,
    Expression<int>? seq,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TodosCompanion copyWith({
    Value<int>? id,
    Value<int>? seq,
    Value<String>? title,
    Value<String>? status,
    Value<String>? priority,
    Value<DateTime?>? dueDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
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
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<int> todoId = GeneratedColumn<int>(
    'todo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES todos (id)',
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
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
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
    todoId,
    title,
    durationSec,
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
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
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
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}todo_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
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
  final int? todoId;
  final String title;
  final int durationSec;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? note;
  final String locale;
  final DateTime createdAt;
  const Plan({
    required this.id,
    this.todoId,
    required this.title,
    required this.durationSec,
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
    if (!nullToAbsent || todoId != null) {
      map['todo_id'] = Variable<int>(todoId);
    }
    map['title'] = Variable<String>(title);
    map['duration_sec'] = Variable<int>(durationSec);
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
      todoId: todoId == null && nullToAbsent
          ? const Value.absent()
          : Value(todoId),
      title: Value(title),
      durationSec: Value(durationSec),
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
      todoId: serializer.fromJson<int?>(json['todoId']),
      title: serializer.fromJson<String>(json['title']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
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
      'todoId': serializer.toJson<int?>(todoId),
      'title': serializer.toJson<String>(title),
      'durationSec': serializer.toJson<int>(durationSec),
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
    Value<int?> todoId = const Value.absent(),
    String? title,
    int? durationSec,
    DateTime? startAt,
    DateTime? endAt,
    String? status,
    Value<String?> note = const Value.absent(),
    String? locale,
    DateTime? createdAt,
  }) => Plan(
    id: id ?? this.id,
    todoId: todoId.present ? todoId.value : this.todoId,
    title: title ?? this.title,
    durationSec: durationSec ?? this.durationSec,
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
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      title: data.title.present ? data.title.value : this.title,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
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
          ..write('todoId: $todoId, ')
          ..write('title: $title, ')
          ..write('durationSec: $durationSec, ')
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
    todoId,
    title,
    durationSec,
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
          other.todoId == this.todoId &&
          other.title == this.title &&
          other.durationSec == this.durationSec &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.status == this.status &&
          other.note == this.note &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<int?> todoId;
  final Value<String> title;
  final Value<int> durationSec;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<String> status;
  final Value<String?> note;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    this.title = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    required String title,
    required int durationSec,
    required DateTime startAt,
    required DateTime endAt,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.locale = const Value.absent(),
    required DateTime createdAt,
  }) : title = Value(title),
       durationSec = Value(durationSec),
       startAt = Value(startAt),
       endAt = Value(endAt),
       createdAt = Value(createdAt);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<int>? todoId,
    Expression<String>? title,
    Expression<int>? durationSec,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (title != null) 'title': title,
      if (durationSec != null) 'duration_sec': durationSec,
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
    Value<int?>? todoId,
    Value<String>? title,
    Value<int>? durationSec,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<String>? status,
    Value<String?>? note,
    Value<String>? locale,
    Value<DateTime>? createdAt,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      title: title ?? this.title,
      durationSec: durationSec ?? this.durationSec,
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
    if (todoId.present) {
      map['todo_id'] = Variable<int>(todoId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
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
          ..write('todoId: $todoId, ')
          ..write('title: $title, ')
          ..write('durationSec: $durationSec, ')
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

class $TodoLogsTable extends TodoLogs
    with TableInfo<$TodoLogsTable, TodoLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<int> todoId = GeneratedColumn<int>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES todos (id)',
    ),
  );
  static const VerificationMeta _entryTextMeta = const VerificationMeta(
    'entryText',
  );
  @override
  late final GeneratedColumn<String> entryText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    todoId,
    entryText,
    kind,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _entryTextMeta,
        entryText.isAcceptableOrUnknown(data['text']!, _entryTextMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTextMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
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
  TodoLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}todo_id'],
      )!,
      entryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TodoLogsTable createAlias(String alias) {
    return $TodoLogsTable(attachedDatabase, alias);
  }
}

class TodoLogRow extends DataClass implements Insertable<TodoLogRow> {
  final int id;
  final int todoId;
  final String entryText;
  final String kind;
  final DateTime createdAt;
  const TodoLogRow({
    required this.id,
    required this.todoId,
    required this.entryText,
    required this.kind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['todo_id'] = Variable<int>(todoId);
    map['text'] = Variable<String>(entryText);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TodoLogsCompanion toCompanion(bool nullToAbsent) {
    return TodoLogsCompanion(
      id: Value(id),
      todoId: Value(todoId),
      entryText: Value(entryText),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory TodoLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoLogRow(
      id: serializer.fromJson<int>(json['id']),
      todoId: serializer.fromJson<int>(json['todoId']),
      entryText: serializer.fromJson<String>(json['entryText']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'todoId': serializer.toJson<int>(todoId),
      'entryText': serializer.toJson<String>(entryText),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TodoLogRow copyWith({
    int? id,
    int? todoId,
    String? entryText,
    String? kind,
    DateTime? createdAt,
  }) => TodoLogRow(
    id: id ?? this.id,
    todoId: todoId ?? this.todoId,
    entryText: entryText ?? this.entryText,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
  );
  TodoLogRow copyWithCompanion(TodoLogsCompanion data) {
    return TodoLogRow(
      id: data.id.present ? data.id.value : this.id,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      entryText: data.entryText.present ? data.entryText.value : this.entryText,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoLogRow(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('entryText: $entryText, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, todoId, entryText, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoLogRow &&
          other.id == this.id &&
          other.todoId == this.todoId &&
          other.entryText == this.entryText &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class TodoLogsCompanion extends UpdateCompanion<TodoLogRow> {
  final Value<int> id;
  final Value<int> todoId;
  final Value<String> entryText;
  final Value<String> kind;
  final Value<DateTime> createdAt;
  const TodoLogsCompanion({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    this.entryText = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TodoLogsCompanion.insert({
    this.id = const Value.absent(),
    required int todoId,
    required String entryText,
    required String kind,
    required DateTime createdAt,
  }) : todoId = Value(todoId),
       entryText = Value(entryText),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<TodoLogRow> custom({
    Expression<int>? id,
    Expression<int>? todoId,
    Expression<String>? entryText,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (entryText != null) 'text': entryText,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TodoLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? todoId,
    Value<String>? entryText,
    Value<String>? kind,
    Value<DateTime>? createdAt,
  }) {
    return TodoLogsCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      entryText: entryText ?? this.entryText,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<int>(todoId.value);
    }
    if (entryText.present) {
      map['text'] = Variable<String>(entryText.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoLogsCompanion(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('entryText: $entryText, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PetConfigsTable petConfigs = $PetConfigsTable(this);
  late final $TodoLogsTable todoLogs = $TodoLogsTable(this);
  late final PlansDao plansDao = PlansDao(this as AppDatabase);
  late final TodosDao todosDao = TodosDao(this as AppDatabase);
  late final TodoLogsDao todoLogsDao = TodoLogsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    todos,
    plans,
    petConfigs,
    todoLogs,
  ];
}

typedef $$TodosTableCreateCompanionBuilder =
    TodosCompanion Function({
      Value<int> id,
      required int seq,
      required String title,
      Value<String> status,
      Value<String> priority,
      Value<DateTime?> dueDate,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TodosTableUpdateCompanionBuilder =
    TodosCompanion Function({
      Value<int> id,
      Value<int> seq,
      Value<String> title,
      Value<String> status,
      Value<String> priority,
      Value<DateTime?> dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TodosTableReferences
    extends BaseReferences<_$AppDatabase, $TodosTable, TodoRow> {
  $$TodosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlansTable, List<Plan>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: $_aliasNameGenerator(db.todos.id, db.plans.todoId),
  );

  $$PlansTableProcessedTableManager get plansRefs {
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.todoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TodoLogsTable, List<TodoLogRow>>
  _todoLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.todoLogs,
    aliasName: $_aliasNameGenerator(db.todos.id, db.todoLogs.todoId),
  );

  $$TodoLogsTableProcessedTableManager get todoLogsRefs {
    final manager = $$TodoLogsTableTableManager(
      $_db,
      $_db.todoLogs,
    ).filter((f) => f.todoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_todoLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TodosTableFilterComposer extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  Expression<bool> plansRefs(
    Expression<bool> Function($$PlansTableFilterComposer f) f,
  ) {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> todoLogsRefs(
    Expression<bool> Function($$TodoLogsTableFilterComposer f) f,
  ) {
    final $$TodoLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoLogs,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoLogsTableFilterComposer(
            $db: $db,
            $table: $db.todoLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

class $$TodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($$PlansTableAnnotationComposer a) f,
  ) {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> todoLogsRefs<T extends Object>(
    Expression<T> Function($$TodoLogsTableAnnotationComposer a) f,
  ) {
    final $$TodoLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoLogs,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.todoLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTable,
          TodoRow,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (TodoRow, $$TodosTableReferences),
          TodoRow,
          PrefetchHooks Function({bool plansRefs, bool todoLogsRefs})
        > {
  $$TodosTableTableManager(_$AppDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                seq: seq,
                title: title,
                status: status,
                priority: priority,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int seq,
                required String title,
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TodosCompanion.insert(
                id: id,
                seq: seq,
                title: title,
                status: status,
                priority: priority,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TodosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({plansRefs = false, todoLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (plansRefs) db.plans,
                if (todoLogsRefs) db.todoLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plansRefs)
                    await $_getPrefetchedData<TodoRow, $TodosTable, Plan>(
                      currentTable: table,
                      referencedTable: $$TodosTableReferences._plansRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TodosTableReferences(db, table, p0).plansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.todoId == item.id),
                      typedResults: items,
                    ),
                  if (todoLogsRefs)
                    await $_getPrefetchedData<TodoRow, $TodosTable, TodoLogRow>(
                      currentTable: table,
                      referencedTable: $$TodosTableReferences
                          ._todoLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TodosTableReferences(db, table, p0).todoLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.todoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTable,
      TodoRow,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (TodoRow, $$TodosTableReferences),
      TodoRow,
      PrefetchHooks Function({bool plansRefs, bool todoLogsRefs})
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      Value<int?> todoId,
      required String title,
      required int durationSec,
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
      Value<int?> todoId,
      Value<String> title,
      Value<int> durationSec,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<String> status,
      Value<String?> note,
      Value<String> locale,
      Value<DateTime> createdAt,
    });

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TodosTable _todoIdTable(_$AppDatabase db) =>
      db.todos.createAlias($_aliasNameGenerator(db.plans.todoId, db.todos.id));

  $$TodosTableProcessedTableManager? get todoId {
    final $_column = $_itemColumn<int>('todo_id');
    if ($_column == null) return null;
    final manager = $$TodosTableTableManager(
      $_db,
      $_db.todos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_todoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
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

  $$TodosTableFilterComposer get todoId {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
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

  $$TodosTableOrderingComposer get todoId {
    final $$TodosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableOrderingComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
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

  $$TodosTableAnnotationComposer get todoId {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Plan, $$PlansTableReferences),
          Plan,
          PrefetchHooks Function({bool todoId})
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
                Value<int?> todoId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                todoId: todoId,
                title: title,
                durationSec: durationSec,
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
                Value<int?> todoId = const Value.absent(),
                required String title,
                required int durationSec,
                required DateTime startAt,
                required DateTime endAt,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> locale = const Value.absent(),
                required DateTime createdAt,
              }) => PlansCompanion.insert(
                id: id,
                todoId: todoId,
                title: title,
                durationSec: durationSec,
                startAt: startAt,
                endAt: endAt,
                status: status,
                note: note,
                locale: locale,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({todoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (todoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.todoId,
                                referencedTable: $$PlansTableReferences
                                    ._todoIdTable(db),
                                referencedColumn: $$PlansTableReferences
                                    ._todoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (Plan, $$PlansTableReferences),
      Plan,
      PrefetchHooks Function({bool todoId})
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
typedef $$TodoLogsTableCreateCompanionBuilder =
    TodoLogsCompanion Function({
      Value<int> id,
      required int todoId,
      required String entryText,
      required String kind,
      required DateTime createdAt,
    });
typedef $$TodoLogsTableUpdateCompanionBuilder =
    TodoLogsCompanion Function({
      Value<int> id,
      Value<int> todoId,
      Value<String> entryText,
      Value<String> kind,
      Value<DateTime> createdAt,
    });

final class $$TodoLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TodoLogsTable, TodoLogRow> {
  $$TodoLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TodosTable _todoIdTable(_$AppDatabase db) => db.todos.createAlias(
    $_aliasNameGenerator(db.todoLogs.todoId, db.todos.id),
  );

  $$TodosTableProcessedTableManager get todoId {
    final $_column = $_itemColumn<int>('todo_id')!;

    final manager = $$TodosTableTableManager(
      $_db,
      $_db.todos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_todoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TodoLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoLogsTable> {
  $$TodoLogsTableFilterComposer({
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

  ColumnFilters<String> get entryText => $composableBuilder(
    column: $table.entryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TodosTableFilterComposer get todoId {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoLogsTable> {
  $$TodoLogsTableOrderingComposer({
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

  ColumnOrderings<String> get entryText => $composableBuilder(
    column: $table.entryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TodosTableOrderingComposer get todoId {
    final $$TodosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableOrderingComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoLogsTable> {
  $$TodoLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryText =>
      $composableBuilder(column: $table.entryText, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TodosTableAnnotationComposer get todoId {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoLogsTable,
          TodoLogRow,
          $$TodoLogsTableFilterComposer,
          $$TodoLogsTableOrderingComposer,
          $$TodoLogsTableAnnotationComposer,
          $$TodoLogsTableCreateCompanionBuilder,
          $$TodoLogsTableUpdateCompanionBuilder,
          (TodoLogRow, $$TodoLogsTableReferences),
          TodoLogRow,
          PrefetchHooks Function({bool todoId})
        > {
  $$TodoLogsTableTableManager(_$AppDatabase db, $TodoLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> todoId = const Value.absent(),
                Value<String> entryText = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TodoLogsCompanion(
                id: id,
                todoId: todoId,
                entryText: entryText,
                kind: kind,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int todoId,
                required String entryText,
                required String kind,
                required DateTime createdAt,
              }) => TodoLogsCompanion.insert(
                id: id,
                todoId: todoId,
                entryText: entryText,
                kind: kind,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TodoLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (todoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.todoId,
                                referencedTable: $$TodoLogsTableReferences
                                    ._todoIdTable(db),
                                referencedColumn: $$TodoLogsTableReferences
                                    ._todoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TodoLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoLogsTable,
      TodoLogRow,
      $$TodoLogsTableFilterComposer,
      $$TodoLogsTableOrderingComposer,
      $$TodoLogsTableAnnotationComposer,
      $$TodoLogsTableCreateCompanionBuilder,
      $$TodoLogsTableUpdateCompanionBuilder,
      (TodoLogRow, $$TodoLogsTableReferences),
      TodoLogRow,
      PrefetchHooks Function({bool todoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PetConfigsTableTableManager get petConfigs =>
      $$PetConfigsTableTableManager(_db, _db.petConfigs);
  $$TodoLogsTableTableManager get todoLogs =>
      $$TodoLogsTableTableManager(_db, _db.todoLogs);
}

mixin _$PlansDaoMixin on DatabaseAccessor<AppDatabase> {
  $TodosTable get todos => attachedDatabase.todos;
  $PlansTable get plans => attachedDatabase.plans;
  PlansDaoManager get managers => PlansDaoManager(this);
}

class PlansDaoManager {
  final _$PlansDaoMixin _db;
  PlansDaoManager(this._db);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db.attachedDatabase, _db.todos);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db.attachedDatabase, _db.plans);
}

mixin _$TodosDaoMixin on DatabaseAccessor<AppDatabase> {
  $TodosTable get todos => attachedDatabase.todos;
  $PlansTable get plans => attachedDatabase.plans;
  TodosDaoManager get managers => TodosDaoManager(this);
}

class TodosDaoManager {
  final _$TodosDaoMixin _db;
  TodosDaoManager(this._db);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db.attachedDatabase, _db.todos);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db.attachedDatabase, _db.plans);
}

mixin _$TodoLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TodosTable get todos => attachedDatabase.todos;
  $TodoLogsTable get todoLogs => attachedDatabase.todoLogs;
  TodoLogsDaoManager get managers => TodoLogsDaoManager(this);
}

class TodoLogsDaoManager {
  final _$TodoLogsDaoMixin _db;
  TodoLogsDaoManager(this._db);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db.attachedDatabase, _db.todos);
  $$TodoLogsTableTableManager get todoLogs =>
      $$TodoLogsTableTableManager(_db.attachedDatabase, _db.todoLogs);
}
