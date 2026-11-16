import 'package:fabriscan/app/theme.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Confidence in words + a 3-segment meter. Never a percentage (PRD §6).
/// Colour is never the only signal: the word and the icon change too.
class ConfidenceMeter extends StatelessWidget {
  const new({required this.level, super.key, this.compact = false});
  final ConfidenceLevel level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Theme.of(context).extension<ConfidenceColors>()!;
    final (word, icon, fg, bg, onBg, filled) = switch (level) {
      ConfidenceLevel.high => (
        l.confHigh,
        Symbols.verified_rounded,
        c.high,
        c.highContainer,
        c.onHighContainer,
        3,
      ),
      ConfidenceLevel.possible => (
        l.confPossible,
        Symbols.help_rounded,
        c.possible,
        c.possibleContainer,
        c.onPossibleContainer,
        2,
      ),
      ConfidenceLevel.notSure => (
        l.confNotSure,
        Symbols.report_rounded,
        c.notSure,
        c.notSureContainer,
        c.onNotSureContainer,
        1,
      ),
    };
    final chip = Container(
      padding: EdgeInsets.fromLTRB(8, compact ? 2 : 5, 12, compact ? 2 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(icon, size: compact ? 16 : 18, fill: 1, color: onBg),
          Text(
            word,
            style:
                (compact
                        ? Theme.of(context).textTheme.labelMedium
                        : Theme.of(context).textTheme.labelLarge)
                    ?.copyWith(color: onBg),
          ),
        ],
      ),
    );
    if (compact) {
      return Semantics(label: word, excludeSemantics: true, child: chip);
    }
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: word,
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          chip,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              for (var i = 0; i < 3; i++)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduce ? 1 : 0, end: 1),
                  duration: Duration(milliseconds: reduce ? 0 : 300 + i * 100),
                  builder: (context, t, _) => Container(
                    width: 28,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? Color.lerp(
                              Theme.of(context).colorScheme.outlineVariant,
                              fg,
                              t,
                            )
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
