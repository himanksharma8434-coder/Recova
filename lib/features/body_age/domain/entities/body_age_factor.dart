/// Health factors contributing to Body Age calculation.
enum BodyAgeFactor {
  vo2Max,
  restingHeartRate,
  vigorousActivity,
  bodyComposition;

  String get displayName {
    switch (this) {
      case BodyAgeFactor.vo2Max:
        return 'VO2 Max';
      case BodyAgeFactor.restingHeartRate:
        return 'Resting Heart Rate';
      case BodyAgeFactor.vigorousActivity:
        return 'Vigorous Activity';
      case BodyAgeFactor.bodyComposition:
        return 'Body Composition';
    }
  }

  String get description {
    switch (this) {
      case BodyAgeFactor.vo2Max:
        return 'Cardiorespiratory capacity compared to population norms.';
      case BodyAgeFactor.restingHeartRate:
        return '30-day baseline resting pulse indicating cardiovascular strain.';
      case BodyAgeFactor.vigorousActivity:
        return 'Weekly minutes & frequency of high-intensity aerobic exercise.';
      case BodyAgeFactor.bodyComposition:
        return 'Body fat percentage (or BMI) reflecting metabolic health.';
    }
  }
}
