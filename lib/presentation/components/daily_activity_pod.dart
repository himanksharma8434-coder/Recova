import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'glass_card.dart';

/// Daily Movement & Energy Expenditure Card.
/// Glassmorphic treatment with Tok design tokens.
class DailyActivityPod extends StatelessWidget {
  final int? todaySteps;
  final double? activeCalories;
  final double? totalCalories;

  const DailyActivityPod({
    super.key,
    this.todaySteps,
    this.activeCalories,
    this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    final steps = todaySteps ?? 0;
    final activeKcal = activeCalories?.toInt() ?? 0;
    final totalKcal = totalCalories?.toInt() ?? 0;

    const stepTarget = 10000;
    final stepRatio = (steps / stepTarget).clamp(0.0, 1.0);

    return GlassCard(
      onTap: () => _showDailyActivityDetails(
          context, steps, activeKcal, totalKcal, stepRatio),
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
                    Icon(Icons.directions_run,
                        size: 14, color: Tok.textTertiary),
                    const SizedBox(width: Tok.space8),
                    Flexible(
                      child: Text(
                        'DAILY ACTIVITY & ENERGY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TokType.caption.copyWith(
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
                      steps > 0 ? '${(stepRatio * 100).toInt()}% GOAL' : '--',
                      style: TokType.badge.copyWith(
                        color: Tok.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: Tok.space6),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Tok.textTertiary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Tok.space16),

          // ── 3 Column Activity Metrics ──
          Row(
            children: [
              // Steps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STEPS (TODAY)', style: TokType.caption),
                    const SizedBox(height: 3),
                    Text(
                      steps > 0 ? _formatNumber(steps) : '--',
                      style: TokType.metricMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: Tok.space2),
                    Text(
                      'TODAY • / 10,000',
                      style: TokType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 30,
                color: Tok.glassBorder,
              ),
              const SizedBox(width: Tok.space12),

              // Active Calories
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTIVE', style: TokType.caption),
                    const SizedBox(height: 3),
                    Text(
                      activeKcal > 0 ? '$activeKcal' : '--',
                      style: TokType.metricMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: Tok.space2),
                    Text(
                      'kcal',
                      style: TokType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 30,
                color: Tok.glassBorder,
              ),
              const SizedBox(width: Tok.space12),

              // Total Metabolic Burn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL', style: TokType.caption),
                    const SizedBox(height: 3),
                    Text(
                      totalKcal > 0 ? '$totalKcal' : '--',
                      style: TokType.metricMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: Tok.space2),
                    Text(
                      'kcal',
                      style: TokType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space16),

          // ── Progress Bar with neon accent ──
          ClipRRect(
            borderRadius: BorderRadius.circular(1.5),
            child: Stack(
              children: [
                Container(
                  height: 3.0,
                  decoration: BoxDecoration(
                    color: Tok.glassFillRecessed,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: stepRatio,
                  child: Container(
                    height: 3.5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Tok.accentAmber,
                          Tok.neonAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1.75),
                      boxShadow: [
                        BoxShadow(
                          color: Tok.neonAccent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      final str = number.toString();
      return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return number.toString();
  }

  void _showDailyActivityDetails(
    BuildContext context,
    int steps,
    int activeKcal,
    int totalKcal,
    double stepRatio,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Tok.glassFillDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
                border: Border.all(color: Tok.glassBorder, width: 1.0),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tok.space20,
                    vertical: Tok.space20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Tok.glassBorderBright,
                            borderRadius: BorderRadius.circular(Tok.space2),
                          ),
                        ),
                      ),
                      const SizedBox(height: Tok.space16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DAILY ACTIVITY TELEMETRY',
                            style: TokType.cardTitle.copyWith(
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          GlassPill(
                            child: Text(
                              'DAY ONLY (00:00 - NOW)',
                              style: TokType.badge.copyWith(
                                color: Tok.textPrimary,
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Tok.space16),

                      // Detail Card
                      GlassCard(
                        padding: const EdgeInsets.all(Tok.space16),
                        child: Column(
                          children: [
                            _detailRow(
                              'Pedometer Steps (Today)',
                              steps > 0 ? '${_formatNumber(steps)} steps' : '--',
                              null,
                            ),
                            Divider(height: Tok.space16, color: Tok.glassBorder),
                            _detailRow(
                              'Goal Completion',
                              steps > 0
                                  ? '${(stepRatio * 100).toInt()}% of 10k target'
                                  : '--',
                              null,
                            ),
                            Divider(height: Tok.space16, color: Tok.glassBorder),
                            _detailRow(
                              'Active Energy Expenditure',
                              activeKcal > 0 ? '$activeKcal kcal' : '--',
                              Tok.recoveryModerate,
                            ),
                            Divider(height: Tok.space16, color: Tok.glassBorder),
                            _detailRow(
                              'Total Caloric Burn (with BMR)',
                              totalKcal > 0 ? '$totalKcal kcal' : '--',
                              null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Tok.space16),

                      // Note
                      GlassCard(
                        padding: const EdgeInsets.all(Tok.space12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 14, color: Tok.textTertiary),
                            const SizedBox(width: Tok.space8),
                            Expanded(
                              child: Text(
                                'Telemetry is strictly aggregated for today (from midnight to present). Multi-source overlaps (phone and watch) and weekly accumulations are de-duplicated to ensure 100% daily accuracy.',
                                style: TokType.caption.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TokType.bodySmall),
        Text(
          value,
          style: TokType.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Tok.textPrimary,
          ),
        ),
      ],
    );
  }
}
