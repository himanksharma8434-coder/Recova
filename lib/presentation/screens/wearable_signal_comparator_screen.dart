import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/comparator_engine.dart';
import '../components/liquid_glass.dart';

/// Interactive BLE & Wearable Signal Comparator Screen.
/// Provides empirical benchmarking between Wrist Optical PPG and Gold-Standard Chest-Strap ECG.
class WearableSignalComparatorScreen extends StatefulWidget {
  const WearableSignalComparatorScreen({super.key});

  @override
  State<WearableSignalComparatorScreen> createState() =>
      _WearableSignalComparatorScreenState();
}

class _WearableSignalComparatorScreenState
    extends State<WearableSignalComparatorScreen> {
  final ComparatorEngine _comparator = const ComparatorEngine();
  int _selectedScenarioIndex = 0;

  // Realistic beat-to-beat RR interval datasets (in milliseconds)
  static final List<({String label, List<double> ecg, List<double> ppg})>
      _scenarios = [
    (
      label: 'RESTING SUPINE',
      // High resting HRV, pristine optical alignment with minor 4-10ms pulse wave dispersion
      ecg: [840, 860, 890, 875, 830, 810, 825, 870, 895, 910, 880, 850, 835, 860, 885],
      ppg: [842, 858, 893, 871, 834, 807, 828, 866, 899, 908, 884, 847, 839, 858, 882],
    ),
    (
      label: 'DYNAMIC CADENCE',
      // Moderate arm movement, arm swing micro-displacements introduce 25-45ms optical noise
      ecg: [580, 575, 590, 585, 570, 565, 580, 595, 600, 590, 575, 580, 570, 585, 590],
      ppg: [560, 610, 575, 615, 555, 585, 560, 620, 580, 615, 560, 605, 550, 610, 570],
    ),
    (
      label: 'COLD PERFUSION',
      // Peripheral vasoconstriction causes attenuated pulse peak, 2 ectopic noise spikes rejected
      ecg: [780, 790, 810, 800, 770, 760, 775, 795, 815, 820, 805, 790, 780, 795, 810],
      ppg: [775, 798, 816, 792, 120, 755, 780, 802, 2250, 818, 800, 794, 782, 791, 815],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final active = _scenarios[_selectedScenarioIndex];
    final result = _comparator.compareSignals(
      ecgRrIntervalsMs: active.ecg,
      ppgPeakIntervalsMs: active.ppg,
    );

    final qualityColor = _getQualityColor(result.qualityLevel);

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
              'SENSOR BENCHMARK',
              style: TokType.sectionLabel.copyWith(
                letterSpacing: 1.3,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Tok.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Chest Strap ECG vs Wrist Optical PPG',
              style: TextStyle(fontSize: 10, color: Tok.textSecondary),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scenario Selector Tabs ──
            Semantics(
              label: 'Telemetry condition selector',
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: RecovaColors.surfaceElevation2,
                  borderRadius: BorderRadius.circular(Tok.radiusSm),
                  border: Border.all(color: RecovaColors.borderSubtle, width: 0.8),
                ),
                child: Row(
                  children: List.generate(_scenarios.length, (index) {
                    final isSelected = index == _selectedScenarioIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedScenarioIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Tok.neonAccent.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? Tok.neonAccent.withValues(alpha: 0.6)
                                  : Colors.transparent,
                              width: 0.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _scenarios[index].label,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: 0.5,
                              color: isSelected ? Tok.neonAccent : Tok.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Overall Match & SQI Pod ──
            Semantics(
              label: 'Signal Quality Index ${result.signalQualityIndexPct.toStringAsFixed(1)} percent, ${result.qualityLevel.name}',
              child: LiquidGlass(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                accentGlow: qualityColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sensors_rounded, size: 16, color: qualityColor),
                            const SizedBox(width: 8),
                            const Text(
                              'SIGNAL QUALITY INDEX (SQI)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Tok.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: qualityColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: qualityColor.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            result.qualityLevel.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: qualityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // SQI Score Display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          result.signalQualityIndexPct.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: Tok.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '% MATCH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Tok.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'PEARSON r = ${result.pearsonCorrelation.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: qualityColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MAE: ${result.meanAbsoluteErrorMs.toStringAsFixed(1)} ms',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Tok.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Diagnostic Summary
                    Text(
                      result.diagnosticSummary,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Tok.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Dual Provenance Badges ──
            Row(
              children: [
                Expanded(
                  child: _buildProvenanceCard(
                    title: 'CHEST STRAP',
                    technology: 'ECG Electrodes',
                    status: 'GOLD STANDARD',
                    provenance: 'MEASURED',
                    color: Tok.neonAccent,
                    rmssd: result.ecgRmssdMs,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildProvenanceCard(
                    title: 'WRIST WATCH',
                    technology: 'Optical PPG',
                    status: result.qualityLevel == SignalQualityLevel.excellent
                        ? 'MEASURED'
                        : 'FILTERED',
                    provenance: result.qualityLevel == SignalQualityLevel.excellent
                        ? 'MEASURED'
                        : 'ESTIMATED',
                    color: result.qualityLevel == SignalQualityLevel.excellent
                        ? Tok.accentBlue
                        : Tok.accentAmber,
                    rmssd: result.ppgRmssdMs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Visual Pulse Waveform Preview ──
            LiquidGlass(
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PULSE WAVE SYNCHRONIZATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Tok.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          _buildLegendDot(Tok.neonAccent, 'ECG R-Peak'),
                          const SizedBox(width: 8),
                          _buildLegendDot(Tok.accentBlue, 'PPG Wave'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: RecovaColors.surfaceElevation1,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(color: RecovaColors.borderSubtle, width: 0.8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CustomPaint(
                      painter: _PulseWaveformPainter(
                        ecgIntervals: active.ecg,
                        ppgIntervals: active.ppg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.rejectedArtifactCount} motion/ectopic artifacts filtered out of ${result.pairedBeatsCount + result.rejectedArtifactCount} total pulses.',
                    style: const TextStyle(fontSize: 10, color: Tok.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Physiological Differences & Science Explanation ──
            LiquidGlass(
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.science_outlined, size: 16, color: Tok.neonAccent),
                      SizedBox(width: 8),
                      Text(
                        'WHY OPTICAL DIFFERS FROM ECG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Tok.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.physiologicalCaveats.map((caveat) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Tok.neonAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                caveat,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Tok.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProvenanceCard({
    required String title,
    required String technology,
    required String status,
    required String provenance,
    required Color color,
    required double rmssd,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation2,
        borderRadius: BorderRadius.circular(Tok.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Tok.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  provenance,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            technology,
            style: const TextStyle(fontSize: 9.5, color: Tok.textTertiary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RMSSD',
                style: TextStyle(fontSize: 9, color: Tok.textSecondary),
              ),
              Text(
                '${rmssd.toStringAsFixed(1)} ms',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(SignalQualityLevel level) {
    switch (level) {
      case SignalQualityLevel.excellent:
        return Tok.neonAccent;
      case SignalQualityLevel.good:
        return Tok.accentBlue;
      case SignalQualityLevel.moderate:
        return Tok.accentAmber;
      case SignalQualityLevel.degraded:
        return Tok.recoverySuppressed;
    }
  }
}

/// Lightweight waveform painter rendering synchronized beats.
class _PulseWaveformPainter extends CustomPainter {
  final List<double> ecgIntervals;
  final List<double> ppgIntervals;

  const _PulseWaveformPainter({
    required this.ecgIntervals,
    required this.ppgIntervals,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ecgPaint = Paint()
      ..color = Tok.neonAccent
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final ppgPaint = Paint()
      ..color = Tok.accentBlue.withValues(alpha: 0.8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final n = ecgIntervals.length;
    if (n < 2) return;

    final stepX = size.width / (n - 1);
    final midY = size.height * 0.5;

    final ecgPath = Path();
    final ppgPath = Path();

    for (int i = 0; i < n; i++) {
      final x = i * stepX;
      // Normalize intervals (600 - 1000ms) to fit height
      final ecgNorm = ((ecgIntervals[i] - 700) / 300).clamp(-1.0, 1.0);
      final ppgNorm = ((ppgIntervals[i] - 700) / 300).clamp(-1.0, 1.0);

      final ecgY = midY - (ecgNorm * (size.height * 0.35));
      final ppgY = midY - (ppgNorm * (size.height * 0.35));

      if (i == 0) {
        ecgPath.moveTo(x, ecgY);
        ppgPath.moveTo(x, ppgY);
      } else {
        ecgPath.lineTo(x, ecgY);
        ppgPath.lineTo(x, ppgY);
      }
    }

    canvas.drawPath(ecgPath, ecgPaint);
    canvas.drawPath(ppgPath, ppgPaint);
  }

  @override
  bool shouldRepaint(covariant _PulseWaveformPainter oldDelegate) => true;
}

