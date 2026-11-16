import 'dart:convert';

import 'package:fabriscan/features/identify/domain/fabric_classifier.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `assets/model/model_meta.json` + `labels.txt` (architecture §5.4).
final modelMetaProvider = FutureProvider<ModelMeta>((ref) async {
  final meta = await rootBundle.loadString('assets/model/model_meta.json');
  final labels = await rootBundle.loadString('assets/model/labels.txt');
  return ModelMeta.fromJson(jsonDecode(meta) as Map<String, dynamic>, [
    for (final l in const LineSplitter().convert(labels))
      if (l.trim().isNotEmpty) l.trim(),
  ]);
});

final decisionPolicyProvider = FutureProvider<DecisionPolicy>(
  (ref) async => DecisionPolicy(await ref.watch(modelMetaProvider.future)),
);

/// Test builds only: which answer the stand-in scanner gives.
class TestScenarioNotifier extends Notifier<TestScenario> {
  @override
  TestScenario build() => TestScenario.cycle;
  TestScenario get value => state;
  set value(TestScenario s) => state = s;
}

final testScenarioProvider =
    NotifierProvider<TestScenarioNotifier, TestScenario>(
      TestScenarioNotifier.new,
    );

/// The fabric scanner. Until the trained model ships (M3) this is the
/// [FakeClassifier]; `model_meta.json` marks that build as a stand-in.
final classifierProvider = FutureProvider<FabricClassifier>((ref) async {
  final meta = await ref.watch(modelMetaProvider.future);
  return FakeClassifier(
    meta: meta,
    scenario: () => ref.read(testScenarioProvider),
  );
});
