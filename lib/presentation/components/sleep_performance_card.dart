import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/repositories/health_source_repository.dart';
import 'glass_card.dart';

/// Full-width Glassmorphic Card for Sleep Architecture.
class SleepPerformanceCard extends StatelessWidget {
  final double? sleepHours;
  final double? baselineSleepHours;
  final SleepStageBreakdown? sleepStages;
  final List<DistributedSleepSession> sleepSessions;
  final VoidCallback? onTap;

  const SleepPerformanceCard({
    super.key,
    this.sleepHours,
    this.baselineSleepHours,
    this.sleepStages,
    this.sleepSessions = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSleep = sleepHours != null && sleepHours! > 0.0;
    final sleep = sleepHours ?? 0.0;
    final sleepH = sleep.floor();
    final sleepM = ((sleep - sleepH) * 60).round();

    final baselineH = baselineSleepHours ?? 8.0;
    final sleepPerf = hasSleep && baselineH > 0
        ? ((sleep / baselineH) * 100).clamp(0, 150).round()
        : null;

    final stages = sleepStages;
    final hasStages = stages != null && stages.hasStageData;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.bedtime_outlined,
                        size: 14, color: Tok.accentBlue),
                    const SizedBox(width: Tok.space8),
                    Flexible(
                      child: Text(
                        'SLEEP ARCHITECTURE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TokType.caption.copyWith(
                          color: Tok.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Tok.space8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassPill(
                    child: Text(
                      sleepPerf != null ? '$sleepPerf% PERFORMANCE' : '--',
                      style: TokType.badge.copyWith(
                        color: Tok.textPrimary,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: Tok.space6),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Tok.textSecondary,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),

          // ── Big Duration Readout & Delta ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    hasSleep ? '${sleepH}h' : '--',
                    style: TokType.metricLarge.copyWith(fontSize: 30),
                  ),
                  if (hasSleep) ...[
                    const SizedBox(width: Tok.space4),
                    Text(
                      '${sleepM}m',
                      style: TokType.metricMedium.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                'TARGET: ${baselineH.toStringAsFixed(1)}h',
                style: TokType.caption.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (sleepSessions.length > 1) ...[
            const SizedBox(height: Tok.space12),
            Wrap(
              spacing: Tok.space6,
              runSpacing: Tok.space4,
              children: sleepSessions.map((s) {
                final sH = s.durationHours.floor();
                final sM = s.durationMinutes % 60;
                final durStr = sH > 0 ? '${sH}h ${sM}m' : '${sM}m';
                final isNight = s.type == SleepSessionType.nightSleep;
                return GlassPill(
                  accentColor: isNight ? null : Tok.recoverySuppressed,
                  child: Text(
                    '${s.title} • $durStr',
                    style: TokType.badge.copyWith(
                      color: isNight
                          ? Tok.textSecondary
                          : Tok.recoverySuppressed,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: Tok.space16),

          // ── Stage Distribution Bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(Tok.space2),
            child: SizedBox(
              height: 4,
              child: hasStages
                  ? Row(
                      children: [
                        if (stages.deepMinutes > 0)
                          Expanded(
                            flex: stages.deepMinutes,
                            child: Container(color: Tok.accentBlue),
                          ),
                        if (stages.remMinutes > 0)
                          Expanded(
                            flex: stages.remMinutes,
                            child: Container(color: Tok.accentViolet),
                          ),
                        if (stages.lightMinutes > 0)
                          Expanded(
                            flex: stages.lightMinutes,
                            child: Container(color: const Color(0xFF38BDF8)),
                          ),
                        if (stages.awakeMinutes > 0)
                          Expanded(
                            flex: stages.awakeMinutes,
                            child: Container(color: Tok.recoverySuppressed),
                          ),
                      ],
                    )
                  : Container(
                      color: hasSleep
                          ? Tok.accentBlue.withValues(alpha: 0.5)
                          : Tok.glassFillRecessed,
                    ),
            ),
          ),
          const SizedBox(height: Tok.space12),

          // ── Stages Legend ──
          Wrap(
            spacing: Tok.space12,
            runSpacing: Tok.space6,
            children: [
              _StageLegendItem(
                dotColor: Tok.accentBlue,
                label: 'DEEP',
                value: hasStages ? '${stages.deepMinutes}m' : '--',
              ),
              _StageLegendItem(
                dotColor: Tok.accentViolet,
                label: 'REM',
                value: hasStages ? '${stages.remMinutes}m' : '--',
              ),
              _StageLegendItem(
                dotColor: const Color(0xFF38BDF8),
                label: 'LIGHT',
                value: hasStages ? '${stages.lightMinutes}m' : '--',
              ),
              _StageLegendItem(
                dotColor: Tok.recoverySuppressed,
                label: 'AWAKE',
                value: hasStages ? '${stages.awakeMinutes}m' : '--',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageLegendItem extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;

  const _StageLegendItem({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label $value',
          style: TokType.caption,
        ),
      ],
    );
  }
}
