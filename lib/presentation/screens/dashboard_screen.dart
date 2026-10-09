import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import '../cubits/health_sync/health_sync_state.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../core/theme/design_tokens.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';
import 'vo2_max_detail_screen.dart';

/// Main recovery dashboard screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Tok.canvasDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'RECOVERY',
          style: TokType.heading.copyWith(letterSpacing: 2.0),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<HealthSyncCubit, HealthSyncState>(
            builder: (context, state) {
              return IconButton(
                icon: state is HealthSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Tok.neonAccent,
                        ),
                      )
                    : const Icon(Icons.sync, color: Tok.textPrimary),
                onPressed: state is HealthSyncing
                    ? null
                    : () async {
                        await context.read<HealthSyncCubit>().syncNow();
                        if (context.mounted) {
                          context.read<DashboardCubit>().refresh();
                        }
                      },
                tooltip: 'Sync',
              );
            },
          ),
        ],
      ),
      body: AmbientGlowBackdrop(
        primaryGlow: Tok.recoveryOptimal,
        secondaryGlow: Tok.accentBlue,
        child: BlocConsumer<HealthSyncCubit, HealthSyncState>(
          listener: (context, syncState) {
            if (syncState is HealthSyncSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Synced ${syncState.recordCount} records'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (syncState is HealthSyncFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sync failed: ${syncState.message}'),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, syncState) {
            return BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Tok.neonAccent),
                  );
                }
                if (state is DashboardError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TokType.body.copyWith(color: Tok.recoverySuppressed),
                    ),
                  );
                }
                if (state is DashboardEmpty) {
                  return _buildEmptyState(context);
                }
                if (state is DashboardLoaded) {
                  return _buildDashboard(context, state.summary);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No health data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the sync button to pull data from Health Connect',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          LiquidGlassButton(
            onTap: () async {
              await context.read<HealthSyncCubit>().syncNow();
              if (context.mounted) {
                context.read<DashboardCubit>().refresh();
              }
            },
            icon: const Icon(Icons.sync, color: Tok.neonAccent, size: 20),
            label: 'Sync Wearable Biometrics',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DerivedMetricSummary summary) {
    final score = summary.recoveryScore ?? 50;
    final isOptimal = score >= 67;
    final isModerate = score >= 34 && score < 67;
    final statusColor = isOptimal
        ? Tok.recoveryOptimal
        : isModerate
            ? Tok.recoveryModerate
            : Tok.recoverySuppressed;
    final statusLabel = isOptimal
        ? 'OPTIMAL RECOVERY'
        : isModerate
            ? 'MODERATE RECOVERY'
            : 'SUPPRESSED RECOVERY';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Liquid Glass Status Pill ──
          Center(
            child: LiquidGlassPill(
              label: statusLabel,
              indicatorColor: statusColor,
              trailing: Text(
                '${score.toInt()}%',
                style: TokType.badge.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recovery Score Card
          _RecoveryScoreCard(summary: summary),
          const SizedBox(height: 16),

          // Component Breakdown
          _ComponentBreakdownCard(summary: summary),
          const SizedBox(height: 16),

          // VO2max Card
          if (summary.estimatedVo2Max != null)
            _Vo2MaxCard(summary: summary),
          if (summary.estimatedVo2Max != null) const SizedBox(height: 16),

          // Vital Stats Row
          _VitalStatsRow(summary: summary),
          const SizedBox(height: 16),

          // Sync info
          if (summary.lastSyncedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${summary.totalRecords} records synced · Last sync: ${_formatTime(summary.lastSyncedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Recovery Score Card ──

class _RecoveryScoreCard extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _RecoveryScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final score = summary.recoveryScore ?? 50;
    final color = _scoreColor(score);

    return GlassCard(
      accentGlow: color,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'RECOVERY SCORE',
            style: TokType.cardTitle.copyWith(
              letterSpacing: 1.5,
              color: Tok.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Radial gauge using PieChart
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 65,
                    sections: [
                      PieChartSectionData(
                        value: score,
                        color: color,
                        radius: 18,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - score,
                        color: color.withValues(alpha: 0.15),
                        radius: 18,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TokType.metricLarge.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      _scoreLabel(score),
                      style: TokType.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary factor
          if (summary.primaryFactor != null) ...[
            const SizedBox(height: 14),
            LiquidGlassPill(
              label: summary.primaryFactor!.toUpperCase(),
              indicatorColor: color,
            ),
          ],
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 67) return Tok.recoveryOptimal;
    if (score >= 34) return Tok.recoveryModerate;
    return Tok.recoverySuppressed;
  }

  String _scoreLabel(double score) {
    if (score >= 67) return 'Optimal';
    if (score >= 34) return 'Moderate';
    return 'Suppressed';
  }
}

// ── Component Breakdown Card ──

class _ComponentBreakdownCard extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _ComponentBreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOVERY BREAKDOWN',
            style: TokType.cardTitle.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _ComponentBar(
            label: 'Resting HR',
            value: summary.recoveryComponentRhr ?? 50,
            icon: Icons.favorite,
            weight: '50%',
          ),
          const SizedBox(height: 12),
          _ComponentBar(
            label: 'Sleep',
            value: summary.recoveryComponentSleep ?? 50,
            icon: Icons.bedtime,
            weight: '35%',
          ),
          const SizedBox(height: 12),
          _ComponentBar(
            label: 'Blood Oxygen',
            value: summary.recoveryComponentSpo2 ?? 50,
            icon: Icons.air,
            weight: '15%',
          ),
        ],
      ),
    );
  }
}

class _ComponentBar extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final String weight;
  const _ComponentBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 67
        ? Tok.recoveryOptimal
        : value >= 34
            ? Tok.recoveryModerate
            : Tok.recoverySuppressed;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TokType.body.copyWith(color: Tok.textPrimary),
              ),
            ),
            Text(
              '${value.toInt()}',
              style: TokType.body.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              weight,
              style: TokType.caption.copyWith(color: Tok.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (value / 100).clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.15),
          color: color,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

// ── VO2max Card ──

class _Vo2MaxCard extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _Vo2MaxCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final vo2max = summary.estimatedVo2Max!;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Vo2MaxDetailScreen(summary: summary),
          ),
        );
      },
      child: GlassCard(
        accentGlow: Tok.neonAccent,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Tok.neonAccentSurface,
                border: Border.all(
                  color: Tok.neonAccent.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.speed, color: Tok.neonAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'EST. VO₂ MAX',
                        style: TokType.caption.copyWith(letterSpacing: 1.2),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message:
                            'Estimated from resting and max heart rate.\nNot a clinical measurement.',
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Tok.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${vo2max.toStringAsFixed(1)} mL/kg/min',
                    style: TokType.metricMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Tok.neonAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vital Stats Row ──

class _VitalStatsRow extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _VitalStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.favorite,
            label: 'Resting HR',
            value: summary.restingHr != null
                ? '${summary.restingHr!.toInt()} bpm'
                : '—',
            accentColor: Tok.recoveryOptimal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.bedtime,
            label: 'Avg Sleep',
            value: summary.sleepHours != null
                ? '${summary.sleepHours!.toStringAsFixed(1)} hrs'
                : '—',
            accentColor: Tok.accentBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.air,
            label: 'SpO₂',
            value: summary.spo2 != null
                ? '${summary.spo2!.toStringAsFixed(0)}%'
                : '—',
            accentColor: Tok.accentBlue,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor = Tok.neonAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hasBlur: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TokType.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TokType.caption.copyWith(color: Tok.textSecondary),
          ),
        ],
      ),
    );
  }
}
