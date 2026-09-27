import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Backwards-compatible color definitions.
/// All values now alias to the [Tok] design token system.
/// Screens should migrate to [Tok] directly over time.
class RecovaColors {
  RecovaColors._();

  // ── Surface Architecture ───────────────────────────────────────────────
  static const Color canvasBase = Tok.canvasBase;
  static const Color surfaceElevation1 = Tok.glassFill;
  static const Color surfaceElevation2 = Tok.glassFillRecessed;
  static const Color surfaceElevation3 = Tok.glassFillElevated;
  static const Color surfaceContainer = Tok.glassFillElevated;
  static const Color surfaceContainerHigh = Tok.glassFillElevated;
  static const Color surfaceContainerHighest = Tok.glassFillElevated;

  // ── Structural Borders ─────────────────────────────────────────────────
  static const Color borderSubtle = Tok.glassBorder;
  static const Color borderMedium = Tok.glassBorderBright;
  static const Color borderHover = Tok.glassBorderBright;
  static const Color surfaceOverlay = Tok.glassFillRecessed;

  // ── Liquid Glass Standard Colors ───────────────────────────────────────
  static const Color liquidGlassFill = Tok.liquidGlassFill;
  static const Color liquidGlassBorder = Tok.liquidGlassBorder;
  static const Color liquidGlassTopHighlight = Tok.liquidGlassTopHighlight;
  static const Color liquidGlassBottomReflection = Tok.liquidGlassBottomReflection;
  static const Color liquidGlassOuterShadow = Tok.liquidGlassOuterShadow;

  // ── Typography ─────────────────────────────────────────────────────────
  static const Color onSurface = Tok.textPrimary;
  static const Color onSurfaceVariant = Tok.textSecondary;
  static const Color textPrimary = Tok.textPrimary;
  static const Color textSecondary = Tok.textSecondary;
  static const Color textTertiary = Tok.textTertiary;
  static const Color textMuted = Tok.textMuted;

  // ── Accent (was Nothing Red → now neon accent for key highlights) ──────
  static const Color nothingRed = Tok.recoverySuppressed;
  static const Color nothingRedContainer = Tok.recoverySuppressedSurface;
  static const Color nothingRedBorder = Tok.recoverySuppressedGlow;

  // ── Monochrome Scales ─────────────────────────────────────────────────
  static const Color monochromeWhite = Tok.textPrimary;
  static const Color monochromeSilver = Tok.textSecondary;
  static const Color monochromeGray = Tok.textTertiary;
  static const Color monochromeDark = Tok.textMuted;

  // ── Semantic Tokens ────────────────────────────────────────────────────
  // Primary / Recovery
  static const Color recoveryEmerald = Tok.neonAccent;
  static const Color recoveryEmeraldBright = Tok.neonAccent;
  static const Color recoveryEmeraldDim = Tok.neonAccentDim;
  static const Color recoveryEmeraldContainer = Tok.neonAccentSurface;
  static const Color recoveryEmeraldBorder = Tok.neonAccentGlow;

  // Sleep / Restorative
  static const Color restorativeAzure = Tok.accentBlue;
  static const Color restorativeAzureBright = Tok.accentBlue;
  static const Color restorativeAzureSky = Tok.accentBlue;
  static const Color restorativeAzureContainer = Tok.accentBlueSurface;
  static const Color restorativeAzureBorder = Tok.accentBlueSurface;

  // Strain / Workouts
  static const Color kineticAmber = Tok.recoveryModerate;
  static const Color kineticAmberGold = Tok.recoveryModerate;
  static const Color kineticAmberLight = Tok.recoveryModerate;
  static const Color kineticAmberContainer = Tok.recoveryModerateSurface;
  static const Color kineticAmberBorder = Tok.recoveryModerateGlow;

  // Suppressed / Warning
  static const Color stressCrimson = Tok.recoverySuppressed;
  static const Color stressCrimsonContainer = Tok.recoverySuppressedSurface;
  static const Color stressCrimsonBorder = Tok.recoverySuppressedGlow;

  // Secondary / Predictive
  static const Color neuralViolet = Tok.textSecondary;
  static const Color neuralVioletContainer = Tok.glassFill;
  static const Color neuralVioletBorder = Tok.glassBorder;

  // ── Ambient Glow ───────────────────────────────────────────────────────
  static const Color glowRecovery = Tok.neonAccentGlow;
  static const Color glowStrain = Tok.recoveryModerateGlow;
  static const Color glowSleep = Tok.accentBlueSurface;
}

/// Recovery score tier classification — bridged to new token colors.
enum RecoveryTier {
  optimal('OPTIMAL RECOVERY', 'PRIMED FOR STRAIN', Tok.recoveryOptimal,
      Tok.recoveryOptimalSurface, Tok.recoveryOptimalGlow),
  moderate('MODERATE RECOVERY', 'MAINTAIN LOAD', Tok.recoveryModerate,
      Tok.recoveryModerateSurface, Tok.recoveryModerateGlow),
  suppressed('SUPPRESSED RECOVERY', 'ACTIVE REST RECOMMENDED',
      Tok.recoverySuppressed, Tok.recoverySuppressedSurface, Tok.recoverySuppressedGlow),
  calibrating('CALIBRATING', 'SYNCING BIOMETRICS', Tok.recoveryCalibrating,
      Tok.glassFillRecessed, Tok.glassBorder);

  final String label;
  final String statusSubtitle;
  final Color color;
  final Color containerColor;
  final Color borderColor;

  const RecoveryTier(this.label, this.statusSubtitle, this.color,
      this.containerColor, this.borderColor);

  static RecoveryTier fromScore(double? score) {
    if (score == null || score <= 0) return RecoveryTier.calibrating;
    if (score <= 33) return RecoveryTier.suppressed;
    if (score <= 66) return RecoveryTier.moderate;
    return RecoveryTier.optimal;
  }
}
