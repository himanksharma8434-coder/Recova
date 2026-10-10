import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../domain/services/vo2_max_estimator.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';

class Vo2MaxDetailScreen extends StatelessWidget {
  final DerivedMetricSummary summary;

  const Vo2MaxDetailScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currentVo2Max = summary.estimatedVo2Max ?? 0.0;

    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      body: AmbientGlowBackdrop(
        primaryGlow: Tok.neonAccent,
        secondaryGlow: Tok.accentViolet,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'VO₂ MAX ESTIMATION',
                style: TokType.sectionLabel.copyWith(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: Tok.textSecondary,
                ),
              ),
              centerTitle: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Tok.space20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: Tok.space12),
                  _buildHero(context, currentVo2Max),
                  const SizedBox(height: Tok.space20),
                  _buildHistoricalBarGraph(context),
                  const SizedBox(height: Tok.space20),
                  _buildHowItWorksCard(context),
                  const SizedBox(height: Tok.space20),
                  _buildAlgorithmDetailsCard(context),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, double currentVo2Max) {
    return GlassCard(
      elevated: true,
      accentGlow: Tok.neonAccent.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space24,
        vertical: Tok.space24,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Tok.neonAccentSurface,
              border: Border.all(
                color: Tok.neonAccent.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: const Icon(Icons.speed_rounded, color: Tok.neonAccent, size: 28),
          ),
          const SizedBox(height: Tok.space16),
          Text(
            'YOUR ESTIMATE',
            style: TokType.sectionLabel.copyWith(
              letterSpacing: 2.2,
              fontSize: 9.5,
              color: Tok.textSecondary,
            ),
          ),
          const SizedBox(height: Tok.space8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentVo2Max > 0 ? currentVo2Max.toStringAsFixed(1) : '--',
                style: TokType.displayNumber.copyWith(
                  fontSize: 56,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: Tok.neonAccent,
                ),
              ),
              const SizedBox(width: Tok.space4),
              Text(
                'mL/kg/min',
                style: TokType.caption.copyWith(
                  color: Tok.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalBarGraph(BuildContext context) {
    final v7d = summary.estimatedVo2Max7d ?? summary.estimatedVo2Max ?? 0;
    final v30d = summary.estimatedVo2Max30d ?? summary.estimatedVo2Max ?? 0;
    final vAll = summary.estimatedVo2MaxAllTime ?? summary.estimatedVo2Max ?? 0;

    final maxVal = [v7d, v30d, vAll, 60.0].reduce((a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(Tok.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Tok.textPrimary, size: 20),
                  const SizedBox(width: Tok.space8),
                  Text(
                    'TRENDS',
                    style: TokType.cardTitle.copyWith(letterSpacing: 1.2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('7D', v7d, maxVal),
              _buildBar('30D', v30d, maxVal),
              _buildBar('ALL TIME', vAll, maxVal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double maxVal) {
    final ratio = maxVal > 0 ? (value / maxVal).clamp(0.05, 1.0) : 0.05;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value > 0 ? value.toStringAsFixed(1) : '-',
          style: TokType.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: Tok.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 100 * ratio,
          decoration: BoxDecoration(
            color: Tok.neonAccent.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Tok.neonAccent,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Tok.neonAccent.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TokType.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Tok.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Tok.textPrimary, size: 20),
              const SizedBox(width: Tok.space8),
              Text(
                'HOW IT WORKS',
                style: TokType.cardTitle.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: Tok.space16),
          Text(
            'We use the validated Uth-Sørensen baseline model to calculate your VO₂ max using simply the ratio of maximum heart rate to resting heart rate.',
            style: TokType.bodySmall.copyWith(
              color: Tok.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Tok.space16),
          _buildStepRow(
            icon: Icons.favorite_border,
            title: 'Simple and Direct',
            description: 'This is an estimate derived from your peak and resting heart rate data. It is not a clinical VO₂ max test.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Tok.glassFillElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Tok.neonAccent),
        ),
        const SizedBox(width: Tok.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TokType.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TokType.caption.copyWith(
                  color: Tok.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlgorithmDetailsCard(BuildContext context) {
    return FutureBuilder<Vo2MaxResult?>(
      future: context.read<HealthSourceRepository>().getLatestVo2MaxResult(),
      builder: (context, snapshot) {
        final vo2Result = snapshot.data;
        return LiquidGlass(
          hasBlur: false,
          padding: const EdgeInsets.all(Tok.space20),
          borderRadius: BorderRadius.circular(Tok.radiusLg),
          customBottomReflection: Tok.accentBlue.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.functions_rounded, color: Tok.accentBlue, size: 20),
                  const SizedBox(width: Tok.space8),
                  Text(
                    'THE MATH',
                    style: TokType.cardTitle.copyWith(
                      letterSpacing: 1.2,
                      color: Tok.accentBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tok.space16),
              Text(
                'Powered by the Uth-Sørensen Baseline Equation',
                style: TokType.bodySmall.copyWith(
                  color: Tok.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Tok.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Tok.canvasDeep.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Tok.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BASELINE COMPARISON',
                      style: TokType.caption.copyWith(color: Tok.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    if (vo2Result?.userMaxHr != null && vo2Result?.userRestingHr != null) ...[
                      Text(
                        '15.3 × (${vo2Result!.userMaxHr!.toInt()} / ${vo2Result!.userRestingHr!.toInt()}) = ${(15.3 * (vo2Result!.userMaxHr! / vo2Result!.userRestingHr!)).toStringAsFixed(1)}',
                        style: TokType.mono.copyWith(color: Tok.neonAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calculated using 15.3 × (Peak HR / Avg RHR)',
                        style: TokType.caption.copyWith(color: Tok.textSecondary),
                      ),
                    ] else ...[
                      Text(
                        '15.3 × (HRmax / HRrest) = VO₂_Max',
                        style: TokType.mono.copyWith(color: Tok.neonAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
