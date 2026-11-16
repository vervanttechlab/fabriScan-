import 'dart:io';

import 'package:fabriscan/app/theme.dart';
import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/features/history/data/history_repository.dart';
import 'package:fabriscan/features/history/presentation/history_screens.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:fabriscan/features/result/presentation/result_screen.dart';
import 'package:fabriscan/features/scan/data/photo_processing.dart';
import 'package:fabriscan/features/scan/presentation/scan_session.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';

final Uint8List thumb = PhotoProcessing.makeThumbnail(
  img.encodeJpg(img.Image(width: 64, height: 48)),
);

class _Preset extends ScanSessionNotifier {
  new(this.initial);
  final ScanSession initial;
  @override
  ScanSession build() => initial;
}

ScanSession sessionFor(ResultState state, List<ScoredFabric> topK) =>
    ScanSession(
      thumbnail: thumb,
      result: IdentificationResult(
        state: state,
        topK: topK,
        modelVersion: 'fake-dev',
      ),
    );

Future<HistoryRepository> pump(
  WidgetTester tester,
  Widget home, {
  ScanSession? session,
}) async {
  final db = AppDatabase.memory();
  final dir = await tester.runAsync(
    () => Directory.systemTemp.createTemp('thumbs'),
  );
  final repo = HistoryRepository(db, () async => dir!);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/fabric/:id/care',
        builder: (_, s) => Text('care:${s.pathParameters['id']}'),
      ),
      GoRoute(path: '/browse', builder: (_, _) => const Text('browse')),
      GoRoute(path: '/history/:id', builder: (_, _) => const Text('detail')),
      GoRoute(path: '/help', builder: (_, _) => const Text('help')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        historyRepositoryProvider.overrideWithValue(repo),
        if (session != null)
          scanSessionProvider.overrideWith(() => _Preset(session)),
      ],
      child: MaterialApp.router(
        theme: HiblaTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await settle(tester);
  return repo;
}

/// Lets real async work (assets, SQLite) finish between frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void widgetTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  setUp(rootBundle.clear);

  widgetTest('state A: one answer, fiber hint, no percentage (US-12, 15)', (
    tester,
  ) async {
    await pump(
      tester,
      const ResultScreen(),
      session: sessionFor(ResultState.confident, const [
        ScoredFabric('FAB-SATIN', 0.86),
        ScoredFabric('FAB-TAFFETA', 0.07),
      ]),
    );
    expect(find.text('Satin'), findsOneWidget);
    expect(find.text('High match'), findsOneWidget);
    expect(
      find.text('Check the garment label to confirm fiber.'),
      findsOneWidget,
    );
    expect(find.text('View care guide'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('certain'), findsNothing);
  });

  widgetTest('state B: picking an option saves it (US-13, US-40)', (
    tester,
  ) async {
    final repo = await pump(
      tester,
      const ResultScreen(),
      session: sessionFor(ResultState.unsure, const [
        ScoredFabric('FAB-PINA', 0.58),
        ScoredFabric('FAB-PINASEDA', 0.27),
        ScoredFabric('FAB-JUSI', 0.09),
      ]),
    );
    expect(find.text('This could be…'), findsOneWidget);
    expect(find.text('Option 3'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Option 2'), 200);
    final pick = find.descendant(
      of: find.ancestor(of: find.text('Option 2'), matching: find.byType(Card)),
      matching: find.text('This one · View care guide'),
    );
    await tester.ensureVisible(pick);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(pick);
    await settle(tester);
    final saved = await tester.runAsync(() => repo.watchAll().first);
    expect(find.text('care:FAB-PINASEDA'), findsOneWidget);
    expect(saved!.single.chosenFabricId, 'FAB-PINASEDA');
    expect(saved.single.outcome, 'B');
  });

  widgetTest('state C: honest message, nothing saved (US-14)', (tester) async {
    await pump(
      tester,
      const ResultScreen(),
      session: sessionFor(ResultState.cantIdentify, const []),
    );
    expect(find.text("We couldn't identify this fabric"), findsOneWidget);
    expect(find.text('Not sure'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nothing was saved to History.'),
      200,
    );
    expect(find.textContaining('Gowns'), findsOneWidget);
  });

  widgetTest('History lists scans and deletes with confirmation (US-41, 42)', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('thumbs'),
    );
    final repo = HistoryRepository(db, () async => dir!);
    await tester.runAsync(
      () => repo.save(
        result: const IdentificationResult(
          state: ResultState.confident,
          topK: [ScoredFabric('FAB-LINEN', 0.9)],
          modelVersion: 'fake-dev',
        ),
        chosenFabricId: 'FAB-LINEN',
        confidence: ConfidenceLevel.high,
        source: PhotoSource.camera,
        thumbnailJpeg: thumb,
        contentVersion: 'c',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          historyRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: HiblaTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HistoryScreen(),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('Linen'), findsOneWidget);
    expect(find.text('High match'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Linen scan'));
    await settle(tester);
    expect(find.text('Delete this scan?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Linen'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Linen scan'));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.text('No scans yet'), findsOneWidget);
  });
}
