import 'dart:convert';

import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the bundled catalog once at startup (ADR-006). Works offline.
class CatalogRepository {
  const new(this._bundle);
  final AssetBundle _bundle;

  static const assetPath = 'assets/content/catalog.json';

  Future<Catalog> load() async {
    final raw = await _bundle.loadString(assetPath);
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(rootBundle),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(catalogRepositoryProvider).load(),
);
