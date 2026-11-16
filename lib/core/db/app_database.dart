import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Small key/value settings (`architecture.md` §5.2 `app_prefs`):
/// onboarding_done, theme_mode. Scan history tables are added in M2.
class AppPrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [AppPrefs])
class AppDatabase extends _$AppDatabase {
  new([QueryExecutor? executor]) : super(executor ?? _open());

  /// In-memory database for tests.
  new memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

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
