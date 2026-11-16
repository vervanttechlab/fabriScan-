import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/fabric_swatch.dart';
import 'package:fabriscan/core/widgets/page_padding.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/browse_screens.dart';
import 'package:fabriscan/features/catalog/presentation/catalog_widgets.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// S15 Care guide (US-20, US-21): 5 sections in fixed order, numbered steps,
/// Sources per section, disclaimer at top and bottom. Works offline.
class CareGuideScreen extends StatefulWidget {
  const new({required this.fabricId, super.key, this.section});
  final String fabricId;
  final CareSectionId? section;

  @override
  State<CareGuideScreen> createState() => _CareGuideScreenState();
}

class _CareGuideScreenState extends State<CareGuideScreen> {
  final Map<CareSectionId, GlobalKey<State<StatefulWidget>>> _keys = {
    for (final id in CareSectionId.values) id: GlobalKey(),
  };
  String? _stain;

  @override
  void initState() {
    super.initState();
    if (widget.section != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _jump(widget.section!),
      );
    }
  }

  void _jump(CareSectionId id) {
    final ctx = _keys[id]!.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _sources(Catalog catalog, List<String> ids, String title) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text(title, style: t.titleLarge),
              const SizedBox(height: 12),
              if (catalog.isSample) ...[
                SampleContentTag(label: l.sampleCitations),
                const SizedBox(height: 12),
              ],
              for (final (i, id) in ids.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text('${i + 1}.', style: t.titleSmall),
                      Expanded(
                        child: SelectableText(
                          (catalog.citations[id]?.apa ?? id).replaceFirst(
                            '[PLACEHOLDER] ',
                            '',
                          ),
                          style: t.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return CatalogBuilder(
      builder: (context, catalog) {
        final f = catalog.fabrics[widget.fabricId];
        if (f == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l.notFound)),
          );
        }
        final sections = careSectionLabels(l);
        return Scaffold(
          appBar: AppBar(
            title: Text(l.careTitle),
            actions: [
              IconButton(
                tooltip: l.careAllSources,
                icon: const Icon(Symbols.menu_book_rounded),
                onPressed: () =>
                    _sources(catalog, f.care.allCitationIds, l.careAllSources),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 150),
                  child: FabricSwatch(
                    fabric: f,
                    scrim: true,
                    radius: 28,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 2,
                      children: [
                        const SizedBox(height: 40),
                        Text(l.careEyebrow, style: t.textTheme.labelMedium),
                        Text(
                          f.name,
                          style: t.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(f.fiberLabel, style: t.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const CareLabelDisclaimer(),
                if (f.hasFiberAmbiguity)
                  InfoBanner(
                    kind: BannerKind.fiber,
                    icon: Symbols.label_rounded,
                    child: Text(
                      l.careDelicateNote(f.mostDelicateFiber),
                      style: t.textTheme.bodyMedium,
                    ),
                  ),
                if (catalog.isSample) const SampleContentTag(),
                Semantics(
                  label: l.careSectionsNav,
                  container: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        for (final (id, label, icon) in sections)
                          ActionChip(
                            avatar: Icon(icon, size: 18),
                            label: Text(
                              id == CareSectionId.stainRemoval
                                  ? l.careStainShort
                                  : label,
                            ),
                            onPressed: () => _jump(id),
                          ),
                      ],
                    ),
                  ),
                ),
                for (final (id, label, icon) in sections)
                  _CareSectionCard(
                    key: _keys[id],
                    icon: icon,
                    title: label,
                    subtitle: id == CareSectionId.stainRemoval
                        ? l.carePickStain
                        : l.careSteps(f.care[id].steps.length),
                    sourcesCount: id == CareSectionId.stainRemoval
                        ? f.care[id].citationIds.length
                        : f.care[id].citationIds.length,
                    onSources: () => _sources(
                      catalog,
                      f.care[id].citationIds,
                      l.careSourcesFor(label),
                    ),
                    child: switch (id) {
                      CareSectionId.stainRemoval => _stainBody(catalog, f),
                      CareSectionId.ironing => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          if (f.care.ironSetting case final s?)
                            _IronSettingRow(setting: s),
                          _Steps(steps: f.care[id].steps),
                        ],
                      ),
                      _ => _Steps(steps: f.care[id].steps),
                    },
                  ),
                InfoBanner(
                  kind: BannerKind.eco,
                  icon: Symbols.eco_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(l.careEcoTitle, style: t.textTheme.titleSmall),
                      Text(l.careEcoBody, style: t.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const CareLabelDisclaimer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stainBody(Catalog catalog, Fabric f) {
    final l = AppLocalizations.of(context);
    final advice = f.care.byStain;
    if (advice.isEmpty) {
      return _Steps(steps: f.care[CareSectionId.stainRemoval].steps);
    }
    final selected =
        advice.where((a) => a.stain == _stain).firstOrNull ?? advice.first;
    final delicate = f.fiberContent.any((x) => x.type == FiberType.natural);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Semantics(
          label: l.careStainGroup,
          container: true,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in advice)
                ChoiceChip(
                  label: Text(catalog.stainName(a.stain)),
                  selected: a == selected,
                  onSelected: (_) => setState(() => _stain = a.stain),
                ),
            ],
          ),
        ),
        _Steps(steps: selected.steps),
        if (delicate)
          InfoBanner(
            kind: BannerKind.fiber,
            icon: Symbols.warning_rounded,
            child: Text(
              l.careTestFirst,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _CareSectionCard extends StatefulWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.sourcesCount,
    required this.onSources,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final int sourcesCount;
  final VoidCallback onSources;

  @override
  State<_CareSectionCard> createState() => _CareSectionCardState();
}

class _CareSectionCardState extends State<_CareSectionCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Card.filled(
      color: s.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _open,
            button: true,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  spacing: 12,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: s.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.icon, color: s.onPrimaryContainer),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: t.textTheme.titleMedium),
                          Text(
                            widget.subtitle,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Symbols.expand_more_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.child,
                  TextButton.icon(
                    onPressed: widget.onSources,
                    icon: const Icon(Symbols.menu_book_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context)
                          .careSources(widget.sourcesCount),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const new({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        for (final (i, step) in steps.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: t.textTheme.labelLarge?.copyWith(
                    color: t.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(step, style: t.textTheme.bodyLarge),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _IronSettingRow extends StatelessWidget {
  const new({required this.setting});
  final IronSetting setting;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final level = setting.dots == 0
        ? l.careNoIron
        : l.careIronDots(setting.dots);
    return Semantics(
      label: l.careIronLabel('$level, ${setting.text}'),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          spacing: 12,
          children: [
            Row(
              spacing: 4,
              children: [
                for (var i = 1; i <= 3; i++)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= setting.dots
                          ? t.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(color: t.colorScheme.primary),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$level · ',
                  style: t.textTheme.titleSmall,
                  children: [
                    TextSpan(text: setting.text, style: t.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
