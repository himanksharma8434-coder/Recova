import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../features/body_age/data/repositories/body_age_repository_impl.dart';
import '../../features/body_age/domain/entities/body_age_factor.dart';
import '../../features/body_age/domain/entities/body_age_result.dart';
import '../../features/body_age/domain/repositories/body_age_repository.dart';
import '../../features/body_age/presentation/components/monthly_checkin_dialog.dart';
import '../../features/body_age/presentation/screens/body_age_fitness_screen.dart';
import '../../services/background_sync_service.dart';
import '../../services/user_profile_service.dart';
import '../components/edit_body_fat_dialog.dart';
import '../components/liquid_glass.dart';
import '../components/motion.dart';
import '../components/radial_score_gauge.dart';
import '../components/vital_metric_tile.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import '../cubits/health_sync/health_sync_state.dart';
import 'recovery_calculation_screen.dart';
import 'resting_hr_detail_screen.dart';
import 'blood_o2_detail_screen.dart';
import 'hrv_detail_screen.dart';
import 'profile_settings_screen.dart';

/// Minimalist Home (Pulse) screen focused purely on Recovery, Key Vitals,
/// Body Age, and Daily Autonomic Balance with 30-minute background auto-sync telemetry.
class PulseScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback onSyncTap;
  final DateTime? lastSyncedAt;
  final ValueChanged<int>? onNavigateTab;

  const PulseScreen({
    super.key,
    required this.summary,
    required this.onSyncTap,
    this.lastSyncedAt,
    this.onNavigateTab,
  });

  @override
  State<PulseScreen> createState() => _PulseScreenState();
}

class _PulseScreenState extends State<PulseScreen> {
  late final BodyAgeRepository _bodyAgeRepo;
  FitnessBodyAgeResult? _bodyAgeResult;
  UserProfile? _userProfile;
  bool _loadingBodyAge = false;

  @override
  void initState() {
    super.initState();
    _bodyAgeRepo = BodyAgeRepositoryImpl();
    _loadBodyAgeData();
  }

  @override
  void didUpdateWidget(PulseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary?.estimatedVo2Max != widget.summary?.estimatedVo2Max ||
        oldWidget.summary?.restingHr != widget.summary?.restingHr) {
      _loadBodyAgeData();
    }
  }

  Future<void> _loadBodyAgeData() async {
    setState(() => _loadingBodyAge = true);
    try {
      final result = await _bodyAgeRepo.calculateCurrentBodyAge().timeout(
            const Duration(seconds: 2),
            onTimeout: () => null,
          );
      final profile = await UserProfileService.getProfile().timeout(
            const Duration(seconds: 2),
            onTimeout: () => const UserProfile(),
          );
      if (mounted) {
        setState(() {
          _bodyAgeResult = result;
          _userProfile = profile;
          _loadingBodyAge = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBodyAge = false);
    }
  }

  void _openCheckinModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyCheckinDialog(
        prefilledWeight: _userProfile?.weightKg,
        prefilledBodyFat: _userProfile?.bodyFatPct,
        initialIsKg: true,
      ),
    );
    _loadBodyAgeData();
  }

  void _openEditBodyFat() async {
    final profile = await UserProfileService.getProfile();
    if (!mounted) return;
    await EditBodyFatDialog.show(
      context,
      initialBodyFat: profile.bodyFatPct,
      gender: profile.gender,
      onSaved: _loadBodyAgeData,
    );
    _loadBodyAgeData();
  }

  void _openFullBodyAgeScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BodyAgeFitnessScreen(
          bodyAgeRepository: _bodyAgeRepo,
        ),
      ),
    ).then((_) => _loadBodyAgeData());
  }

  void _openHrvDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HrvDetailScreen(summary: widget.summary),
      ),
    );
  }

  void _openRecoveryCalculation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecoveryCalculationScreen(summary: widget.summary),
      ),
    );
  }

  void _openRestingHrDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestingHrDetailScreen(summary: widget.summary),
      ),
    );
  }

  void _openBloodO2Detail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BloodO2DetailScreen(summary: widget.summary),
      ),
    );
  }

  void _openProfileSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );
  }

  IconData _iconForFactor(BodyAgeFactor factor) {
    switch (factor) {
      case BodyAgeFactor.vo2Max:
        return Icons.speed;
      case BodyAgeFactor.restingHeartRate:
        return Icons.favorite;
      case BodyAgeFactor.vigorousActivity:
        return Icons.directions_run;
      case BodyAgeFactor.bodyComposition:
        return Icons.monitor_weight_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    // Dynamic RHR delta vs baseline
    String rhrDeltaText = 'Awaiting sync';
    Color rhrDeltaColor = Tok.textSecondary;
    final restingHr = summary?.restingHr;
    final baseRhr = summary?.baselineRestingHr;
    if (restingHr != null && baseRhr != null) {
      final diff = (restingHr - baseRhr).round();
      if (diff < 0) {
        rhrDeltaText = '$diff bpm basal';
        rhrDeltaColor = Tok.textSecondary;
      } else if (diff > 0) {
        rhrDeltaText = '+$diff bpm basal';
        rhrDeltaColor = Tok.recoverySuppressed;
      } else {
        rhrDeltaText = 'On baseline';
        rhrDeltaColor = Tok.textSecondary;
      }
    } else if (summary?.restingHr != null) {
      rhrDeltaText = 'Current basal';
      rhrDeltaColor = Tok.textSecondary;
    }

    // Dynamic SpO2 delta / state
    String spo2DeltaText = 'Awaiting sync';
    Color spo2DeltaColor = Tok.textSecondary;
    if (summary?.spo2 != null) {
      if (summary!.spo2! >= 95) {
        spo2DeltaText = 'Optimal range';
        spo2DeltaColor = Tok.textSecondary;
      } else {
        spo2DeltaText = 'Elevated desat';
        spo2DeltaColor = Tok.recoverySuppressed;
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(
        left: Tok.space16,
        right: Tok.space16,
        top: Tok.space12,
        bottom: 110,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today, ${_currentDateFormatted()}',
                      style: TokType.heading.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    BlocBuilder<HealthSyncCubit, HealthSyncState>(
                      builder: (context, syncState) {
                        final isSyncing = syncState is HealthSyncing;
                        final syncRelative = formatRelativeSyncTime(widget.lastSyncedAt);
                        final label = isSyncing
                            ? 'SYNCING...'
                            : (summary != null
                                ? 'AUTO 30M • $syncRelative'
                                : 'AUTO 30M • SYNC');
                        final indicatorColor = isSyncing
                            ? Tok.accentBlue
                            : (summary != null ? Tok.neonAccent : Tok.accentAmber);

                        return GestureDetector(
                          onTap: isSyncing ? null : widget.onSyncTap,
                          child: LiquidGlassPill(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Tok.space12,
                              vertical: Tok.space4,
                            ),
                            indicatorColor: indicatorColor,
                            label: label,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Tok.space8),
              // Actions: Settings & Sync
              Row(
                children: [
                  LiquidGlass(
                    borderRadius: BorderRadius.circular(Tok.radiusSm),
                    padding: const EdgeInsets.all(Tok.space10),
                    onTap: () => _openProfileSettings(),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Tok.textSecondary,
                    ),
                  ),
                  const SizedBox(width: Tok.space8),
                  BlocBuilder<HealthSyncCubit, HealthSyncState>(
                    buildWhen: (prev, current) =>
                        (prev is HealthSyncing) != (current is HealthSyncing),
                    builder: (context, state) {
                      return LiquidGlass(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        padding: const EdgeInsets.all(Tok.space10),
                        onTap: state is HealthSyncing ? null : widget.onSyncTap,
                        child: state is HealthSyncing
                            ? const GlassLoadingSpinner(
                                size: 18,
                                color: Tok.neonAccent,
                              )
                            : const Icon(
                                Icons.sensors_outlined,
                                size: 20,
                                color: Tok.neonAccent,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Tok.space20),

          // ── Recovery Gauge ──
          RadialScoreGauge(
            score: summary?.recoveryScore,
            baselineScore: summary?.baselineRecoveryScore,
            size: 220,
            onTap: () => _openRecoveryCalculation(),
          ),
          const SizedBox(height: Tok.space20),

          // ── Key Biometrics Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tok.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KEY BIOMETRICS',
                  style: TokType.sectionLabel.copyWith(
                    letterSpacing: 1.4,
                    fontSize: 10,
                    color: Tok.textTertiary,
                  ),
                ),
                Text(
                  'BASAL BASELINE',
                  style: TokType.caption.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                    color: Tok.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tok.space10),

          // ── Quick Vital Metrics ──
          Row(
            children: [
              Expanded(
                child: VitalMetricTile(
                  label: 'HRV (rMSSD)',
                  value: summary?.hrvMs != null
                      ? '${summary!.hrvMs!.toInt()}'
                      : '--',
                  unit: 'ms',
                  deltaText: summary?.hrvMs != null
                      ? 'Within range'
                      : 'Awaiting log',
                  deltaColor: summary?.hrvMs != null
                      ? Tok.recoveryOptimal
                      : Tok.textSecondary,
                  icon: Icons.monitor_heart_outlined,
                  iconColor: Tok.neonAccent,
                  onTap: () => _openHrvDetail(),
                ),
              ),
              const SizedBox(width: Tok.space8),
              Expanded(
                child: VitalMetricTile(
                  label: 'RESTING HR',
                  value: summary?.restingHr != null
                      ? '${summary!.restingHr!.toInt()}'
                      : '--',
                  unit: 'bpm',
                  deltaText: rhrDeltaText,
                  deltaColor: rhrDeltaColor,
                  icon: Icons.favorite_border,
                  iconColor: Tok.accentAmber,
                  onTap: () => _openRestingHrDetail(),
                ),
              ),
              const SizedBox(width: Tok.space8),
              Expanded(
                child: VitalMetricTile(
                  label: 'BLOOD O2',
                  value: summary?.spo2 != null
                      ? summary!.spo2!.toStringAsFixed(0)
                      : '--',
                  unit: '%',
                  deltaText: spo2DeltaText,
                  deltaColor: spo2DeltaColor,
                  icon: Icons.air,
                  iconColor: Tok.accentBlue,
                  onTap: () => _openBloodO2Detail(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space20),

          // ── Body Age Section ──
          _buildBodyAgeSection(),
          const SizedBox(height: Tok.space20),

          // ── Subtle Guidance & Auto-Sync Footer ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tok.space16),
              child: Text(
                'Auto-fetch active every 30m • Tap biometrics for details',
                style: TokType.caption.copyWith(
                  color: Tok.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY AGE SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBodyAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.accessibility_new_rounded,
                  size: 14,
                  color: Tok.neonAccent,
                ),
                SizedBox(width: 6),
                Text(
                  'BODY AGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Tok.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _openFullBodyAgeScreen,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'DETAILS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Tok.neonAccent,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Tok.neonAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_loadingBodyAge)
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RecovaColors.surfaceElevation1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RecovaColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Tok.neonAccent.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'CALCULATING BODY AGE...',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Tok.textTertiary,
                  ),
                ),
              ],
            ),
          )
        else if (_bodyAgeResult != null)
          _buildBodyAgeResultCard(_bodyAgeResult!)
        else
          _buildBodyAgeEmptyCard(),
      ],
    );
  }

  Widget _buildBodyAgeResultCard(FitnessBodyAgeResult result) {
    final diff = result.difference;
    final isYounger = diff < 0;
    final isSame = diff == 0;

    final badgeBg = isYounger
        ? Colors.green.withValues(alpha: 0.15)
        : isSame
            ? Tok.glassFillRecessed
            : Colors.orange.withValues(alpha: 0.15);
    final badgeBorder = isYounger
        ? Colors.green
        : isSame
            ? Tok.glassBorder
            : Colors.orange;
    final badgeTextColor = isYounger
        ? Colors.greenAccent
        : isSame
            ? Tok.textSecondary
            : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isYounger
              ? Tok.neonAccent.withValues(alpha: 0.3)
              : RecovaColors.borderSubtle,
        ),
        boxShadow: [
          if (isYounger)
            BoxShadow(
              color: Tok.neonAccent.withValues(alpha: 0.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESTIMATED FUNCTIONAL AGE',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        result.bodyAge.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0,
                          color: RecovaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'YEARS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Tok.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (result.achievableBodyAge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: RecovaColors.surfaceElevation2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RecovaColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ACHIEVABLE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Tok.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.achievableBodyAge!.toStringAsFixed(1)} yrs',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Tok.neonAccent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Difference Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeBorder),
            ),
            child: Text(
              isSame
                  ? 'Matches your chronological age (${result.chronologicalAge} yrs)'
                  : isYounger
                      ? '▼ ${diff.abs().toStringAsFixed(1)} years younger than actual age (${result.chronologicalAge})'
                      : '▲ ${diff.abs().toStringAsFixed(1)} years older than actual age (${result.chronologicalAge})',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Physiological Factor Chips
          Row(
            children: BodyAgeFactor.values.map((factor) {
              final age = result.factorAges[factor];
              final factorLabel = factor.displayName.split(' ').first;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: RecovaColors.surfaceElevation2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: RecovaColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _iconForFactor(factor),
                        size: 13,
                        color: age != null ? Tok.neonAccent : Tok.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        factorLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: RecovaColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        age != null ? '${age.toStringAsFixed(1)}y' : '--',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: age != null
                              ? RecovaColors.textPrimary
                              : RecovaColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action row: Edit Body Fat / Monthly Check-In
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _openEditBodyFat,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.tune_rounded, size: 12, color: Tok.neonAccent),
                    SizedBox(width: 4),
                    Text(
                      'EDIT BODY FAT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Tok.neonAccent,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openCheckinModal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_calendar_outlined,
                        size: 12, color: Tok.neonAccent),
                    SizedBox(width: 4),
                    Text(
                      'MONTHLY CHECK-IN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Tok.neonAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyAgeEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RecovaColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insights, size: 20, color: Tok.neonAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CALCULATE YOUR BODY AGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: RecovaColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Body Age estimates your biological fitness from VO2 Max, Resting HR, activity, and body composition.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: RecovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _openCheckinModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Tok.neonAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'SET PROFILE & MEASUREMENTS',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _currentDateFormatted() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }
}
