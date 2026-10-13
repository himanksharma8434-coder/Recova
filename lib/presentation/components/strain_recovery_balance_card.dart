import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';
import 'liquid_glass.dart';

/// Interactive glassmorphic card connecting Daily Strain and Dynamic Recovery.
/// Explicitly reveals how cardiovascular strain fatigues the body
/// and how restful inactivity slowly replenishes physiological recovery throughout the day.
class StrainRecoveryBalanceCard extends StatelessWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback? onTapStrain;
  final VoidCallback? onTapRecovery;

  const StrainRecoveryBalanceCard({
    super.key,
    required this.summary,
    this.onTapStrain,
    this.onTapRecovery,
  });

  @override
  Widget build(BuildContext context) {
    final dayStrain = summary?.dayStrain ?? 0.0;
    final targetStrain = summary?.targetStrain ?? 14.0;
    final liveRecovery = summary?.recoveryScore ?? 50.0;
    final baselineRecovery = summary?.baselineRecoveryScore ?? liveRecovery;
    final strainImpact = summary?.strainImpact ?? 0.0;
    final restReplenishment = summary?.restReplenishment ?? 0.0;
    final restHours = summary?.restHours ?? 0.0;

    // Determine autonomic state
    final bool isResting = restReplenishment >= 1.0 && restReplenishment >= strainImpact;
    final bool isUnderHeavyStrain = strainImpact > 3.0 && strainImpact > restReplenishment;

    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    if (isUnderHeavyStrain) {
      badgeColor = Tok.accentAmber;
      badgeLabel = 'STRAIN FATIGUE';
      badgeIcon = Icons.bolt_rounded;
    } else if (isResting) {
      badgeColor = Tok.recoveryOptimal;
      badgeLabel = 'REST REPLENISHING';
      badgeIcon = Icons.self_improvement_rounded;
    } else {
      badgeColor = Tok.accentBlue;
      badgeLabel = 'EQUILIBRIUM';
      badgeIcon = Icons.balance_rounded;
    }

    final strainProgress = (dayStrain / 21.0).clamp(0.0, 1.0);
    final targetProgress = (targetStrain / 21.0).clamp(0.0, 1.0);

    return LiquidGlass(
      padding: const EdgeInsets.all(Tok.space14),
      borderRadius: BorderRadius.circular(Tok.radiusLg),
      onTap: onTapRecovery ?? onTapStrain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor.withValues(alpha: 0.16),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        badgeIcon,
                        size: 14,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STRAIN & RECOVERY BALANCE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: RecovaColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'AUTONOMIC INTERPLAY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor,
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Two Columns: Day Strain & Dynamic Shift ──
          Row(
            children: [
              // Column 1: Accumulated Day Strain
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Tok.glassFillRecessed,
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    border: Border.all(color: Tok.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'DAY STRAIN',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: RecovaColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TAR ${targetStrain.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Tok.accentAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            dayStrain.toStringAsFixed(1),
                            style: TokType.displayNumber.copyWith(
                              fontSize: 18,
                              color: Tok.accentAmber,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '/21',
                              style: TokType.unit.copyWith(
                                fontSize: 9.5,
                                color: Tok.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress track with target marker
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: strainProgress,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Tok.accentAmber,
                                        Color(0xFFFF9500),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Tok.accentAmber.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: (width * targetProgress).clamp(0.0, width - 2),
                                top: -2,
                                child: Container(
                                  width: 2,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Column 2: Live Dynamic Shift
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Tok.glassFillRecessed,
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    border: Border.all(color: Tok.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'DYNAMICS',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: RecovaColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'WAK ${baselineRecovery.round()}%',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: RecovaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (isResting) ...[
                            Text(
                              '+${restReplenishment.round()}%',
                              style: TokType.displayNumber.copyWith(
                                fontSize: 18,
                                color: Tok.recoveryOptimal,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'GAIN',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Tok.recoveryOptimal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else if (isUnderHeavyStrain) ...[
                            Text(
                              '-${strainImpact.round()}%',
                              style: TokType.displayNumber.copyWith(
                                fontSize: 18,
                                color: Tok.accentAmber,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'LOAD',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Tok.accentAmber,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${liveRecovery.round()}%',
                              style: TokType.displayNumber.copyWith(
                                fontSize: 18,
                                color: Tok.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'NET',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Tok.accentBlue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isResting
                            ? '${restHours.toStringAsFixed(1)}h rest logged'
                            : (isUnderHeavyStrain
                                ? 'Cardio load active'
                                : 'Restoring at baseline'),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: RecovaColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Narrative Explainer Banner ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(Tok.radiusSm),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(
                  isResting
                      ? Icons.trending_up_rounded
                      : (isUnderHeavyStrain
                          ? Icons.trending_down_rounded
                          : Icons.autorenew_rounded),
                  size: 14,
                  color: badgeColor,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    isResting
                        ? 'Recovery is slowly increasing (+1.25%/hr) as you rest without strenuous activity.'
                        : (isUnderHeavyStrain
                            ? 'Today\'s strain (${dayStrain.toStringAsFixed(1)}) creates acute fatigue (-${strainImpact.round()}%). Rest helps replenish.'
                            : 'Low strain detected. Keep resting without strenuous workouts to slowly replenish recovery.'),
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: RecovaColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 9,
                  color: RecovaColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
