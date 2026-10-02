import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/entities/body_age_result.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';
import '../cubits/body_age/body_age_cubit.dart';
import '../cubits/body_age/body_age_state.dart';

/// Body Age Estimation Screen.
/// Automatically pulls all available wearable data and computes
/// a functional body age vs chronological age.
class BodyAgeScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;

  const BodyAgeScreen({super.key, this.summary});

  @override
  State<BodyAgeScreen> createState() => _BodyAgeScreenState();
}

class _BodyAgeScreenState extends State<BodyAgeScreen>
    with TickerProviderStateMixin {
  final _ageController = TextEditingController();
  String? _selectedSex;
  late BodyAgeCubit _cubit;
  late AnimationController _pulseController;
  late AnimationController _revealController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    final repo = context.read<HealthSourceRepository>();
    _cubit = BodyAgeCubit(repository: repo);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _compute() {
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age (1–120)')),
      );
      return;
    }
    _cubit.compute(age: age, sex: _selectedSex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: RecovaColors.canvasBase,
        body: BlocConsumer<BodyAgeCubit, BodyAgeState>(
          listener: (context, state) {
            if (state is BodyAgeLoaded) {
              _revealController.forward(from: 0);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ──
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  expandedHeight: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'BODY AGE',
                    style: TokType.sectionLabel.copyWith(
                      fontSize: 12,
                      letterSpacing: 2.0,
                      color: Tok.textSecondary,
                    ),
                  ),
                  centerTitle: true,
                ),

                // ── Content ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Tok.space20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: Tok.space16),
                      if (state is BodyAgeInitial || state is BodyAgeError)
                        _buildInputForm(state),
                      if (state is BodyAgeLoading) _buildLoading(),
                      if (state is BodyAgeUnderage) _buildUnderage(),
                      if (state is BodyAgeLoaded)
                        _buildResults(state.result),
                      const SizedBox(height: 120), // bottom padding for nav
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT FORM
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInputForm(BodyAgeState state) {
    return Column(
      children: [
        // Hero illustration area
        GlassCard(
          elevated: true,
          padding: const EdgeInsets.all(Tok.space24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Tok.glassFill,
                  border: Border.all(
                    color: Tok.glassBorderBright,
                    width: 1.5,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.timer_outlined,
                      size: 36,
                      color: Tok.textPrimary.withValues(
                        alpha: 0.5 + _pulseAnimation.value * 0.5,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Tok.space16),
              Text(
                'Discover Your Body Age',
                style: TokType.heading.copyWith(fontSize: 20),
              ),
              const SizedBox(height: Tok.space8),
              Text(
                'Your wearable data will be analyzed automatically.\nJust tell us your age and biological sex.',
                textAlign: TextAlign.center,
                style: TokType.body.copyWith(
                  color: Tok.textTertiary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Tok.space20),

        // Age input
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR AGE',
                style: TokType.sectionLabel,
              ),
              const SizedBox(height: Tok.space12),
              ClipRRect(
                borderRadius: BorderRadius.circular(Tok.radiusSm),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: TokType.metricLarge.copyWith(fontSize: 24),
                    decoration: InputDecoration(
                      hintText: '25',
                      hintStyle: TokType.metricLarge.copyWith(
                        fontSize: 24,
                        color: Tok.textMuted,
                      ),
                      suffixText: 'years',
                      suffixStyle: TokType.unit,
                      filled: true,
                      fillColor: Tok.glassFillRecessed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide: BorderSide(
                          color: Tok.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide: BorderSide(
                          color: Tok.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide: BorderSide(
                          color: Tok.glassBorderBright,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Tok.space16,
                        vertical: Tok.space12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Tok.space12),

        // Sex selector
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIOLOGICAL SEX',
                style: TokType.sectionLabel,
              ),
              const SizedBox(height: Tok.space4),
              Text(
                'Used for population norm comparison',
                style: TokType.bodySmall.copyWith(color: Tok.textMuted),
              ),
              const SizedBox(height: Tok.space12),
              Row(
                children: [
                  _buildSexOption('male', 'Male', Icons.male),
                  const SizedBox(width: Tok.space12),
                  _buildSexOption('female', 'Female', Icons.female),
                  const SizedBox(width: Tok.space12),
                  _buildSexOption(null, 'Skip', Icons.remove),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: Tok.space20),

        // Error message
        if (state is BodyAgeError) ...[
          GlassCard(
            accentGlow: Tok.recoverySuppressed.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18,
                    color: Tok.recoverySuppressed),
                const SizedBox(width: Tok.space8),
                Expanded(
                  child: Text(
                    state.message,
                    style: TokType.bodySmall.copyWith(
                      color: Tok.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tok.space16),
        ],

        // Compute button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: _compute,
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              padding: EdgeInsets.zero,
              customBottomReflection: Tok.textPrimary.withValues(alpha: 0.08),
              child: Center(
                child: Text(
                  'ESTIMATE BODY AGE',
                  style: TokType.cardTitle.copyWith(
                    letterSpacing: 1.6,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: Tok.space12),
        Text(
          'All data stays on your device.',
          textAlign: TextAlign.center,
          style: TokType.caption.copyWith(color: Tok.textMuted),
        ),
      ],
    );
  }

  Widget _buildSexOption(String? value, String label, IconData icon) {
    final isSelected = _selectedSex == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSex = value),
        child: AnimatedContainer(
          duration: Tok.animFast,
          padding: const EdgeInsets.symmetric(
              vertical: Tok.space12, horizontal: Tok.space8),
          decoration: BoxDecoration(
            color: isSelected
                ? Tok.glassFillElevated
                : Tok.glassFillRecessed,
            borderRadius: BorderRadius.circular(Tok.radiusSm),
            border: Border.all(
              color: isSelected ? Tok.glassBorderBright : Tok.glassBorder,
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Tok.textPrimary : Tok.textTertiary),
              const SizedBox(height: Tok.space4),
              Text(
                label,
                style: TokType.caption.copyWith(
                  color: isSelected ? Tok.textPrimary : Tok.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return GlassCard(
      elevated: true,
      padding: const EdgeInsets.symmetric(vertical: Tok.space48),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Tok.glassFill,
                  boxShadow: [
                    BoxShadow(
                      color: Tok.neonAccent
                          .withValues(alpha: 0.1 * _pulseAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  color: Tok.textSecondary,
                  size: 28,
                ),
              );
            },
          ),
          const SizedBox(height: Tok.space16),
          Text(
            'Analyzing your biometrics...',
            style: TokType.body.copyWith(color: Tok.textSecondary),
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Comparing against population norms',
            style: TokType.caption.copyWith(color: Tok.textMuted),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UNDERAGE STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildUnderage() {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space24),
      child: Column(
        children: [
          const Icon(Icons.child_care, size: 48, color: Tok.textTertiary),
          const SizedBox(height: Tok.space16),
          Text(
            'Body Age Norms Apply to Adults',
            style: TokType.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Population norms used for body age estimation are '
            'calibrated for adults (18+). We recommend tracking '
            'general healthy habits instead.',
            style: TokType.body.copyWith(color: Tok.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Tok.space20),
          GestureDetector(
            onTap: () => _cubit.reset(),
            child: LiquidGlass(
              padding: const EdgeInsets.symmetric(
                horizontal: Tok.space24,
                vertical: Tok.space12,
              ),
              child: Text(
                'GO BACK',
                style: TokType.cardTitle.copyWith(
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESULTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildResults(BodyAgeResult result) {
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _revealAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _revealAnimation.value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Hero body age display
          _buildHeroAge(result),
          const SizedBox(height: Tok.space20),

          // Component breakdown
          _buildComponentBreakdown(result),
          const SizedBox(height: Tok.space16),

          // Derived metrics
          if (result.derivedMetrics.bmi != null ||
              result.derivedMetrics.vo2maxUsed != null)
            _buildDerivedMetrics(result),

          if (result.derivedMetrics.bmi != null ||
              result.derivedMetrics.vo2maxUsed != null)
            const SizedBox(height: Tok.space16),

          // Top levers
          if (result.topLevers.isNotEmpty) _buildTopLevers(result),
          if (result.topLevers.isNotEmpty) const SizedBox(height: Tok.space16),

          // Data quality & confidence
          _buildDataQuality(result),
          const SizedBox(height: Tok.space16),

          // Disclaimer
          _buildDisclaimer(result),
          const SizedBox(height: Tok.space20),

          // Recalculate button
          GestureDetector(
            onTap: () => _cubit.reset(),
            child: LiquidGlass(
              padding: const EdgeInsets.symmetric(
                horizontal: Tok.space24,
                vertical: Tok.space12,
              ),
              child: Text(
                'RECALCULATE',
                style: TokType.cardTitle.copyWith(
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Age Display ──

  Widget _buildHeroAge(BodyAgeResult result) {
    final diff = result.ageDifferenceYears;
    final isYounger = diff < 0;
    final isOlder = diff > 0;
    final diffAbs = diff.abs();
    final tierColor = isYounger
        ? Tok.recoveryOptimal
        : isOlder
            ? Tok.recoverySuppressed
            : Tok.recoveryModerate;

    return GlassCard(
      elevated: true,
      accentGlow: tierColor.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space24,
        vertical: Tok.space32,
      ),
      child: Column(
        children: [
          // Label
          Text(
            'ESTIMATED BODY AGE',
            style: TokType.sectionLabel.copyWith(
              letterSpacing: 2.4,
              fontSize: 9.5,
            ),
          ),
          const SizedBox(height: Tok.space12),

          // Big number
          _buildBodyAgeGauge(result),

          const SizedBox(height: Tok.space16),

          // Difference pill
          LiquidGlass(
            padding: const EdgeInsets.symmetric(
              horizontal: Tok.space16,
              vertical: Tok.space6,
            ),
            customBottomReflection: tierColor.withValues(alpha: 0.15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tierColor.withValues(
                          alpha: _pulseAnimation.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tierColor.withValues(
                              alpha: _pulseAnimation.value * 0.5,
                            ),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: Tok.space8),
                Text(
                  isYounger
                      ? '${diffAbs.toStringAsFixed(1)} YEARS YOUNGER'
                      : isOlder
                          ? '${diffAbs.toStringAsFixed(1)} YEARS OLDER'
                          : 'MATCHES YOUR AGE',
                  style: TokType.caption.copyWith(
                    color: Tok.textSecondary,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Tok.space16),

          // Chronological age reference
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chronological Age: ',
                style: TokType.bodySmall.copyWith(color: Tok.textTertiary),
              ),
              Text(
                '${result.chronologicalAge}',
                style: TokType.bodySmall.copyWith(
                  color: Tok.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: Tok.space8),

          // Confidence badge
          _buildConfidenceBadge(result.confidence),
        ],
      ),
    );
  }

  Widget _buildBodyAgeGauge(BodyAgeResult result) {
    final diff = result.ageDifferenceYears;
    final tierColor = diff < 0
        ? Tok.recoveryOptimal
        : diff > 0
            ? Tok.recoverySuppressed
            : Tok.recoveryModerate;

    // Normalize offset for gauge display (-15 to +15 → 0 to 1)
    final normalizedOffset =
        ((diff + 15) / 30).clamp(0.0, 1.0);
    // Invert so that younger (left/green) has higher fill
    final fillRatio = 1.0 - normalizedOffset;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background dark disc
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Tok.canvasDeep,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: tierColor.withValues(
                        alpha: 0.08 * _pulseAnimation.value,
                      ),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              );
            },
          ),

          // Gauge arcs
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _BodyAgeGaugePainter(
                fillRatio: fillRatio,
                accentColor: tierColor,
              ),
            ),
          ),

          // Center number
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.bodyAge % 1 == 0
                    ? result.bodyAge.toInt().toString()
                    : result.bodyAge.toStringAsFixed(1),
                style: TokType.displayNumber.copyWith(
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'YEARS',
                style: TokType.caption.copyWith(
                  letterSpacing: 2.0,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(BodyAgeConfidence confidence) {
    final Color color;
    switch (confidence) {
      case BodyAgeConfidence.high:
        color = Tok.recoveryOptimal;
      case BodyAgeConfidence.medium:
        color = Tok.recoveryModerate;
      case BodyAgeConfidence.low:
        color = Tok.recoverySuppressed;
    }

    return GlassPill(
      accentColor: color,
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space12,
        vertical: Tok.space4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: Tok.space6),
          Text(
            '${confidence.label} CONFIDENCE',
            style: TokType.caption.copyWith(
              color: Tok.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Component Breakdown ──

  Widget _buildComponentBreakdown(BodyAgeResult result) {
    if (result.components.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMPONENT BREAKDOWN', style: TokType.sectionLabel),
          const SizedBox(height: Tok.space16),
          ...result.components.map((c) => _buildComponentRow(c)),
        ],
      ),
    );
  }

  Widget _buildComponentRow(BodyAgeComponent component) {
    final isPositive = component.offsetYears < 0;
    final isNegative = component.offsetYears > 0;
    final color = isPositive
        ? Tok.recoveryOptimal
        : isNegative
            ? Tok.recoverySuppressed
            : Tok.recoveryModerate;

    final offsetText = component.offsetYears > 0
        ? '+${component.offsetYears.toStringAsFixed(1)}'
        : component.offsetYears.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: Tok.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category color indicator
              Container(
                width: 3,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: Tok.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.category.toUpperCase(),
                      style: TokType.caption.copyWith(
                        color: Tok.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      component.note,
                      style: TokType.bodySmall.copyWith(
                        color: Tok.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Tok.space8),
              // Year offset
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${offsetText}y',
                    style: TokType.metricMedium.copyWith(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'P${component.percentileEstimate}',
                    style: TokType.caption.copyWith(
                      color: Tok.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bar indicator
          Padding(
            padding: const EdgeInsets.only(
                left: 15, top: Tok.space4),
            child: _buildOffsetBar(component.offsetYears, color),
          ),

          // Inputs used
          Padding(
            padding: const EdgeInsets.only(left: 15, top: Tok.space4),
            child: Wrap(
              spacing: Tok.space4,
              runSpacing: Tok.space4,
              children: component.inputsUsed.map((input) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Tok.glassFillRecessed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    input,
                    style: TokType.caption.copyWith(
                      fontSize: 8,
                      color: Tok.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetBar(double offset, Color color) {
    // Center-anchored bar: 0 is center, -10 is far left, +10 is far right
    final normalized = (offset / 10).clamp(-1.0, 1.0);

    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final center = width / 2;
          final barWidth = (normalized.abs() * center).clamp(2.0, center);
          final left = normalized < 0 ? center - barWidth : center;

          return Stack(
            children: [
              // Track
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Tok.glassFillRecessed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Center mark
              Positioned(
                left: center - 0.5,
                child: Container(
                  width: 1,
                  height: 4,
                  color: Tok.textMuted,
                ),
              ),
              // Fill bar
              Positioned(
                left: left,
                child: Container(
                  width: barWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Derived Metrics ──

  Widget _buildDerivedMetrics(BodyAgeResult result) {
    final metrics = result.derivedMetrics;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DERIVED METRICS', style: TokType.sectionLabel),
          const SizedBox(height: Tok.space16),
          Row(
            children: [
              if (metrics.bmi != null)
                _buildMetricTile('BMI', metrics.bmi!.toStringAsFixed(1), ''),
              if (metrics.vo2maxUsed != null)
                _buildMetricTile(
                    'VO₂MAX', metrics.vo2maxUsed!.toStringAsFixed(1), 'mL/kg/min'),
              if (metrics.bmrKcal != null)
                _buildMetricTile(
                    'BMR', metrics.bmrKcal!.toStringAsFixed(0), 'kcal/day'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TokType.sectionLabel),
          const SizedBox(height: Tok.space4),
          Text(
            value,
            style: TokType.metricMedium.copyWith(fontSize: 18),
          ),
          if (unit.isNotEmpty)
            Text(unit, style: TokType.caption.copyWith(color: Tok.textMuted)),
        ],
      ),
    );
  }

  // ── Top Levers ──

  Widget _buildTopLevers(BodyAgeResult result) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_down, size: 16, color: Tok.textSecondary),
              const SizedBox(width: Tok.space8),
              Text('TOP ACTIONS TO LOWER BODY AGE',
                  style: TokType.sectionLabel),
            ],
          ),
          const SizedBox(height: Tok.space16),
          ...result.topLevers.asMap().entries.map((entry) {
            final i = entry.key;
            final lever = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < result.topLevers.length - 1 ? Tok.space16 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tok.glassFillElevated,
                      border: Border.all(
                        color: Tok.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TokType.caption.copyWith(
                          color: Tok.textPrimary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Tok.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lever.action,
                          style: TokType.bodySmall.copyWith(
                            color: Tok.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: Tok.space4),
                        Row(
                          children: [
                            Icon(Icons.arrow_downward,
                                size: 10, color: Tok.recoveryOptimal),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                lever.expectedEffect,
                                style: TokType.caption.copyWith(
                                  color: Tok.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 10, color: Tok.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              lever.timeframe,
                              style: TokType.caption.copyWith(
                                color: Tok.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ── Data Quality & Missing Inputs ──

  Widget _buildDataQuality(BodyAgeResult result) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATA QUALITY', style: TokType.sectionLabel),
          const SizedBox(height: Tok.space12),

          if (result.missingInputs.isNotEmpty) ...[
            Text(
              'Missing inputs that would improve accuracy:',
              style: TokType.bodySmall.copyWith(color: Tok.textTertiary),
            ),
            const SizedBox(height: Tok.space8),
            ...result.missingInputs.map((input) => Padding(
                  padding: const EdgeInsets.only(bottom: Tok.space4),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 12, color: Tok.textMuted),
                      const SizedBox(width: Tok.space8),
                      Expanded(
                        child: Text(
                          input,
                          style: TokType.bodySmall
                              .copyWith(color: Tok.textTertiary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          if (result.dataQualityFlags.isNotEmpty) ...[
            const SizedBox(height: Tok.space12),
            ...result.dataQualityFlags.map((flag) => Padding(
                  padding: const EdgeInsets.only(bottom: Tok.space4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 12, color: Tok.textMuted),
                      const SizedBox(width: Tok.space8),
                      Expanded(
                        child: Text(
                          flag,
                          style: TokType.bodySmall
                              .copyWith(color: Tok.textMuted),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── Disclaimer ──

  Widget _buildDisclaimer(BodyAgeResult result) {
    return GlassCardLight(
      padding: const EdgeInsets.all(Tok.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: Tok.textMuted),
          const SizedBox(width: Tok.space8),
          Expanded(
            child: Text(
              result.disclaimer,
              style: TokType.caption.copyWith(
                color: Tok.textMuted,
                height: 1.5,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BODY AGE GAUGE PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _BodyAgeGaugePainter extends CustomPainter {
  final double fillRatio;
  final Color accentColor;

  _BodyAgeGaugePainter({
    required this.fillRatio,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // 1. Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Dot matrix ring (60 dots)
    const totalDots = 60;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      final angle = (i * 2 * pi) / totalDots - (pi / 2);
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), 1.2, dotPaint);
    }

    // 3. Active fill
    if (fillRatio > 0) {
      final activeDotsCount = (fillRatio * totalDots).round();

      final activeDotPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < activeDotsCount; i++) {
        final angle = (i * 2 * pi) / totalDots - (pi / 2);
        final dotX = center.dx + radius * cos(angle);
        final dotY = center.dy + radius * sin(angle);
        canvas.drawCircle(Offset(dotX, dotY), 2.2, activeDotPaint);
      }

      // Inner arc
      final sweepAngle = fillRatio * 2 * pi;
      final innerArcPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -pi / 2,
        sweepAngle,
        false,
        innerArcPaint,
      );

      // Glow arc
      final glowArcPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -pi / 2,
        sweepAngle,
        false,
        glowArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BodyAgeGaugePainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio ||
        oldDelegate.accentColor != accentColor;
  }
}
