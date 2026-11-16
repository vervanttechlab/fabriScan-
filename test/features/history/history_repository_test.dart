import 'dart:io';
import 'dart:typed_data';

import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/features/history/data/history_repository.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:fabriscan/features/scan/data/photo_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const resultA = IdentificationResult(
  state: ResultState.confident,
  topK: [ScoredFabric('FAB-SATIN', 0.86), ScoredFabric('FAB-TAFFETA', 0.07)],
  modelVersion: 'test',
);

void main() {
  late AppDatabase db;
  late Directory dir;
  late HistoryRepository repo;
  var now = DateTime(2026, 11, 16, 9);

  setUp(() async {
    db = AppDatabase.memory();
    dir = await Directory.systemTemp.createTemp('thumbs');
    repo = HistoryRepository(db, () async => dir, clock: () => now);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> saveOne(String fabric) => repo.save(
    result: resultA,
    chosenFabricId: fabric,
    confidence: ConfidenceLevel.high,
    source: PhotoSource.camera,
    thumbnailJpeg: PhotoProcessing.makeThumbnail(
      img.encodeJpg(img.Image(width: 40, height: 30)),
    ),
    contentVersion: 'c1',
  );

  test(
    'saves A results newest first, with a thumbnail file (US-40, 41)',
    () async {
      final first = await saveOne('FAB-SATIN');
      now = now.add(const Duration(minutes: 5));
      final second = await saveOne('FAB-LACE');
      final rows = await repo.watchAll().first;
      expect(rows.map((r) => r.id), [second, first]);
      expect(File(rows.first.thumbnailPath).existsSync(), isTrue);
      expect(rows.first.outcome, 'A');
      expect(rows.first.ownerUid, isNull);
      expect(rows.first.topKJson, contains('FAB-TAFFETA'));
    },
  );

  test('"Not right?" changes the saved fabric', () async {
    final id = await saveOne('FAB-SATIN');
    await repo.changeChoice(id, 'FAB-TAFFETA', ConfidenceLevel.notSure);
    final r = await repo.byId(id);
    expect(r!.chosenFabricId, 'FAB-TAFFETA');
    expect(r.confidence, 'notSure');
  });

  test(
    'deleting a guest scan removes the row and the thumbnail (US-42)',
    () async {
      final id = await saveOne('FAB-SATIN');
      final path = (await repo.byId(id))!.thumbnailPath;
      await repo.delete(id);
      expect(await repo.byId(id), isNull);
      expect(File(path).existsSync(), isFalse);
    },
  );

  test('clear all empties history', () async {
    await saveOne('FAB-SATIN');
    await saveOne('FAB-LACE');
    await repo.clearAll();
    expect(await repo.watchAll().first, isEmpty);
    expect(dir.listSync(), isEmpty);
  });

  test('thumbnail is 256 px square and at most 30 KB (ADR-005)', () {
    final big = img.Image(width: 1600, height: 1200);
    for (final p in big) {
      p
        ..r = (p.x * 7) % 256
        ..g = (p.y * 13) % 256
        ..b = ((p.x + p.y) * 3) % 256;
    }
    final jpg = PhotoProcessing.makeThumbnail(img.encodeJpg(big, quality: 95));
    final t = img.decodeJpg(jpg)!;
    expect(t.width, 256);
    expect(t.height, 256);
    expect(jpg.length, lessThanOrEqualTo(30 * 1024));
  });

  test('unreadable bytes are rejected', () {
    expect(
      () => PhotoProcessing.makeThumbnail(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });
}
