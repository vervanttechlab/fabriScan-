import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('onboarding is shown once, theme is remembered (US-01)', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    var container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    var s = await container.read(settingsProvider.future);
    expect(s.onboardingDone, isFalse);
    expect(s.themeMode, ThemeMode.system);

    await container.read(settingsProvider.notifier).completeOnboarding();
    await container
        .read(settingsProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    container.dispose();

    // A fresh start reads the saved values back.
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    s = await container.read(settingsProvider.future);
    expect(s.onboardingDone, isTrue);
    expect(s.themeMode, ThemeMode.dark);
  });
}
