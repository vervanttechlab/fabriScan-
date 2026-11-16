import 'dart:convert';
import 'dart:io';

import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: what `tools/content/build_catalog.py` writes, the app can read.
/// Regenerate the fixture when the builder's output changes.
void main() {
  test('app reads a catalog built from the researchers spreadsheet', () {
    final raw = File('test/fixtures/catalog_from_xlsx.json').readAsStringSync();
    final c = Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    expect(c.isSample, isFalse);
    expect(c.categories.map((x) => x.id), [
      'barong',
      'formal',
      'gowns_filipiniana',
      'beaded',
    ]);
    final pina = c.fabrics['FAB-PINA']!;
    expect(pina.aka, ['Piña cloth']);
    expect(pina.categoryIds, ['barong', 'gowns_filipiniana']);
    expect(c.fabricsIn('gowns_filipiniana').map((f) => f.id), [
      'FAB-PINA',
      'FAB-SATIN',
    ]);
    expect(pina.care[CareSectionId.washing].steps, [
      'First step.',
      'Second step.',
    ]);
    expect(pina.care.ironSetting!.dots, 1);
    expect(pina.care.byStain.map((s) => s.stain), ['food', 'sweat']);
    expect(c.stainName('food'), 'Food & oil');
    expect(c.fabrics['FAB-SATIN']!.hasFiberAmbiguity, isTrue);
    for (final id in pina.care.allCitationIds) {
      expect(c.citations, contains(id));
    }
  });
}
