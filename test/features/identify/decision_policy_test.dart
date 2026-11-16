import 'dart:typed_data';

import 'package:fabriscan/features/identify/domain/fabric_classifier.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:flutter_test/flutter_test.dart';

const meta = ModelMeta(
  modelVersion: 'test',
  labels: ['FAB-A', 'FAB-B', 'FAB-C', 'FAB-D', 'not_fabric'],
  temperature: 1,
  tHigh: 0.80,
  tLow: 0.50,
  margin: 0.15,
);

void main() {
  const policy = DecisionPolicy(meta);

  group('DecisionPolicy (ADR-004)', () {
    final cases = <(String, Map<String, double>, ResultState)>[
      (
        'clear winner → A',
        {'FAB-A': 0.86, 'FAB-B': 0.07, 'FAB-C': 0.07},
        ResultState.confident,
      ),
      (
        'exactly t_high, margin ok → A',
        {'FAB-A': 0.80, 'FAB-B': 0.10, 'FAB-C': 0.10},
        ResultState.confident,
      ),
      (
        'high but margin too small → B',
        {'FAB-A': 0.81, 'FAB-B': 0.70},
        ResultState.unsure,
      ),
      (
        'just under t_high → B',
        {'FAB-A': 0.79, 'FAB-B': 0.10},
        ResultState.unsure,
      ),
      ('exactly t_low → B', {'FAB-A': 0.50, 'FAB-B': 0.30}, ResultState.unsure),
      (
        'under t_low → C',
        {'FAB-A': 0.49, 'FAB-B': 0.30},
        ResultState.cantIdentify,
      ),
      (
        'not_fabric on top → C',
        {'not_fabric': 0.55, 'FAB-A': 0.40},
        ResultState.cantIdentify,
      ),
      (
        'confident not_fabric → C',
        {'not_fabric': 0.95, 'FAB-A': 0.05},
        ResultState.cantIdentify,
      ),
      ('empty → C', <String, double>{}, ResultState.cantIdentify),
    ];
    for (final (name, scores, expected) in cases) {
      test(name, () => expect(policy.decide(scores).state, expected));
    }

    test('top 3 never includes not_fabric', () {
      final r = policy.decide({
        'FAB-A': 0.6,
        'not_fabric': 0.2,
        'FAB-B': 0.1,
        'FAB-C': 0.06,
        'FAB-D': 0.04,
      });
      expect(r.state, ResultState.unsure);
      expect(r.topK.map((s) => s.fabricId), ['FAB-A', 'FAB-B', 'FAB-C']);
    });

    test('state C carries no fabrics', () {
      expect(policy.decide({'not_fabric': 0.9, 'FAB-A': 0.1}).topK, isEmpty);
    });

    test('confidence words follow the thresholds', () {
      expect(policy.levelFor(0.9), ConfidenceLevel.high);
      expect(policy.levelFor(0.6), ConfidenceLevel.possible);
      expect(policy.levelFor(0.2), ConfidenceLevel.notSure);
    });
  });

  test('softmax with temperature sums to 1 and flattens', () {
    final p1 = softmax([2, 1, 0]);
    final p2 = softmax([2, 1, 0], temperature: 2);
    expect(p1.reduce((a, b) => a + b), closeTo(1, 1e-9));
    expect(p2.first, lessThan(p1.first));
  });

  group('FakeClassifier', () {
    test('cycle mode gives A, then B, then C', () async {
      final fake = FakeClassifier(
        meta: meta,
        scenario: () => TestScenario.cycle,
      );
      final states = [
        for (var i = 0; i < 3; i++)
          policy.decide(await fake.classify(Uint8List(0))).state,
      ];
      expect(states, [
        ResultState.confident,
        ResultState.unsure,
        ResultState.cantIdentify,
      ]);
    });

    test('scores always sum to 1', () async {
      for (final s in TestScenario.values) {
        final fake = FakeClassifier(meta: meta, scenario: () => s);
        final p = await fake.classify(Uint8List(0));
        expect(p.values.reduce((a, b) => a + b), closeTo(1, 1e-9));
        expect(p.keys.toSet(), meta.labels.toSet());
      }
    });
  });
}
