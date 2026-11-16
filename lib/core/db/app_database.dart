import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Small key/value settings (`architecture.md` §5.2 `app_prefs`):
/// onboarding_done, theme_mode.
class AppPrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Saved scans (`architecture.md` §5.2 `scan_records`). Only states A and B
/// are saved; state C never is (US-14).
@DataClassName('ScanRecord')
class ScanRecords extends Table {
  TextColumn get id => text()();

  /// Null = guest scan, kept on this phone only.
  TextColumn get ownerUid => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft-delete marker for synced accounts (ADR-005).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// camera | gallery
  TextColumn get source => text()();

  /// A | B
  TextColumn get outcome => text()();
  TextColumn get chosenFabricId => text()();

  /// high | possible | notSure — the word shown in History.
  TextColumn get confidence => text()();

  /// `[{fabricId, score}]` × up to 3.
  TextColumn get topKJson => text()();

  /// 256 px JPEG in the app's documents folder. Full photos are never kept.
  TextColumn get thumbnailPath => text()();
  TextColumn get modelVersion => text()();
  TextColumn get contentVersion => text()();

  /// local | pending | synced
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [AppPrefs, ScanRecords])
class AppDatabase extends _$AppDatabase {
  new([QueryExecutor? executor]) : super(executor ?? _open());

  /// In-memory database for tests.
  new memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(scanRecords);
    },
  );

  Future<String?> readPref(String key) async {
    final row = await (select(
      appPrefs,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writePref(String key, String value) => into(appPrefs)
      .insertOnConflictUpdate(AppPrefsCompanion.insert(key: key, value: value));

  static QueryExecutor _open() => LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(dir.path, 'fabriscan.sqlite')),
    );
  });
}
