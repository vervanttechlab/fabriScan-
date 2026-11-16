import 'package:fabriscan/core/widgets/fabric_swatch.dart';
import 'package:fabriscan/features/catalog/data/catalog_repository.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Builds [builder] once the bundled catalog is loaded (instant after splash).
class CatalogBuilder extends ConsumerWidget {
  const new({required this.builder, super.key});
  final Widget Function(BuildContext context, Catalog catalog) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(catalogProvider)
        .when(
          data: (c) => builder(context, c),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(AppLocalizations.of(context).errorLoading),
            ),
          ),
        );
  }
}

IconData categoryIcon(String id) => switch (id) {
  'barong' => Symbols.checkroom_rounded,
  'formal' => Symbols.work_rounded,
  'gowns' => Symbols.styler_rounded,
  'filipiniana' => Symbols.auto_awesome_rounded,
  _ => Symbols.category_rounded,
};

/// Category tags for a fabric (outlined chips).
class CategoryTags extends StatelessWidget {
  const new({required this.fabric, required this.catalog, super.key});
  final Fabric fabric;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final id in fabric.categoryIds)
        if (catalog.category(id) case final c?)
          Chip(
            avatar: Icon(categoryIcon(id), size: 18),
            label: Text(c.name),
            visualDensity: VisualDensity.compact,
          ),
    ],
  );
}

/// 2-column fabric card (S17): swatch with scrim, name, fiber.
class FabricCard extends StatelessWidget {
  const new({
    required this.fabric,
    required this.catalog,
    super.key,
    this.currentCategory,
  });

  final Fabric fabric;
  final Catalog catalog;
  final String? currentCategory;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final others = [
      for (final id in fabric.categoryIds)
        if (id != currentCategory) catalog.category(id)?.name ?? id,
    ];
    return Semantics(
      button: true,
      label: '${fabric.name}, ${fabric.fiberLabel}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.push('/fabric/${fabric.id}'),
        child: FabricSwatch(
          fabric: fabric,
          scrim: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                fabric.name,
                style: t.titleLarge?.copyWith(
                  fontFamily: 'Fraunces',
                  color: Colors.white,
                ),
              ),
              Text(fabric.fiberLabel, style: t.bodySmall),
              if (currentCategory != null && others.isNotEmpty)
                Text(l.alsoIn(others.join(', ')), style: t.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple list row used for search results.
class FabricListTile extends StatelessWidget {
  const new({required this.fabric, required this.catalog, super.key});
  final Fabric fabric;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final sub = [
      if (fabric.aka.isNotEmpty) fabric.aka.join(', '),
      fabric.categoryIds.map((c) => catalog.category(c)?.name ?? c).join(', '),
    ].join(' · ');
    return ListTile(
      minTileHeight: 64,
      leading: SizedBox.square(
        dimension: 48,
        child: FabricSwatch(fabric: fabric, radius: 12),
      ),
      title: Text(fabric.name),
      subtitle: Text(sub),
      trailing: const Icon(Symbols.chevron_right_rounded),
      onTap: () => context.push('/fabric/${fabric.id}'),
    );
  }
}
