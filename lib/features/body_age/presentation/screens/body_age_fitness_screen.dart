import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../presentation/components/ambient_glow_backdrop.dart';
import '../../../../presentation/components/glass_card.dart';
import '../../data/repositories/body_age_repository_impl.dart';
import '../../domain/entities/body_age_factor.dart';
import '../../domain/entities/body_age_result.dart';
import '../../domain/repositories/body_age_repository.dart';
import '../components/monthly_checkin_dialog.dart';

/// Full-featured Fitness Body Age screen displaying physiological factor breakdowns,
/// achievable targets, historical trend charts, and the monthly check-in action.
class BodyAgeFitnessScreen extends StatefulWidget {
  final BodyAgeRepository? bodyAgeRepository;

  const BodyAgeFitnessScreen({
    super.key,
    this.bodyAgeRepository,
  });

  @override
  State<BodyAgeFitnessScreen> createState() => _BodyAgeFitnessScreenState();
}

class _BodyAgeFitnessScreenState extends State<BodyAgeFitnessScreen> {
  late final BodyAgeRepository _bodyAgeRepo;

  FitnessBodyAgeResult? _latestResult;
  List<FitnessBodyAgeResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bodyAgeRepo = widget.bodyAgeRepository ?? BodyAgeRepositoryImpl();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Parallelize loading current result and historical snapshots
    final results = await Future.wait([
      _bodyAgeRepo.calculateCurrentBodyAge(),
      _bodyAgeRepo.getSnapshotHistory(limit: 6),
    ]);

    if (mounted) {
      setState(() {
        _latestResult = results[0] as FitnessBodyAgeResult?;
        _history = results[1] as List<FitnessBodyAgeResult>;
        _isLoading = false;
      });
    }
  }

  void _openCheckinModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MonthlyCheckinDialog(
        prefilledWeight: null,
        initialIsKg: true,
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tok.canvasBase,
      body: AmbientGlowBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Tok.neonAccent,
                        ),
                      )
                    : _latestResult == null
                        ? _buildEmptyState()
                        : _buildMainContent(_latestResult!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space16,
        vertical: Tok.space12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Tok.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'FITNESS BODY AGE',
            style: TokType.heading.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined, color: Tok.neonAccent),
            tooltip: 'Monthly Check-In',
            onPressed: _openCheckinModal,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tok.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights, size: 48, color: Tok.textMuted),
            const SizedBox(height: Tok.space16),
            Text(
              'NOT ENOUGH DATA YET',
              style: TokType.sectionLabel.copyWith(
                color: Tok.neonAccent,
              ),
            ),
            const SizedBox(height: Tok.space8),
            Text(
              'Body age requires at least 2 physiological factors (such as Resting HR, VO2 Max, or a monthly body measurement).',
              textAlign: TextAlign.center,
              style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
            ),
            const SizedBox(height: Tok.space24),
            ElevatedButton(
              onPressed: _openCheckinModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Tok.neonAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: Tok.space24,
                  vertical: Tok.space12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Tok.radiusMd),
                ),
              ),
              child: const Text('LOG MEASUREMENTS NOW'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(FitnessBodyAgeResult result) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Tok.space16),
      children: [
        _buildHeroScoreCard(result),
        const SizedBox(height: Tok.space16),
        _buildFactorBreakdownSection(result),
        const SizedBox(height: Tok.space16),
        if (result.achievableBodyAge != null) ...[
          _buildAchievableTargetCard(result),
          const SizedBox(height: Tok.space16),
        ],
        if (_history.length >= 2) ...[
          _buildTrendChartCard(_history),
          const SizedBox(height: Tok.space16),
        ],
        _buildDisclaimer(),
        const SizedBox(height: Tok.space24),
      ],
    );
  }

  Widget _buildHeroScoreCard(FitnessBodyAgeResult result) {
    final diff = result.difference;
    final isYounger = diff < 0;
    final isSame = diff == 0;

    return GlassCard(
      accentGlow: isYounger ? Tok.neonAccentGlow : null,
      padding: const EdgeInsets.all(Tok.space20),
      child: Column(
        children: [
          Text(
            'FUNCTIONAL BODY AGE',
            style: TokType.sectionLabel,
          ),
          const SizedBox(height: Tok.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                result.bodyAge.toStringAsFixed(1),
                style: TokType.displayNumber,
              ),
              const SizedBox(width: Tok.space8),
              Text(
                'YEARS',
                style: TokType.unit,
              ),
            ],
          ),
          const SizedBox(height: Tok.space8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Tok.space14,
              vertical: Tok.space6,
            ),
            decoration: BoxDecoration(
              color: isYounger
                  ? Colors.green.withValues(alpha: 0.15)
                  : isSame
                      ? Tok.glassFillRecessed
                      : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Tok.radiusFull),
              border: Border.all(
                color: isYounger
                    ? Colors.green
                    : isSame
                        ? Tok.glassBorder
                        : Colors.orange,
              ),
            ),
            child: Text(
              isSame
                  ? 'Matches your chronological age of ${result.chronologicalAge}'
                  : isYounger
                      ? '▼ ${diff.abs().toStringAsFixed(1)} years younger than actual age (${result.chronologicalAge})'
                      : '▲ ${diff.abs().toStringAsFixed(1)} years older than actual age (${result.chronologicalAge})',
              style: TokType.caption.copyWith(
                color: isYounger
                    ? Colors.greenAccent
                    : isSame
                        ? Tok.textSecondary
                        : Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorBreakdownSection(FitnessBodyAgeResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHYSIOLOGICAL BREAKDOWN',
          style: TokType.sectionLabel,
        ),
        const SizedBox(height: Tok.space12),
        ...BodyAgeFactor.values.map((factor) {
          final age = result.factorAges[factor];
          final isMissing = age == null;

          return Padding(
            padding: const EdgeInsets.only(bottom: Tok.space10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Tok.space16,
                vertical: Tok.space12,
              ),
              child: Row(
                children: [
                  Icon(
                    _iconForFactor(factor),
                    color: isMissing ? Tok.textMuted : Tok.neonAccent,
                    size: 22,
                  ),
                  const SizedBox(width: Tok.space14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factor.displayName,
                          style: TokType.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isMissing ? 'No data recorded yet' : factor.description,
                          style: TokType.caption.copyWith(color: Tok.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isMissing ? '—' : '${age.toStringAsFixed(1)} yr',
                    style: TokType.cardTitle.copyWith(
                      color: isMissing
                          ? Tok.textMuted
                          : age <= result.chronologicalAge
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievableTargetCard(FitnessBodyAgeResult result) {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACHIEVABLE TARGET',
                style: TokType.sectionLabel.copyWith(
                  color: Tok.neonAccent,
                ),
              ),
              Text(
                '${result.achievableBodyAge?.toStringAsFixed(1)} yrs',
                style: TokType.metricMedium.copyWith(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Target body age achievable with targeted lifestyle improvements:',
            style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
          ),
          const SizedBox(height: Tok.space12),
          ...result.topImprovements.map((factor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Tok.space6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Tok.neonAccent)),
                  Expanded(
                    child: Text(
                      _tipForFactor(factor),
                      style: TokType.bodySmall.copyWith(color: Tok.textPrimary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(List<FitnessBodyAgeResult> history) {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].bodyAge));
    }

    return GlassCard(
      padding: const EdgeInsets.all(Tok.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORICAL BODY AGE TREND',
            style: TokType.sectionLabel,
          ),
          const SizedBox(height: Tok.space16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Tok.neonAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Tok.neonAccent.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tok.space8),
      child: Text(
        'Estimate for wellness purposes, not medical advice. Based on population norms from The Cooper Institute, NHANES, and WHO guidelines.',
        textAlign: TextAlign.center,
        style: TokType.caption.copyWith(color: Tok.textMuted),
      ),
    );
  }

  IconData _iconForFactor(BodyAgeFactor factor) {
    switch (factor) {
      case BodyAgeFactor.vo2Max:
        return Icons.speed_outlined;
      case BodyAgeFactor.restingHeartRate:
        return Icons.favorite_border;
      case BodyAgeFactor.vigorousActivity:
        return Icons.fitness_center_outlined;
      case BodyAgeFactor.bodyComposition:
        return Icons.accessibility_new_outlined;
    }
  }

  String _tipForFactor(BodyAgeFactor factor) {
    switch (factor) {
      case BodyAgeFactor.vo2Max:
        return 'Cardio HIIT: 2 weekly interval sessions can raise VO2 max by 2–4 mL/kg/min.';
      case BodyAgeFactor.restingHeartRate:
        return 'Sleep & Recovery: Consistent sleep timing and zone 2 cardio can lower baseline RHR.';
      case BodyAgeFactor.vigorousActivity:
        return 'Weekly Volume: Aim for at least 75+ minutes of vigorous aerobic workouts each week.';
      case BodyAgeFactor.bodyComposition:
        return 'Body Composition: Resistance training and nutrition can reduce body fat % and improve functional metabolic age.';
    }
  }
}
