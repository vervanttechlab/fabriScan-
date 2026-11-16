import 'dart:ui' show ImageFilter;

import 'package:fabriscan/features/scan/presentation/scan_session.dart' as scan;
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Floating pill navigation: Home · Browse · Scan · History · Profile.
class AppShell extends StatelessWidget {
  const new({required this.shell, super.key});
  final StatefulNavigationShell shell;

  static Future<void> startScan(BuildContext context) =>
      scan.startScan(context);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      (Symbols.home_rounded, l.navHome),
      (Symbols.grid_view_rounded, l.navBrowse),
      (Symbols.history_rounded, l.navHistory),
      (Symbols.person_rounded, l.navProfile),
    ];
    Widget tab(int i) {
      final (icon, label) = tabs[i];
      final selected = shell.currentIndex == i;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: InkResponse(
            onTap: () => shell.goBranch(i, initialLocation: selected),
            radius: 36,
            child: SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? s.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      icon,
                      fill: selected ? 1 : 0,
                      color: selected
                          ? s.onPrimaryContainer
                          : s.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? s.onSurface : s.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: dark ? const Color(0xC71F1A15) : const Color(0xC7FFFCF5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: dark
                      ? const Color(0x1AF1E8DA)
                      : const Color(0x1A3B2A1E),
                ),
              ),
              child: Row(
                children: [
                  tab(0),
                  tab(1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Tooltip(
                      message: l.navScan,
                      child: Material(
                        color: s.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => startScan(context),
                          child: SizedBox(
                            width: 56,
                            height: 52,
                            child: Icon(
                              Symbols.photo_camera_rounded,
                              fill: 1,
                              color: s.onPrimary,
                              semanticLabel: l.navScan,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  tab(2),
                  tab(3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
