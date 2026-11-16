import 'package:fabriscan/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Settings read once at startup, before the first frame, so the splash can
/// decide where to go and the theme doesn't flash.
class AppSettings {
  const new({required this.onboardingDone, required this.themeMode});
  final bool onboardingDone;
  final ThemeMode themeMode;

  AppSettings copyWith({bool? onboardingDone, ThemeMode? themeMode}) =>
      AppSettings(
        onboardingDone: onboardingDone ?? this.onboardingDone,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _onboarding = 'onboarding_done';
  static const _theme = 'theme_mode';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<AppSettings> build() async {
    final onboarding = await _db.readPref(_onboarding);
    final theme = await _db.readPref(_theme);
    return AppSettings(
      onboardingDone: onboarding == 'true',
      themeMode: ThemeMode.values.asNameMap()[theme] ?? ThemeMode.system,
    );
  }

  Future<void> completeOnboarding() async {
    await _db.writePref(_onboarding, 'true');
    state = AsyncData(state.requireValue.copyWith(onboardingDone: true));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _db.writePref(_theme, mode.name);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
