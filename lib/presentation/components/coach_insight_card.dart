import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import 'glass_card.dart';

class CoachInsightCard extends StatelessWidget {
  final double? recoveryScore;
  final String? primaryFactor;

  const CoachInsightCard({
    super.key,
    required this.recoveryScore,
    this.primaryFactor,
  });

  @override
  Widget build(BuildContext context) {
    final score = recoveryScore ?? 50;
    final tier = RecoveryTier.fromScore(recoveryScore);

    String insightText;
    String strainTarget;
    String optimalWindow;

    if (score >= 80) {
      insightText =
          'Your parasympathetic balance is optimal today. Recommended target strain: ';
      strainTarget = '14.5 – 17.2';
      optimalWindow = 'OPTIMAL WINDOW: 10:30 AM - 2:00 PM';
    } else if (score >= 50) {
      insightText =
          'Moderate autonomic recovery detected. Maintain steady conditioning. Target strain: ';
      strainTarget = '10.0 – 13.5';
      optimalWindow = 'RECOMMENDED: AEROBIC ZONE 2 TRAINING';
    } else {
      insightText =
          'Suppressed recovery indicated (${primaryFactor ?? 'Resting HR elevated'}). Prioritize sleep & active recovery. Target strain: ';
      strainTarget = '6.0 – 9.0';
      optimalWindow = 'ACTIVE RECOVERY & HYDRATION ONLY';
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_outlined,
                      size: 15, color: Tok.neonAccent),
                  const SizedBox(width: Tok.space8),
                  Text(
                    'COACH INSIGHT',
                    style: TokType.cardTitle.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              Text(
                'AUTONOMIC AI',
                style: TokType.caption,
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),

          // Insight Narrative
          RichText(
            text: TextSpan(
              style: TokType.body,
              children: [
                TextSpan(text: insightText),
                TextSpan(
                  text: strainTarget,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: tier.color,
                  ),
                ),
                const TextSpan(
                    text: '. Tailored to your baseline & daily telemetry.'),
              ],
            ),
          ),
          const SizedBox(height: Tok.space12),

          // Footer Window
          Container(
            padding: const EdgeInsets.only(top: Tok.space12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Tok.glassBorder),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tier.color,
                          boxShadow: [
                            BoxShadow(
                              color: tier.color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Tok.space6),
                      Flexible(
                        child: Text(
                          optimalWindow,
                          style: TokType.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'DETAILS',
                      style: TokType.caption.copyWith(
                        color: Tok.textSecondary,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 12, color: Tok.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
