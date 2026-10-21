import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../services/background_sync_service.dart';
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
/// and Daily Autonomic Balance with 30-minute background auto-sync telemetry.
class PulseScreen extends StatelessWidget {
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

  void _openHrvDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HrvDetailScreen(summary: summary),
      ),
    );
  }

  void _openRecoveryCalculation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecoveryCalculationScreen(summary: summary),
      ),
    );
  }

  void _openRestingHrDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestingHrDetailScreen(summary: summary),
      ),
    );
  }

  void _openBloodO2Detail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BloodO2DetailScreen(summary: summary),
      ),
    );
  }

  void _openProfileSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic RHR delta vs baseline
    String rhrDeltaText = 'Awaiting sync';
    Color rhrDeltaColor = Tok.textSecondary;
    if (summary?.restingHr != null && summary?.baselineRestingHr != null) {
      final diff = (summary!.restingHr! - summary!.baselineRestingHr!).round();
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
                        final syncRelative = formatRelativeSyncTime(lastSyncedAt);
                        final label = isSyncing
                            ? 'SYNCING...'
                            : (summary != null
                                ? 'AUTO 30M • $syncRelative'
                                : 'AUTO 30M • SYNC');
                        final indicatorColor = isSyncing
                            ? Tok.accentBlue
                            : (summary != null ? Tok.neonAccent : Tok.accentAmber);

                        return GestureDetector(
                          onTap: isSyncing ? null : onSyncTap,
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
                    onTap: () => _openProfileSettings(context),
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
                        onTap: state is HealthSyncing ? null : onSyncTap,
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
            onTap: () => _openRecoveryCalculation(context),
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
                  onTap: () => _openHrvDetail(context),
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
                  onTap: () => _openRestingHrDetail(context),
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
                  onTap: () => _openBloodO2Detail(context),
                ),
              ),
            ],
          ),
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

  String _currentDateFormatted() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }
}

