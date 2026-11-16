import 'package:fabriscan/app/app.dart';
import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/features/onboarding/presentation/onboarding_screens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  double textScale = 1,
  Size size = const Size(360, 800),
  AppDatabase? db,
}) async {
  PackageInfo.setMockInitialValues(
    appName: 'FabriSCAN+',
    packageName: 'ph.edu.dmmsu.fabriscan',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final database = db ?? AppDatabase.memory();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const FabriScanApp(),
    ),
  );
  // Splash waits ~1.4 s plus real async work (DB, asset): step both clocks
  // until the splash has routed away.
  for (var i = 0; i < 50; i++) {
    if (find.byType(SplashScreen).evaluate().isEmpty) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pumpAndSettle();
  expect(find.byType(SplashScreen), findsNothing, reason: 'splash finished');
  return database;
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text);
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

void main() {
  // The asset cache would hand later tests a Future owned by an earlier
  // test's fake clock, which never completes.
  setUp(rootBundle.clear);

  testWidgets('first launch: onboarding → guest → home (US-01, US-02)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(find.text('Scan any fabric'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tapText(tester, 'Next');
    expect(find.text('Get a care guide'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    await tapText(tester, 'Next');
    await tapText(tester, 'Get started');

    expect(find.text('Continue as Guest'), findsOneWidget);
    await tapText(tester, 'Continue as Guest');
    expect(find.text('What fabric is this?'), findsOneWidget);
    expect(find.text('Barong'), findsOneWidget);

    // Onboarding is saved, so it is not shown again.
    expect(await db.readPref('onboarding_done'), 'true');
  });

  testWidgets('browse → category → fabric → care guide (US-30, US-20)', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    await db.writePref('onboarding_done', 'true');
    await pumpApp(tester, db: db);
    expect(find.text('What fabric is this?'), findsOneWidget);

    await tapText(tester, 'Browse');
    expect(find.text('Browse fabrics'), findsOneWidget);
    for (final c in ['Barong', 'Formal wear', 'Gowns', 'Filipiniana']) {
      await tester.scrollUntilVisible(find.text(c), 200);
      expect(find.text(c), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Barong'), -200);
    await tapText(tester, 'Barong');
    expect(find.text('Piña'), findsOneWidget);
    expect(find.text('Jusi'), findsOneWidget);

    await tapText(tester, 'Jusi');
    expect(find.text("What it's made of"), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Check the garment label to confirm fiber.'),
      200,
    );
    expect(
      find.text('Check the garment label to confirm fiber.'),
      findsOneWidget,
    );

    await tapText(tester, 'Open care guide');
    expect(find.text('Care guide'), findsOneWidget);
    for (final s in [
      'Washing',
      'Drying',
      'Ironing',
      'Stain removal',
      'Storage',
    ]) {
      expect(find.text(s), findsWidgets);
    }
    expect(
      find.text(
        'This is general guidance. '
        "Always follow the garment's care label if it differs.",
      ),
      findsNWidgets(2),
    );

    // Stain types switch the steps (US-21).
    await tapText(tester, 'Sweat');
    expect(find.textContaining('white vinegar'), findsOneWidget);
  });

  testWidgets('search finds Piña when typing "pina" (US-31)', (tester) async {
    final db = AppDatabase.memory();
    await db.writePref('onboarding_done', 'true');
    await pumpApp(tester, db: db);
    await tapText(tester, 'Browse');
    await tapText(tester, 'Search fabrics, e.g. piña');
    await tester.enterText(find.byType(TextField), 'pina');
    await tester.pumpAndSettle();
    expect(find.text('Piña'), findsOneWidget);
    expect(find.text('Piña-seda'), findsOneWidget);
  });

  testWidgets('theme choice is saved', (tester) async {
    final db = AppDatabase.memory();
    await db.writePref('onboarding_done', 'true');
    await pumpApp(tester, db: db);
    await tapText(tester, 'Profile');
    await tapText(tester, 'Dark');
    expect(await db.readPref('theme_mode'), 'dark');
  });

  for (final route in ['home', 'care', 'about']) {
    testWidgets('1.3× text at 360 dp does not overflow: $route', (
      tester,
    ) async {
      final db = AppDatabase.memory();
      await db.writePref('onboarding_done', 'true');
      await pumpApp(tester, db: db, textScale: 1.3);
      if (route == 'care') {
        await tapText(tester, 'Browse');
        await tapText(tester, 'Gowns');
        await tapText(tester, 'Satin');
        await tapText(tester, 'Open care guide');
      } else if (route == 'about') {
        await tapText(tester, 'Profile');
        await tapText(tester, 'About & privacy');
      }
      expect(tester.takeException(), isNull);
    });
  }
}
