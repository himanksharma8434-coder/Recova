/// Estimates VO2 max using a simplified Uth–Sørensen-derived formula:
///
///   VO2max ≈ 15 × (HRmax / HRrest)
///
/// Where:
/// - [restingHr7dAvg]: average resting HR across all 7 days of the week.
/// - [maxHrTop3Avg]: average of the highest heart rates from the top 3 days.
///   Nullable — may not exist if the user hasn't exercised enough.
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
  /// [maxHrFromExercise] is the average of the top 3 daily max HRs (or single peak if fewer days).
  double? call({
    required double? restingHr7dBaseline,
    required double? maxHrFromExercise,
    int? userAge,
  }) {
    final hrRest = restingHr7dBaseline;
    if (hrRest == null || hrRest <= 0) return null;

    double hrMax;
    if (maxHrFromExercise != null && maxHrFromExercise > 0) {
      hrMax = maxHrFromExercise;
    } else if (userAge != null && userAge > 0 && userAge < 120) {
      hrMax = 220.0 - userAge;
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
