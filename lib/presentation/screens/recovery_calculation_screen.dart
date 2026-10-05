import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';

/// Scientific Explainer Screen detailing how Recova calculates
/// the daily recovery score using the 3-pillar biometric algorithm.
class RecoveryCalculationScreen extends StatelessWidget {
  final DerivedMetricSummary? summary;

  const RecoveryCalculationScreen({
    super.key,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    // Read pre-computed recovery components and composite score directly from local database summary
    final hrvComponent = summary?.recoveryComponentHrv ?? 75.0;
    final rhrComponent = summary?.recoveryComponentRhr ?? 50.0;
    final sleepComponent = summary?.recoveryComponentSleep ?? 50.0;
    final spo2Component = summary?.recoveryComponentSpo2 ?? 50.0;
    final respComponent = summary?.recoveryComponentRespiratory ?? 100.0;
    final primaryFactor = summary?.primaryFactor ?? 'Baselines calibrating.';
    final score = summary?.recoveryScore;
    final tier = RecoveryTier.fromScore(score);

    // Combined pulmonary / vital score for SpO2 + Respiratory (5% + 5% = 10%)
    final pulmonaryComponent = ((spo2Component + respComponent) / 2.0).roundToDouble();

    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      body: AmbientGlowBackdrop(
        primaryGlow: Tok.recoveryOptimal,
        secondaryGlow: Tok.accentAmber,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Navigation Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Tok.glassFill,
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder(
                          side: BorderSide(color: Tok.glassBorder),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: RecovaColors.monochromeWhite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOW RECOVERY IS CALCULATED',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: RecovaColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'AUTONOMIC COMPOSITE ALGORITHM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: RecovaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Today's Composite Score Hero ──
                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(18),
                        accentGlow: tier.color.withValues(alpha: 0.15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TODAY\'S SCORE',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.4,
                                        color: RecovaColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          score != null
                                              ? '${score.toInt()}'
                                              : '--',
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: -1.0,
                                            color: tier.color,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          '%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: RecovaColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: tier.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: tier.borderColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tier.color,
                                          boxShadow: [
                                            BoxShadow(
                                              color: tier.color.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        tier.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: tier.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Tok.glassFillRecessed,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Tok.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: tier.color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      primaryFactor,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: RecovaColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Algorithm Foundation ──
                      const Text(
                        'THE BIOMETRIC PILLARS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: RecovaColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Pillar 1: Heart Rate Variability (40%) ──
                      _PillarCard(
                        title: '1. HEART RATE VARIABILITY (HRV)',
                        weight: '40% WEIGHT',
                        weightFraction: 0.40,
                        todayScore: hrvComponent,
                        pillarColor: Tok.recoveryOptimal,
                        icon: Icons.monitor_heart_outlined,
                        formula: 'Deviation = (Today HRV - Baseline HRV) / Baseline',
                        explanation:
                            'HRV is the gold standard indicator for central nervous system readiness and vagal parasympathetic tone. When HRV is elevated above baseline, your body is primed for strain. Suppressed HRV signifies accumulated systemic fatigue.',
                        userMetric: summary?.hrvMs != null
                            ? '${summary!.hrvMs!.toInt()} ms (RMSSD/SDNN)'
                            : 'Awaiting sensor sync',
                        baselineMetric: summary?.baselineHrv != null
                            ? '${summary!.baselineHrv!.toInt()} ms baseline'
                            : '55 ms standard target',
                      ),
                      const SizedBox(height: 12),

                      // ── Pillar 2: Resting Heart Rate (30%) ──
                      _PillarCard(
                        title: '2. RESTING HEART RATE',
                        weight: '30% WEIGHT',
                        weightFraction: 0.30,
                        todayScore: rhrComponent,
                        pillarColor: Tok.accentAmber,
                        icon: Icons.favorite_border,
                        formula: 'Deviation = (Today RHR - 14D Baseline) / Baseline',
                        explanation:
                            'Resting HR is the primary cardiovascular proxy for central nervous system fatigue. When basal RHR is at or below your baseline, this pillar scores 100%. An elevation above baseline indicates cardiovascular strain.',
                        userMetric: summary?.restingHr != null
                            ? '${summary!.restingHr!.toInt()} bpm (Basal)'
                            : 'Awaiting wearable sync',
                        baselineMetric: summary?.baselineRestingHr != null
                            ? '${summary!.baselineRestingHr!.toInt()} bpm (Base)'
                            : '60 bpm standard target',
                      ),
                      const SizedBox(height: 12),

                      // ── Pillar 3: Sleep Duration & Architecture (20%) ──
                      _PillarCard(
                        title: '3. SLEEP DURATION & ARCHITECTURE',
                        weight: '20% WEIGHT',
                        weightFraction: 0.20,
                        todayScore: sleepComponent,
                        pillarColor: Tok.accentBlue,
                        icon: Icons.bedtime_outlined,
                        formula: 'Performance = Duration vs Need + Stage Quality Adjustment',
                        explanation:
                            'Sleep restores cellular energy, releases human growth hormone, and resets parasympathetic tone. Restorative stages (Deep + REM) provide vital tissue repair and cognitive consolidation.',
                        userMetric: summary?.sleepHours != null
                            ? '${summary!.sleepHours!.toStringAsFixed(1)} hrs (${summary?.sleepStages?.deepMinutes ?? 0}m Deep, ${summary?.sleepStages?.remMinutes ?? 0}m REM)'
                            : 'Awaiting sleep session',
                        baselineMetric: summary?.baselineSleepHours != null
                            ? '${summary!.baselineSleepHours!.toStringAsFixed(1)} hrs baseline'
                            : '8.0 hrs standard target',
                      ),
                      const SizedBox(height: 12),

                      // ── Pillar 4: Pulmonary & Blood Oxygen (10%) ──
                      _PillarCard(
                        title: '4. BLOOD OXYGEN & RESPIRATION',
                        weight: '10% WEIGHT',
                        weightFraction: 0.10,
                        todayScore: pulmonaryComponent,
                        pillarColor: Tok.neonAccent,
                        icon: Icons.air,
                        formula: 'Stability = Nocturnal SpO2 (>=95%) & Respiratory Flux',
                        explanation:
                            'Blood oxygen levels reflect nocturnal pulmonary stability and tissue oxygenation. Maintaining nominal saturation (>=95%) and stable respiratory rate confirms autonomic equilibrium.',
                        userMetric: summary?.spo2 != null
                            ? '${summary!.spo2!.toStringAsFixed(0)}% SpO2 • ${summary?.respiratoryRate != null ? '${summary!.respiratoryRate!.toStringAsFixed(1)} rpm' : '-- rpm'}'
                            : 'Awaiting sensor log',
                        baselineMetric: '>=95% nominal • ~14.0 rpm',
                      ),
                      const SizedBox(height: 20),

                      // ── Dynamic Re-weighting Card ──
                      GlassCard(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.tune,
                                    size: 15, color: Tok.accentAmber),
                                SizedBox(width: 8),
                                Text(
                                  'DYNAMIC RE-WEIGHTING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: RecovaColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'If your wearable lacks a specific sensor (such as SpO2 or continuous HRV), Recova\'s algorithm automatically re-normalizes the active pillars so the composite score remains calibrated to 100% without artificial penalties.',
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.5,
                                color: RecovaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Zero Cloud Privacy Guarantee ──
                      GlassCard(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 15, color: Tok.recoveryOptimal),
                                SizedBox(width: 8),
                                Text(
                                  'ON-DEVICE COMPUTATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: RecovaColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'All baselines, standard deviations, and composite formulas are computed locally on your device via SQLite. Zero telemetry is sent to any external server or cloud provider.',
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.5,
                                color: RecovaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String title;
  final String weight;
  final double weightFraction;
  final double todayScore;
  final Color pillarColor;
  final IconData icon;
  final String formula;
  final String explanation;
  final String userMetric;
  final String baselineMetric;

  const _PillarCard({
    required this.title,
    required this.weight,
    required this.weightFraction,
    required this.todayScore,
    required this.pillarColor,
    required this.icon,
    required this.formula,
    required this.explanation,
    required this.userMetric,
    required this.baselineMetric,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      accentGlow: pillarColor.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: pillarColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: RecovaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pillarColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: pillarColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  weight,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: pillarColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Sub-Score Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PILLAR COMPONENT SCORE',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: RecovaColors.textTertiary,
                ),
              ),
              Text(
                '${todayScore.toInt()} / 100',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: pillarColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (todayScore / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                pillarColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // User live stats vs baseline
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Tok.glassFillRecessed,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Tok.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TODAY RECORDED',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userMetric,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'CALIBRATED TARGET',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        baselineMetric,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Formula & Explanation
          Text(
            formula,
            style: const TextStyle(
              fontSize: 9.5,
              fontFamily: 'monospace',
              color: RecovaColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 11,
              height: 1.45,
              color: RecovaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
