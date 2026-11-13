import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/health_monitor_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/liquid_glass.dart';
import 'methodology_sheet.dart';
import 'trust_center_screen.dart';

/// Screen presenting the unified Health Monitor panel for the 5 overnight vitals:
/// 1. HRV (rMSSD)
/// 2. Resting Heart Rate (Nadir)
/// 3. Respiratory Rate
/// 4. Blood Oxygen (SpO2)
/// 5. Skin Temperature Deviation
class HealthMonitorScreen extends StatelessWidget {
  final DerivedMetricSummary? summary;

  const HealthMonitorScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final report = summary?.healthMonitorReport ??
        const HealthMonitorEngine().evaluateReport(
          daysOfData: summary?.effectiveDaysOfData ?? 14,
          todayHrvMs: summary?.hrvMs,
          baselineHrvMs: summary?.baselineHrv,
          isHrvEstimated: summary?.isHrvEstimated ?? false,
          todayRhrBpm: summary?.restingHr,
          baselineRhrBpm: summary?.baselineRestingHr,
          todayRespiratoryRate: summary?.respiratoryRate,
          baselineRespiratoryRate: summary?.baselineRespiratoryRate,
          todaySpo2: summary?.spo2,
          baselineSpo2: summary?.baselineSpo2,
          todaySkinTempDeviationCelsius: summary?.skinTempDeviation,
          baselineSkinTempDeviationCelsius: summary?.baselineSkinTemp,
        );

    final statusColor = _getStatusColor(report.overallStatus);

    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Tok.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HEALTH MONITOR',
              style: TokType.sectionLabel.copyWith(
                letterSpacing: 1.4,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Tok.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Overnight Physiological Baselines • 5 Core Vitals',
              style: TokType.caption.copyWith(
                fontSize: 10,
                color: Tok.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Trust & Data Privacy',
            icon: const Icon(
              Icons.shield_outlined,
              color: Tok.neonAccent,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrustCenterScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Methodology & Citations',
            icon: const Icon(
              Icons.menu_book_rounded,
              color: Tok.textSecondary,
              size: 20,
            ),
            onPressed: () => MethodologySheet.show(context),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // ── Hero Status Visor Banner ──
          LiquidGlass(
            borderRadius: BorderRadius.circular(Tok.radiusLg),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEMIC STATUS',
                          style: TokType.sectionLabel.copyWith(
                            letterSpacing: 1.3,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Tok.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          report.overallStatus.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  report.statusHeadline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: RecovaColors.monochromeWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.statusSubhead,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  report.nonDiagnosticGuidance,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Tok.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Section Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'CORE OVERNIGHT VITALS',
                  style: TokType.sectionLabel.copyWith(
                    letterSpacing: 1.3,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Tok.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '60D BASELINE',
                style: TokType.sectionLabel.copyWith(
                  letterSpacing: 1.1,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Tok.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── 5 Vital Cards ──
          ...report.vitals.map((vital) => _buildVitalCard(vital)),

          const SizedBox(height: 16),

          // ── FDA Jan 2026 Non-Diagnostic Safeguard Banner ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Tok.glassFillRecessed,
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              border: Border.all(color: Tok.glassBorder, width: 0.8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Tok.neonAccent,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FDA 2026 GENERAL WELLNESS SAFEGUARD',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Tok.neonAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Recova provides physiological trend analysis intended solely for general wellness and athletic conditioning. '
                        'It does not provide medical advice, diagnosis, or clinical treatment. If out-of-range biometrics persist and you feel unwell, consult a qualified physician.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Tok.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Bottom Action Links ──
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrustCenterScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Tok.glassFillElevated,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(color: Tok.glassBorderBright, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'TRUST & PRIVACY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Tok.neonAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => MethodologySheet.show(context),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Tok.glassFillRecessed,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(color: Tok.glassBorder, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'VIEW METHODOLOGY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Tok.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(HealthVital vital) {
    final statusColor = _getVitalStatusColor(vital.status);
    final provenanceColor = vital.provenance == VitalProvenance.estimated
        ? Tok.accentViolet
        : Tok.neonAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Vital Name & Provenance Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vital.label.toUpperCase(),
                    style: TokType.sectionLabel.copyWith(
                      letterSpacing: 1.1,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: RecovaColors.monochromeWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: provenanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: provenanceColor.withValues(alpha: 0.3),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    vital.provenance.label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: provenanceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Value & Baseline Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        vital.value != null
                            ? (vital.type == HealthVitalType.skinTemperature
                                ? '${vital.value! >= 0 ? "+" : ""}${vital.value!.toStringAsFixed(2)}'
                                : (vital.type == HealthVitalType.respiratoryRate
                                    ? vital.value!.toStringAsFixed(1)
                                    : vital.value!.round().toString()))
                            : '--',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: RecovaColors.monochromeWhite,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vital.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Tok.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          vital.deviationString,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Tok.radiusSm),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    vital.status.label,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual Normal Range Track Bar
            _buildNormalRangeTrack(vital),

            const SizedBox(height: 10),

            // Non-Diagnostic Context & Sensor Limitation
            Text(
              vital.nonDiagnosticNote,
              style: const TextStyle(
                fontSize: 10.5,
                color: Tok.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalRangeTrack(HealthVital vital) {
    if (vital.rangeLower == null || vital.rangeUpper == null) {
      return Container(
        height: 6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Tok.glassFillRecessed,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.centerLeft,
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Tok.accentBlue.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }

    final lower = vital.rangeLower!;
    final upper = vital.rangeUpper!;
    final val = vital.value ?? lower;

    // Normal band span
    final span = max(0.001, upper - lower);
    // Relative position 0.0 to 1.0 clamped
    final double posRatio;
    if (val < lower) {
      posRatio = 0.05;
    } else if (val > upper) {
      posRatio = 0.95;
    } else {
      posRatio = 0.15 + (0.70 * ((val - lower) / span));
    }

    final lowerStr = vital.type == HealthVitalType.skinTemperature
        ? '${lower.toStringAsFixed(1)}°'
        : lower.round().toString();
    final upperStr = vital.type == HealthVitalType.skinTemperature
        ? '+${upper.toStringAsFixed(1)}°'
        : upper.round().toString();

    return Column(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: 7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(3.5),
              ),
            ),
            // Normal range band in center
            Positioned(
              left: 40,
              right: 40,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: Tok.recoveryOptimal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3.5),
                  border: Border.all(
                    color: Tok.recoveryOptimal.withValues(alpha: 0.4),
                    width: 0.6,
                  ),
                ),
              ),
            ),
            // Today indicator pin
            FractionallySizedBox(
              widthFactor: posRatio.clamp(0.05, 0.95),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _getVitalStatusColor(vital.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: _getVitalStatusColor(vital.status).withValues(alpha: 0.7),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Band: $lowerStr to $upperStr ${vital.unit}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Tok.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Baseline: ${vital.baseline != null ? (vital.type == HealthVitalType.skinTemperature ? "±0.0°" : vital.baseline!.round().toString()) : "--"}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Tok.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(OverallHealthStatus status) {
    switch (status) {
      case OverallHealthStatus.allOptimal:
        return Tok.recoveryOptimal;
      case OverallHealthStatus.elevatedAttention:
        return Tok.accentAmber;
      case OverallHealthStatus.systemicAnomaly:
        return Tok.recoverySuppressed;
      case OverallHealthStatus.calibrating:
        return Tok.accentBlue;
    }
  }

  Color _getVitalStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.inRange:
        return Tok.recoveryOptimal;
      case VitalStatus.elevated:
      case VitalStatus.suppressed:
        return Tok.accentAmber;
      case VitalStatus.calibrating:
        return Tok.accentBlue;
      case VitalStatus.noData:
        return Tok.textSecondary;
    }
  }
}
