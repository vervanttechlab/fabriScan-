import 'dart:async';
import 'dart:io';

import 'package:fabriscan/core/db/app_database.dart';
import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/confidence_meter.dart';
import 'package:fabriscan/core/widgets/page_padding.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/catalog_widgets.dart';
import 'package:fabriscan/features/history/data/history_repository.dart';
import 'package:fabriscan/features/scan/presentation/scan_session.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// "Today, 3:41 PM" / "Yesterday, 9:02 AM" / "Nov 3, 2026".
String formatWhen(AppLocalizations l, DateTime when, {bool short = false}) {
  final now = DateTime.now();
  final day = DateTime(when.year, when.month, when.day);
  final today = DateTime(now.year, now.month, now.day);
  final time = DateFormat.jm().format(when);
  final diff = today.difference(day).inDays;
  if (diff == 0) return short ? l.todayShort : l.today(time);
  if (diff == 1) return short ? l.yesterdayShort : l.yesterday(time);
  return short
      ? DateFormat.MMMd().format(when)
      : DateFormat.yMMMd().format(when);
}

Future<void> confirmDelete(
  BuildContext context,
  WidgetRef ref,
  ScanRecord r,
  String fabricName,
) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l.deleteTitle),
      content: Text(l.deleteBody(fabricName, formatWhen(l, r.createdAt))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d, false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l.delete),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await ref.read(historyRepositoryProvider).delete(r.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.deleted), behavior: SnackBarBehavior.floating),
    );
  }
}

class ScanThumb extends StatelessWidget {
  const new({required this.record, super.key, this.size = 56});
  final ScanRecord record;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size / 4),
    child: SizedBox.square(
      dimension: size,
      child: Image.file(
        File(record.thumbnailPath),
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: const Icon(Symbols.image_rounded),
        ),
      ),
    ),
  );
}

/// S19 History (US-41).
class HistoryScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final records = ref.watch(historyProvider).value ?? const <ScanRecord>[];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CatalogBuilder(
          builder: (context, catalog) => ListView(
            padding: pagePadding(context, top: 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.historyTitle,
                      style: t.textTheme.headlineMedium,
                    ),
                  ),
                  if (records.isNotEmpty)
                    Chip(
                      avatar: const Icon(Symbols.smartphone_rounded, size: 18),
                      label: Text(l.historyOnPhone),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (records.isEmpty)
                EmptyState(
                  icon: Symbols.history_rounded,
                  title: l.historyEmptyTitle,
                  body: l.historyEmptyBody,
                  action: FilledButton.icon(
                    onPressed: () => startScan(context),
                    icon: const Icon(Symbols.photo_camera_rounded),
                    label: Text(l.navScan),
                  ),
                )
              else ...[
                Card.outlined(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final r in records)
                        _HistoryRow(
                          record: r,
                          fabric: catalog.fabrics[r.chosenFabricId],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.historyFooter,
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const new({required this.record, required this.fabric});
  final ScanRecord record;
  final Fabric? fabric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final name = fabric?.name ?? record.chosenFabricId;
    return InkWell(
      onTap: () => context.push('/history/${record.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          spacing: 14,
          children: [
            ScanThumb(record: record),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(name, style: t.textTheme.titleMedium),
                  Text(
                    formatWhen(l, record.createdAt),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  ConfidenceMeter(level: confidenceOf(record), compact: true),
                ],
              ),
            ),
            IconButton(
              tooltip: l.historyDelete(name),
              onPressed: () => confirmDelete(context, ref, record, name),
              icon: const Icon(Symbols.delete_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// S20 Saved scan detail (US-41, US-42).
class HistoryDetailScreen extends ConsumerWidget {
  const new({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final record = ref.watch(scanRecordProvider(id)).value;
    return CatalogBuilder(
      builder: (context, catalog) {
        if (record == null) {
          return Scaffold(appBar: AppBar(title: Text(l.savedScan)));
        }
        final f = catalog.fabrics[record.chosenFabricId];
        final name = f?.name ?? record.chosenFabricId;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.savedScan),
            actions: [
              IconButton(
                tooltip: l.historyDelete(name),
                onPressed: () async {
                  await confirmDelete(context, ref, record, name);
                  if (context.mounted &&
                      await ref.read(historyRepositoryProvider).byId(id) ==
                          null &&
                      context.mounted) {
                    context.pop();
                  }
                },
                icon: const Icon(Symbols.delete_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: pagePadding(context),
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.file(
                    File(record.thumbnailPath),
                    fit: BoxFit.cover,
                    semanticLabel: l.yourPhoto,
                    errorBuilder: (context, _, _) =>
                        ColoredBox(color: t.colorScheme.surfaceContainerHigh),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                [
                  formatWhen(l, record.createdAt),
                  if (record.source == 'gallery')
                    l.sourceGallery
                  else
                    l.sourceCamera,
                ].join(' · '),
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(name, style: t.textTheme.headlineLarge),
              if (f != null)
                Text(
                  f.fiberLabel,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              ConfidenceMeter(level: confidenceOf(record)),
              if (f != null) ...[
                const SizedBox(height: 14),
                FiberHint(fabric: f),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => context.push('/fabric/${f.id}/care'),
                  icon: const Icon(Symbols.menu_book_rounded),
                  label: Text(l.viewCareGuide),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.push('/fabric/${f.id}'),
                  child: Text(l.aboutFabric(f.name)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Home's "Recent scans" strip.
class RecentScansStrip extends ConsumerWidget {
  const new({required this.catalog, super.key});
  final Catalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final records = ref.watch(historyProvider).value ?? const <ScanRecord>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.homeRecent, style: t.textTheme.titleMedium)),
            if (records.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/history'),
                child: Text(l.seeAll),
              ),
          ],
        ),
        if (records.isEmpty)
          Card.filled(
            color: t.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.homeRecentEmpty,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 112 + MediaQuery.textScalerOf(context).scale(44),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: records.length.clamp(0, 6),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final r = records[i];
                final name =
                    catalog.fabrics[r.chosenFabricId]?.name ?? r.chosenFabricId;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => unawaited(context.push('/history/${r.id}')),
                  child: SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        ScanThumb(record: r, size: 96),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.titleSmall,
                        ),
                        Text(
                          formatWhen(l, r.createdAt, short: true),
                          style: t.textTheme.bodySmall?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
