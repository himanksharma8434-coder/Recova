import 'package:equatable/equatable.dart';

/// Confidence level for the body age estimate.
enum BodyAgeConfidence {
  high,
  medium,
  low;

  String get label => name.toUpperCase();
}

/// Derived body-composition and fitness metrics.
class BodyAgeDerivedMetrics extends Equatable {
  final double? bmi;
  final double? whtr;
  final double? whr;
  final double? bmrKcal;
  final double? vo2maxUsed;

  const BodyAgeDerivedMetrics({
    this.bmi,
    this.whtr,
    this.whr,
    this.bmrKcal,
    this.vo2maxUsed,
  });

  Map<String, dynamic> toJson() => {
        'bmi': bmi,
        'whtr': whtr,
        'whr': whr,
        'bmr_kcal': bmrKcal,
        'vo2max_used': vo2maxUsed,
      };

  @override
  List<Object?> get props => [bmi, whtr, whr, bmrKcal, vo2maxUsed];
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

  Map<String, dynamic> toJson() => {
        'category': category,
        'weight_used': weightUsed,
        'percentile_estimate': percentileEstimate,
        'offset_years': offsetYears,
        'inputs_used': inputsUsed,
        'note': note,
      };

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

  Map<String, dynamic> toJson() => {
        'action': action,
        'expected_effect': expectedEffect,
        'timeframe': timeframe,
      };

  @override
  List<Object?> get props => [action];
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

  /// Convert result to strictly valid JSON matching Section 8 schema.
  Map<String, dynamic> toJson() => {
        'chronological_age': chronologicalAge,
        'body_age': bodyAge,
        'age_difference_years': ageDifferenceYears,
        'confidence': confidence.name,
        'components': components.map((c) => c.toJson()).toList(),
        'derived_metrics': derivedMetrics.toJson(),
        'missing_inputs': missingInputs,
        'data_quality_flags': dataQualityFlags,
        'top_levers': topLevers.map((l) => l.toJson()).toList(),
        'disclaimer': disclaimer,
      };

  /// Generates the plain-language user report (Part B, ~120-200 words).
  String generateUserReport() {
    final buffer = StringBuffer();
    // 1. Result line
    if (ageDifferenceYears == 0) {
      buffer.writeln(
          'Your estimated body age is ${bodyAge.toStringAsFixed(1)}, matching your actual age of $chronologicalAge.');
    } else {
      final direction = ageDifferenceYears < 0 ? 'younger' : 'older';
      buffer.writeln(
          'Your estimated body age is ${bodyAge.toStringAsFixed(1)}, which is ${ageDifferenceYears.abs().toStringAsFixed(1)} years $direction than your actual age of $chronologicalAge.');
    }
    buffer.writeln();

    // 2. Strengths
    final strList = strengths;
    if (strList.isNotEmpty) {
      final strNames =
          strList.map((c) => c.category.toLowerCase()).join(' and ');
      buffer.writeln(
          'Key strengths: Your $strNames scored favorably against population norms, helping pull your body age down.');
    } else {
      buffer.writeln(
          'Key strengths: You have a baseline to build upon across tracked biometric markers.');
    }
    buffer.writeln();

    // 3. Weaknesses
    final weakList = weaknesses;
    if (weakList.isNotEmpty) {
      final weakNames =
          weakList.map((c) => c.category.toLowerCase()).join(' and ');
      buffer.writeln(
          'Areas for improvement: Your $weakNames elevated your body age estimate.');
    } else {
      buffer.writeln(
          'Areas for improvement: Consistent lifestyle habits will help sustain your current functional fitness level.');
    }
    buffer.writeln();

    // 4. Top 3 levers
    buffer.writeln('Top actionable levers:');
    for (int i = 0; i < topLevers.length; i++) {
      final lever = topLevers[i];
      buffer.writeln(
          '${i + 1}. ${lever.action} (${lever.expectedEffect} over ${lever.timeframe}).');
    }
    buffer.writeln();

    // 5. Confidence & single most useful missing input
    final missingNote = missingInputs.isNotEmpty
        ? ' Providing ${missingInputs.first.toLowerCase()} would most improve accuracy.'
        : ' Wearable coverage across key biometric categories is comprehensive.';
    buffer.writeln(
        'Confidence level: ${confidence.name.toUpperCase()}.$missingNote');
    buffer.writeln();

    // 6. Disclaimer
    buffer.writeln(disclaimer);

    return buffer.toString().trim();
  }

  @override
  List<Object?> get props => [bodyAge, chronologicalAge, confidence];
}
