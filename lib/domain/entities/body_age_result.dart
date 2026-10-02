import 'package:equatable/equatable.dart';

/// Confidence level for the body age estimate.
enum BodyAgeConfidence {
  high,
  medium,
  low;

  String get label => name.toUpperCase();
}

/// A single scored category contributing to body age.
class BodyAgeComponent extends Equatable {
  final String category;
  final double weightUsed;
  final String percentileEstimate;
  final double offsetYears;
  final List<String> inputsUsed;
  final String note;

  const BodyAgeComponent({
    required this.category,
    required this.weightUsed,
    required this.percentileEstimate,
    required this.offsetYears,
    required this.inputsUsed,
    required this.note,
  });

  @override
  List<Object?> get props => [category];
}

/// A concrete, measurable action to lower body age.
class BodyAgeLever extends Equatable {
  final String action;
  final String expectedEffect;
  final String timeframe;

  const BodyAgeLever({
    required this.action,
    required this.expectedEffect,
    required this.timeframe,
  });

  @override
  List<Object?> get props => [action];
}

/// Derived body-composition and fitness metrics.
class BodyAgeDerivedMetrics extends Equatable {
  final double? bmi;
  final double? bmrKcal;
  final double? vo2maxUsed;

  const BodyAgeDerivedMetrics({
    this.bmi,
    this.bmrKcal,
    this.vo2maxUsed,
  });

  @override
  List<Object?> get props => [bmi, bmrKcal, vo2maxUsed];
}

/// Complete result of the Body Age Estimation Engine.
class BodyAgeResult extends Equatable {
  final int chronologicalAge;
  final double bodyAge;
  final double ageDifferenceYears;
  final BodyAgeConfidence confidence;
  final List<BodyAgeComponent> components;
  final BodyAgeDerivedMetrics derivedMetrics;
  final List<String> missingInputs;
  final List<String> dataQualityFlags;
  final List<BodyAgeLever> topLevers;
  final String disclaimer;

  const BodyAgeResult({
    required this.chronologicalAge,
    required this.bodyAge,
    required this.ageDifferenceYears,
    required this.confidence,
    required this.components,
    required this.derivedMetrics,
    required this.missingInputs,
    required this.dataQualityFlags,
    required this.topLevers,
    required this.disclaimer,
  });

  /// Components that pulled age DOWN (strengths).
  List<BodyAgeComponent> get strengths =>
      components.where((c) => c.offsetYears < 0).toList()
        ..sort((a, b) => a.offsetYears.compareTo(b.offsetYears));

  /// Components that pulled age UP (weaknesses).
  List<BodyAgeComponent> get weaknesses =>
      components.where((c) => c.offsetYears > 0).toList()
        ..sort((a, b) => b.offsetYears.compareTo(a.offsetYears));

  @override
  List<Object?> get props => [bodyAge, chronologicalAge, confidence];
}
