/// Central physiological configuration for the Body Engine.
///
/// Every constant, weight, calibration slope, and tier boundary lives here.
/// All scores persisted to SQLite record [algorithmVersion] so that calculations
/// are 100% reproducible across historical updates.
class EngineConfig {
  EngineConfig._();

  /// Current version of the physiological science engine.
  /// Increment whenever weights, curves, or baseline formulas change.
  static const String algorithmVersion = '2.0.0';

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. CALIBRATION TIMELINE (Days of Wear)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Days 1 to 3: The engine collects initial nocturnal biometric samples.
  /// No readiness score is displayed to prevent misleading the user.
  static const int minDaysForBaselineCollection = 3;

  /// Days 4 to 13: Provisional readiness scores are displayed with a prominent
  /// "CALIBRATING" badge, as personal standard deviation is still stabilizing.
  static const int minDaysForProvisionalScore = 4;

  /// Day 14+: Full readiness score with high confidence.
  static const int minDaysForFullScore = 14;

  /// Days 30 to 60: Individual 60-day baseline normal range band (mean ± 0.75 SD)
  /// is fully established.
  static const int minDaysForStableNormalRange = 30;
  static const int idealDaysForNormalRange = 60;

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. HRV (HEART RATE VARIABILITY) PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Rolling baseline window length in days for the active HRV comparison.
  static const int hrvRollingBaselineDays = 7;

  /// Minimum valid nights required within the 7-day window to compute rolling baseline.
  static const int hrvMinNightsInRollingBaseline = 3;

  /// Multiplier for standard deviation to define the personal "Normal Range" band.
  /// In athletic sports science (e.g., Plews et al., 2013), normal range is defined as:
  ///   Normal Band = Mean ± 0.75 * SD (applied to ln(RMSSD)).
  // ASSUMPTION: needs calibration
  static const double hrvNormalRangeSdMultiplier = 0.75;

  /// Clamping limit for HRV z-score: bounds extremes from sensor dropouts or arrhythmias.
  static const double hrvZScoreClamp = 3.0;

  /// Adaptive fallback baseline when fewer than 3 nights of data exist (ms).
  /// Based on epidemiological median resting RMSSD for healthy adults.
  // ASSUMPTION: needs calibration
  static const double hrvAdaptiveFallbackRmssd = 55.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. RESTING HEART RATE (RHR) PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Window for short-term resting heart rate baseline.
  static const int rhrRollingBaselineDays = 7;

  /// Adaptive default RHR when zero prior days exist (bpm).
  // ASSUMPTION: needs calibration
  static const double rhrAdaptiveFallbackBpm = 60.0;

  /// Clamping limit for RHR z-score.
  static const double rhrZScoreClamp = 3.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. SLEEP NEED & SUFFICIENCY PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Biological minimum sleep need baseline for adults (minutes = 7.0 hours).
  static const int sleepNeedFloorMinutes = 420;

  /// Default baseline sleep need for adults (minutes = 8.0 hours).
  static const int sleepNeedDefaultMinutes = 480;

  /// Maximum sensible sleep need ceiling for athletes (minutes = 10.0 hours).
  static const int sleepNeedCeilingMinutes = 600;

  /// Fraction of daytime strain that translates into additional sleep need tonight.
  /// Every point of strain beyond moderate (10.0) adds ~2.5 minutes of extra sleep need.
  // ASSUMPTION: needs calibration
  static const double sleepStrainAdditionMultiplier = 2.5;

  /// Fraction of accumulated sleep debt paid back per night (typically 20% to avoid sleep inertia).
  // ASSUMPTION: needs calibration
  static const double sleepDebtPaybackFraction = 0.20;

  /// Maximum sleep debt added to a single night's sleep need (minutes = 90 min).
  static const int sleepDebtMaxAdditionMinutes = 90;

  /// Credit deducted from sleep need for naps taken during the preceding day (fraction).
  // ASSUMPTION: needs calibration
  static const double napCreditFraction = 1.0;

  /// Sleep deficit recovery governor threshold (minutes = 6.0 hours).
  /// Athletes sleeping under 6 hours cannot achieve the top readiness tier (> 66%).
  static const int sleepGovernorThresholdMinutes = 360;

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. READINESS / RECOVERY COMPOSITE SCORING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Composite weights for morning readiness pillars (must sum to 1.0).
  /// Reflects autonomic nervous system balance, cardiovascular basal efficiency,
  /// cellular sleep restoration, and pulmonary stability.
  // ASSUMPTION: needs calibration
  static const double weightHrv = 0.50;
  // ASSUMPTION: needs calibration
  static const double weightRhr = 0.20;
  // ASSUMPTION: needs calibration
  static const double weightSleep = 0.20;
  // ASSUMPTION: needs calibration
  static const double weightRespiratory = 0.10;

  /// Slope factor for the logistic sigmoid mapping function:
  ///   Readiness = 100 / (1 + exp(-sigmoidSlope * compositeZ))
  // ASSUMPTION: needs calibration
  static const double readinessSigmoidSlope = 1.1;

  /// Readiness Tier Boundaries (0 to 100 scale)
  static const double readinessTierHighThreshold = 67.0;     // Optimal / Peak (Green)
  static const double readinessTierModerateThreshold = 34.0; // Moderate / Balanced (Amber)
  // Below 34.0 is Low / Recovery Priority (Red)

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. CARDIOVASCULAR LOAD / STRAIN PARAMETERS (0 to 21 Scale)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Scale factor for Banister/Edwards TRIMP mapping:
  ///   Load = 21 * (1 - exp(-TRIMP / loadScalingFactor))
  /// Calibrated so that a hard 60-minute interval workout yields a load of ~14–16.
  // ASSUMPTION: needs calibration
  static const double loadScalingFactor = 18.0;

  /// Target load bands based on morning readiness:
  /// High readiness (>= 67) targets moderate-to-high strain (14.0 - 18.0).
  /// Moderate readiness (34 - 66) targets balanced strain (10.0 - 14.0).
  /// Low readiness (< 34) recommends restorative load (0.0 - 9.0).
  static const double targetLoadHighBase = 14.0;
  static const double targetLoadModerateBase = 10.0;
  static const double targetLoadLowBase = 6.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. DAYTIME STRESS & ENERGY RESERVE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Minimum days of telemetry required before presenting the Energy Reserve gauge.
  static const int minDaysForEnergyReserve = 10;

  /// Energy Reserve replenishing rate during restful, low-movement periods (% per hour).
  // ASSUMPTION: needs calibration
  static const double energyReserveRestChargePerHour = 1.5;

  /// Energy Reserve draining rate per point of accumulated workout strain.
  // ASSUMPTION: needs calibration
  static const double energyReserveStrainDrainPerPoint = 3.5;
}

