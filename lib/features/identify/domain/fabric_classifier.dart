import 'dart:typed_data';

import 'package:fabriscan/features/identify/domain/identification.dart';

/// Identifies fabric in a photo. Returns calibrated probabilities per label.
/// The real TFLite implementation (M3) runs in a background isolate.
abstract interface class FabricClassifier {
  String get modelVersion;
  Future<Map<String, double>> classify(Uint8List imageBytes);
}

/// Which answer the stand-in scanner gives (test builds only).
enum TestScenario { cycle, confident, unsure, cantIdentify }

/// Development stand-in until the trained model exists (M3). Returns fixed,
/// realistic score vectors so every result state can be tested on a phone.
class FakeClassifier implements FabricClassifier {
  new({required this.meta, required this._scenario});

  final ModelMeta meta;
  final TestScenario Function() _scenario;
  int _count = 0;

  @override
  String get modelVersion => meta.modelVersion;

  /// The state the next [classify] call will produce.
  ResultState get nextState {
    final s = _scenario();
    return switch (s) {
      TestScenario.confident => ResultState.confident,
      TestScenario.unsure => ResultState.unsure,
      TestScenario.cantIdentify => ResultState.cantIdentify,
      TestScenario.cycle => ResultState.values[_count % 3],
    };
  }

  @override
  Future<Map<String, double>> classify(Uint8List imageBytes) async {
    final state = nextState;
    _count++;
    final fabrics = meta.labels.where((l) => l != ModelMeta.notFabric).toList();
    String pick(String id, int fallback) =>
        fabrics.contains(id) ? id : fabrics[fallback % fabrics.length];
    final scores = <String, double>{};
    void put(String id, double p) => scores[id] = (scores[id] ?? 0) + p;
    switch (state) {
      case ResultState.confident:
        put(pick('FAB-SATIN', 0), 0.86);
        put(pick('FAB-TAFFETA', 1), 0.07);
        put(pick('FAB-CHIFFON', 2), 0.03);
      case ResultState.unsure:
        put(pick('FAB-PINA', 0), 0.58);
        put(pick('FAB-PINASEDA', 1), 0.27);
        put(pick('FAB-JUSI', 2), 0.09);
      case ResultState.cantIdentify:
        put(ModelMeta.notFabric, 0.58);
        put(pick('FAB-LINEN', 3), 0.14);
        put(pick('FAB-COTTON', 4), 0.09);
    }
    final rest = 1 - scores.values.fold<double>(0, (a, b) => a + b);
    final others = meta.labels.where((l) => !scores.containsKey(l)).toList();
    for (final l in others) {
      scores[l] = rest / others.length;
    }
    return scores;
  }
}
