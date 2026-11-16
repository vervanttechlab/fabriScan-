import 'package:fabriscan/app/router.dart';
import 'package:fabriscan/app/theme.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget. Theme mode comes from Settings (Light / Dark / System).
class FabriScanApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode =
        ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.system;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: HiblaTheme.light(),
      darkTheme: HiblaTheme.dark(),
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
