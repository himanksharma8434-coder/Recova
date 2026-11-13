import 'package:flutter/material.dart';
import '../../core/config/engine_config.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';

/// Modal bottom sheet presenting the transparent, peer-reviewed Body Engine methodology.
class MethodologySheet extends StatelessWidget {
  const MethodologySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MethodologySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: RecovaColors.canvasBase,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Tok.glassBorder, width: 1.0),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RecovaColors.monochromeWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALGORITHM METHODOLOGY',
                            style: TokType.sectionLabel.copyWith(
                              letterSpacing: 1.4,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Tok.neonAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version ${EngineConfig.algorithmVersion} • Peer-Reviewed Sports Science',
                            style: TokType.caption.copyWith(
                              fontSize: 10,
                              color: Tok.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Tok.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Tok.glassBorder, height: 16),

              // Scrollable body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                  children: [
                    _buildSectionCard(
                      title: '1. Transparent Physiology vs Black Boxes',
                      badge: 'FDA 2026 WELLNESS',
                      content:
                          'Unlike commercial competitors that treat algorithms as trade secrets, this engine is built on published sports-cardiology literature (Plews et al., 2013; Buchheit, 2014; Shaffer & Ginsberg, 2017).\n\n'
                          'We do not diagnose medical conditions or claim clinical equivalence. All evaluations serve athletic readiness and recovery trend discovery.',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '2. Heart Rate Variability (HRV)',
                      badge: 'WEIGHT 50%',
                      content:
                          '• Metric: Root Mean Square of Successive Differences (RMSSD).\n'
                          '• Normalization: Natural-log transform ln(RMSSD) normalizes right-skewed human distributions.\n'
                          '• Personal Baseline: 7-day rolling mean & 60-day normal range band (Mean ± 0.75 SD).\n'
                          '• Ectopic Filtering: Successive beat jumps > 20% and non-physiological readings (<300ms, >2000ms) are strictly rejected.\n'
                          '• Zero-HRV Fallback: When raw beat-to-beat RR is unavailable, derived from nocturnal pulse streams with transparent provenance (HrvSource.estimated).',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '3. Resting Heart Rate (RHR)',
                      badge: 'WEIGHT 20%',
                      content:
                          '• 5-Minute Nadir: Scans nocturnal pulse telemetry for the sustained circadian minimum, filtering out tossing and brief awakenings.\n'
                          '• Inverted Z-Score: Lower resting heart rate maps to positive readiness, reflecting cardiovascular efficiency.',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '4. Sleep Architecture & Dynamic Need',
                      badge: 'WEIGHT 20%',
                      content:
                          '• Dynamic Need Formula: Base Need + (Strain - 10) × 2.5m + 20% Debt Payback - 100% Nap Credit.\n'
                          '• 4-Pillar Quality: Sufficiency (40%), Efficiency (25%), Restorative deep/REM share (20%), Bedtime consistency (15%).\n'
                          '• Sleep Deficit Governor: Sleeps under 6.0 hours (360m) are strictly capped at score ≤ 66.0, preventing an "Optimal" score.',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '5. Cardiovascular Load (0 to 21 Scale)',
                      badge: 'KARVONEN HRR',
                      content:
                          '• Intensity: Heart Rate Reserve (HR - RHR) / (MaxHR - RHR) across 5 zones.\n'
                          '• Banister/Edwards TRIMP: Weighted zone-minutes.\n'
                          '• Diminishing Returns: Load = 21 × (1 - exp(-TRIMP / 18.0)). Hard intervals yield ~14–16 load.\n'
                          '• Target Range: Live target band is driven by morning recovery (Optimal: 14.0–18.0, Moderate: 10.0–13.9, Low: 6.0–9.9).',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '6. Workload Balance (ACWR)',
                      badge: 'GABBETT 2016',
                      content:
                          '• Acute:Chronic Workload Ratio compares acute 7-day load against chronic 28-day preparation.\n'
                          '• Sweet Spot: 0.8 to 1.3 optimizes fitness gains with low injury risk.\n'
                          '• Danger Zone: ACWR > 1.4 triggers workload warnings to protect ligaments and tendons even on high-recovery days.',
                    ),
                    const SizedBox(height: 14),

                    _buildSectionCard(
                      title: '7. Calibration & Confidence States',
                      badge: 'ZERO FAKE DATA',
                      content:
                          '• Days 1–3: Initial baseline collection (Readiness score is null to prevent misleading advice).\n'
                          '• Days 4–13: Provisional score displayed with calibrating badge.\n'
                          '• Day 14+: High-confidence score with established 60-day standard deviation.\n'
                          '• Energy Reserve: Unlocks after 10 days of wear.',
                    ),
                    const SizedBox(height: 20),

                    // Literature citations
                    Text(
                      'ACADEMIC REFERENCES',
                      style: TokType.sectionLabel.copyWith(
                        letterSpacing: 1.2,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Tok.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCitation(
                      'Plews et al. (2013)',
                      'Training adaptation and heart rate variability in elite endurance athletes. Sports Medicine, 43(9), 773-781.',
                    ),
                    _buildCitation(
                      'Buchheit, M. (2014)',
                      'Monitoring training status with HR measures: do all roads lead to Rome? Frontiers in Physiology, 5, 73.',
                    ),
                    _buildCitation(
                      'Gabbett, T. J. (2016)',
                      'The training—injury prevention paradox: should athletes be training smarter and harder? Br J Sports Med, 50(5), 273-280.',
                    ),
                    _buildCitation(
                      'FDA Guidance (Jan 2026)',
                      'General Wellness: Policy for Low Risk Devices - Guidance for Industry and Food and Drug Administration Staff.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String badge,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tok.glassFill,
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        border: Border.all(color: Tok.glassBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: RecovaColors.monochromeWhite,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Tok.neonAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Tok.neonAccent.withValues(alpha: 0.3),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Tok.neonAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TokType.caption.copyWith(
              fontSize: 11.5,
              height: 1.45,
              color: Tok.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitation(String author, String citation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Tok.neonAccent)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 10.5, height: 1.35),
                children: [
                  TextSpan(
                    text: '$author. ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: RecovaColors.monochromeWhite,
                    ),
                  ),
                  TextSpan(
                    text: citation,
                    style: const TextStyle(color: Tok.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
