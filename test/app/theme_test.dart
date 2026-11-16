import 'dart:math' as math;

import 'package:fabriscan/app/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // NFR-8: text contrast >= 4.5:1 in both themes (pairs from tokens.json).
  for (final (name, s, c) in [
    ('light', HiblaTheme.lightScheme, ConfidenceColors.light),
    ('dark', HiblaTheme.darkScheme, ConfidenceColors.dark),
  ]) {
    group('$name theme contrast', () {
      final pairs = <String, (Color, Color)>{
        'onPrimary/primary': (s.onPrimary, s.primary),
        'onPrimaryContainer/primaryContainer': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'onSecondaryContainer/secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'onTertiaryContainer/tertiaryContainer': (
          s.onTertiaryContainer,
          s.tertiaryContainer,
        ),
        'onErrorContainer/errorContainer': (
          s.onErrorContainer,
          s.errorContainer,
        ),
        'onSurface/surface': (s.onSurface, s.surface),
        'onSurfaceVariant/surface': (s.onSurfaceVariant, s.surface),
        'onSurfaceVariant/surfaceContainerHighest': (
          s.onSurfaceVariant,
          s.surfaceContainerHighest,
        ),
        'primary/surface': (s.primary, s.surface),
        'error/surface': (s.error, s.surface),
        'confHigh/surfaceContainerLow': (c.high, s.surfaceContainerLow),
        'confPossible/surfaceContainerLow': (c.possible, s.surfaceContainerLow),
        'confNotSure/surfaceContainerLow': (c.notSure, s.surfaceContainerLow),
        'onConfHigh/confHighContainer': (c.onHighContainer, c.highContainer),
        'onConfPossible/confPossibleContainer': (
          c.onPossibleContainer,
          c.possibleContainer,
        ),
        'onConfNotSure/confNotSureContainer': (
          c.onNotSureContainer,
          c.notSureContainer,
        ),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () => expect(contrast(fg, bg), greaterThanOrEqualTo(4.5)));
      }
    });
  }

  test('themes carry the confidence extension and bundled fonts', () {
    final t = HiblaTheme.light();
    expect(t.extension<ConfidenceColors>(), ConfidenceColors.light);
    expect(t.textTheme.headlineLarge?.fontFamily, HiblaTheme.displayFont);
    expect(t.textTheme.bodyMedium?.fontFamily, HiblaTheme.uiFont);
    expect(HiblaTheme.dark().colorScheme.brightness, Brightness.dark);
  });
}
