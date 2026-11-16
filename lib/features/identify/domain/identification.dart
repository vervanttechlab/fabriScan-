import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Scanner settings from `assets/model/model_meta.json` (ADR-004). Thresholds
/// are data, chosen on the validation set; they are never hard-coded.
@immutable
class ModelMeta {
  const new({
    required this.modelVersion,
    required this.labels,
    required this.temperature,
    required this.tHigh,
    required this.tLow,
    required this.margin,
    this.inputSize = 224,
    this.isStandIn = false,
  });

  factory fromJson(Map<String, dynamic> j, List<String> labels) => ModelMeta(
    modelVersion: j['modelVersion'] as String,
    labels: labels,
    temperature: (j['temperature'] as num).toDouble(),
    tHigh: (j['t_high'] as num).toDouble(),
    tLow: (j['t_low'] as num).toDouble(),
    margin: (j['margin'] as num).toDouble(),
    inputSize: (j['inputSize'] as num?)?.toInt() ?? 224,
    isStandIn: ((j['status'] as String?) ?? '').contains('[PLACEHOLDER]'),
  );

  final String modelVersion;

  /// Class order of the model output; includes [notFabric].
  final List<String> labels;
  final double temperature;
  final double tHigh;
  final double tLow;
  final double margin;
  final int inputSize;

  /// True for the development stand-in (no trained model yet).
  final bool isStandIn;

  static const notFabric = 'not_fabric';
}

/// Result states from PRD §6.
enum ResultState {
  /// A: confident, one answer.
  confident,

  /// B: unsure, top 3 to compare.
  unsure,

  /// C: can't identify; nothing is saved.
  cantIdentify,
}

/// How a single score is described to users. Never a percentage.
enum ConfidenceLevel { high, possible, notSure }

@immutable
class ScoredFabric {
  const new(this.fabricId, this.score);
  final String fabricId;
  final double score;

  Map<String, Object> toJson() => {'fabricId': fabricId, 'score': score};

  @override
  bool operator ==(Object other) =>
      other is ScoredFabric &&
      other.fabricId == fabricId &&
      other.score == score;

  @override
  int get hashCode => Object.hash(fabricId, score);
}

@immutable
class IdentificationResult {
  const new({
    required this.state,
    required this.topK,
    required this.modelVersion,
  });

  final ResultState state;

  /// Up to 3 fabrics, best first. Never contains `not_fabric`.
  final List<ScoredFabric> topK;
  final String modelVersion;

  ScoredFabric? get top => topK.firstOrNull;
}

/// Turns calibrated class probabilities into result state A / B / C (ADR-004).
class DecisionPolicy {
  const new(this.meta);
  final ModelMeta meta;

  IdentificationResult decide(Map<String, double> probabilities) {
    final ranked = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final fabrics = [
      for (final e in ranked)
        if (e.key != ModelMeta.notFabric) ScoredFabric(e.key, e.value),
    ].take(3).toList();

    final top1 = ranked.isEmpty ? null : ranked.first;
    final ResultState state;
    if (top1 == null ||
        top1.key == ModelMeta.notFabric ||
        top1.value < meta.tLow) {
      state = ResultState.cantIdentify;
    } else {
      final top2 = ranked.length > 1 ? ranked[1].value : 0.0;
      state = top1.value >= meta.tHigh && (top1.value - top2) >= meta.margin
          ? ResultState.confident
          : ResultState.unsure;
    }
    return IdentificationResult(
      state: state,
      topK: state == ResultState.cantIdentify ? const [] : fabrics,
      modelVersion: meta.modelVersion,
    );
  }

  /// Word shown next to one option's score.
  ConfidenceLevel levelFor(double score) => score >= meta.tHigh
      ? ConfidenceLevel.high
      : score >= meta.tLow
      ? ConfidenceLevel.possible
      : ConfidenceLevel.notSure;
}

/// Temperature-scaled softmax for raw model logits (used by the real model).
List<double> softmax(List<double> logits, {double temperature = 1}) {
  if (logits.isEmpty) return const [];
  final scaled = [for (final l in logits) l / temperature];
  final m = scaled.reduce(math.max);
  final exps = [for (final s in scaled) math.exp(s - m)];
  final sum = exps.reduce((a, b) => a + b);
  return [for (final e in exps) e / sum];
}
