import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import 'liquid_glass.dart';

/// Sleep Advisor & Bedtime Target Card.
class SleepAdvisorCard extends StatelessWidget {
  final int sleepNeedMinutes;
  final double? lastNightSleepHours;
  final int strainAdditionMinutes;
  final int debtAdditionMinutes;
  final int napCreditMinutes;
  final VoidCallback? onTap;

  const SleepAdvisorCard({
    super.key,
    required this.sleepNeedMinutes,
    this.lastNightSleepHours,
    this.strainAdditionMinutes = 0,
    this.debtAdditionMinutes = 0,
    this.napCreditMinutes = 0,
    this.onTap,
  });

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _calculateBedtime(int needMinutes, {int targetWakeHour = 7}) {
    final wakeTime = DateTime(2026, 1, 1, targetWakeHour, 0);
    // Add 15 mins for average sleep latency (time to fall asleep)
    final bedtime = wakeTime.subtract(Duration(minutes: needMinutes + 15));
    final hour12 = bedtime.hour > 12
        ? bedtime.hour - 12
        : (bedtime.hour == 0 ? 12 : bedtime.hour);
    final ampm = bedtime.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = bedtime.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final needFormatted = _formatMinutes(sleepNeedMinutes);
    final suggestedBedtime = _calculateBedtime(sleepNeedMinutes);

    return Semantics(
      label: "Tonight's Sleep Need",
      value: '$needFormatted sleep needed, suggested bedtime $suggestedBedtime',
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(Tok.radiusLg),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Tok.accentBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Tok.accentBlue.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'TONIGHT\'S SLEEP NEED',
                            style: TokType.sectionLabel.copyWith(
                              letterSpacing: 1.0,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Tok.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Tok.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Tok.accentBlue.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'BEDTIME $suggestedBedtime',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Tok.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),

            // Number Readout
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        needFormatted,
                        style: TokType.metricLarge.copyWith(
                          fontSize: 34,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: Tok.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'target',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Tok.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (lastNightSleepHours != null)
                  Text(
                    'Last night: ${lastNightSleepHours!.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Tok.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Breakdown Chips: Base, Strain, Debt, Nap
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBreakdownChip('Base 8.0h', Tok.textSecondary),
                if (strainAdditionMinutes > 0)
                  _buildBreakdownChip('+$strainAdditionMinutes m Strain', Tok.accentAmber),
                if (debtAdditionMinutes > 0)
                  _buildBreakdownChip('+$debtAdditionMinutes m Debt', Tok.recoverySuppressed),
                if (napCreditMinutes > 0)
                  _buildBreakdownChip('-$napCreditMinutes m Nap Credit', Tok.recoveryOptimal),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bedtime for 7:00 AM wake',
                    style: TokType.caption.copyWith(
                      fontSize: 10.5,
                      color: Tok.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'Tap for stages',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Tok.neonAccent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBreakdownChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Tok.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.7,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
