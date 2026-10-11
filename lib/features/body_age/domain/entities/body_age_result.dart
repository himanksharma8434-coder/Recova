import 'package:equatable/equatable.dart';
import 'body_age_factor.dart';

/// Complete result produced by the Body Age Calculation Engine.
class FitnessBodyAgeResult extends Equatable {
  final double bodyAge;
  final int chronologicalAge;
  final double difference; // bodyAge - chronologicalAge (negative = younger)
  final double? achievableBodyAge;
  final Map<BodyAgeFactor, double> factorAges;
  final List<BodyAgeFactor> topImprovements;
  final List<BodyAgeFactor> missingFactors;
  final DateTime calculatedAt;

  const FitnessBodyAgeResult({
    required this.bodyAge,
    required this.chronologicalAge,
    required this.difference,
    this.achievableBodyAge,
    required this.factorAges,
    required this.topImprovements,
    required this.missingFactors,
    required this.calculatedAt,
  });

  bool get isYounger => difference < 0;
  bool get isOlder => difference > 0;
  bool get isSame => difference == 0;

  Map<String, dynamic> toJson() => {
        'body_age': bodyAge,
        'chronological_age': chronologicalAge,
        'difference': difference,
        'achievable_body_age': achievableBodyAge,
        'factor_ages': factorAges.map(
          (k, v) => MapEntry(k.name, v),
        ),
        'top_improvements': topImprovements.map((f) => f.name).toList(),
        'missing_factors': missingFactors.map((f) => f.name).toList(),
        'calculated_at': calculatedAt.toIso8601String(),
      };

  factory FitnessBodyAgeResult.fromJson(Map<String, dynamic> json) {
    final factorAgesRaw = json['factor_ages'] as Map<String, dynamic>? ?? {};
    final factorAges = <BodyAgeFactor, double>{};
    for (final entry in factorAgesRaw.entries) {
      final factor = BodyAgeFactor.values.firstWhere(
        (f) => f.name == entry.key,
        orElse: () => BodyAgeFactor.vo2Max,
      );
      factorAges[factor] = (entry.value as num).toDouble();
    }

    final topImprovementsRaw =
        (json['top_improvements'] as List<dynamic>?) ?? [];
    final topImprovements = topImprovementsRaw
        .map((e) => BodyAgeFactor.values.firstWhere(
              (f) => f.name == e,
              orElse: () => BodyAgeFactor.vo2Max,
            ))
        .toList();

    final missingFactorsRaw =
        (json['missing_factors'] as List<dynamic>?) ?? [];
    final missingFactors = missingFactorsRaw
        .map((e) => BodyAgeFactor.values.firstWhere(
              (f) => f.name == e,
              orElse: () => BodyAgeFactor.vo2Max,
            ))
        .toList();

    return FitnessBodyAgeResult(
      bodyAge: (json['body_age'] as num).toDouble(),
      chronologicalAge: (json['chronological_age'] as num).toInt(),
      difference: (json['difference'] as num).toDouble(),
      achievableBodyAge: (json['achievable_body_age'] as num?)?.toDouble(),
      factorAges: factorAges,
      topImprovements: topImprovements,
      missingFactors: missingFactors,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        bodyAge,
        chronologicalAge,
        difference,
        achievableBodyAge,
        factorAges,
        topImprovements,
        missingFactors,
        calculatedAt,
      ];
}
