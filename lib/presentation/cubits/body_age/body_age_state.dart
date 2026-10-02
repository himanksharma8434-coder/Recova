import 'package:equatable/equatable.dart';
import '../../../domain/entities/body_age_result.dart';

/// States for the Body Age screen.
sealed class BodyAgeState extends Equatable {
  const BodyAgeState();

  @override
  List<Object?> get props => [];
}

/// Initial state — awaiting user's age/sex input.
class BodyAgeInitial extends BodyAgeState {
  const BodyAgeInitial();
}

/// Computing body age from wearable data.
class BodyAgeLoading extends BodyAgeState {
  const BodyAgeLoading();
}

/// Body age computed successfully.
class BodyAgeLoaded extends BodyAgeState {
  final BodyAgeResult result;
  const BodyAgeLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

/// User is under 18 — body age not applicable.
class BodyAgeUnderage extends BodyAgeState {
  const BodyAgeUnderage();
}

/// Error computing body age.
class BodyAgeError extends BodyAgeState {
  final String message;
  const BodyAgeError({required this.message});

  @override
  List<Object?> get props => [message];
}
