import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

enum BannerKind { info, fiber, eco }

/// Inline note card (design-system "Banner"). Not dismissible.
class InfoBanner extends StatelessWidget {
  const new({
    required this.icon,
    required this.child,
    super.key,
    this.kind = BannerKind.info,
  });

  final IconData icon;
  final Widget child;
  final BannerKind kind;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      BannerKind.info => (s.surfaceContainerHigh, s.onSurface),
      BannerKind.fiber => (s.secondaryContainer, s.onSecondaryContainer),
      BannerKind.eco => (s.tertiaryContainer, s.onTertiaryContainer),
    };
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: fg),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: fg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Icon(icon),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Always shown on care guides (US-20).
class CareLabelDisclaimer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => InfoBanner(
    icon: Symbols.info_rounded,
    child: Text(
      AppLocalizations.of(context).careDisclaimer,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

/// Fiber ambiguity hint (S14). Shown whenever a fabric has several fibers.
class FiberHint extends StatelessWidget {
  const new({required this.fabric, super.key});
  final Fabric fabric;

  @override
  Widget build(BuildContext context) {
    if (!fabric.hasFiberAmbiguity) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fibers = fabric.fiberContent
        .map((f) => f.fiber.toLowerCase())
        .join(' ${l.fiberOr} ');
    return InfoBanner(
      kind: BannerKind.fiber,
      icon: Symbols.label_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(l.fiberHintTitle, style: t.titleSmall),
          Text(l.fiberHintBody(fabric.name, fibers), style: t.bodyMedium),
        ],
      ),
    );
  }
}

/// Dev builds only: marks sample text that the researchers will replace.
class SampleContentTag extends StatelessWidget {
  const new({super.key, this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: s.outline),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(
              Symbols.edit_note_rounded,
              size: 16,
              color: s.onSurfaceVariant,
            ),
            Flexible(
              child: Text(
                label ?? AppLocalizations.of(context).sampleContent,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: s.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state: icon ring, title, body and an optional action.
class EmptyState extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Column(
        spacing: 12,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: t.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 44,
              color: t.colorScheme.onSecondaryContainer,
            ),
          ),
          Text(
            title,
            style: t.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            body,
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          ?action,
        ],
      ),
    );
  }
}

void showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
