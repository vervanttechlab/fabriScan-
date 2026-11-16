import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum PhotoSource { camera, gallery }

/// Saved scans on this phone (US-40–42). Guest scans never leave the phone.
class HistoryRepository {
  new(this._db, this._thumbDir, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Future<Directory> Function() _thumbDir;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  /// Newest first; deleted rows hidden.
  Stream<List<ScanRecord>> watchAll() =>
      (_db.select(_db.scanRecords)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<ScanRecord?> byId(String id) => (_db.select(
    _db.scanRecords,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  /// Saves an A or B result with the fabric the user ended up with.
  Future<String> save({
    required IdentificationResult result,
    required String chosenFabricId,
    required ConfidenceLevel confidence,
    required PhotoSource source,
    required Uint8List thumbnailJpeg,
    required String contentVersion,
  }) async {
    assert(result.state != ResultState.cantIdentify, 'State C is never saved');
    final id = _uuid.v4();
    final dir = await _thumbDir();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, '$id.jpg'));
    await file.writeAsBytes(thumbnailJpeg, flush: true);
    final now = _clock();
    await _db
        .into(_db.scanRecords)
        .insert(
          ScanRecordsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            source: source.name,
            outcome: result.state == ResultState.confident ? 'A' : 'B',
            chosenFabricId: chosenFabricId,
            confidence: confidence.name,
            topKJson: jsonEncode([for (final s in result.topK) s.toJson()]),
            thumbnailPath: file.path,
            modelVersion: result.modelVersion,
            contentVersion: contentVersion,
          ),
        );
    return id;
  }

  /// "Not right?" in state A: the user picked another fabric.
  Future<void> changeChoice(
    String id,
    String fabricId,
    ConfidenceLevel confidence,
  ) => (_db.update(_db.scanRecords)..where((t) => t.id.equals(id))).write(
    ScanRecordsCompanion(
      chosenFabricId: Value(fabricId),
      confidence: Value(confidence.name),
      updatedAt: Value(_clock()),
    ),
  );

  /// Guest scans are removed completely, thumbnail included. Account scans
  /// keep a soft-delete marker so the deletion can sync (ADR-005, M4).
  Future<void> delete(String id) async {
    final row = await (_db.select(
      _db.scanRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (row.ownerUid == null) {
      await (_db.delete(_db.scanRecords)..where((t) => t.id.equals(id))).go();
      await _deleteFile(row.thumbnailPath);
    } else {
      await (_db.update(_db.scanRecords)..where((t) => t.id.equals(id))).write(
        ScanRecordsCompanion(
          deletedAt: Value(_clock()),
          updatedAt: Value(_clock()),
          syncStatus: const Value('pending'),
        ),
      );
    }
  }

  Future<void> clearAll() async {
    final rows = await _db.select(_db.scanRecords).get();
    for (final r in rows) {
      await delete(r.id);
    }
  }

  Future<void> _deleteFile(String path) async {
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(
    ref.watch(appDatabaseProvider),
    () async => Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'thumbnails'),
    ),
  ),
);

final historyProvider = StreamProvider<List<ScanRecord>>(
  (ref) => ref.watch(historyRepositoryProvider).watchAll(),
);

// ignore: specify_nonobvious_property_types, family type isn't exported.
final scanRecordProvider = FutureProvider.family<ScanRecord?, String>((
  ref,
  id,
) {
  ref.watch(historyProvider); // refresh after edits
  return ref.watch(historyRepositoryProvider).byId(id);
});

ConfidenceLevel confidenceOf(ScanRecord r) =>
    ConfidenceLevel.values.asNameMap()[r.confidence] ??
    ConfidenceLevel.possible;
