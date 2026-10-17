import 'package:equatable/equatable.dart';
import '../../../domain/entities/body_age_result.dart';
import '../../../domain/repositories/body_measurement_repository.dart';

abstract class BodyAgeCheckinState extends Equatable {
  const BodyAgeCheckinState();

  @override
  List<Object?> get props => [];
}

class BodyAgeCheckinInitial extends BodyAgeCheckinState {
  const BodyAgeCheckinInitial();
}

class BodyAgeCheckinPrompt extends BodyAgeCheckinState {
  final BodyMeasurementEntry? lastMeasurement;
  final bool isKgUnit;
  final double? prefilledWeight;
  final double? prefilledBodyFat;

  const BodyAgeCheckinPrompt({
    this.lastMeasurement,
    this.isKgUnit = true,
    this.prefilledWeight,
    this.prefilledBodyFat,
  });

  @override
  List<Object?> get props => [
        lastMeasurement,
        isKgUnit,
        prefilledWeight,
        prefilledBodyFat,
      ];
}

class BodyAgeCheckinSaving extends BodyAgeCheckinState {
  const BodyAgeCheckinSaving();
}

class BodyAgeCheckinSuccess extends BodyAgeCheckinState {
  final FitnessBodyAgeResult result;
  final double? previousBodyAge;
  final double newBodyAge;
  final double deltaFromPrevious;

  const BodyAgeCheckinSuccess({
    required this.result,
    this.previousBodyAge,
    required this.newBodyAge,
    required this.deltaFromPrevious,
  });

  @override
  List<Object?> get props => [
        result,
        previousBodyAge,
        newBodyAge,
        deltaFromPrevious,
      ];
}

class BodyAgeCheckinDismissed extends BodyAgeCheckinState {
  final String reason; // 'snoozed' | 'skipped' | 'saved'

  const BodyAgeCheckinDismissed(this.reason);

  @override
  List<Object?> get props => [reason];
}
