// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppPrefsTable extends AppPrefs with TableInfo<$AppPrefsTable, AppPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPref(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppPrefsTable createAlias(String alias) {
    return $AppPrefsTable(attachedDatabase, alias);
  }
}

class AppPref extends DataClass implements Insertable<AppPref> {
  final String key;
  final String value;
  const AppPref({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppPrefsCompanion toCompanion(bool nullToAbsent) {
    return AppPrefsCompanion(key: Value(key), value: Value(value));
  }

  factory AppPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPref(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppPref copyWith({String? key, String? value}) =>
      AppPref(key: key ?? this.key, value: value ?? this.value);
  AppPref copyWithCompanion(AppPrefsCompanion data) {
    return AppPref(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPref(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPref && other.key == this.key && other.value == this.value);
}

class AppPrefsCompanion extends UpdateCompanion<AppPref> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppPrefsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPrefsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppPref> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPrefsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppPrefsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPrefsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanRecordsTable extends ScanRecords
    with TableInfo<$ScanRecordsTable, ScanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chosenFabricIdMeta = const VerificationMeta(
    'chosenFabricId',
  );
  @override
  late final GeneratedColumn<String> chosenFabricId = GeneratedColumn<String>(
    'chosen_fabric_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topKJsonMeta = const VerificationMeta(
    'topKJson',
  );
  @override
  late final GeneratedColumn<String> topKJson = GeneratedColumn<String>(
    'top_k_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    createdAt,
    updatedAt,
    deletedAt,
    source,
    outcome,
    chosenFabricId,
    confidence,
    topKJson,
    thumbnailPath,
    modelVersion,
    contentVersion,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('chosen_fabric_id')) {
      context.handle(
        _chosenFabricIdMeta,
        chosenFabricId.isAcceptableOrUnknown(
          data['chosen_fabric_id']!,
          _chosenFabricIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chosenFabricIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('top_k_json')) {
      context.handle(
        _topKJsonMeta,
        topKJson.isAcceptableOrUnknown(data['top_k_json']!, _topKJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_topKJsonMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailPathMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      chosenFabricId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chosen_fabric_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      topKJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_k_json'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ScanRecordsTable createAlias(String alias) {
    return $ScanRecordsTable(attachedDatabase, alias);
  }
}

class ScanRecord extends DataClass implements Insertable<ScanRecord> {
  final String id;

  /// Null = guest scan, kept on this phone only.
  final String? ownerUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft-delete marker for synced accounts (ADR-005).
  final DateTime? deletedAt;

  /// camera | gallery
  final String source;

  /// A | B
  final String outcome;
  final String chosenFabricId;

  /// high | possible | notSure — the word shown in History.
  final String confidence;

  /// `[{fabricId, score}]` × up to 3.
  final String topKJson;

  /// 256 px JPEG in the app's documents folder. Full photos are never kept.
  final String thumbnailPath;
  final String modelVersion;
  final String contentVersion;

  /// local | pending | synced
  final String syncStatus;
  const ScanRecord({
    required this.id,
    this.ownerUid,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.source,
    required this.outcome,
    required this.chosenFabricId,
    required this.confidence,
    required this.topKJson,
    required this.thumbnailPath,
    required this.modelVersion,
    required this.contentVersion,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['source'] = Variable<String>(source);
    map['outcome'] = Variable<String>(outcome);
    map['chosen_fabric_id'] = Variable<String>(chosenFabricId);
    map['confidence'] = Variable<String>(confidence);
    map['top_k_json'] = Variable<String>(topKJson);
    map['thumbnail_path'] = Variable<String>(thumbnailPath);
    map['model_version'] = Variable<String>(modelVersion);
    map['content_version'] = Variable<String>(contentVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ScanRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScanRecordsCompanion(
      id: Value(id),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      source: Value(source),
      outcome: Value(outcome),
      chosenFabricId: Value(chosenFabricId),
      confidence: Value(confidence),
      topKJson: Value(topKJson),
      thumbnailPath: Value(thumbnailPath),
      modelVersion: Value(modelVersion),
      contentVersion: Value(contentVersion),
      syncStatus: Value(syncStatus),
    );
  }

  factory ScanRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRecord(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      source: serializer.fromJson<String>(json['source']),
      outcome: serializer.fromJson<String>(json['outcome']),
      chosenFabricId: serializer.fromJson<String>(json['chosenFabricId']),
      confidence: serializer.fromJson<String>(json['confidence']),
      topKJson: serializer.fromJson<String>(json['topKJson']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      contentVersion: serializer.fromJson<String>(json['contentVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'source': serializer.toJson<String>(source),
      'outcome': serializer.toJson<String>(outcome),
      'chosenFabricId': serializer.toJson<String>(chosenFabricId),
      'confidence': serializer.toJson<String>(confidence),
      'topKJson': serializer.toJson<String>(topKJson),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'contentVersion': serializer.toJson<String>(contentVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ScanRecord copyWith({
    String? id,
    Value<String?> ownerUid = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? source,
    String? outcome,
    String? chosenFabricId,
    String? confidence,
    String? topKJson,
    String? thumbnailPath,
    String? modelVersion,
    String? contentVersion,
    String? syncStatus,
  }) => ScanRecord(
    id: id ?? this.id,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    source: source ?? this.source,
    outcome: outcome ?? this.outcome,
    chosenFabricId: chosenFabricId ?? this.chosenFabricId,
    confidence: confidence ?? this.confidence,
    topKJson: topKJson ?? this.topKJson,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    modelVersion: modelVersion ?? this.modelVersion,
    contentVersion: contentVersion ?? this.contentVersion,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ScanRecord copyWithCompanion(ScanRecordsCompanion data) {
    return ScanRecord(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      source: data.source.present ? data.source.value : this.source,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      chosenFabricId: data.chosenFabricId.present
          ? data.chosenFabricId.value
          : this.chosenFabricId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      topKJson: data.topKJson.present ? data.topKJson.value : this.topKJson,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecord(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('source: $source, ')
          ..write('outcome: $outcome, ')
          ..write('chosenFabricId: $chosenFabricId, ')
          ..write('confidence: $confidence, ')
          ..write('topKJson: $topKJson, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    createdAt,
    updatedAt,
    deletedAt,
    source,
    outcome,
    chosenFabricId,
    confidence,
    topKJson,
    thumbnailPath,
    modelVersion,
    contentVersion,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRecord &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.source == this.source &&
          other.outcome == this.outcome &&
          other.chosenFabricId == this.chosenFabricId &&
          other.confidence == this.confidence &&
          other.topKJson == this.topKJson &&
          other.thumbnailPath == this.thumbnailPath &&
          other.modelVersion == this.modelVersion &&
          other.contentVersion == this.contentVersion &&
          other.syncStatus == this.syncStatus);
}

class ScanRecordsCompanion extends UpdateCompanion<ScanRecord> {
  final Value<String> id;
  final Value<String?> ownerUid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> source;
  final Value<String> outcome;
  final Value<String> chosenFabricId;
  final Value<String> confidence;
  final Value<String> topKJson;
  final Value<String> thumbnailPath;
  final Value<String> modelVersion;
  final Value<String> contentVersion;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ScanRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.outcome = const Value.absent(),
    this.chosenFabricId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.topKJson = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanRecordsCompanion.insert({
    required String id,
    this.ownerUid = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String source,
    required String outcome,
    required String chosenFabricId,
    required String confidence,
    required String topKJson,
    required String thumbnailPath,
    required String modelVersion,
    required String contentVersion,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       source = Value(source),
       outcome = Value(outcome),
       chosenFabricId = Value(chosenFabricId),
       confidence = Value(confidence),
       topKJson = Value(topKJson),
       thumbnailPath = Value(thumbnailPath),
       modelVersion = Value(modelVersion),
       contentVersion = Value(contentVersion);
  static Insertable<ScanRecord> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? source,
    Expression<String>? outcome,
    Expression<String>? chosenFabricId,
    Expression<String>? confidence,
    Expression<String>? topKJson,
    Expression<String>? thumbnailPath,
    Expression<String>? modelVersion,
    Expression<String>? contentVersion,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (source != null) 'source': source,
      if (outcome != null) 'outcome': outcome,
      if (chosenFabricId != null) 'chosen_fabric_id': chosenFabricId,
      if (confidence != null) 'confidence': confidence,
      if (topKJson != null) 'top_k_json': topKJson,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (modelVersion != null) 'model_version': modelVersion,
      if (contentVersion != null) 'content_version': contentVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUid,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? source,
    Value<String>? outcome,
    Value<String>? chosenFabricId,
    Value<String>? confidence,
    Value<String>? topKJson,
    Value<String>? thumbnailPath,
    Value<String>? modelVersion,
    Value<String>? contentVersion,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ScanRecordsCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      source: source ?? this.source,
      outcome: outcome ?? this.outcome,
      chosenFabricId: chosenFabricId ?? this.chosenFabricId,
      confidence: confidence ?? this.confidence,
      topKJson: topKJson ?? this.topKJson,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      modelVersion: modelVersion ?? this.modelVersion,
      contentVersion: contentVersion ?? this.contentVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (chosenFabricId.present) {
      map['chosen_fabric_id'] = Variable<String>(chosenFabricId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (topKJson.present) {
      map['top_k_json'] = Variable<String>(topKJson.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('source: $source, ')
          ..write('outcome: $outcome, ')
          ..write('chosenFabricId: $chosenFabricId, ')
          ..write('confidence: $confidence, ')
          ..write('topKJson: $topKJson, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppPrefsTable appPrefs = $AppPrefsTable(this);
  late final $ScanRecordsTable scanRecords = $ScanRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appPrefs, scanRecords];
}

typedef $$AppPrefsTableCreateCompanionBuilder = AppPrefsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppPrefsTableUpdateCompanionBuilder = AppPrefsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $AppPrefsTable> {
  $$AppPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPrefsTable> {
  $$AppPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPrefsTable> {
  $$AppPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPrefsTable,
          AppPref,
          $$AppPrefsTableFilterComposer,
          $$AppPrefsTableOrderingComposer,
          $$AppPrefsTableAnnotationComposer,
          $$AppPrefsTableCreateCompanionBuilder,
          $$AppPrefsTableUpdateCompanionBuilder,
          (AppPref, BaseReferences<_$AppDatabase, $AppPrefsTable, AppPref>),
          AppPref,
          PrefetchHooks Function()
        > {
  $$AppPrefsTableTableManager(_$AppDatabase db, $AppPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppPrefsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppPrefsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPrefsTable, AppPref>(table),
                  BaseReferences<_$AppDatabase, $AppPrefsTable, AppPref>(
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

typedef $$AppPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPrefsTable,
      AppPref,
      $$AppPrefsTableFilterComposer,
      $$AppPrefsTableOrderingComposer,
      $$AppPrefsTableAnnotationComposer,
      $$AppPrefsTableCreateCompanionBuilder,
      $$AppPrefsTableUpdateCompanionBuilder,
      (AppPref, BaseReferences<_$AppDatabase, $AppPrefsTable, AppPref>),
      AppPref,
      PrefetchHooks Function()
    >;
typedef $$ScanRecordsTableCreateCompanionBuilder =
    ScanRecordsCompanion Function({
      required String id,
      Value<String?> ownerUid,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String source,
      required String outcome,
      required String chosenFabricId,
      required String confidence,
      required String topKJson,
      required String thumbnailPath,
      required String modelVersion,
      required String contentVersion,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ScanRecordsTableUpdateCompanionBuilder =
    ScanRecordsCompanion Function({
      Value<String> id,
      Value<String?> ownerUid,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> source,
      Value<String> outcome,
      Value<String> chosenFabricId,
      Value<String> confidence,
      Value<String> topKJson,
      Value<String> thumbnailPath,
      Value<String> modelVersion,
      Value<String> contentVersion,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ScanRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chosenFabricId => $composableBuilder(
    column: $table.chosenFabricId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topKJson => $composableBuilder(
    column: $table.topKJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chosenFabricId => $composableBuilder(
    column: $table.chosenFabricId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topKJson => $composableBuilder(
    column: $table.topKJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get chosenFabricId => $composableBuilder(
    column: $table.chosenFabricId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topKJson =>
      $composableBuilder(column: $table.topKJson, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ScanRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanRecordsTable,
          ScanRecord,
          $$ScanRecordsTableFilterComposer,
          $$ScanRecordsTableOrderingComposer,
          $$ScanRecordsTableAnnotationComposer,
          $$ScanRecordsTableCreateCompanionBuilder,
          $$ScanRecordsTableUpdateCompanionBuilder,
          (
            ScanRecord,
            BaseReferences<_$AppDatabase, $ScanRecordsTable, ScanRecord>,
          ),
          ScanRecord,
          PrefetchHooks Function()
        > {
  $$ScanRecordsTableTableManager(_$AppDatabase db, $ScanRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String> chosenFabricId = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<String> topKJson = const Value.absent(),
                Value<String> thumbnailPath = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRecordsCompanion(
                id: id,
                ownerUid: ownerUid,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                source: source,
                outcome: outcome,
                chosenFabricId: chosenFabricId,
                confidence: confidence,
                topKJson: topKJson,
                thumbnailPath: thumbnailPath,
                modelVersion: modelVersion,
                contentVersion: contentVersion,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerUid = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String source,
                required String outcome,
                required String chosenFabricId,
                required String confidence,
                required String topKJson,
                required String thumbnailPath,
                required String modelVersion,
                required String contentVersion,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRecordsCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                source: source,
                outcome: outcome,
                chosenFabricId: chosenFabricId,
                confidence: confidence,
                topKJson: topKJson,
                thumbnailPath: thumbnailPath,
                modelVersion: modelVersion,
                contentVersion: contentVersion,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanRecordsTable, ScanRecord>(table),
                  BaseReferences<_$AppDatabase, $ScanRecordsTable, ScanRecord>(
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

typedef $$ScanRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanRecordsTable,
      ScanRecord,
      $$ScanRecordsTableFilterComposer,
      $$ScanRecordsTableOrderingComposer,
      $$ScanRecordsTableAnnotationComposer,
      $$ScanRecordsTableCreateCompanionBuilder,
      $$ScanRecordsTableUpdateCompanionBuilder,
      (
        ScanRecord,
        BaseReferences<_$AppDatabase, $ScanRecordsTable, ScanRecord>,
      ),
      ScanRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppPrefsTableTableManager get appPrefs =>
      $$AppPrefsTableTableManager(_db, _db.appPrefs);
  $$ScanRecordsTableTableManager get scanRecords =>
      $$ScanRecordsTableTableManager(_db, _db.scanRecords);
}
