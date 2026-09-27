import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/daily_activity_pod.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';
import '../components/motion.dart';
import '../components/radial_score_gauge.dart';
import '../components/sleep_performance_card.dart';
import '../components/vital_metric_tile.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import '../cubits/health_sync/health_sync_state.dart';
import 'recovery_calculation_screen.dart';
import 'resting_hr_detail_screen.dart';
import 'blood_o2_detail_screen.dart';
import 'sleep_architecture_detail_screen.dart';
import 'hrv_detail_screen.dart';

class PulseScreen extends StatelessWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback onSyncTap;

  const PulseScreen({
    super.key,
    required this.summary,
    required this.onSyncTap,
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

  void _openSleepArchitectureDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SleepArchitectureDetailScreen(summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic RHR delta vs baseline
    String rhrDeltaText = 'Awaiting sync';
    Color rhrDeltaColor = Tok.textMuted;
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
    Color spo2DeltaColor = Tok.textMuted;
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: Tok.space16,
        right: Tok.space16,
        top: Tok.space12,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today, ${_currentDateFormatted()}',
                    style: TokType.heading,
                  ),
                  const SizedBox(height: 6),
                  LiquidGlassPill(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tok.space12,
                      vertical: Tok.space4,
                    ),
                    indicatorColor: summary != null ? Tok.neonAccent : Tok.textMuted,
                    label: summary != null ? 'WEARABLE SYNCED' : 'AWAITING SYNC',
                  ),
                ],
              ),
              // Sync Button
              BlocBuilder<HealthSyncCubit, HealthSyncState>(
                buildWhen: (prev, current) =>
                    (prev is HealthSyncing) != (current is HealthSyncing),
                builder: (context, state) {
                  return LiquidGlass(
                    borderRadius: BorderRadius.circular(Tok.radiusSm),
                    padding: const EdgeInsets.all(Tok.space12),
                    onTap: state is HealthSyncing ? null : onSyncTap,
                    child: state is HealthSyncing
                        ? GlassLoadingSpinner(
                            size: 16,
                            color: Tok.neonAccent,
                          )
                        : Icon(
                            Icons.sensors_outlined,
                            size: 18,
                            color: Tok.neonAccent,
                          ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: Tok.space20),

          // ── Recovery Gauge ──
          RadialScoreGauge(
            score: summary?.recoveryScore,
            size: 210,
            onTap: () => _openRecoveryCalculation(context),
          ),
          const SizedBox(height: Tok.space24),

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
                      ? Tok.textSecondary
                      : Tok.textMuted,
                  icon: Icons.monitor_heart_outlined,
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
                  onTap: () => _openBloodO2Detail(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space16),

          // ── Sleep Architecture ──
          SleepPerformanceCard(
            sleepHours: summary?.sleepHours,
            baselineSleepHours: summary?.baselineSleepHours,
            sleepStages: summary?.sleepStages,
            sleepSessions: summary?.sleepSessions ?? const [],
            onTap: () => _openSleepArchitectureDetail(context),
          ),
          const SizedBox(height: Tok.space16),

          // ── Daily Activity ──
          DailyActivityPod(
            todaySteps: summary?.todaySteps,
            activeCalories: summary?.activeCalories,
            totalCalories: summary?.totalCalories,
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
