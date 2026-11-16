import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/fabric_swatch.dart';
import 'package:fabriscan/core/widgets/page_padding.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/catalog_widgets.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// S16 Browse: 4 categories with fabric counts (US-30).
class BrowseScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CatalogBuilder(
          builder: (context, catalog) => ListView(
            padding: pagePadding(context, top: 16),
            children: [
              Text(l.browseTitle, style: t.textTheme.headlineMedium),
              const SizedBox(height: 14),
              Semantics(
                button: true,
                child: Material(
                  color: t.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => context.push('/browse/search'),
                    child: SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          spacing: 12,
                          children: [
                            const Icon(Symbols.search_rounded),
                            Expanded(
                              child: Text(
                                l.browseSearchHint,
                                style: t.textTheme.bodyLarge?.copyWith(
                                  color: t.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final c in catalog.categories)
                if (catalog.fabrics[c.coverFabricId] case final cover?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => context.push('/browse/${c.id}'),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 120),
                          child: FabricSwatch(
                            fabric: cover,
                            scrim: true,
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    spacing: 2,
                                    children: [
                                      const SizedBox(height: 48),
                                      Text(
                                        c.name,
                                        style: t.textTheme.headlineSmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      Text(
                                        l.browseCategoryLine(
                                          l.homeFabricCount(
                                            catalog.fabricsIn(c.id).length,
                                          ),
                                          c.description,
                                        ),
                                        style: t.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Symbols.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 4),
              Text(
                l.browseOffline(catalog.fabrics.length),
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// S17 Category → fabric grid.
class CategoryScreen extends StatelessWidget {
  const new({required this.categoryId, super.key});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return CatalogBuilder(
      builder: (context, catalog) {
        final c = catalog.category(categoryId);
        final list = catalog.fabricsIn(categoryId);
        return Scaffold(
          appBar: AppBar(title: Text(c?.name ?? '')),
          body: c == null
              ? Center(child: Text(l.notFound))
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.categoryIntro(
                            c.description,
                            l.homeFabricCount(list.length),
                          ),
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: pagePadding(context),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: list.length,
                        itemBuilder: (context, i) => FabricCard(
                          fabric: list[i],
                          catalog: catalog,
                          currentCategory: categoryId,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// S18 Fabric detail.
class FabricDetailScreen extends StatelessWidget {
  const new({required this.fabricId, super.key});
  final String fabricId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return CatalogBuilder(
      builder: (context, catalog) {
        final f = catalog.fabrics[fabricId];
        if (f == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l.notFound)),
          );
        }
        final sections = careSectionLabels(l);
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: pagePadding(context),
            children: [
              SizedBox(height: 200, child: FabricSwatch(fabric: f, radius: 28)),
              const SizedBox(height: 16),
              Text(f.name, style: t.textTheme.headlineLarge),
              if (f.aka.isNotEmpty)
                Text(
                  l.fabricAlsoCalled(f.aka.join(', ')),
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              CategoryTags(fabric: f, catalog: catalog),
              const SizedBox(height: 16),
              Text(f.description, style: t.textTheme.bodyLarge),
              if (catalog.isSample) ...[
                const SizedBox(height: 8),
                SampleContentTag(label: l.sampleDescription),
              ],
              const SizedBox(height: 20),
              Text(l.fabricMadeOf, style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final x in f.fiberContent)
                    Chip(
                      avatar: Icon(switch (x.type) {
                        FiberType.natural => Symbols.eco_rounded,
                        FiberType.synthetic => Symbols.science_rounded,
                        FiberType.blend => Symbols.join_rounded,
                      }, size: 18),
                      label: Text(
                        '${x.fiber} · ${switch (x.type) {
                          FiberType.natural => l.fiberNatural,
                          FiberType.synthetic => l.fiberSynthetic,
                          FiberType.blend => l.fiberBlend,
                        }}',
                      ),
                    ),
                ],
              ),
              if (f.hasFiberAmbiguity) ...[
                const SizedBox(height: 8),
                FiberHint(fabric: f),
              ],
              const SizedBox(height: 20),
              Card.filled(
                color: t.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(l.fabricRecognize, style: t.textTheme.titleMedium),
                      for (final x in f.identifyingFeatures)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Icon(
                              Symbols.check_circle_rounded,
                              color: t.colorScheme.tertiary,
                            ),
                            Expanded(
                              child: Text(x, style: t.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l.fabricCareGuide, style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card.outlined(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (id, label, icon) in sections)
                      ListTile(
                        minTileHeight: 56,
                        leading: Icon(icon),
                        title: Text(label),
                        trailing: const Icon(Symbols.chevron_right_rounded),
                        onTap: () => context.push(
                          '/fabric/${f.id}/care?section=${id.name}',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/fabric/${f.id}/care'),
                icon: const Icon(Symbols.menu_book_rounded),
                label: Text(l.fabricOpenCare),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The 5 care sections in US-20 order, with labels and icons.
List<(CareSectionId, String, IconData)> careSectionLabels(
  AppLocalizations l,
) => [
  (CareSectionId.washing, l.careWashing, Symbols.local_laundry_service_rounded),
  (CareSectionId.drying, l.careDrying, Symbols.air_rounded),
  (CareSectionId.ironing, l.careIroning, Symbols.iron_rounded),
  (CareSectionId.stainRemoval, l.careStain, Symbols.water_drop_rounded),
  (CareSectionId.storage, l.careStorage, Symbols.inventory_2_rounded),
];

/// S26 Search (US-31).
class SearchScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _q,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Symbols.search_rounded),
              filled: true,
              fillColor: t.colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: CatalogBuilder(
        builder: (context, catalog) {
          final q = _q.text.trim();
          final results = catalog.search(q);
          if (q.length < 2) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l.searchTypeMore,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          if (results.isEmpty) {
            return EmptyState(
              icon: Symbols.search_off_rounded,
              title: l.searchNone(q),
              body: l.searchNoneHint,
            );
          }
          return ListView(
            children: [
              for (final f in results)
                FabricListTile(fabric: f, catalog: catalog),
            ],
          );
        },
      ),
    );
  }
}
