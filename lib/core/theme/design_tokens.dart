import 'package:flutter/material.dart';

class Tok {
  Tok._();

  static const Color canvasBase = Color(0xFF0A0E14);
  static const Color canvasDeep = Color(0xFF060A10);

  static const Color glassFill = Color(0x14FFFFFF);        
  static const Color glassFillElevated = Color(0x1AFFFFFF); 
  static const Color glassFillRecessed = Color(0x0AFFFFFF); 

  static const Color glassBorder = Color(0x1AFFFFFF);       // 10% white
  static const Color glassBorderBright = Color(0x33FFFFFF);  // 20% white — top edge specular

  static const Color glassGlow = Color(0x0DFFFFFF);        // 5% white

  static const double glassBlurSigma = 24.0;
  static const double glassBlurSigmaLight = 12.0;

  static const Color neonAccent = Color(0xFF00E5CC);
  static const Color neonAccentDim = Color(0xFF00B8A3);
  static const Color neonAccentGlow = Color(0x3300E5CC);     // 20% for glows
  static const Color neonAccentSurface = Color(0x1A00E5CC);  // 10% for containers

  static const Color accentBlue = Color(0xFF4A9EFF);         // Informational
  static const Color accentBlueSurface = Color(0x1A4A9EFF);

  static const Color recoveryOptimal = Color(0xFF00E5CC);    // Matches neon accent
  static const Color recoveryOptimalGlow = Color(0x3300E5CC);
  static const Color recoveryOptimalSurface = Color(0x1A00E5CC);

  static const Color recoveryModerate = Color(0xFFE5A800);   // Warm amber
  static const Color recoveryModerateGlow = Color(0x33E5A800);
  static const Color recoveryModerateSurface = Color(0x1AE5A800);

  static const Color recoverySuppressed = Color(0xFFFF4C6E); // Coral-rose, not raw red
  static const Color recoverySuppressedGlow = Color(0x33FF4C6E);
  static const Color recoverySuppressedSurface = Color(0x1AFF4C6E);

  static const Color recoveryCalibrating = Color(0xFF5A6070); // Muted steel

  // ── Typography Colors ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F2F5);    // Near-white, not pure white
  static const Color textSecondary = Color(0xFFB0B8C4);   // Silver-blue
  static const Color textTertiary = Color(0xFF6B7280);    // Cool gray
  static const Color textMuted = Color(0xFF3D4350);       // Very muted

  // ── Spacing Scale (4px base) ────────────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  // ── Border Radii ────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusFull = 100;

  // ── Animation Durations ─────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animEntrance = Duration(milliseconds: 500);

  /// Stagger delay between sequential card entrances.
  static const Duration staggerDelay = Duration(milliseconds: 60);
}

class TokType {
  TokType._();

  /// Big hero number style — recovery score, VO2max readout.
  static const TextStyle displayNumber = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w200,
    letterSpacing: -2.0,
    color: Tok.textPrimary,
    height: 1.0,
    fontFamily: 'Inter',
  );

  /// Large metric readout (e.g. "72" bpm on cards).
  static const TextStyle metricLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.0,
    color: Tok.textPrimary,
    height: 1.1,
    fontFamily: 'Inter',
  );

  /// Medium metric readout for secondary numbers.
  static const TextStyle metricMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: Tok.textPrimary,
    fontFamily: 'Inter',
  );

  /// Screen heading.
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: Tok.textPrimary,
    fontFamily: 'Inter',
  );

  /// Section heading — ALL CAPS label.
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: Tok.textTertiary,
    fontFamily: 'Inter',
  );

  /// Card title.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: Tok.textPrimary,
    fontFamily: 'Inter',
  );

  /// Body text.
  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Tok.textSecondary,
    fontFamily: 'Inter',
  );

  /// Body small.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: Tok.textSecondary,
    fontFamily: 'Inter',
  );

  /// Caption / tag labels.
  static const TextStyle caption = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: Tok.textTertiary,
    fontFamily: 'Inter',
  );

  /// Unit suffix (%, bpm, ms).
  static const TextStyle unit = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Tok.textTertiary,
    fontFamily: 'Inter',
  );

  /// Pill / badge label.
  static const TextStyle badge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    fontFamily: 'Inter',
  );

  /// Formula / monospace.
  static const TextStyle mono = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    fontFamily: 'monospace',
    color: Tok.textTertiary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECOVERY TIER (Updated with palette-harmonized colors)
// ═══════════════════════════════════════════════════════════════════════════════

enum RecoveryTierV2 {
  optimal(
    'OPTIMAL RECOVERY',
    'PRIMED FOR STRAIN',
    Tok.recoveryOptimal,
    Tok.recoveryOptimalSurface,
    Tok.recoveryOptimalGlow,
  ),
  moderate(
    'MODERATE RECOVERY',
    'MAINTAIN LOAD',
    Tok.recoveryModerate,
    Tok.recoveryModerateSurface,
    Tok.recoveryModerateGlow,
  ),
  suppressed(
    'SUPPRESSED RECOVERY',
    'ACTIVE REST RECOMMENDED',
    Tok.recoverySuppressed,
    Tok.recoverySuppressedSurface,
    Tok.recoverySuppressedGlow,
  ),
  calibrating(
    'CALIBRATING',
    'SYNCING BIOMETRICS',
    Tok.recoveryCalibrating,
    Color(0x145A6070),
    Color(0x005A6070),
  );

  final String label;
  final String statusSubtitle;
  final Color color;
  final Color containerColor;
  final Color glowColor;

  const RecoveryTierV2(
    this.label,
    this.statusSubtitle,
    this.color,
    this.containerColor,
    this.glowColor,
  );

  static RecoveryTierV2 fromScore(double? score) {
    if (score == null || score <= 0) return RecoveryTierV2.calibrating;
    if (score <= 33) return RecoveryTierV2.suppressed;
    if (score <= 66) return RecoveryTierV2.moderate;
    return RecoveryTierV2.optimal;
  }
}
