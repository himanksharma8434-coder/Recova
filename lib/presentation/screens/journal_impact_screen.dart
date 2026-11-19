import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/journal_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/liquid_glass.dart';

/// Screen presenting transparent 30-day behavioral habit correlations against next-day recovery.
class JournalImpactScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;

  const JournalImpactScreen({super.key, this.summary});

  @override
  State<JournalImpactScreen> createState() => _JournalImpactScreenState();
}

class _JournalImpactScreenState extends State<JournalImpactScreen> {
  List<BehaviorCorrelation>? _correlations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCorrelations();
  }

  Future<void> _loadCorrelations() async {
    if (widget.summary?.habitCorrelations.isNotEmpty == true) {
      setState(() {
        _correlations = widget.summary!.habitCorrelations;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = sl<HealthSourceRepository>();
      final list = await repo.getHabitCorrelations();
      if (mounted) {
        setState(() {
          _correlations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: RecovaColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'HABIT IMPACT & HABITS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: RecovaColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Tok.neonAccent),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FDA 2026 / Trust & Methodology Disclaimer ──
                  _buildTrustDisclaimerBanner(),
                  const SizedBox(height: 16),

                  // ── Section Header ──
                  const Text(
                    '30-DAY HABIT CORRELATIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Correlation List or Empty State ──
                  if (_correlations == null || _correlations!.isEmpty)
                    _buildEmptyState()
                  else
                    ..._correlations!.map(_buildCorrelationCard),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTrustDisclaimerBanner() {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(Tok.radiusMd),
      accentGlow: Tok.neonAccent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.science_rounded, size: 16, color: Tok.neonAccent),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'CORRELATION, NOT CAUSATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Tok.neonAccent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'This engine evaluates next-day morning readiness and nocturnal vitals on days following a logged behavior versus days when it was absent. '
            'Minimum 5 logged days are required to detect an emerging trend, and 10 days for high confidence. Results represent statistical associations, not clinical diagnoses.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: RecovaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(Tok.radiusMd),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.edit_note_rounded, size: 36, color: RecovaColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No Behaviors Logged Yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: RecovaColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Quick-tap daily habits (Alcohol, Late Meal, Late Caffeine, Magnesium) on your Today screen. Once you log 5+ occurrences, your personalized impact breakdown will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: RecovaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationCard(BehaviorCorrelation correlation) {
    final isCollecting =
        correlation.status == HabitConfidenceStatus.insufficientData;
    final isGrounded = correlation.status == HabitConfidenceStatus.grounded;
    final delta = correlation.readinessDeltaPercent;
    final isNegative = delta != null && delta < 0;

    final Color impactColor;
    if (isCollecting) {
      impactColor = RecovaColors.textTertiary;
    } else if (isNegative) {
      impactColor = Tok.recoverySuppressed;
    } else {
      impactColor = Tok.recoveryOptimal;
    }

    final def = BehaviorTagDefinition.fromKey(correlation.tag);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag Name, Status Badge & Impact %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: RecovaColors.surfaceElevation3,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getIconData(def.iconName),
                          size: 16,
                          color: impactColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              correlation.displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: RecovaColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${correlation.taggedDaysCount} logged days',
                              style: const TextStyle(
                                fontSize: 10,
                                color: RecovaColors.textTertiary,
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
                const SizedBox(width: 8),
                // Impact % or Collecting Pill
                if (isCollecting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: RecovaColors.surfaceElevation3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: RecovaColors.borderSubtle),
                    ),
                    child: Text(
                      'COLLECTING (${correlation.taggedDaysCount}/5)',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Tok.accentAmber,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: impactColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: impactColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${delta! >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}% READINESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: impactColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar if collecting
            if (isCollecting) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (correlation.taggedDaysCount / 5.0).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: RecovaColors.surfaceElevation3,
                  valueColor: const AlwaysStoppedAnimation(Tok.accentAmber),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Secondary vitals shift pills (RHR and HRV)
            if (!isCollecting &&
                (correlation.rhrDeltaBpm != null || correlation.hrvDeltaMs != null)) ...[
              Row(
                children: [
                  if (correlation.rhrDeltaBpm != null) ...[
                    _buildVitalShiftPill(
                      label: 'RHR',
                      delta: correlation.rhrDeltaBpm!,
                      unit: 'bpm',
                      isFlippedPositive: true, // Lower RHR is better
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (correlation.hrvDeltaMs != null)
                    _buildVitalShiftPill(
                      label: 'HRV',
                      delta: correlation.hrvDeltaMs!,
                      unit: 'ms',
                      isFlippedPositive: false, // Higher HRV is better
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Coaching summary
            Text(
              correlation.coachingInsight,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: RecovaColors.textSecondary,
              ),
            ),

            if (isGrounded) ...[
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.verified_rounded, size: 11, color: Tok.neonAccent),
                  SizedBox(width: 4),
                  Text(
                    'High statistical confidence (10+ occurrences)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Tok.neonAccent,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalShiftPill({
    required String label,
    required double delta,
    required String unit,
    required bool isFlippedPositive,
  }) {
    final sign = delta >= 0 ? '+' : '';
    final isGood = isFlippedPositive ? delta <= 0 : delta >= 0;
    final color = isGood ? Tok.recoveryOptimal : Tok.recoverySuppressed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RecovaColors.borderSubtle),
      ),
      child: Text(
        '$label $sign${delta.toStringAsFixed(1)} $unit',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'wine_bar':
        return Icons.wine_bar_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'coronavirus':
        return Icons.sick_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'hot_tub':
        return Icons.hot_tub_rounded;
      case 'air':
        return Icons.air_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }
}
