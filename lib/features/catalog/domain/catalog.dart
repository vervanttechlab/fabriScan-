import 'package:flutter/foundation.dart';

/// Read-only fabric content (`assets/content/catalog.json`,
/// `docs/architecture/architecture.md` §5.1). Written by the researchers,
/// built by `tools/content/build_catalog.py`. Never edited in code.
@immutable
class Catalog {
  const new({
    required this.contentVersion,
    required this.isSample,
    required this.categories,
    required this.stainTypes,
    required this.fabrics,
    required this.citations,
  });

  factory fromJson(Map<String, dynamic> j) {
    final status = (j['status'] as String?) ?? '';
    final fabrics = [
      for (final f in j['fabrics'] as List) Fabric.fromJson(_map(f)),
    ];
    return Catalog(
      contentVersion: j['contentVersion'] as String,
      isSample: status.contains('[PLACEHOLDER]'),
      categories: [
        for (final c in j['categories'] as List)
          FabricCategory.fromJson(_map(c)),
      ]..sort((a, b) => a.order.compareTo(b.order)),
      stainTypes: [
        for (final s in (j['stainTypes'] as List?) ?? const <Object>[])
          StainType.fromJson(_map(s)),
      ],
      fabrics: {for (final f in fabrics) f.id: f},
      citations: {
        for (final c in j['citations'] as List)
          (_map(c)['id'] as String): Citation.fromJson(_map(c)),
      },
    );
  }

  final String contentVersion;

  /// True for the development sample. The app then shows a "Sample content"
  /// tag; the release content check refuses such a catalog.
  final bool isSample;
  final List<FabricCategory> categories;
  final List<StainType> stainTypes;
  final Map<String, Fabric> fabrics;
  final Map<String, Citation> citations;

  FabricCategory? category(String id) =>
      categories.where((c) => c.id == id).firstOrNull;

  /// Fabrics in a category, in catalog order. A fabric listed under several
  /// categories appears in each (US-30).
  List<Fabric> fabricsIn(String categoryId) => [
    for (final f in fabrics.values)
      if (f.categoryIds.contains(categoryId)) f,
  ];

  String stainName(String id) =>
      stainTypes.where((s) => s.id == id).firstOrNull?.name ?? id;

  /// Diacritic-insensitive search on name and aliases (US-31): "pina" finds
  /// "Piña". Needs at least 2 characters.
  List<Fabric> search(String query) {
    final q = foldDiacritics(query.trim().toLowerCase());
    if (q.length < 2) return const [];
    bool hit(String s) => foldDiacritics(s.toLowerCase()).contains(q);
    final starts = <Fabric>[];
    final contains = <Fabric>[];
    for (final f in fabrics.values) {
      final names = [f.name, ...f.aka];
      if (names.any((n) => foldDiacritics(n.toLowerCase()).startsWith(q))) {
        starts.add(f);
      } else if (names.any(hit)) {
        contains.add(f);
      }
    }
    return [...starts, ...contains];
  }
}

const _fold = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ñ': 'n', 'ç': 'c', '’': "'",
};

String foldDiacritics(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(_fold[ch] ?? ch);
  }
  return b.toString();
}

Map<String, dynamic> _map(Object? o) => (o! as Map).cast<String, dynamic>();
List<String> _strings(Object? o) => [
  for (final s in (o as List?) ?? const <Object>[]) s as String,
];

@immutable
class FabricCategory {
  const new({
    required this.id,
    required this.name,
    required this.order,
    required this.description,
    required this.coverFabricId,
  });

  factory fromJson(Map<String, dynamic> j) => FabricCategory(
    id: j['id'] as String,
    name: j['name'] as String,
    order: (j['order'] as num).toInt(),
    description: j['description'] as String,
    coverFabricId: j['coverFabricId'] as String?,
  );

  final String id;
  final String name;
  final int order;
  final String description;
  final String? coverFabricId;
}

@immutable
class StainType {
  const new({required this.id, required this.name});
  factory fromJson(Map<String, dynamic> j) =>
      StainType(id: j['id'] as String, name: j['name'] as String);
  final String id;
  final String name;
}

enum FiberType { natural, synthetic, blend }

@immutable
class FiberContent {
  const new({required this.fiber, required this.type, this.note = ''});
  factory fromJson(Map<String, dynamic> j) => FiberContent(
    fiber: j['fiber'] as String,
    type: FiberType.values.byName(j['type'] as String),
    note: (j['note'] as String?) ?? '',
  );
  final String fiber;
  final FiberType type;
  final String note;
}

/// Placeholder look for a fabric until the researchers supply photos.
@immutable
class Swatch {
  const new({required this.base, required this.accent, required this.pattern});
  factory fromJson(Map<String, dynamic>? j) => j == null
      ? const Swatch(base: 0xFFE5DCCA, accent: 0xFF8C7A68, pattern: 'plain')
      : Swatch(
          base: _hex(j['base'] as String),
          accent: _hex(j['accent'] as String),
          pattern: j['pattern'] as String,
        );
  static int _hex(String s) =>
      int.parse('FF${s.replaceFirst('#', '')}', radix: 16);
  final int base;
  final int accent;
  final String pattern;
}

@immutable
class Fabric {
  const new({
    required this.id,
    required this.name,
    required this.aka,
    required this.categoryIds,
    required this.fiberContent,
    required this.description,
    required this.identifyingFeatures,
    required this.images,
    required this.swatch,
    required this.care,
  });

  factory fromJson(Map<String, dynamic> j) => Fabric(
    id: j['id'] as String,
    name: j['name'] as String,
    aka: _strings(j['aka']),
    categoryIds: _strings(j['categoryIds']),
    fiberContent: [
      for (final x in j['fiberContent'] as List) FiberContent.fromJson(_map(x)),
    ],
    description: j['description'] as String,
    identifyingFeatures: _strings(j['identifyingFeatures']),
    images: _strings(j['images']),
    swatch: Swatch.fromJson(j['swatch'] == null ? null : _map(j['swatch'])),
    care: CareGuide.fromJson(_map(j['care'])),
  );

  final String id;
  final String name;
  final List<String> aka;
  final List<String> categoryIds;
  final List<FiberContent> fiberContent;
  final String description;
  final List<String> identifyingFeatures;
  final List<String> images;
  final Swatch swatch;
  final CareGuide care;

  /// More than one possible fiber: the app must show the fiber hint (S14).
  bool get hasFiberAmbiguity => fiberContent.length > 1;

  /// "Polyester or silk": first fiber as written, the rest lower-cased.
  String get fiberLabel => [
    if (fiberContent.isNotEmpty) fiberContent.first.fiber,
    for (final f in fiberContent.skip(1)) f.fiber.toLowerCase(),
  ].join(' or ');

  /// The most delicate version, which the care steps are written for.
  String get mostDelicateFiber =>
      (fiberContent.where((f) => f.type == FiberType.natural).firstOrNull ??
              fiberContent.first)
          .fiber
          .toLowerCase();
}

enum CareSectionId { washing, drying, ironing, stainRemoval, storage }

@immutable
class CareGuide {
  const new(this.sections, this.ironSetting, this.byStain);

  factory fromJson(Map<String, dynamic> j) {
    final sections = <CareSectionId, CareSection>{
      for (final id in CareSectionId.values)
        id: CareSection.fromJson(_map(j[id.name])),
    };
    final ironing = _map(j['ironing']);
    final setting = ironing['setting'] == null
        ? null
        : _map(ironing['setting']);
    return CareGuide(
      sections,
      setting == null
          ? null
          : IronSetting(
              dots: (setting['dots'] as num).toInt(),
              text: setting['text'] as String,
            ),
      [
        for (final s
            in (_map(j['stainRemoval'])['byStain'] as List?) ??
                const <Object>[])
          StainAdvice.fromJson(_map(s)),
      ],
    );
  }

  /// All 5 sections, always in the US-20 order.
  final Map<CareSectionId, CareSection> sections;
  final IronSetting? ironSetting;
  final List<StainAdvice> byStain;

  CareSection operator [](CareSectionId id) => sections[id]!;

  List<String> get allCitationIds => {
    for (final s in sections.values) ...s.citationIds,
    for (final s in byStain) ...s.citationIds,
  }.toList();
}

@immutable
class CareSection {
  const new({required this.steps, required this.citationIds});
  factory fromJson(Map<String, dynamic> j) => CareSection(
    steps: _strings(j['steps']),
    citationIds: _strings(j['citationIds']),
  );
  final List<String> steps;
  final List<String> citationIds;
}

@immutable
class IronSetting {
  const new({required this.dots, required this.text});

  /// 0 = do not iron, 1–3 = iron dots on the care label.
  final int dots;
  final String text;
}

@immutable
class StainAdvice {
  const new({
    required this.stain,
    required this.steps,
    required this.citationIds,
  });
  factory fromJson(Map<String, dynamic> j) => StainAdvice(
    stain: j['stain'] as String,
    steps: _strings(j['steps']),
    citationIds: _strings(j['citationIds']),
  );
  final String stain;
  final List<String> steps;
  final List<String> citationIds;
}

@immutable
class Citation {
  const new({required this.id, required this.apa});
  factory fromJson(Map<String, dynamic> j) =>
      Citation(id: j['id'] as String, apa: j['apa'] as String);
  final String id;
  final String apa;
}
