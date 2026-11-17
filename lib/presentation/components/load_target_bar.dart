import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import 'liquid_glass.dart';

/// Cardiovascular Load Bar (0 to 21 scale) with live Target Range Band.
class LoadTargetBar extends StatelessWidget {
  final double currentLoad;
  final double targetLower;
  final double targetUpper;
  final int workoutMinutes;
  final int todaySteps;
  final VoidCallback? onTap;

  const LoadTargetBar({
    super.key,
    required this.currentLoad,
    required this.targetLower,
    required this.targetUpper,
    this.workoutMinutes = 0,
    this.todaySteps = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressFraction = (currentLoad / 21.0).clamp(0.0, 1.0);
    final targetStartFraction = (targetLower / 21.0).clamp(0.0, 1.0);
    final targetEndFraction = (targetUpper / 21.0).clamp(0.0, 1.0);

    final isInTarget = currentLoad >= targetLower && currentLoad <= targetUpper;
    final isAboveTarget = currentLoad > targetUpper;

    Color loadColor = Tok.accentAmber;
    if (isInTarget) {
      loadColor = Tok.recoveryOptimal;
    } else if (isAboveTarget) {
      loadColor = Tok.accentViolet;
    }

    return Semantics(
      label: 'Cardiovascular Load',
      value: '${currentLoad.toStringAsFixed(1)} of 21 scale, target range ${targetLower.toStringAsFixed(1)} to ${targetUpper.toStringAsFixed(1)}',
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
                            color: Tok.accentAmber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Tok.accentAmber.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'CARDIOVASCULAR LOAD',
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
                      color: Tok.accentAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Tok.accentAmber.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'TARGET ${targetLower.toStringAsFixed(1)} - ${targetUpper.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Tok.accentAmber,
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
                    children: [
                      Text(
                        currentLoad.toStringAsFixed(1),
                        style: TokType.metricLarge.copyWith(
                          fontSize: 34,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: Tok.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          '/ 21.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Tok.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isInTarget
                      ? 'Target Reached'
                      : (currentLoad < targetLower
                          ? '${(targetLower - currentLoad).toStringAsFixed(1)} to target'
                          : 'Target Exceeded'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: loadColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Track with Target Zone Bracket
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final left = width * targetStartFraction;
                final targetWidth = width * (targetEndFraction - targetStartFraction);
                final fillWidth = width * progressFraction;

                return Stack(
                  children: [
                    // Background Track
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: RecovaColors.monochromeWhite.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),

                    // Target Zone Bracket (Visual highlight of recommended band)
                    Positioned(
                      left: left,
                      width: targetWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Tok.accentAmber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Tok.accentAmber.withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),

                    // Current Load Fill
                    Container(
                      height: 10,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            loadColor.withValues(alpha: 0.6),
                            loadColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: loadColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Quick Stats Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workoutMinutes > 0
                        ? '${workoutMinutes}m workout • ${todaySteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps'
                        : (todaySteps > 0
                            ? '${todaySteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} active steps'
                            : 'Awaiting movement'),
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
                    'Tap for 5 zones',
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
}
