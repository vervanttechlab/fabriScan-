import 'dart:convert';
import 'dart:io';

import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    final raw = File('assets/content/catalog.json').readAsStringSync();
    catalog = Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('dev catalog is marked as sample content', () {
    expect(catalog.isSample, isTrue);
  });

  test('4 categories in order with fabric counts (US-30)', () {
    expect(catalog.categories.map((c) => c.name), [
      'Barong',
      'Formal wear',
      'Gowns',
      'Filipiniana',
    ]);
    expect(catalog.fabricsIn('barong'), hasLength(5));
    expect(catalog.fabricsIn('filipiniana'), hasLength(5));
  });

  test('a fabric in 2 categories appears in both (US-30)', () {
    expect(catalog.fabricsIn('barong').map((f) => f.id), contains('FAB-PINA'));
    expect(
      catalog.fabricsIn('filipiniana').map((f) => f.id),
      contains('FAB-PINA'),
    );
  });

  test('every fabric has all 5 care sections, each cited (US-20)', () {
    for (final f in catalog.fabrics.values) {
      expect(f.care.sections.keys, CareSectionId.values, reason: f.id);
      for (final id in CareSectionId.values) {
        expect(f.care[id].citationIds, isNotEmpty, reason: '${f.id} $id');
        for (final c in f.care[id].citationIds) {
          expect(catalog.citations, contains(c));
        }
      }
      expect(f.care.byStain, isNotEmpty, reason: f.id);
    }
  });

  test('search is diacritic-insensitive and needs 2 characters (US-31)', () {
    expect(catalog.search('p'), isEmpty);
    expect(catalog.search('pina').first.name, 'Piña');
    expect(catalog.search('PIÑA').first.name, 'Piña');
    expect(catalog.search('husi').map((f) => f.name), ['Jusi']);
    expect(catalog.search('gusot').map((f) => f.name), ['Cocoon']);
    expect(catalog.search('zzz'), isEmpty);
  });

  test('fiber helpers', () {
    final satin = catalog.fabrics['FAB-SATIN']!;
    expect(satin.hasFiberAmbiguity, isTrue);
    expect(satin.fiberLabel, 'Polyester or silk');
    expect(satin.mostDelicateFiber, 'silk');
    expect(catalog.fabrics['FAB-LINEN']!.hasFiberAmbiguity, isFalse);
  });

  test('fold diacritics', () {
    expect(foldDiacritics('piña-seda t’nalak'), "pina-seda t'nalak");
  });
}
