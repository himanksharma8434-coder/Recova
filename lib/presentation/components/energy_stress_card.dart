import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/body_engine/body_engine.dart';
import 'liquid_glass.dart';

/// Intraday Energy Reserve & Daytime Stress Card.
class EnergyStressCard extends StatelessWidget {
  final double? energyReserve;
  final bool isEnergyReserveCalibrating;
  final int daysOfData;
  final StressBand stressBand;
  final double stressScore;

  const EnergyStressCard({
    super.key,
    this.energyReserve,
    this.isEnergyReserveCalibrating = false,
    this.daysOfData = 14,
    this.stressBand = StressBand.balanced,
    this.stressScore = 35.0,
  });

  Color _getStressColor() {
    switch (stressBand) {
      case StressBand.calm:
        return Tok.recoveryOptimal;
      case StressBand.balanced:
        return Tok.accentBlue;
      case StressBand.elevated:
        return Tok.accentAmber;
      case StressBand.high:
        return Tok.recoverySuppressed;
    }
  }

  String _getStressLabel() {
    switch (stressBand) {
      case StressBand.calm:
        return 'CALM';
      case StressBand.balanced:
        return 'BALANCED';
      case StressBand.elevated:
        return 'ELEVATED';
      case StressBand.high:
        return 'HIGH';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stressColor = _getStressColor();
    final stressLabel = _getStressLabel();

    return Row(
      children: [
        // ── 1. Energy Reserve Pod ──
        Expanded(
          child: Semantics(
            label: 'Energy Reserve',
            value: isEnergyReserveCalibrating || energyReserve == null
                ? 'Calibrating baseline'
                : '${energyReserve!.round()} percent',
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(Tok.radiusLg),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Tok.neonAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Tok.neonAccent.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'ENERGY RESERVE',
                                style: TokType.sectionLabel.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 1.2,
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isEnergyReserveCalibrating || energyReserve == null) ...[
                    Text(
                      'CALIBRATING',
                      style: TokType.metricLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Tok.accentAmber,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlocks in ${10 - daysOfData > 0 ? 10 - daysOfData : 1}d',
                      style: TokType.caption.copyWith(
                        fontSize: 10,
                        color: Tok.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${energyReserve!.round()}',
                            style: TokType.metricLarge.copyWith(
                              fontSize: 28,
                              height: 1.0,
                              fontWeight: FontWeight.w800,
                              color: Tok.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Tok.neonAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Charges with rest & naps',
                      style: TokType.caption.copyWith(
                        fontSize: 10,
                        color: Tok.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── 2. Daytime Autonomic Stress Pod ──
        Expanded(
          child: Semantics(
            label: 'Daytime Autonomic Stress',
            value: '$stressLabel, score ${stressScore.round()}',
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(Tok.radiusLg),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: stressColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: stressColor.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'DAY STRESS',
                              style: TokType.sectionLabel.copyWith(
                                fontSize: 9,
                                letterSpacing: 1.2,
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
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        stressLabel,
                        style: TokType.metricLarge.copyWith(
                          fontSize: 18,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: stressColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sedentary • Paused in workout',
                  style: TokType.caption.copyWith(
                    fontSize: 10,
                    color: Tok.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
  }
}
