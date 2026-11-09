import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/body_engine/health_monitor_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../screens/health_monitor_screen.dart';
import 'liquid_glass.dart';

/// Glanceable Health Monitor pod displayed on the main Pulse screen.
/// Summarizes the 5 overnight vitals with interactive navigation to the deep-dive panel.
class HealthMonitorPod extends StatelessWidget {
  final DerivedMetricSummary? summary;

  const HealthMonitorPod({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final report = summary?.healthMonitorReport;
    final overallStatus = report?.overallStatus ?? OverallHealthStatus.calibrating;
    final isCalibrating = overallStatus == OverallHealthStatus.calibrating;
    final isAnomaly = overallStatus == OverallHealthStatus.systemicAnomaly;
    final isAttention = overallStatus == OverallHealthStatus.elevatedAttention;

    final Color statusColor;
    final String statusLabel;

    if (isCalibrating) {
      statusColor = Tok.accentAmber;
      statusLabel = 'CALIBRATING (${report?.daysOfData ?? 1}/7)';
    } else if (isAnomaly) {
      statusColor = Tok.recoverySuppressed;
      statusLabel = 'SYSTEMIC ANOMALY';
    } else if (isAttention) {
      statusColor = Tok.accentAmber;
      statusLabel = '1 VITAL ELEVATED';
    } else {
      statusColor = Tok.recoveryOptimal;
      statusLabel = '${report?.inRangeCount ?? 5}/5 IN RANGE';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HealthMonitorScreen(summary: summary),
          ),
        );
      },
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Section label, status pill & arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HEALTH MONITOR',
                      style: TokType.sectionLabel.copyWith(
                        letterSpacing: 1.3,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
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
                            statusLabel,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: statusColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Tok.textSecondary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5 Vitals Glance Row
            Row(
              children: [
                _buildVitalIndicator(
                  label: 'HRV',
                  vital: report?.getVital(HealthVitalType.hrv),
                ),
                const SizedBox(width: 6),
                _buildVitalIndicator(
                  label: 'RHR',
                  vital: report?.getVital(HealthVitalType.rhr),
                ),
                const SizedBox(width: 6),
                _buildVitalIndicator(
                  label: 'RESP',
                  vital: report?.getVital(HealthVitalType.respiratoryRate),
                ),
                const SizedBox(width: 6),
                _buildVitalIndicator(
                  label: 'SPO2',
                  vital: report?.getVital(HealthVitalType.bloodOxygen),
                ),
                const SizedBox(width: 6),
                _buildVitalIndicator(
                  label: 'TEMP',
                  vital: report?.getVital(HealthVitalType.skinTemperature),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalIndicator({
    required String label,
    required HealthVital? vital,
  }) {
    final status = vital?.status ?? VitalStatus.calibrating;
    final Color color;

    switch (status) {
      case VitalStatus.inRange:
        color = Tok.recoveryOptimal;
        break;
      case VitalStatus.elevated:
      case VitalStatus.suppressed:
        color = Tok.accentAmber;
        break;
      case VitalStatus.calibrating:
        color = Tok.accentBlue;
        break;
      case VitalStatus.noData:
        color = Tok.textSecondary;
        break;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Tok.glassFillRecessed,
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 0.7,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4.5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Tok.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              vital?.value != null
                  ? (vital!.type == HealthVitalType.skinTemperature
                      ? '${vital.value! >= 0 ? "+" : ""}${vital.value!.toStringAsFixed(1)}°'
                      : vital.value!.round().toString())
                  : '--',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Tok.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
