import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/insights_engine.dart';
import 'liquid_glass.dart';

/// Modern Liquid-Glass explainable insight card.
/// Displays plain-language physiological coaching with direct metric attribution.
class ExplainableInsightCard extends StatefulWidget {
  final EngineInsight insight;
  final VoidCallback? onDismiss;

  const ExplainableInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
  });

  @override
  State<ExplainableInsightCard> createState() => _ExplainableInsightCardState();
}

class _ExplainableInsightCardState extends State<ExplainableInsightCard> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final insight = widget.insight;
    final isHigh = insight.priority == InsightPriority.high;

    final Color accentColor;
    final IconData categoryIcon;

    switch (insight.category) {
      case 'health':
        accentColor = Tok.recoverySuppressed;
        categoryIcon = Icons.warning_amber_rounded;
        break;
      case 'readiness':
        accentColor = isHigh ? Tok.recoverySuppressed : Tok.recoveryOptimal;
        categoryIcon = Icons.favorite_rounded;
        break;
      case 'sleep':
        accentColor = Tok.accentAmber;
        categoryIcon = Icons.bedtime_rounded;
        break;
      case 'load':
        accentColor = Tok.accentAmber;
        categoryIcon = Icons.bolt_rounded;
        break;
      case 'habit':
        accentColor = isHigh ? Tok.recoverySuppressed : Tok.neonAccent;
        categoryIcon = Icons.auto_awesome_rounded;
        break;
      default:
        accentColor = Tok.accentBlue;
        categoryIcon = Icons.insights_rounded;
        break;
    }

    return LiquidGlass(
      borderRadius: BorderRadius.circular(Tok.radiusMd),
      accentGlow: accentColor,
      hasBlur: false,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Category Badge + Dismiss Button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 12, color: accentColor),
                    const SizedBox(width: 5),
                    Text(
                      insight.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: RecovaColors.textTertiary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _isDismissed = true);
                  widget.onDismiss?.call();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Insight Title ──
          Text(
            insight.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: RecovaColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // ── Summary Copy ──
          Text(
            insight.summary,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: RecovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // ── Concrete Metric Reference Badges ──
          if (insight.metricReferences.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: insight.metricReferences.map((ref) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: RecovaColors.surfaceElevation3,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: RecovaColors.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    ref,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: RecovaColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // ── Actionable Nudge Highlight Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.actionableNudge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: RecovaColors.textPrimary.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
