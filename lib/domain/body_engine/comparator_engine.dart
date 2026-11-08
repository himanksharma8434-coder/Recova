import 'dart:math' as math;
import 'health_monitor_engine.dart';

/// Signal quality rating of wearable optical sensor vs ECG reference.
enum SignalQualityLevel {
  /// Pristine match (correlation > 0.92, MAE < 15ms)
  excellent,
  /// Reliable resting data (correlation 0.80 - 0.92, MAE 15 - 30ms)
  good,
  /// Motion noise or peripheral vasoconstriction detected (correlation 0.60 - 0.79, MAE 30 - 60ms)
  moderate,
  /// Severe motion artifacts or loose wrist fit (correlation < 0.60, MAE > 60ms)
  degraded,
}

/// Comparison analysis between Gold-Standard Chest-Strap ECG and Wrist Optical PPG.
class WearableComparisonResult {
  /// Number of matched beat intervals analyzed.
  final int pairedBeatsCount;

  /// Mean Absolute Error in milliseconds between optical and ECG intervals.
  final double meanAbsoluteErrorMs;

  /// Pearson correlation coefficient (-1.0 to 1.0).
  final double pearsonCorrelation;

  /// Signal Quality Index percentage (0% to 100% of intervals within +-20ms of ECG).
  final double signalQualityIndexPct;

  /// Gold-standard ECG RMSSD in milliseconds.
  final double ecgRmssdMs;

  /// Wrist optical PPG RMSSD in milliseconds.
  final double ppgRmssdMs;

  /// Percentage error in computed HRV RMSSD ((PPG - ECG) / ECG * 100).
  final double hrvPercentageError;

  /// Count of ectopic or motion artifact beats detected and filtered.
  final int rejectedArtifactCount;

  /// Qualitative signal quality assessment.
  final SignalQualityLevel qualityLevel;

  /// Provenance designation for both streams.
  final VitalProvenance ecgProvenance;
  final VitalProvenance ppgProvenance;

  /// Human-readable physiological diagnostic explanation.
  final String diagnosticSummary;

  /// Educational caveats detailing why optical PPG diverges from ECG.
  final List<String> physiologicalCaveats;

  const WearableComparisonResult({
    required this.pairedBeatsCount,
    required this.meanAbsoluteErrorMs,
    required this.pearsonCorrelation,
    required this.signalQualityIndexPct,
    required this.ecgRmssdMs,
    required this.ppgRmssdMs,
    required this.hrvPercentageError,
    required this.rejectedArtifactCount,
    required this.qualityLevel,
    required this.ecgProvenance,
    required this.ppgProvenance,
    required this.diagnosticSummary,
    required this.physiologicalCaveats,
  });
}

/// Pure Dart science engine for comparing optical PPG vs chest-strap ECG.
class ComparatorEngine {
  const ComparatorEngine();

  /// Compares synchronized lists of ECG RR intervals and Wrist PPG peak-to-peak intervals.
  WearableComparisonResult compareSignals({
    required List<double> ecgRrIntervalsMs,
    required List<double> ppgPeakIntervalsMs,
  }) {
    if (ecgRrIntervalsMs.isEmpty || ppgPeakIntervalsMs.isEmpty) {
      return const WearableComparisonResult(
        pairedBeatsCount: 0,
        meanAbsoluteErrorMs: 0.0,
        pearsonCorrelation: 0.0,
        signalQualityIndexPct: 0.0,
        ecgRmssdMs: 0.0,
        ppgRmssdMs: 0.0,
        hrvPercentageError: 0.0,
        rejectedArtifactCount: 0,
        qualityLevel: SignalQualityLevel.degraded,
        ecgProvenance: VitalProvenance.sensorHardware,
        ppgProvenance: VitalProvenance.estimated,
        diagnosticSummary: 'Insufficient beat telemetry for empirical comparison.',
        physiologicalCaveats: [],
      );
    }

    final n = math.min(ecgRrIntervalsMs.length, ppgPeakIntervalsMs.length);
    final List<double> validEcg = [];
    final List<double> validPpg = [];
    int rejectedArtifacts = 0;

    // Filter physiological outliers: intervals < 300ms (200 bpm), > 2000ms (30 bpm), or >20% successive jumps
    for (int i = 0; i < n; i++) {
      final ecg = ecgRrIntervalsMs[i];
      final ppg = ppgPeakIntervalsMs[i];

      final isEcgPhysiological = ecg >= 300.0 && ecg <= 2000.0;
      final isPpgPhysiological = ppg >= 300.0 && ppg <= 2000.0;

      if (!isEcgPhysiological || !isPpgPhysiological) {
        rejectedArtifacts++;
        continue;
      }

      if (validEcg.isNotEmpty) {
        final lastEcg = validEcg.last;
        final lastPpg = validPpg.last;
        final ecgJump = (ecg - lastEcg).abs() / lastEcg;
        final ppgJump = (ppg - lastPpg).abs() / lastPpg;

        // Reject beats with sudden ectopic or motion jumps > 25%
        if (ecgJump > 0.25 || ppgJump > 0.25) {
          rejectedArtifacts++;
          continue;
        }
      }

      validEcg.add(ecg);
      validPpg.add(ppg);
    }

    if (validEcg.length < 5) {
      return WearableComparisonResult(
        pairedBeatsCount: validEcg.length,
        meanAbsoluteErrorMs: 0.0,
        pearsonCorrelation: 0.0,
        signalQualityIndexPct: 0.0,
        ecgRmssdMs: 0.0,
        ppgRmssdMs: 0.0,
        hrvPercentageError: 0.0,
        rejectedArtifactCount: rejectedArtifacts,
        qualityLevel: SignalQualityLevel.degraded,
        ecgProvenance: VitalProvenance.sensorHardware,
        ppgProvenance: VitalProvenance.estimated,
        diagnosticSummary: 'Too few clean non-ectopic beats ($validEcg.length) to calibrate precision.',
        physiologicalCaveats: const [
          'Ensure the chest strap is moistened with conductive gel or water.',
          'Verify the wristband is snug 1-2 fingers above the ulnar styloid bone.',
        ],
      );
    }

    // 1. Mean Absolute Error (MAE)
    double absoluteErrorSum = 0.0;
    int within20msCount = 0;
    for (int i = 0; i < validEcg.length; i++) {
      final diff = (validPpg[i] - validEcg[i]).abs();
      absoluteErrorSum += diff;
      if (diff <= 20.0) {
        within20msCount++;
      }
    }
    final mae = absoluteErrorSum / validEcg.length;
    final sqiPct = (within20msCount / validEcg.length) * 100.0;

    // 2. Pearson Correlation Coefficient
    final meanEcg = validEcg.reduce((a, b) => a + b) / validEcg.length;
    final meanPpg = validPpg.reduce((a, b) => a + b) / validPpg.length;

    double numerator = 0.0;
    double denomEcg = 0.0;
    double denomPpg = 0.0;

    for (int i = 0; i < validEcg.length; i++) {
      final dEcg = validEcg[i] - meanEcg;
      final dPpg = validPpg[i] - meanPpg;
      numerator += dEcg * dPpg;
      denomEcg += dEcg * dEcg;
      denomPpg += dPpg * dPpg;
    }

    final denom = math.sqrt(denomEcg * denomPpg);
    final correlation = denom > 0.0 ? (numerator / denom).clamp(-1.0, 1.0) : 0.0;

    // 3. RMSSD Computation for both streams
    double ecgDiffSq = 0.0;
    double ppgDiffSq = 0.0;
    for (int i = 0; i < validEcg.length - 1; i++) {
      final dE = validEcg[i + 1] - validEcg[i];
      final dP = validPpg[i + 1] - validPpg[i];
      ecgDiffSq += dE * dE;
      ppgDiffSq += dP * dP;
    }

    final ecgRmssd = math.sqrt(ecgDiffSq / (validEcg.length - 1));
    final ppgRmssd = math.sqrt(ppgDiffSq / (validPpg.length - 1));
    final hrvPctError = ecgRmssd > 0 ? ((ppgRmssd - ecgRmssd) / ecgRmssd) * 100.0 : 0.0;

    // 4. Quality Level Determination
    final SignalQualityLevel quality;
    if (correlation >= 0.92 && mae <= 18.0) {
      quality = SignalQualityLevel.excellent;
    } else if (correlation >= 0.80 && mae <= 32.0) {
      quality = SignalQualityLevel.good;
    } else if (correlation >= 0.60 && mae <= 55.0) {
      quality = SignalQualityLevel.moderate;
    } else {
      quality = SignalQualityLevel.degraded;
    }

    // 5. Educational Caveats & Diagnostic Summary
    final List<String> caveats = [
      'Pulse Transit Time (PTT): Optical pulse waves arrive at the wrist 150-250ms after electrical ventricular depolarization.',
      'Motion Displacement: Wrist movement shifts the optical photodiode relative to arterial capillary beds, creating momentary optical noise.',
      'Peripheral Perfusion: Cold ambient temperature and sympathetic vasoconstriction reduce PPG pulsatile amplitude.',
      'Chest Strap Accuracy: Chest straps measure bioelectric voltage (QRS complex) with <1ms jitter, serving as the clinical gold standard.',
    ];

    final String summary;
    switch (quality) {
      case SignalQualityLevel.excellent:
        summary = 'Near-perfect optical alignment with chest strap ECG. HRV RMSSD error is within ${hrvPctError.abs().toStringAsFixed(1)}%.';
        break;
      case SignalQualityLevel.good:
        summary = 'Reliable resting agreement. Minor optical phase jitter detected during micro-movements.';
        break;
      case SignalQualityLevel.moderate:
        summary = 'Moderate divergence observed (MAE ${mae.toStringAsFixed(1)}ms). Likely caused by arm motion or sub-optimal wristband tension.';
        break;
      case SignalQualityLevel.degraded:
        summary = 'Significant signal noise detected. Wearable data should be treated as estimated rather than raw measured beats.';
        break;
    }

    return WearableComparisonResult(
      pairedBeatsCount: validEcg.length,
      meanAbsoluteErrorMs: mae,
      pearsonCorrelation: correlation,
      signalQualityIndexPct: sqiPct,
      ecgRmssdMs: ecgRmssd,
      ppgRmssdMs: ppgRmssd,
      hrvPercentageError: hrvPctError,
      rejectedArtifactCount: rejectedArtifacts,
      qualityLevel: quality,
      ecgProvenance: VitalProvenance.sensorHardware,
      ppgProvenance: quality == SignalQualityLevel.excellent
          ? VitalProvenance.sensorHardware
          : VitalProvenance.estimated,
      diagnosticSummary: summary,
      physiologicalCaveats: caveats,
    );
  }
}
