import 'dart:async';

import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/confidence_meter.dart';
import 'package:fabriscan/core/widgets/fabric_swatch.dart';
import 'package:fabriscan/core/widgets/page_padding.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/catalog_widgets.dart';
import 'package:fabriscan/features/identify/data/identify_providers.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:fabriscan/features/scan/presentation/scan_session.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// S11–S14 Result: state A (confident), B (unsure) or C (can't identify).
class ResultScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(scanSessionProvider);
    final result = session.result;
    final policy = ref.watch(decisionPolicyProvider).value;
    final standIn = ref.watch(modelMetaProvider).value?.isStandIn ?? false;
    if (result == null || policy == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultTitle),
        actions: [
          IconButton(
            tooltip: l.camTips,
            onPressed: () => context.push('/help'),
            icon: const Icon(Symbols.lightbulb_rounded),
          ),
        ],
      ),
      body: CatalogBuilder(
        builder: (context, catalog) => ListView(
          padding: pagePadding(context),
          children: [
            if (standIn) ...[
              InfoBanner(
                icon: Symbols.science_rounded,
                child: Text(l.testScannerBanner),
              ),
              const SizedBox(height: 12),
            ],
            switch (result.state) {
              ResultState.confident => _ConfidentView(
                catalog: catalog,
                result: result,
                policy: policy,
              ),
              ResultState.unsure => _UnsureView(
                catalog: catalog,
                result: result,
                policy: policy,
              ),
              ResultState.cantIdentify => _CantIdentifyView(catalog: catalog),
            },
          ],
        ),
      ),
    );
  }
}

class _YourPhoto extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final thumb = ref.watch(scanSessionProvider).thumbnail;
    return Row(
      spacing: 12,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox.square(
            dimension: 56,
            child: thumb == null
                ? ColoredBox(color: t.colorScheme.surfaceContainerHigh)
                : Image.memory(
                    thumb,
                    fit: BoxFit.cover,
                    semanticLabel: l.yourPhoto,
                  ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.yourPhoto, style: t.textTheme.titleSmall),
              Text(
                l.scannedNow,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Features extends StatelessWidget {
  const new({required this.fabric, this.title});
  final Fabric fabric;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (title != null) Text(title!, style: t.textTheme.titleSmall),
        for (final x in fabric.identifyingFeatures)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Icon(Symbols.check_circle_rounded, color: t.colorScheme.tertiary),
              Expanded(child: Text(x, style: t.textTheme.bodyMedium)),
            ],
          ),
      ],
    );
  }
}

/// State A: one answer + "Not right?" (US-12).
class _ConfidentView extends ConsumerWidget {
  const new({
    required this.catalog,
    required this.result,
    required this.policy,
  });
  final Catalog catalog;
  final IdentificationResult result;
  final DecisionPolicy policy;

  void _others(BuildContext context, WidgetRef ref, Fabric top) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(l.otherMatchesTitle, style: t.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              l.otherMatchesBody(top.name),
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final s in result.topK.skip(1))
              if (catalog.fabrics[s.fabricId] case final f?)
                Card.outlined(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(sheet);
                      await ref.read(scanSessionProvider.notifier).choose(f.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.savedAs(f.name)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      unawaited(context.push('/fabric/${f.id}/care'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        spacing: 12,
                        children: [
                          SizedBox.square(
                            dimension: 56,
                            child: FabricSwatch(fabric: f, radius: 14),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(f.name, style: t.textTheme.titleMedium),
                                Text(
                                  f.fiberLabel,
                                  style: t.textTheme.bodySmall,
                                ),
                                ConfidenceMeter(
                                  level: policy.levelFor(s.score),
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Symbols.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(sheet);
                context.go('/browse');
              },
              icon: const Icon(Symbols.grid_view_rounded),
              label: Text(l.browseFabrics),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final f = catalog.fabrics[result.top!.fabricId];
    if (f == null) return Text(l.notFound);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        SizedBox(
          height: 150,
          child: FabricSwatch(
            fabric: f,
            scrim: true,
            radius: 28,
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: _YourPhotoOnDark(),
            ),
          ),
        ),
        const ConfidenceMeter(level: ConfidenceLevel.high),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(f.name, style: t.textTheme.headlineLarge),
            Text(
              f.fiberLabel,
              style: t.textTheme.bodyLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            CategoryTags(fabric: f, catalog: catalog),
          ],
        ),
        FiberHint(fabric: f),
        Card.filled(
          color: t.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _Features(fabric: f, title: l.checkOnGarment),
          ),
        ),
        FilledButton.icon(
          onPressed: () => context.push('/fabric/${f.id}/care'),
          icon: const Icon(Symbols.menu_book_rounded),
          label: Text(l.viewCareGuide),
        ),
        TextButton.icon(
          onPressed: () => _others(context, ref, f),
          icon: const Icon(Symbols.expand_more_rounded),
          label: Text(l.notRight),
        ),
        _Footer(text: l.savedLikely, icon: Symbols.bookmark_added_rounded),
      ],
    );
  }
}

class _YourPhotoOnDark extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final thumb = ref.watch(scanSessionProvider).thumbnail;
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: thumb == null
              ? const SizedBox.shrink()
              : Image.memory(
                  thumb,
                  fit: BoxFit.cover,
                  semanticLabel: l.yourPhoto,
                ),
        ),
        Text(
          '${l.yourPhoto}\n${l.scannedNow}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// State B: "This could be…" with the top 3 to compare (US-13).
class _UnsureView extends ConsumerWidget {
  const new({
    required this.catalog,
    required this.result,
    required this.policy,
  });
  final Catalog catalog;
  final IdentificationResult result;
  final DecisionPolicy policy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        const ConfidenceMeter(level: ConfidenceLevel.possible),
        Text(l.couldBeTitle, style: t.textTheme.headlineMedium),
        Text(
          l.couldBeBody,
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const _YourPhoto(),
        Text(
          l.couldBeTip,
          style: t.textTheme.bodySmall?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        for (final (i, s) in result.topK.indexed)
          if (catalog.fabrics[s.fabricId] case final f?)
            Card.outlined(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 96,
                    child: FabricSwatch(fabric: f, radius: 0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    style: t.textTheme.headlineSmall,
                                  ),
                                  Text(
                                    f.fiberLabel,
                                    style: t.textTheme.bodyMedium?.copyWith(
                                      color: t.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              l.optionN(i + 1),
                              style: t.textTheme.labelSmall,
                            ),
                          ],
                        ),
                        ConfidenceMeter(level: policy.levelFor(s.score)),
                        _Features(fabric: f),
                        FiberHint(fabric: f),
                        FilledButton.tonal(
                          onPressed: () async {
                            await ref
                                .read(scanSessionProvider.notifier)
                                .choose(f.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.savedAs(f.name)),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            unawaited(context.push('/fabric/${f.id}/care'));
                          },
                          child: Text(l.thisOne),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        Card.filled(
          color: t.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(l.noneOfThese, style: t.textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => retake(context),
                      icon: const Icon(Symbols.replay_rounded),
                      label: Text(l.reviewRetake),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/browse'),
                      icon: const Icon(Symbols.grid_view_rounded),
                      label: Text(l.browse),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _Footer(text: l.pickedSaved),
      ],
    );
  }
}

/// State C: honest "can't identify", nothing saved (US-14).
class _CantIdentifyView extends StatelessWidget {
  const new({required this.catalog});
  final Catalog catalog;

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
    final names = catalog.categories.map((c) => c.name).toList();
    final scope = names.length > 1
        ? '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}'
        : names.join();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        EmptyState(
          icon: Symbols.help_center_rounded,
          title: l.cantTitle,
          body: l.cantBody,
          action: const ConfidenceMeter(level: ConfidenceLevel.notSure),
        ),
        Card.filled(
          color: t.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(l.cantTips, style: t.textTheme.titleSmall),
                for (final (icon, tip) in tips)
                  Row(
                    spacing: 10,
                    children: [
                      Icon(icon, color: t.colorScheme.primary),
                      Expanded(child: Text(tip, style: t.textTheme.bodyMedium)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () => retake(context),
          icon: const Icon(Symbols.photo_camera_rounded),
          label: Text(l.retakePhoto),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/browse'),
          icon: const Icon(Symbols.grid_view_rounded),
          label: Text(l.browseFabrics),
        ),
        InfoBanner(
          icon: Symbols.info_rounded,
          child: Text(l.scopeNote(scope), style: t.textTheme.bodyMedium),
        ),
        _Footer(text: l.nothingSaved),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const new({required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final style = t.textTheme.bodySmall?.copyWith(
      color: t.colorScheme.onSurfaceVariant,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        if (icon != null) Icon(icon, size: 16, color: style?.color),
        Flexible(
          child: Text(text, style: style, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
