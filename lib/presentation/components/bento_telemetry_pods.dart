import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/repositories/health_source_repository.dart';
import 'glass_card.dart';

class BentoTelemetryPods extends StatelessWidget {
  final double? dayStrain;
  final double? sleepHours;
  final double? baselineSleepHours;
  final SleepStageBreakdown? sleepStages;

  const BentoTelemetryPods({
    super.key,
    this.dayStrain,
    this.sleepHours,
    this.baselineSleepHours,
    this.sleepStages,
  });

  @override
  Widget build(BuildContext context) {
    final hasStrain = dayStrain != null && dayStrain! > 0.0;
    final strain = dayStrain ?? 0.0;
    final strainPercent = (strain / 21.0).clamp(0.0, 1.0);

    final hasSleep = sleepHours != null && sleepHours! > 0.0;
    final sleep = sleepHours ?? 0.0;
    final sleepH = sleep.floor();
    final sleepM = ((sleep - sleepH) * 60).round();

    final baselineH = baselineSleepHours ?? 8.0;
    final sleepPerf = hasSleep && baselineH > 0
        ? ((sleep / baselineH) * 100).clamp(0, 150).round()
        : null;

    return Row(
      children: [
        // ── Day Strain Pod ──
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(Tok.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt,
                            size: 14, color: Tok.recoveryModerate),
                        const SizedBox(width: Tok.space4),
                        Text(
                          'DAY STRAIN',
                          style: TokType.caption.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'MAX 21',
                      style: TokType.caption.copyWith(
                        color: Tok.textSecondary,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Tok.space12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hasStrain ? strain.toStringAsFixed(1) : '--',
                      style: TokType.metricLarge.copyWith(fontSize: 24),
                    ),
                    const SizedBox(width: Tok.space4),
                    Text(
                      '/ 21.0',
                      style: TokType.bodySmall.copyWith(
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Tok.space4),
                Text(
                  hasStrain
                      ? (strain >= 14
                          ? 'HIGH LOAD'
                          : strain >= 8
                              ? 'MODERATE LOAD'
                              : 'LIGHT LOAD')
                      : 'NO LOAD RECORDED',
                  style: TokType.caption.copyWith(
                    color: hasStrain ? Tok.textSecondary : Tok.textSecondary,
                  ),
                ),
                const SizedBox(height: Tok.space12),
                // Progress Bar with accent glow
                Stack(
                  children: [
                    Container(
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Tok.glassFillRecessed,
                        borderRadius: BorderRadius.circular(Tok.space2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: strainPercent,
                      child: Container(
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: Tok.recoveryModerate,
                          borderRadius: BorderRadius.circular(Tok.space2),
                          boxShadow: [
                            BoxShadow(
                              color: Tok.recoveryModerate
                                  .withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Tok.space12),

        // ── Sleep Architecture Pod ──
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(Tok.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bedtime,
                            size: 14, color: Tok.accentBlue),
                        const SizedBox(width: Tok.space4),
                        Text(
                          'SLEEP',
                          style: TokType.caption.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      sleepPerf != null ? '$sleepPerf% PERF' : '--',
                      style: TokType.caption.copyWith(
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Tok.space12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hasSleep ? '${sleepH}h' : '--',
                      style: TokType.metricLarge.copyWith(fontSize: 24),
                    ),
                    if (hasSleep) ...[
                      const SizedBox(width: Tok.space4),
                      Text(
                        '${sleepM}m',
                        style: TokType.metricMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Tok.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Tok.space4),
                Text(
                  hasSleep
                      ? (sleep >= baselineH
                          ? 'BASELINE MET'
                          : 'SLEEP DEFICIT')
                      : 'AWAITING SLEEP LOG',
                  style: TokType.caption.copyWith(
                    color: hasSleep ? Tok.textSecondary : Tok.textSecondary,
                  ),
                ),
                const SizedBox(height: Tok.space12),
                // Stage breakdown
                ClipRRect(
                  borderRadius: BorderRadius.circular(Tok.space2),
                  child: SizedBox(
                    height: 3.5,
                    child: (sleepStages != null &&
                            sleepStages!.hasStageData)
                        ? Row(
                            children: [
                              if (sleepStages!.deepMinutes > 0)
                                Expanded(
                                  flex: sleepStages!.deepMinutes,
                                  child: Container(color: Tok.neonAccent),
                                ),
                              if (sleepStages!.remMinutes > 0)
                                Expanded(
                                  flex: sleepStages!.remMinutes,
                                  child: Container(color: Tok.accentBlue),
                                ),
                              if (sleepStages!.lightMinutes > 0)
                                Expanded(
                                  flex: sleepStages!.lightMinutes,
                                  child: Container(color: Tok.textTertiary),
                                ),
                              if (sleepStages!.awakeMinutes > 0)
                                Expanded(
                                  flex: sleepStages!.awakeMinutes,
                                  child: Container(
                                      color: Tok.recoverySuppressed),
                                ),
                            ],
                          )
                        : Container(
                            color: hasSleep
                                ? Tok.textTertiary
                                : Tok.glassFillRecessed,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
