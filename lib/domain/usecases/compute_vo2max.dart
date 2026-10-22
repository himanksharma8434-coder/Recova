/// Estimates VO2 max using a simplified Uth–Sørensen-derived formula:
///
///   VO2max = 15.3 × (HRmax / HRrest)
///
/// Where:
/// - [restingHr7dBaseline]: 7-day average resting HR.
/// - [maxHrFromExercise]: 1 single highest HR from the whole week.
///   If not more than 190, defaults to 190 bpm.
/// - [userAge]: used only for the fallback formula (220 − age) when no
///   exercise data is available. Nullable — if unavailable, and there's no
///   exercise data, VO2max simply cannot be computed.
///
/// ⚠️ This is an ESTIMATE. It should be visually/textually flagged as such
/// in any UI that displays it.
class ComputeVo2Max {
  const ComputeVo2Max();

  /// Returns the estimated VO2 max, or null if insufficient data.
  ///
  /// [restingHr7dBaseline] is the average resting HR over 7 days.
  /// [maxHrFromExercise] is the 1 single highest HR from the whole week (default 190 bpm if <= 190).
  double? call({
    required double? restingHr7dBaseline,
    required double? maxHrFromExercise,
    int? userAge,
  }) {
    final hrRest = restingHr7dBaseline;
    if (hrRest == null || hrRest <= 0) return null;

    double hrMax;
    if (maxHrFromExercise != null && maxHrFromExercise > 0) {
      hrMax = maxHrFromExercise > 190.0 ? maxHrFromExercise : 190.0;
    } else if (userAge != null && userAge > 0 && userAge < 120) {
      final ageMax = 220.0 - userAge;
      hrMax = ageMax > 190.0 ? ageMax : 190.0;
    } else {
      return null; // Cannot compute without HRmax or age
    }

    // Guard against unreasonable ratios
    if (hrMax <= hrRest) return null;

    final vo2 = 15.3 * (hrMax / hrRest);
    if (vo2 < 15.0 || vo2 > 85.0) return null;

    return vo2;
  }
}
