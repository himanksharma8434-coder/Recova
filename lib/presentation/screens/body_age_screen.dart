import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/entities/body_age_result.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../services/user_profile_service.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';
import '../cubits/body_age/body_age_cubit.dart';
import '../cubits/body_age/body_age_state.dart';
import 'profile_settings_screen.dart';

/// Body Age Estimation Screen.
/// Automatically pulls wearable data and compares against population norms
/// using the profile configured once in Settings (BW, Height, Age, Gender).
class BodyAgeScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;

  const BodyAgeScreen({super.key, this.summary});

  @override
  State<BodyAgeScreen> createState() => _BodyAgeScreenState();
}

class _BodyAgeScreenState extends State<BodyAgeScreen>
    with TickerProviderStateMixin {
  UserProfile? _profile;
  late BodyAgeCubit _cubit;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    final repo = context.read<HealthSourceRepository>();
    _cubit = BodyAgeCubit(repository: repo);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );

    _initAndCompute();
  }

  Future<void> _initAndCompute() async {
    final profile = await UserProfileService.getProfile();
    if (!mounted) return;

    setState(() => _profile = profile);

    if (profile.hasRequiredForBodyAge) {
      _cubit.compute(
        age: profile.age!,
        sex: profile.gender,
        heightCm: profile.heightCm,
        weightKg: profile.weightKg,
      );
    }
  }

  Future<void> _openSettings() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );

    if (updated == true && mounted) {
      _initAndCompute();
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: RecovaColors.canvasBase,
        body: AmbientGlowBackdrop(
          primaryGlow: Tok.recoveryOptimal,
          secondaryGlow: Tok.accentViolet,
          child: BlocConsumer<BodyAgeCubit, BodyAgeState>(
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
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Profile Settings',
                      onPressed: _openSettings,
                    ),
                  ],
                ),

                // ── Content ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Tok.space20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: Tok.space12),

                      if (_profile != null && !_profile!.hasRequiredForBodyAge)
                        _buildSetupRequired()
                      else if (state is BodyAgeLoading ||
                          (state is BodyAgeInitial && _profile == null))
                        _buildLoading()
                      else if (state is BodyAgeUnderage)
                        _buildUnderage()
                      else if (state is BodyAgeError)
                        _buildError(state.message)
                      else if (state is BodyAgeLoaded)
                        _buildResults(state.result),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETUP REQUIRED PROMPT (Clean, shown only if profile has no age yet)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSetupRequired() {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Tok.glassFillElevated,
              border: Border.all(color: Tok.glassBorder, width: 0.5),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 28,
              color: Tok.neonAccent,
            ),
          ),
          const SizedBox(height: Tok.space16),
          Text(
            'Configure Profile in Settings',
            style: TokType.heading.copyWith(fontSize: 18),
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Body Age compares your wearable data against age and sex cohorts. '
            'Please add your body weight, height, age, and gender once in settings to calculate your fitness age.',
            textAlign: TextAlign.center,
            style: TokType.bodySmall.copyWith(
              color: Tok.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Tok.space20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GestureDetector(
              onTap: _openSettings,
              child: LiquidGlass(
                borderRadius: BorderRadius.circular(Tok.radiusSm),
                padding: EdgeInsets.zero,
                customBottomReflection:
                    Tok.textPrimary.withValues(alpha: 0.12),
                child: Center(
                  child: Text(
                    'CONFIGURE PROFILE',
                    style: TokType.cardTitle.copyWith(
                      letterSpacing: 1.4,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESULTS DISPLAY (Clean & Focused)
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
          // Profile summary pill
          _buildProfilePill(result),
          const SizedBox(height: Tok.space16),

          // Hero body age display
          _buildHeroAge(result),
          const SizedBox(height: Tok.space16),

          // Component breakdown
          _buildComponentBreakdown(result),
          const SizedBox(height: Tok.space16),

          // Derived metrics (BMI, VO2 Max, BMR)
          if (result.derivedMetrics.bmi != null ||
              result.derivedMetrics.vo2maxUsed != null ||
              result.derivedMetrics.bmrKcal != null)
            _buildDerivedMetrics(result),

          if (result.derivedMetrics.bmi != null ||
              result.derivedMetrics.vo2maxUsed != null ||
              result.derivedMetrics.bmrKcal != null)
            const SizedBox(height: Tok.space16),

          // Top actionable levers
          if (result.topLevers.isNotEmpty) _buildTopLevers(result),
          if (result.topLevers.isNotEmpty) const SizedBox(height: Tok.space16),

          // Data quality & flags (only if any flags exist)
          if (result.dataQualityFlags.isNotEmpty) ...[
            _buildDataQuality(result),
            const SizedBox(height: Tok.space16),
          ],

          // Minimal Disclaimer
          _buildDisclaimer(result),
        ],
      ),
    );
  }

  // ── Profile Summary Pill ──

  Widget _buildProfilePill(BodyAgeResult result) {
    final age = _profile?.age ?? result.chronologicalAge;
    final gender = _profile?.gender == 'female' ? 'Female' : 'Male';
    final weight = _profile?.weightKg != null
        ? ' • ${_profile!.weightKg!.toStringAsFixed(1)} kg'
        : '';
    final height = _profile?.heightCm != null
        ? ' • ${_profile!.heightCm!.toStringAsFixed(0)} cm'
        : '';

    return LiquidGlass(
      onTap: _openSettings,
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space16,
        vertical: Tok.space8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline,
              size: 13, color: Tok.textSecondary),
          const SizedBox(width: 6),
          Text(
            '$age yrs • $gender$weight$height',
            style: TokType.caption.copyWith(
              color: Tok.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.edit_outlined, size: 11, color: Tok.textMuted),
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
      accentGlow: tierColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space24,
        vertical: Tok.space24,
      ),
      child: Column(
        children: [
          Text(
            'ESTIMATED FUNCTIONAL AGE',
            style: TokType.sectionLabel.copyWith(
              letterSpacing: 2.2,
              fontSize: 9.5,
            ),
          ),
          const SizedBox(height: Tok.space12),

          // Big number gauge
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
                Icon(
                  isYounger
                      ? Icons.arrow_downward
                      : isOlder
                          ? Icons.arrow_upward
                          : Icons.check,
                  size: 14,
                  color: tierColor,
                ),
                const SizedBox(width: Tok.space4),
                Text(
                  isYounger
                      ? '${diffAbs.toStringAsFixed(1)} YEARS YOUNGER'
                      : isOlder
                          ? '+${diffAbs.toStringAsFixed(1)} YEARS OLDER'
                          : 'MATCHES CHRONOLOGICAL AGE',
                  style: TokType.caption.copyWith(
                    color: tierColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyAgeGauge(BodyAgeResult result) {
    final diff = result.ageDifferenceYears;
    final isYounger = diff < 0;
    final isOlder = diff > 0;
    final tierColor = isYounger
        ? Tok.recoveryOptimal
        : isOlder
            ? Tok.recoverySuppressed
            : Tok.recoveryModerate;

    final fillRatio = ((result.chronologicalAge - result.bodyAge + 10) / 20)
        .clamp(0.05, 1.0);

    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(170, 170),
            painter: _BodyAgeGaugePainter(
              fillRatio: fillRatio,
              accentColor: tierColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.bodyAge.toStringAsFixed(1),
                style: TokType.displayNumber.copyWith(
                  fontSize: 52,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ACTUAL: ${result.chronologicalAge}',
                style: TokType.caption.copyWith(
                  color: Tok.textMuted,
                  letterSpacing: 1.0,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Component Breakdown ──

  // ── Component Breakdown (5-Second Glanceable) ──

  static const Color _youngerColor = Color(0xFF30D158);
  static const Color _olderColor = Color(0xFFFF9F0A);
  static const Color _onTrackColor = Color(0xFFAEAEB2);

  Widget _buildComponentBreakdown(BodyAgeResult result) {
    final youngerCount =
        result.components.where((c) => c.offsetYears < -0.2).length;
    final olderCount =
        result.components.where((c) => c.offsetYears > 0.2).length;
    final onTrackCount = result.components.length - youngerCount - olderCount;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BIOMETRIC BREAKDOWN', style: TokType.sectionLabel),
              Text(
                '${result.confidence.label} CONFIDENCE',
                style: TokType.caption.copyWith(
                  color: Tok.textMuted,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space8),

          // 5-Second Glance Scoreboard
          Wrap(
            spacing: Tok.space6,
            runSpacing: Tok.space6,
            children: [
              if (youngerCount > 0)
                _buildGlanceScoreBadge(
                  '$youngerCount Helping',
                  _youngerColor,
                  Icons.trending_down_rounded,
                ),
              if (olderCount > 0)
                _buildGlanceScoreBadge(
                  '$olderCount Aging',
                  _olderColor,
                  Icons.trending_up_rounded,
                ),
              if (onTrackCount > 0)
                _buildGlanceScoreBadge(
                  '$onTrackCount On Track',
                  _onTrackColor,
                  Icons.check_circle_outline_rounded,
                ),
            ],
          ),
          const SizedBox(height: Tok.space16),

          ...result.components.map((c) => _buildGlanceableComponentTile(c)),
        ],
      ),
    );
  }

  Widget _buildGlanceScoreBadge(String label, Color color, IconData icon) {
    return LiquidGlass(
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space12,
        vertical: Tok.space6,
      ),
      customBottomReflection: color.withValues(alpha: 0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: Tok.space4),
          Text(
            label,
            style: TokType.caption.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlanceableComponentTile(BodyAgeComponent component) {
    final meta = _getCategoryMeta(component);
    final offset = component.offsetYears;

    final isHelping = offset < -0.2;
    final isAging = offset > 0.2;
    final isOnTrack = !isHelping && !isAging;

    final statusColor = isHelping
        ? _youngerColor
        : isAging
            ? _olderColor
            : _onTrackColor;

    final statusText = isHelping
        ? '-${offset.abs().toStringAsFixed(1)} yrs'
        : isAging
            ? '+${offset.toStringAsFixed(1)} yrs'
            : 'On Track';

    final statusIcon = isHelping
        ? Icons.arrow_downward_rounded
        : isAging
            ? Icons.arrow_upward_rounded
            : Icons.check_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: Tok.space12),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        padding: const EdgeInsets.all(Tok.space12),
        customBottomReflection: statusColor.withValues(alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Title on left, Status Pill on right
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(meta.icon, size: 15, color: statusColor),
                ),
                const SizedBox(width: Tok.space8),
                Expanded(
                  child: Text(
                    meta.title,
                    style: TokType.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status Pill
                LiquidGlass(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tok.space8,
                    vertical: Tok.space4,
                  ),
                  customBottomReflection: statusColor.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 3),
                      Text(
                        statusText,
                        style: TokType.caption.copyWith(
                          color: statusColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          const SizedBox(height: Tok.space8),

          // Row 2: 3-Zone Segmented Visual Bar [ YOUNGER | ON TRACK | AGING ]
          _build3ZoneSegmentedBar(isHelping, isOnTrack, isAging),

          const SizedBox(height: Tok.space8),

          // Row 3: 1-Line Plain English Takeaway
          Text(
            meta.takeaway,
            style: TokType.bodySmall.copyWith(
              color: Tok.textPrimary.withValues(alpha: 0.9),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),

          // Row 4: Clean telemetry source tags
          if (component.inputsUsed.isNotEmpty) ...[
            const SizedBox(height: Tok.space4),
            Text(
              component.inputsUsed.join(' • '),
              style: TokType.caption.copyWith(
                color: Tok.textMuted,
                fontSize: 9.5,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _build3ZoneSegmentedBar(
      bool isHelping, bool isOnTrack, bool isAging) {
    return Row(
      children: [
        // Zone 1: YOUNGER
        Expanded(
          child: _buildZoneSegment(
            label: 'YOUNGER',
            isActive: isHelping,
            activeColor: _youngerColor,
            isLeft: true,
          ),
        ),
        const SizedBox(width: 3),
        // Zone 2: ON TRACK
        Expanded(
          child: _buildZoneSegment(
            label: 'ON TRACK',
            isActive: isOnTrack,
            activeColor: Tok.neonAccent,
          ),
        ),
        const SizedBox(width: 3),
        // Zone 3: AGING
        Expanded(
          child: _buildZoneSegment(
            label: 'AGING',
            isActive: isAging,
            activeColor: _olderColor,
            isRight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneSegment({
    required String label,
    required bool isActive,
    required Color activeColor,
    bool isLeft = false,
    bool isRight = false,
  }) {
    return LiquidGlass(
      height: 22,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.horizontal(
        left: isLeft ? const Radius.circular(Tok.radiusSm) : Radius.zero,
        right: isRight ? const Radius.circular(Tok.radiusSm) : Radius.zero,
      ),
      customBottomReflection:
          isActive ? activeColor.withValues(alpha: 0.25) : null,
      child: Center(
        child: Text(
          label,
          style: TokType.caption.copyWith(
            color: isActive ? activeColor : Tok.textMuted.withValues(alpha: 0.6),
            fontSize: 8.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  _CategoryGlanceMeta _getCategoryMeta(BodyAgeComponent c) {
    final cat = c.category.toLowerCase();
    final offset = c.offsetYears;

    if (cat.contains('cardio')) {
      final takeaway = offset < -0.2
          ? 'Strong aerobic capacity subtracts ${offset.abs().toStringAsFixed(1)} yrs'
          : offset > 0.2
              ? 'Cardiorespiratory capacity is currently adding ${offset.toStringAsFixed(1)} yrs'
              : 'Aerobic fitness & resting heart rate match your cohort';
      return const _CategoryGlanceMeta(
        title: 'Heart & Cardio',
        icon: Icons.favorite_rounded,
      ).copyWith(takeaway: takeaway);
    } else if (cat.contains('autonomic') || cat.contains('recovery')) {
      final takeaway = offset < -0.2
          ? 'High HRV variability takes off ${offset.abs().toStringAsFixed(1)} yrs'
          : offset > 0.2
              ? 'Nervous system strain is currently adding ${offset.toStringAsFixed(1)} yrs'
              : 'Autonomic nervous recovery aligns with your age';
      return const _CategoryGlanceMeta(
        title: 'Recovery & HRV',
        icon: Icons.bolt_rounded,
      ).copyWith(takeaway: takeaway);
    } else if (cat.contains('sleep')) {
      final takeaway = offset < -0.2
          ? 'Consistent restorative sleep takes off ${offset.abs().toStringAsFixed(1)} yrs'
          : offset > 0.2
              ? 'Short sleep duration is currently adding ${offset.toStringAsFixed(1)} yrs'
              : 'Sleep duration meets recommended nightly target';
      return const _CategoryGlanceMeta(
        title: 'Sleep Rest',
        icon: Icons.bedtime_rounded,
      ).copyWith(takeaway: takeaway);
    } else if (cat.contains('body') || cat.contains('comp')) {
      final takeaway = offset < -0.2
          ? 'Healthy body composition subtracts ${offset.abs().toStringAsFixed(1)} yrs'
          : offset > 0.2
              ? 'Body composition metrics are currently adding ${offset.toStringAsFixed(1)} yrs'
              : 'BMI and weight ratio are in a healthy zone';
      return const _CategoryGlanceMeta(
        title: 'Body & Weight',
        icon: Icons.fitness_center_rounded,
      ).copyWith(takeaway: takeaway);
    } else {
      final takeaway = offset < -0.2
          ? 'High daily activity volume knocks off ${offset.abs().toStringAsFixed(1)} yrs'
          : offset > 0.2
              ? 'Lower activity volume is currently adding ${offset.toStringAsFixed(1)} yrs'
              : 'Daily step volume matches recommended activity targets';
      return const _CategoryGlanceMeta(
        title: 'Daily Activity',
        icon: Icons.directions_walk_rounded,
      ).copyWith(takeaway: takeaway);
    }
  }

  // ── Derived Metrics ──

  Widget _buildDerivedMetrics(BodyAgeResult result) {
    final metrics = result.derivedMetrics;
    final items = <Widget>[];

    if (metrics.bmi != null) {
      items.add(_buildMetricTile('BMI', metrics.bmi!.toStringAsFixed(1), 'kg/m²'));
    }
    if (metrics.vo2maxUsed != null) {
      items.add(_buildMetricTile(
          'VO₂MAX', metrics.vo2maxUsed!.toStringAsFixed(1), 'mL/kg/min'));
    }
    if (metrics.bmrKcal != null) {
      items.add(_buildMetricTile(
          'BMR', metrics.bmrKcal!.toStringAsFixed(0), 'kcal/day'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DERIVED METRICS', style: TokType.sectionLabel),
          const SizedBox(height: Tok.space12),
          Row(children: items),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String unit) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: LiquidGlass(
          padding: const EdgeInsets.symmetric(
            horizontal: Tok.space12,
            vertical: Tok.space12,
          ),
          borderRadius: BorderRadius.circular(100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(label, style: TokType.sectionLabel.copyWith(fontSize: 9.5)),
              const SizedBox(height: Tok.space4),
              Text(
                value,
                style: TokType.metricMedium.copyWith(fontSize: 16),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TokType.caption.copyWith(color: Tok.textMuted, fontSize: 8.5),
                ),
            ],
          ),
        ),
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
              const Icon(Icons.trending_down,
                  size: 16, color: Tok.textSecondary),
              const SizedBox(width: Tok.space8),
              Text(
                'TOP ACTIONS TO LOWER BODY AGE',
                style: TokType.sectionLabel,
              ),
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
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tok.glassFillElevated,
                      border: Border.all(color: Tok.glassBorder, width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TokType.caption.copyWith(
                          color: Tok.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lever.expectedEffect,
                          style: TokType.caption.copyWith(
                            color: Tok.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 10, color: Tok.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              lever.timeframe,
                              style: TokType.caption.copyWith(
                                color: Tok.textMuted,
                                fontSize: 9,
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


  // ── Data Quality & Flags ──

  Widget _buildDataQuality(BodyAgeResult result) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HEALTH ALERTS & DATA NOTES', style: TokType.sectionLabel),
          const SizedBox(height: Tok.space8),
          ...result.dataQualityFlags.map((flag) => Padding(
                padding: const EdgeInsets.only(bottom: Tok.space4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 13, color: Tok.textMuted),
                    const SizedBox(width: Tok.space8),
                    Expanded(
                      child: Text(
                        flag,
                        style: TokType.caption.copyWith(
                          color: Tok.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
          const Icon(Icons.shield_outlined, size: 13, color: Tok.textMuted),
          const SizedBox(width: Tok.space8),
          Expanded(
            child: Text(
              result.disclaimer,
              style: TokType.caption.copyWith(
                color: Tok.textMuted,
                height: 1.4,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading & Error states ──

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Tok.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: Tok.space20),
            Text(
              'Computing Body Age...',
              style: TokType.cardTitle.copyWith(
                letterSpacing: 1.4,
                color: Tok.textSecondary,
              ),
            ),
            const SizedBox(height: Tok.space4),
            Text(
              'Analyzing wearable baselines against population cohorts',
              style: TokType.caption.copyWith(color: Tok.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderage() {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space24),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 40, color: Tok.textSecondary),
          const SizedBox(height: Tok.space16),
          Text(
            'Adult Norms Only',
            style: TokType.heading.copyWith(fontSize: 18),
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Body age models are standardized for adults aged 18 and older. '
            'We recommend general healthy habit tracking.',
            textAlign: TextAlign.center,
            style: TokType.bodySmall.copyWith(
              color: Tok.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return GlassCard(
      accentGlow: Tok.recoverySuppressed.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(Tok.space20),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 20, color: Tok.recoverySuppressed),
          const SizedBox(width: Tok.space12),
          Expanded(
            child: Text(
              message,
              style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
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

class _CategoryGlanceMeta {
  final String title;
  final IconData icon;
  final String takeaway;

  const _CategoryGlanceMeta({
    required this.title,
    required this.icon,
    this.takeaway = '',
  });

  _CategoryGlanceMeta copyWith({String? takeaway}) {
    return _CategoryGlanceMeta(
      title: title,
      icon: icon,
      takeaway: takeaway ?? this.takeaway,
    );
  }
}
