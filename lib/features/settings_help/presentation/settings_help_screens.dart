import 'package:fabriscan/app/shell.dart';
import 'package:fabriscan/core/config/app_config.dart';
import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/hibla_logo.dart';
import 'package:fabriscan/features/catalog/data/catalog_repository.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// S19 History. Saving scans arrives with the scan flow (M2); until then
/// the empty state (US-41) is all there is to show.
class HistoryScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Text(
              l.historyTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            EmptyState(
              icon: Symbols.history_rounded,
              title: l.historyEmptyTitle,
              body: l.historyEmptyBody,
              action: FilledButton.icon(
                onPressed: () => AppShell.startScan(context),
                icon: const Icon(Symbols.photo_camera_rounded),
                label: Text(l.navScan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// S23 Profile & settings (guest view; accounts arrive in M4).
class ProfileScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final mode =
        ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.system;
    final version = ref.watch(packageInfoProvider).value?.version ?? '';
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: t.textTheme.labelMedium?.copyWith(
          color: t.colorScheme.onSurfaceVariant,
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Text(l.profileTitle, style: t.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card.filled(
              color: t.colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              t.colorScheme.surfaceContainerHighest,
                          child: const Icon(Symbols.person_rounded),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.profileGuest,
                                style: t.textTheme.titleMedium,
                              ),
                              Text(
                                l.profileGuestScans,
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: t.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l.profileGuestBody,
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () =>
                              showComingSoon(context, l.comingAccounts),
                          child: Text(l.profileSignup),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              showComingSoon(context, l.comingAccounts),
                          child: Text(l.profileLogin),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            heading(l.profileAppearance),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l.themeSystem),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ref.read(settingsProvider.notifier).setThemeMode(s.first),
            ),
            heading(l.profileHelpInfo),
            Card.outlined(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    minTileHeight: 56,
                    leading: const Icon(Symbols.lightbulb_rounded),
                    title: Text(l.profileHelp),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => context.push('/help'),
                  ),
                  ListTile(
                    minTileHeight: 56,
                    leading: const Icon(Symbols.info_rounded),
                    title: Text(l.profileAbout),
                    trailing: const Icon(Symbols.chevron_right_rounded),
                    onTap: () => context.push('/about'),
                  ),
                  // US-52: hidden unless a survey link is configured.
                  if (AppConfig.tamSurveyUrl.isNotEmpty)
                    ListTile(
                      minTileHeight: 56,
                      leading: const Icon(Symbols.rate_review_rounded),
                      title: Text(l.profileSurvey),
                      subtitle: Text(l.profileSurveySub),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                      onTap: () => launchUrl(
                        Uri.parse(AppConfig.tamSurveyUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.profileFooter(version),
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// S24 Help & photo tips (US-50).
class HelpScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final tips = [
      (Symbols.wb_sunny_rounded, l.tipLight),
      (Symbols.flash_off_rounded, l.tipFlash),
      (Symbols.crop_free_rounded, l.tipFill),
      (Symbols.straighten_rounded, l.tipDistance),
      (Symbols.center_focus_strong_rounded, l.tipFocus),
      (Symbols.layers_rounded, l.tipLayer),
    ];
    final guides = [
      (
        l.helpScanTitle,
        [l.helpScan1, l.helpScan2, l.helpScan3, l.helpScan4, l.helpScan5],
      ),
      (l.helpBrowseTitle, [l.helpBrowse1, l.helpBrowse2, l.helpBrowse3]),
      (l.helpHistoryTitle, [l.helpHistory1, l.helpHistory2, l.helpHistory3]),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(l.helpGoodScan, style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card.outlined(
            child: Column(
              children: [
                for (final (icon, text) in tips)
                  ListTile(
                    minTileHeight: 56,
                    leading: Icon(icon),
                    title: Text(text),
                  ),
              ],
            ),
          ),
          for (final (title, steps) in guides) ...[
            const SizedBox(height: 16),
            Card.filled(
              color: t.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(title, style: t.textTheme.titleMedium),
                    for (final (i, s) in steps.indexed)
                      Text('${i + 1}.  $s', style: t.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l.helpManual,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// S25 About & privacy (US-51).
class AboutScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final version = ref.watch(packageInfoProvider).value?.version ?? '';
    final catalog = ref.watch(catalogProvider).value;
    final muted = t.textTheme.bodyMedium?.copyWith(
      color: t.colorScheme.onSurfaceVariant,
    );
    final privacy = [
      (Symbols.smartphone_rounded, l.privacyGuest),
      (Symbols.image_rounded, l.privacyPhoto),
      (Symbols.cloud_rounded, l.privacyAccount),
      (Symbols.block_rounded, l.privacyNoAds),
      (Symbols.delete_rounded, l.privacyDelete),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Row(
            spacing: 14,
            children: [
              const HiblaLogo(size: 56),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wordmark(style: t.textTheme.headlineSmall),
                    Text(l.aboutVersion(version), style: muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card.filled(
            color: t.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l.aboutStudy, style: t.textTheme.labelMedium),
                  Text(
                    l.aboutStudyTitle,
                    style: t.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Fraunces',
                    ),
                  ),
                  Text(l.aboutUniversity, style: muted),
                  Text(l.aboutResearchers, style: t.textTheme.bodyMedium),
                  SampleContentTag(label: l.aboutResearchersSample),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InfoBanner(
            kind: BannerKind.eco,
            icon: Symbols.eco_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(l.aboutSdgTitle, style: t.textTheme.titleSmall),
                Text(l.aboutSdgBody, style: t.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card.filled(
            color: t.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(l.aboutPrivacy, style: t.textTheme.titleMedium),
                  for (final (icon, text) in privacy)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Icon(icon, color: t.colorScheme.primary),
                        Expanded(
                          child: Text(text, style: t.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  Text(l.privacyLaw, style: t.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card.filled(
            color: t.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(l.aboutCareInfo, style: t.textTheme.titleMedium),
                  Text(l.aboutCareInfoBody, style: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card.outlined(
            child: Column(
              children: [
                ListTile(title: Text(l.aboutApp), trailing: Text(version)),
                ListTile(
                  title: Text(l.aboutScanner),
                  trailing: Text(l.aboutScannerNone),
                ),
                ListTile(
                  title: Text(l.aboutContent),
                  trailing: Text(catalog?.contentVersion ?? ''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
