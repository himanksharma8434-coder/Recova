import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/health_source_repository.dart';
import 'body_age_state.dart';

class BodyAgeCubit extends Cubit<BodyAgeState> {
  final HealthSourceRepository repository;

  BodyAgeCubit({required this.repository}) : super(const BodyAgeInitial());

  /// Compute the body age.
  /// [age] and [sex] are the only required user-facing inputs.
  /// All wearable data is gathered automatically from the health database.
  Future<void> compute({
    required int age,
    String? sex,
    double? heightCm,
    double? weightKg,
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    String? smokingStatus,
    int? stressLevel,
  }) async {
    emit(const BodyAgeLoading());

    try {
      final result = await repository.getBodyAge(
        age: age,
        sex: sex,
        heightCm: heightCm,
        weightKg: weightKg,
        waistCircumferenceCm: waistCircumferenceCm,
        hipCircumferenceCm: hipCircumferenceCm,
        smokingStatus: smokingStatus,
        stressLevel: stressLevel,
      );

      if (result == null) {
        // Age < 18
        emit(const BodyAgeUnderage());
      } else {
        emit(BodyAgeLoaded(result: result));
      }
    } catch (e) {
      emit(BodyAgeError(message: e.toString()));
    }
  }

  /// Reset to initial state (for re-entering data).
  void reset() {
    emit(const BodyAgeInitial());
  }
}
