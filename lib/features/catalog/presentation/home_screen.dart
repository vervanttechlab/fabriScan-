import 'package:fabriscan/app/shell.dart';
import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/fabric_swatch.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/catalog_widgets.dart';
import 'package:fabriscan/features/history/presentation/history_screens.dart';
import 'package:fabriscan/features/scan/presentation/scan_session.dart' as scan;
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// S06 Home (bento).
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? l.greetMorning
        : hour < 18
        ? l.greetAfternoon
        : l.greetEvening;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CatalogBuilder(
          builder: (context, catalog) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greet,
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(l.homeTitle, style: t.textTheme.headlineSmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.homeHelp,
                    onPressed: () => context.push('/help'),
                    icon: const Icon(Symbols.help_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ScanTile(onTap: () => AppShell.startScan(context)),
              const SizedBox(height: 10),
              Card.filled(
                color: t.colorScheme.surfaceContainer,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minTileHeight: 60,
                  leading: const Icon(Symbols.photo_library_rounded),
                  title: Text(l.homeUpload, style: t.textTheme.titleMedium),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  onTap: () => scan.startScan(context, upload: true),
                ),
              ),
              const SizedBox(height: 10),
              _CategoryGrid(catalog: catalog),
              const SizedBox(height: 18),
              RecentScansStrip(catalog: catalog),
              const SizedBox(height: 14),
              InfoBanner(
                kind: BannerKind.eco,
                icon: Symbols.lightbulb_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(l.homeTipLabel, style: t.textTheme.labelMedium),
                    Text(l.homeTipSample, style: t.textTheme.bodyMedium),
                    SampleContentTag(label: l.sampleTip),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTile extends StatelessWidget {
  const new({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Semantics(
      button: true,
      label: l.homeScanTitle,
      excludeSemantics: true,
      child: Material(
        color: s.primary,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 150),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 4,
                      children: [
                        Text(
                          l.homeScanTitle,
                          style: t.textTheme.headlineSmall?.copyWith(
                            color: s.onPrimary,
                          ),
                        ),
                        Text(
                          l.homeScanBody,
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: s.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: s.onPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Symbols.photo_camera_rounded,
                      size: 34,
                      fill: 1,
                      color: s.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const new({required this.catalog});
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final tiles = [
      for (final c in catalog.categories)
        if (catalog.fabrics[c.coverFabricId] case final cover?)
          Semantics(
            button: true,
            label: [
              c.name,
              l.homeFabricCount(catalog.fabricsIn(c.id).length),
            ].join(', '),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => context.push('/browse/${c.id}'),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 120),
                child: FabricSwatch(
                  fabric: cover,
                  scrim: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x9917130F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(categoryIcon(c.id)),
                      ),
                      const SizedBox(height: 16),
                      Text(c.name, style: t.titleMedium),
                      Text(
                        l.homeFabricCount(catalog.fabricsIn(c.id).length),
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    ];
    return Column(
      spacing: 10,
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Expanded(child: tiles[i]),
                Expanded(
                  child: i + 1 < tiles.length
                      ? tiles[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
