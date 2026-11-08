import 'dart:math';

/// The 5 core overnight health vitals tracked by the Health Monitor.
enum HealthVitalType {
  hrv('Heart Rate Variability', 'HRV (rMSSD)', 'ms'),
  rhr('Resting Heart Rate', 'RHR (Nadir)', 'bpm'),
  respiratoryRate('Respiratory Rate', 'Resp Rate', 'rpm'),
  bloodOxygen('Blood Oxygen', 'SpO2', '%'),
  skinTemperature('Skin Temperature', 'Skin Temp', '°C');

  final String fullName;
  final String shortName;
  final String unit;
  const HealthVitalType(this.fullName, this.shortName, this.unit);
}

/// Status of an individual vital relative to the user's personal normal range band.
enum VitalStatus {
  inRange('IN RANGE'),
  elevated('ELEVATED'),
  suppressed('SUPPRESSED'),
  calibrating('CALIBRATING'),
  noData('NO DATA');

  final String label;
  const VitalStatus(this.label);
}

/// Provenance / measurement origin of the vital telemetry.
enum VitalProvenance {
  sensorHardware('SENSOR MEASURED'),
  estimated('ESTIMATED (FALLBACK)'),
  unavailable('UNAVAILABLE');

  final String label;
  const VitalProvenance(this.label);
}

/// Overall systemic state of the Health Monitor.
enum OverallHealthStatus {
  calibrating('CALIBRATING BASELINE'),
  allOptimal('ALL VITALS IN RANGE'),
  elevatedAttention('ELEVATED ATTENTION'),
  systemicAnomaly('SYSTEMIC ANOMALY');

  final String label;
  const OverallHealthStatus(this.label);
}

/// Detailed physiological state of a single health vital.
class HealthVital {
  final HealthVitalType type;
  final String label;
  final double? value;
  final double? baseline;
  final double? rangeLower;
  final double? rangeUpper;
  final String unit;
  final VitalStatus status;
  final VitalProvenance provenance;
  final String deviationString;
  final String nonDiagnosticNote;
  final String sensorLimitation;

  const HealthVital({
    required this.type,
    required this.label,
    required this.value,
    required this.baseline,
    required this.rangeLower,
    required this.rangeUpper,
    required this.unit,
    required this.status,
    required this.provenance,
    required this.deviationString,
    required this.nonDiagnosticNote,
    required this.sensorLimitation,
  });

  bool get isOptimal => status == VitalStatus.inRange;
  bool get isOut =>
      status == VitalStatus.elevated || status == VitalStatus.suppressed;
  bool get isCalibrating => status == VitalStatus.calibrating;
}

/// Full comprehensive Health Monitor report evaluated for a single day.
class HealthMonitorReport {
  final OverallHealthStatus overallStatus;
  final String statusHeadline;
  final String statusSubhead;
  final String nonDiagnosticGuidance;
  final List<HealthVital> vitals;
  final int inRangeCount;
  final int totalVitalsWithData;
  final int daysOfData;
  final bool hasSystemicAnomaly;
  final DateTime evaluatedAt;

  const HealthMonitorReport({
    required this.overallStatus,
    required this.statusHeadline,
    required this.statusSubhead,
    required this.nonDiagnosticGuidance,
    required this.vitals,
    required this.inRangeCount,
    required this.totalVitalsWithData,
    required this.daysOfData,
    required this.hasSystemicAnomaly,
    required this.evaluatedAt,
  });

  HealthVital? getVital(HealthVitalType type) {
    for (final v in vitals) {
      if (v.type == type) return v;
    }
    return null;
  }
}

/// Pure Dart physiological science engine for Health Monitor panel.
/// Evaluates personal baseline bands, neutral status flagging,
/// systemic multi-vital deviations ("Something is off"), and non-diagnostic guidance.
class HealthMonitorEngine {
  const HealthMonitorEngine();

  /// Minimum days of overnight wear required to calibrate personal normal bands.
  static const int minCalibrationDays = 7;

  /// Evaluate the complete Health Monitor report from available telemetry.
  HealthMonitorReport evaluateReport({
    required int daysOfData,
    double? todayHrvMs,
    double? baselineHrvMs,
    double? hrvStdDev,
    bool isHrvEstimated = false,
    double? todayRhrBpm,
    double? baselineRhrBpm,
    double? rhrStdDev,
    double? todayRespiratoryRate,
    double? baselineRespiratoryRate,
    double? respStdDev,
    double? todaySpo2,
    double? baselineSpo2,
    double? spo2StdDev,
    double? todaySkinTempDeviationCelsius,
    double? baselineSkinTempDeviationCelsius,
    double? skinTempStdDev,
    DateTime? evaluatedAt,
  }) {
    final now = evaluatedAt ?? DateTime.now();
    final isCalibrating = daysOfData < minCalibrationDays;

    final vitals = <HealthVital>[];

    // ── 1. HRV (RMSSD) ──
    vitals.add(_evaluateHrv(
      value: todayHrvMs,
      baseline: baselineHrvMs,
      stdDev: hrvStdDev,
      isCalibrating: isCalibrating,
      isEstimated: isHrvEstimated,
    ));

    // ── 2. Resting Heart Rate ──
    vitals.add(_evaluateRhr(
      value: todayRhrBpm,
      baseline: baselineRhrBpm,
      stdDev: rhrStdDev,
      isCalibrating: isCalibrating,
    ));

    // ── 3. Respiratory Rate ──
    vitals.add(_evaluateRespiratoryRate(
      value: todayRespiratoryRate,
      baseline: baselineRespiratoryRate,
      stdDev: respStdDev,
      isCalibrating: isCalibrating,
    ));

    // ── 4. Blood Oxygen (SpO2) ──
    vitals.add(_evaluateSpo2(
      value: todaySpo2,
      baseline: baselineSpo2,
      stdDev: spo2StdDev,
      isCalibrating: isCalibrating,
    ));

    // ── 5. Skin Temperature Deviation ──
    vitals.add(_evaluateSkinTemperature(
      deviation: todaySkinTempDeviationCelsius,
      baseline: baselineSkinTempDeviationCelsius,
      stdDev: skinTempStdDev,
      isCalibrating: isCalibrating,
    ));

    // Aggregate statistics
    int inRange = 0;
    int totalWithData = 0;
    int outOfRange = 0;

    for (final v in vitals) {
      if (v.value != null) {
        totalWithData++;
        if (v.status == VitalStatus.inRange) {
          inRange++;
        } else if (v.status == VitalStatus.elevated ||
            v.status == VitalStatus.suppressed) {
          outOfRange++;
        }
      }
    }

    // Determine overall status
    final OverallHealthStatus overallStatus;
    final String headline;
    final String subhead;
    final String guidance;
    final bool systemicAnomaly;

    if (isCalibrating) {
      overallStatus = OverallHealthStatus.calibrating;
      headline = 'CALIBRATING HEALTH BASELINE';
      subhead = 'DAY $daysOfData OF $minCalibrationDays REQUIRED';
      guidance =
          'Recova requires at least 7 nights of sleep wear to establish your individual normal range bands. '
          'We do not generate premature anomaly flags before learning your unique physiology.';
      systemicAnomaly = false;
    } else if (outOfRange >= 2) {
      overallStatus = OverallHealthStatus.systemicAnomaly;
      headline = '$outOfRange VITALS OUT OF NORMAL RANGE';
      subhead = 'SYSTEMIC DEVIATION DETECTED';
      guidance =
          'Two or more overnight biometrics show significant deviation from your established baseline. '
          'Common physiological causes include incomplete physical recovery, impending illness, alcohol metabolism, travel/jet lag, or acute stress. '
          'Consider modifying today\'s training to light activity or active recovery. '
          'If out-of-range readings persist over several days and you feel unwell, consult a qualified healthcare professional.';
      systemicAnomaly = true;
    } else if (outOfRange == 1) {
      overallStatus = OverallHealthStatus.elevatedAttention;
      headline = '1 VITAL OUT OF NORMAL RANGE';
      subhead = 'MILD BASELINE DEVIATION';
      guidance =
          'A single biometric is currently outside your normal range while other vitals remain steady. '
          'Monitor this trend over subsequent nights to observe if your baseline re-stabilizes.';
      systemicAnomaly = false;
    } else {
      overallStatus = OverallHealthStatus.allOptimal;
      headline = 'ALL VITALS IN NORMAL RANGE';
      subhead = '$inRange OF $totalWithData BIOMETRICS STABLE';
      guidance =
          'Your autonomic and cardiovascular biometrics are closely aligned with your personal 60-day baseline. '
          'Systemic recovery is stable.';
      systemicAnomaly = false;
    }

    return HealthMonitorReport(
      overallStatus: overallStatus,
      statusHeadline: headline,
      statusSubhead: subhead,
      nonDiagnosticGuidance: guidance,
      vitals: vitals,
      inRangeCount: inRange,
      totalVitalsWithData: totalWithData,
      daysOfData: daysOfData,
      hasSystemicAnomaly: systemicAnomaly,
      evaluatedAt: now,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INDIVIDUAL VITAL EVALUATORS
  // ─────────────────────────────────────────────────────────────────────────

  HealthVital _evaluateHrv({
    required double? value,
    required double? baseline,
    required double? stdDev,
    required bool isCalibrating,
    required bool isEstimated,
  }) {
    final base = baseline ?? value ?? 55.0;
    final sd = (stdDev != null && stdDev > 0) ? stdDev : (base * 0.15);
    final rangeLower = max(10.0, base - (0.75 * sd));
    final rangeUpper = base + (0.75 * sd);

    VitalStatus status;
    String devStr = '±0 ms';

    if (value == null) {
      status = VitalStatus.noData;
      devStr = '--';
    } else if (isCalibrating) {
      status = VitalStatus.calibrating;
      devStr = 'CALIBRATING';
    } else {
      final diff = value - base;
      final sign = diff >= 0 ? '+' : '';
      devStr = '$sign${diff.round()} ms';
      if (value < rangeLower) {
        status = VitalStatus.suppressed;
      } else if (value > rangeUpper) {
        status = VitalStatus.elevated;
      } else {
        status = VitalStatus.inRange;
      }
    }

    return HealthVital(
      type: HealthVitalType.hrv,
      label: 'Heart Rate Variability',
      value: value,
      baseline: base,
      rangeLower: isCalibrating ? null : rangeLower,
      rangeUpper: isCalibrating ? null : rangeUpper,
      unit: 'ms',
      status: status,
      provenance: value == null
          ? VitalProvenance.unavailable
          : (isEstimated
              ? VitalProvenance.estimated
              : VitalProvenance.sensorHardware),
      deviationString: devStr,
      nonDiagnosticNote:
          'HRV reflects autonomic nervous system balance. Acute drops can occur with poor sleep, alcohol, acute stress, or heavy cardiovascular training load.',
      sensorLimitation:
          'Wrist optical PPG sampling can be affected by nocturnal micro-movements, cold extremities, and watch strap tightness.',
    );
  }

  HealthVital _evaluateRhr({
    required double? value,
    required double? baseline,
    required double? stdDev,
    required bool isCalibrating,
  }) {
    final base = baseline ?? value ?? 60.0;
    final sd = (stdDev != null && stdDev > 0) ? stdDev : 3.5;
    final rangeLower = max(35.0, base - (0.75 * sd));
    final rangeUpper = base + (0.75 * sd);

    VitalStatus status;
    String devStr = '±0 bpm';

    if (value == null) {
      status = VitalStatus.noData;
      devStr = '--';
    } else if (isCalibrating) {
      status = VitalStatus.calibrating;
      devStr = 'CALIBRATING';
    } else {
      final diff = value - base;
      final sign = diff >= 0 ? '+' : '';
      devStr = '$sign${diff.round()} bpm';
      if (value > rangeUpper) {
        status = VitalStatus.elevated;
      } else if (value < rangeLower) {
        status = VitalStatus.suppressed;
      } else {
        status = VitalStatus.inRange;
      }
    }

    return HealthVital(
      type: HealthVitalType.rhr,
      label: 'Resting Heart Rate',
      value: value,
      baseline: base,
      rangeLower: isCalibrating ? null : rangeLower,
      rangeUpper: isCalibrating ? null : rangeUpper,
      unit: 'bpm',
      status: status,
      provenance: value == null
          ? VitalProvenance.unavailable
          : VitalProvenance.sensorHardware,
      deviationString: devStr,
      nonDiagnosticNote:
          'Resting heart rate reflects basal cardiovascular efficiency. Elevations frequently correlate with impending fatigue, dehydration, late digestion, or ambient heat.',
      sensorLimitation:
          'Extracts lowest sustained nocturnal 5-minute nadir. Sudden shifts in sleep position or ambient room temperature can influence nocturnal nadir.',
    );
  }

  HealthVital _evaluateRespiratoryRate({
    required double? value,
    required double? baseline,
    required double? stdDev,
    required bool isCalibrating,
  }) {
    final base = baseline ?? value ?? 15.0;
    final sd = (stdDev != null && stdDev > 0) ? stdDev : 0.8;
    final rangeLower = max(10.0, base - (0.75 * sd));
    final rangeUpper = min(22.0, base + (0.75 * sd));

    VitalStatus status;
    String devStr = '±0.0 rpm';

    if (value == null) {
      status = VitalStatus.noData;
      devStr = '--';
    } else if (isCalibrating) {
      status = VitalStatus.calibrating;
      devStr = 'CALIBRATING';
    } else {
      final diff = value - base;
      final sign = diff >= 0 ? '+' : '';
      devStr = '$sign${diff.toStringAsFixed(1)} rpm';
      if (value > rangeUpper) {
        status = VitalStatus.elevated;
      } else if (value < rangeLower) {
        status = VitalStatus.suppressed;
      } else {
        status = VitalStatus.inRange;
      }
    }

    return HealthVital(
      type: HealthVitalType.respiratoryRate,
      label: 'Respiratory Rate',
      value: value,
      baseline: base,
      rangeLower: isCalibrating ? null : rangeLower,
      rangeUpper: isCalibrating ? null : rangeUpper,
      unit: 'rpm',
      status: status,
      provenance: value == null
          ? VitalProvenance.unavailable
          : VitalProvenance.sensorHardware,
      deviationString: devStr,
      nonDiagnosticNote:
          'Respiratory rate during sleep is remarkably stable night-to-night. A sustained rise of 1–2+ breaths/min is a sensitive physiological marker of respiratory or systemic load.',
      sensorLimitation:
          'Derived via PPG respiratory sinus arrhythmia (RSA) modulation. Dedicated chest straps offer higher diagnostic frequency.',
    );
  }

  HealthVital _evaluateSpo2({
    required double? value,
    required double? baseline,
    required double? stdDev,
    required bool isCalibrating,
  }) {
    final base = baseline ?? value ?? 97.0;
    final rangeLower = max(95.0, base - 1.5);
    final rangeUpper = 100.0;

    VitalStatus status;
    String devStr = '±0%';

    if (value == null) {
      status = VitalStatus.noData;
      devStr = '--';
    } else if (isCalibrating) {
      status = VitalStatus.calibrating;
      devStr = 'CALIBRATING';
    } else {
      final diff = value - base;
      final sign = diff >= 0 ? '+' : '';
      devStr = '$sign${diff.toStringAsFixed(1)}%';
      if (value < rangeLower) {
        status = VitalStatus.suppressed;
      } else {
        status = VitalStatus.inRange;
      }
    }

    return HealthVital(
      type: HealthVitalType.bloodOxygen,
      label: 'Blood Oxygen',
      value: value,
      baseline: base,
      rangeLower: isCalibrating ? null : rangeLower,
      rangeUpper: isCalibrating ? null : rangeUpper,
      unit: '%',
      status: status,
      provenance: value == null
          ? VitalProvenance.unavailable
          : VitalProvenance.sensorHardware,
      deviationString: devStr,
      nonDiagnosticNote:
          'Overnight blood oxygen saturation reflects pulmonary gas exchange efficiency during sleep. Typical healthy resting saturation sits between 95% and 100%.',
      sensorLimitation:
          'Reflective wrist pulse oximetry is sensitive to skin perfusion, hand temperature, and strap tightness. Never use for diagnosing sleep apnea or pulmonary disorders.',
    );
  }

  HealthVital _evaluateSkinTemperature({
    required double? deviation,
    required double? baseline,
    required double? stdDev,
    required bool isCalibrating,
  }) {
    // Skin temperature is inherently tracked as deviation from baseline (0.0°C)
    final dev = deviation;
    final rangeLower = -0.5;
    final rangeUpper = 0.5;

    VitalStatus status;
    String devStr = '±0.0°C';

    if (dev == null) {
      status = VitalStatus.noData;
      devStr = '--';
    } else if (isCalibrating) {
      status = VitalStatus.calibrating;
      devStr = 'CALIBRATING';
    } else {
      final sign = dev >= 0 ? '+' : '';
      devStr = '$sign${dev.toStringAsFixed(2)}°C';
      if (dev > rangeUpper) {
        status = VitalStatus.elevated;
      } else if (dev < rangeLower) {
        status = VitalStatus.suppressed;
      } else {
        status = VitalStatus.inRange;
      }
    }

    return HealthVital(
      type: HealthVitalType.skinTemperature,
      label: 'Skin Temperature',
      value: dev,
      baseline: 0.0,
      rangeLower: isCalibrating ? null : rangeLower,
      rangeUpper: isCalibrating ? null : rangeUpper,
      unit: '°C',
      status: status,
      provenance: dev == null
          ? VitalProvenance.unavailable
          : VitalProvenance.sensorHardware,
      deviationString: devStr,
      nonDiagnosticNote:
          'Monitors relative thermal deviation from your personal 30-day circadian baseline. Changes correlate with sleep environment, circadian rhythm, menstrual phases, or systemic inflammatory response.',
      sensorLimitation:
          'Wrist skin temperature differs substantially from core body temperature. Ambient room temperature, blankets, and limb position directly influence readings.',
    );
  }
}
