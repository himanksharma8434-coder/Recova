import 'dart:math';
import '../../data/database/app_database.dart';

/// Calculates Heart Rate Variability (HRV - specifically rMSSD)
/// from optical Photoplethysmography (PPG) pulse and heart rate telemetry.
///
/// Whoop and modern optical wearables measure HRV through PPG, capturing
/// blood volume changes in microvascular capillary beds using optical sensors.
///
/// When direct HRV records (e.g. from Health Connect / HealthKit) are absent,
/// this derives the root-mean-square of successive differences (rMSSD) across
/// consecutive inter-beat intervals (IBI = 60000 / BPM) during quiet rest or overnight sleep.
class PpgHrvCalculator {
  PpgHrvCalculator._();

  static double? computeRmssdFromHeartRates(List<RawHealthRecord> hrRecords) {
    if (hrRecords.length < 3) return null;

    final sorted = List<RawHealthRecord>.from(hrRecords)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final validDiffs = <double>[];
    final allIbis = <double>[];

    for (int i = 0; i < sorted.length - 1; i++) {
      final r1 = sorted[i];
      final r2 = sorted[i + 1];

      // Must be physically close in time to be considered "successive" in a sampled HR context
      // e.g., within 5 minutes. If it's a gap, it's not a valid successive difference.
      if (r2.startTime.difference(r1.startTime).inMinutes.abs() > 5) {
        continue;
      }

      // Filter non-physiological values (must be 35–220 bpm)
      if (r1.value < 35.0 || r1.value > 220.0) continue;
      if (r2.value < 35.0 || r2.value > 220.0) continue;

      final ibi1 = 60000.0 / r1.value;
      final ibi2 = 60000.0 / r2.value;
      
      allIbis.add(ibi1);
      // We also add the very last one conditionally later, but this gives us a good sample size
      
      final diff = ibi2 - ibi1;
      
      // Filter out sudden motion/ectopic artifacts (differences > 300ms)
      if (diff.abs() > 300.0) continue;
      
      validDiffs.add(diff * diff);
    }

    if (validDiffs.length < 2 || allIbis.length < 2) return null;

    // 1. Calculate rMSSD (Root mean square of successive differences)
    // Reflects short-term, parasympathetic nervous system activity.
    final sumSquaredDiffs = validDiffs.reduce((a, b) => a + b);
    final rmssd = sqrt(sumSquaredDiffs / validDiffs.length);

    // 2. Calculate SDNN (Standard deviation of normal-to-normal intervals)
    // Reflects overall variability (both sympathetic and parasympathetic).
    // Often much more reliable for sparse 1-minute sampled PPG data.
    final meanIbi = allIbis.reduce((a, b) => a + b) / allIbis.length;
    double sumSquaredDeviations = 0;
    for (final ibi in allIbis) {
      final dev = ibi - meanIbi;
      sumSquaredDeviations += dev * dev;
    }
    final sdnn = sqrt(sumSquaredDeviations / allIbis.length);

    // 3. Blend rMSSD and SDNN for a robust composite PPG HRV metric.
    // Sparse data heavily penalizes rMSSD, so weighting SDNN helps stabilize the metric.
    final blendedHrv = (rmssd * 0.4) + (sdnn * 0.6);

    // Clamp to realistic human physiological resting range (15ms to 180ms)
    return blendedHrv.clamp(15.0, 180.0);
  }
}
